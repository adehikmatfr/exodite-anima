#!/usr/bin/env python3
"""Draws the app icon (the ring mark on the brand green) and writes every size.

Pure Python, no packages. Run from the app folder:  python tool/make_icons.py

Colours come from the design tokens (`color.sage.600` and `color.warm.50`,
`.assist/product-design/design/library/tokens.json`). The mark is logo option A2
(chosen 2026-09-20): a ring with a core, in units of the tile size: ring centre
radius 0.315, half stroke 0.046, core radius 0.088.

Writes
  android/app/src/main/res/mipmap-*/ic_launcher.png             legacy icon (Android 7)
  android/app/src/main/res/mipmap-*/ic_launcher_foreground.png  adaptive icon layer
  android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml    adaptive icon (Android 8+, themed on 13+)
  android/app/src/main/res/values/ic_launcher_background.xml
  ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png           every size the set lists
"""
import json
import math
import os
import struct
import zlib

GREEN = (0x4F, 0x6F, 0x5E)   # color.sage.600
CREAM = (0xFA, 0xF7, 0xF2)   # color.warm.50
RING_R, RING_HALF, DOT_R = 0.315, 0.046, 0.088   # logo A2, in tile units


def png(path, w, h, rows, alpha):
    """rows: list of bytes (RGBA or RGB per pixel)."""
    raw = b"".join(b"\x00" + r for r in rows)
    def chunk(tag, data):
        c = struct.pack(">I", len(data)) + tag + data
        return c + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    ihdr = struct.pack(">IIBBBBB", w, h, 8, 6 if alpha else 2, 0, 0, 0)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def clamp(v):
    return 0.0 if v < 0 else 1.0 if v > 1 else v


def render(size, scale, bg, ring, corner=0.0, alpha=True):
    """The A2 mark at `scale` (1.0 = the tile geometry), centred. bg is (r,g,b) or None (transparent)."""
    c = size / 2.0
    R = RING_R * scale * size
    half = RING_HALF * scale * size
    dot = DOT_R * scale * size
    cr = corner * size
    rows = []
    for y in range(size):
        row = bytearray()
        py = y + 0.5
        for x in range(size):
            px = x + 0.5
            d = math.hypot(px - c, py - c)
            a_ring = max(clamp(0.5 - (abs(d - R) - half)), clamp(0.5 - (d - dot)))
            # rounded-square mask for the legacy icon
            m = 1.0
            if cr > 0:
                dx = max(abs(px - c) - (c - cr), 0.0)
                dy = max(abs(py - c) - (c - cr), 0.0)
                m = clamp(cr - math.hypot(dx, dy) + 0.5)
            if bg is None:
                out_a = a_ring
                col = ring
            else:
                out_a = m
                col = tuple(bg[i] * (1 - a_ring) + ring[i] * a_ring for i in range(3))
            if alpha:
                row += bytes((int(col[0] + 0.5), int(col[1] + 0.5), int(col[2] + 0.5), int(out_a * 255 + 0.5)))
            else:
                row += bytes((int(col[0] + 0.5), int(col[1] + 0.5), int(col[2] + 0.5)))
        rows.append(bytes(row))
    return rows


def main():
    res = "android/app/src/main/res"
    legacy = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    layer = {"mdpi": 108, "hdpi": 162, "xhdpi": 216, "xxhdpi": 324, "xxxhdpi": 432}
    for d, s in legacy.items():
        png(f"{res}/mipmap-{d}/ic_launcher.png", s, s, render(s, 1.0, GREEN, CREAM, corner=0.2), True)
    for d, s in layer.items():
        # the adaptive mask shows the middle 66 of 108: keep the whole ring inside it
        png(f"{res}/mipmap-{d}/ic_launcher_foreground.png", s, s, render(s, 0.748, None, CREAM), True)
    os.makedirs(f"{res}/mipmap-anydpi-v26", exist_ok=True)
    with open(f"{res}/mipmap-anydpi-v26/ic_launcher.xml", "w", encoding="utf-8", newline="\n") as f:
        f.write("""<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
""")
    with open(f"{res}/values/ic_launcher_background.xml", "w", encoding="utf-8", newline="\n") as f:
        f.write("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#4F6F5E</color>
</resources>
""")

    ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    with open(f"{ios}/Contents.json", encoding="utf-8") as f:
        info = json.load(f)
    done = {}
    for img in info["images"]:
        name = img.get("filename")
        if not name:
            continue
        w = float(img["size"].split("x")[0]) * float(img["scale"].replace("x", ""))
        px = int(round(w))
        if px not in done:
            # iOS icons must be opaque and square; the system rounds the corners
            done[px] = render(px, 1.0, GREEN, CREAM, alpha=False)
        png(f"{ios}/{name}", px, px, done[px], False)
    print("written: android legacy + adaptive, iOS", len(done), "sizes")


if __name__ == "__main__":
    main()
