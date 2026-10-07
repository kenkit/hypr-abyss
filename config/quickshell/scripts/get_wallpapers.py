#!/usr/bin/env python3
# ==============================================================================
# Fast Wallpaper Scanner for Quickshell Dynamic Wallpaper Selector
# Extracts static images & animated/video wallpapers with 360x200 thumbnail caching
# ==============================================================================

import os
import sys
import json
import hashlib
import subprocess

def get_wallpapers():
    wall_dir = os.path.expanduser('~/Pictures/Wallpapers')
    thumb_dir = os.path.expanduser('~/.cache/wallpaper_thumbs')
    os.makedirs(wall_dir, exist_ok=True)
    os.makedirs(thumb_dir, exist_ok=True)

    static_exts = {'.jpg', '.jpeg', '.png', '.webp', '.bmp'}
    anim_exts = {'.gif', '.mp4', '.webm', '.mkv'}

    items = []
    if os.path.exists(wall_dir):
        files = sorted(os.listdir(wall_dir), key=lambda x: x.lower())
        for f in files:
            full_path = os.path.join(wall_dir, f)
            if not os.path.isfile(full_path):
                continue
            
            ext = os.path.splitext(f)[1].lower()
            is_static = ext in static_exts
            is_anim = ext in anim_exts
            if not (is_static or is_anim):
                continue
            
            # Generar / recuperar miniatura JPEG de 360x200
            h = hashlib.md5(full_path.encode()).hexdigest()
            t_file = os.path.join(thumb_dir, f"{h}.jpg")

            need_generate = not os.path.exists(t_file)
            if not need_generate:
                try:
                    if os.path.getmtime(t_file) < os.path.getmtime(full_path):
                        need_generate = True
                except Exception:
                    need_generate = True

            if need_generate:
                if ext in {'.mp4', '.webm', '.mkv'}:
                    try:
                        subprocess.run(
                            ['ffmpeg', '-y', '-ss', '00:00:01', '-i', full_path, '-vframes', '1', '-vf', 'scale=360:200:force_original_aspect_ratio=increase,crop=360:200', '-q:v', '3', t_file],
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL,
                            timeout=4
                        )
                    except Exception:
                        pass
                else:
                    # Para imágenes y gifs (incluyendo webp)
                    try:
                        subprocess.run(
                            ['magick', f"{full_path}[0]", '-resize', '360x200^', '-gravity', 'center', '-extent', '360x200', '-quality', '85', t_file],
                            stdout=subprocess.DEVNULL,
                            stderr=subprocess.DEVNULL,
                            timeout=4
                        )
                    except Exception:
                        pass

            thumb_url = 'file://' + (t_file if os.path.exists(t_file) else full_path)

            items.append({
                'name': os.path.splitext(f)[0],
                'filename': f,
                'path': full_path,
                'thumb': thumb_url,
                'type': 'animated' if is_anim else 'static',
                'ext': ext.replace('.', '').upper()
            })

    return items

if __name__ == '__main__':
    wallpapers = get_wallpapers()
    print(json.dumps(wallpapers))
