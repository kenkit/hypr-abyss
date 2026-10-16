#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import json
import subprocess

def search(query, limit=8):
    clean_q = query.strip()
    if not clean_q:
        print("[]")
        return

    # 1. Buscar la pista principal que mejor coincida
    cmd_primary = [
        "yt-dlp",
        f"ytsearch1:{clean_q}",
        "--dump-single-json",
        "--flat-playlist",
        "--no-warnings",
        "--quiet"
    ]
    
    primary_id = None
    try:
        res1 = subprocess.run(cmd_primary, capture_output=True, text=True, timeout=10)
        if res1.returncode == 0 and res1.stdout.strip():
            d1 = json.loads(res1.stdout)
            entries1 = d1.get("entries", [])
            if entries1 and entries1[0]:
                primary_id = entries1[0].get("id")
    except Exception:
        pass

    results = []

    # 2. Si encontramos la pista principal, obtenemos su Mix / Radio oficial de canciones relacionadas (RD + video_id)
    if primary_id:
        cmd_mix = [
            "yt-dlp",
            f"https://www.youtube.com/watch?v={primary_id}&list=RD{primary_id}",
            "--dump-single-json",
            "--flat-playlist",
            "--playlist-items", f"1:{limit}",
            "--no-warnings",
            "--quiet"
        ]
        try:
            res_mix = subprocess.run(cmd_mix, capture_output=True, text=True, timeout=12)
            if res_mix.returncode == 0 and res_mix.stdout.strip():
                dm = json.loads(res_mix.stdout)
                for e in dm.get("entries", []):
                    if not e: continue
                    dur = e.get("duration") or 0
                    mins, secs = divmod(int(dur), 60)
                    dur_str = f"{mins:02d}:{secs:02d}" if dur > 0 else "--:--"

                    thumbs = e.get("thumbnails", [])
                    thumb_url = thumbs[-1]["url"] if thumbs else ""

                    title = e.get("title", "Título Desconocido")
                    artist = e.get("uploader") or e.get("channel") or "Artista Desconocido"

                    results.append({
                        "id": e.get("id"),
                        "title": title,
                        "artist": artist,
                        "duration": dur_str,
                        "durationSec": int(dur),
                        "url": f"https://www.youtube.com/watch?v={e.get('id')}",
                        "thumbnail": thumb_url
                    })
        except Exception:
            results = []

    # 3. Fallback: Si el Radio Mix no devolvió suficientes canciones, búsqueda estándar
    if len(results) < 2:
        cmd_fallback = [
            "yt-dlp",
            f"ytsearch{limit}:{clean_q}",
            "--dump-single-json",
            "--flat-playlist",
            "--no-warnings",
            "--quiet"
        ]
        try:
            res_fb = subprocess.run(cmd_fallback, capture_output=True, text=True, timeout=12)
            if res_fb.returncode == 0 and res_fb.stdout.strip():
                dfb = json.loads(res_fb.stdout)
                results = []
                for e in dfb.get("entries", []):
                    if not e: continue
                    dur = e.get("duration") or 0
                    mins, secs = divmod(int(dur), 60)
                    dur_str = f"{mins:02d}:{secs:02d}" if dur > 0 else "--:--"

                    thumbs = e.get("thumbnails", [])
                    thumb_url = thumbs[-1]["url"] if thumbs else ""

                    results.append({
                        "id": e.get("id"),
                        "title": e.get("title", "Título Desconocido"),
                        "artist": e.get("uploader") or e.get("channel") or "Artista Desconocido",
                        "duration": dur_str,
                        "durationSec": int(dur),
                        "url": f"https://www.youtube.com/watch?v={e.get('id')}",
                        "thumbnail": thumb_url
                    })
        except Exception:
            pass

    print(json.dumps(results, ensure_ascii=False))

if __name__ == "__main__":
    q = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "Coldplay Yellow"
    search(q, limit=8)
