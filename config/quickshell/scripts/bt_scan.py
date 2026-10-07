#!/usr/bin/env python3
import subprocess, json, sys

def get_bt_devices(do_scan=False):
    try:
        powered_out = subprocess.check_output(['bluetoothctl', 'show'], text=True, stderr=subprocess.DEVNULL)
        is_powered = 'Powered: yes' in powered_out
        
        if not is_powered:
            return {'powered': False, 'devices': []}

        if do_scan:
            try:
                subprocess.run(['bluetoothctl', '--timeout', '2', 'scan', 'on'], stderr=subprocess.DEVNULL, timeout=3)
            except Exception:
                pass

        dev_out = subprocess.check_output(['bluetoothctl', 'devices'], text=True, stderr=subprocess.DEVNULL)
        devices = []
        for line in dev_out.strip().split('\n'):
            if line.startswith('Device '):
                parts = line.split(' ', 2)
                if len(parts) >= 3:
                    mac = parts[1]
                    name = parts[2]
                    try:
                        info_out = subprocess.check_output(['bluetoothctl', 'info', mac], text=True, stderr=subprocess.DEVNULL)
                        connected = 'Connected: yes' in info_out
                    except Exception:
                        connected = False
                    devices.append({
                        'mac': mac,
                        'name': name,
                        'connected': connected
                    })
        return {'powered': True, 'devices': devices}
    except Exception:
        return {'powered': False, 'devices': []}

if __name__ == '__main__':
    scan_arg = len(sys.argv) > 1 and sys.argv[1] == 'scan'
    print(json.dumps(get_bt_devices(scan_arg)))
