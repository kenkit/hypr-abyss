#!/usr/bin/env python3
# ==============================================================================
# Bluetooth Device Scanner & Status Provider for Quickshell Control Center
# Salida limpia estrictamente en formato JSON para evitar SyntaxError en QML
# ==============================================================================
import subprocess
import json
import sys

def get_bt_devices(do_scan=False):
    try:
        # 1. Comprobar si Bluetooth está encendido
        try:
            powered_out = subprocess.check_output(['bluetoothctl', 'show'], text=True, stderr=subprocess.DEVNULL)
            is_powered = 'Powered: yes' in powered_out
        except Exception:
            is_powered = False

        if not is_powered:
            return {'powered': False, 'devices': []}

        # 2. Si se solicita escaneo activo, ejecutar scan con stdout y stderr redirigidos
        if do_scan:
            try:
                subprocess.run(
                    ['bluetoothctl', '--timeout', '3', 'scan', 'on'],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=4
                )
            except Exception:
                pass

        # 3. Consultar dispositivos conectados en 1 sola llamada (sin lanzar subprocess por dispositivo)
        try:
            conn_out = subprocess.check_output(['bluetoothctl', 'devices', 'Connected'], text=True, stderr=subprocess.DEVNULL)
            conn_macs = {line.split()[1] for line in conn_out.strip().splitlines() if line.startswith('Device ')}
        except Exception:
            conn_macs = set()

        # 4. Consultar dispositivos emparejados en 1 sola llamada
        try:
            pair_out = subprocess.check_output(['bluetoothctl', 'devices', 'Paired'], text=True, stderr=subprocess.DEVNULL)
            pair_macs = {line.split()[1] for line in pair_out.strip().splitlines() if line.startswith('Device ')}
        except Exception:
            pair_macs = set()

        # 5. Obtener lista completa de dispositivos descubiertos
        try:
            dev_out = subprocess.check_output(['bluetoothctl', 'devices'], text=True, stderr=subprocess.DEVNULL)
        except Exception:
            dev_out = ""

        devices = []
        seen_macs = set()
        for line in dev_out.strip().splitlines():
            if line.startswith('Device '):
                parts = line.split(' ', 2)
                if len(parts) >= 3:
                    mac = parts[1].strip()
                    name = parts[2].strip()
                    if not mac or mac in seen_macs:
                        continue
                    seen_macs.add(mac)
                    if not name:
                        name = mac
                    is_conn = mac in conn_macs
                    is_pair = mac in pair_macs
                    is_raw_mac = (name.replace('-', ':').upper() == mac.upper())
                    devices.append({
                        'mac': mac,
                        'name': name,
                        'connected': is_conn,
                        'paired': is_pair,
                        'is_named': not is_raw_mac
                    })

        # 6. Si no hay dispositivos en caché y no se forzó scan, escanear rápidamente
        if not do_scan and len(devices) == 0:
            try:
                subprocess.run(
                    ['bluetoothctl', '--timeout', '2', 'scan', 'on'],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    timeout=3
                )
                dev_out = subprocess.check_output(['bluetoothctl', 'devices'], text=True, stderr=subprocess.DEVNULL)
                for line in dev_out.strip().splitlines():
                    if line.startswith('Device '):
                        parts = line.split(' ', 2)
                        if len(parts) >= 3:
                            mac = parts[1].strip()
                            name = parts[2].strip()
                            if not mac or mac in seen_macs:
                                continue
                            seen_macs.add(mac)
                            if not name:
                                name = mac
                            is_conn = mac in conn_macs
                            is_pair = mac in pair_macs
                            is_raw_mac = (name.replace('-', ':').upper() == mac.upper())
                            devices.append({
                                'mac': mac,
                                'name': name,
                                'connected': is_conn,
                                'paired': is_pair,
                                'is_named': not is_raw_mac
                            })
            except Exception:
                pass

        # 7. Ordenar: Conectados primero, Emparejados después, Con nombre legible antes que beacons
        devices.sort(key=lambda d: (
            not d['connected'],
            not d['paired'],
            not d['is_named'],
            d['name'].lower()
        ))

        return {'powered': True, 'devices': devices}
    except Exception:
        return {'powered': False, 'devices': []}

if __name__ == '__main__':
    scan_arg = len(sys.argv) > 1 and sys.argv[1] == 'scan'
    print(json.dumps(get_bt_devices(scan_arg)))
