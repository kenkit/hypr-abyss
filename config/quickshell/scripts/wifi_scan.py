#!/usr/bin/env python3
import subprocess, json

def get_wifi_list():
    try:
        out = subprocess.check_output(
            ['nmcli', '-t', '-f', 'in-use,ssid,bssid,signal,security', 'dev', 'wifi'], 
            text=True, timeout=5
        )
        networks = []
        seen = set()
        for line in out.strip().split('\n'):
            if not line:
                continue
            parts = line.replace(r'\:', '@@COLON@@').split(':')
            if len(parts) >= 5:
                in_use = parts[0].strip() == '*'
                ssid = parts[1].replace('@@COLON@@', ':').strip()
                signal = int(parts[3]) if parts[3].isdigit() else 0
                sec = parts[4].replace('@@COLON@@', ':').strip()
                if ssid and ssid not in seen:
                    seen.add(ssid)
                    networks.append({
                        'in_use': in_use,
                        'ssid': ssid,
                        'signal': signal,
                        'security': sec,
                        'secured': len(sec) > 0 and sec != '--'
                    })
        networks.sort(key=lambda x: (not x['in_use'], -x['signal']))
        return networks
    except Exception as e:
        return []

if __name__ == '__main__':
    print(json.dumps(get_wifi_list()))
