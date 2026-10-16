#!/usr/bin/env python3
import sys, json, os

config_path = os.path.expanduser('~/.config/quickshell/clock_config.json')

if len(sys.argv) > 1:
    try:
        data = json.loads(sys.argv[1])
        # Preservar o actualizar campos existentes
        current = {}
        if os.path.exists(config_path):
            try:
                with open(config_path, 'r') as f:
                    current = json.load(f)
            except Exception:
                current = {}
        current.update(data)
        with open(config_path, 'w') as f:
            json.dump(current, f, indent=2)
    except Exception as e:
        sys.exit(1)
