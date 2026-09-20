"""Round 2: refinements of option A (ring with a core). Run: python logo_round2.py out.png"""
import sys
from logo_explore import *


def variant(ring_r, ring_half, dot_r, halo=None):
    def fn(x, y):
        parts = [d_ring(x, y, ring_r, ring_half), d_circle(x, y, dot_r)]
        if halo:
            parts.append(d_ring(x, y, halo[0], halo[1]))
        return d_union(*parts)
    return fn


VARIANTS = [
    ("A1 as now", variant(0.300, 0.062, 0.078)),
    ("A2 lighter", variant(0.315, 0.046, 0.088)),
    ("A3 bolder", variant(0.295, 0.078, 0.068)),
    ("A4 with a halo", variant(0.250, 0.050, 0.070, halo=(0.345, 0.014))),
]

DARK = (0x1B, 0x18, 0x15)
LIGHT = (0xFA, 0xF7, 0xF2)
SAGE_LIGHT = (0x8F, 0xB0, 0x9E)


def sheet2(path, big=340, gap=36):
    cols = 2
    thumbs = 88
    cell_w = big + gap
    cell_h = big + gap // 2 + thumbs + gap
    rows_n = 2
    W = cols * cell_w + gap
    H = rows_n * cell_h + gap
    canvas = [bytearray(bytes(SHEET_BG) * W) for _ in range(H)]

    def blit(rows, ox, oy):
        for j, r in enumerate(rows):
            canvas[oy + j][ox * 3: ox * 3 + len(r)] = r

    for n, (name, fn) in enumerate(VARIANTS):
        cx, cy = n % cols, n // cols
        ox = gap + cx * cell_w
        oy = gap + cy * cell_h
        blit(render_tile(big, fn), ox, oy)
        ty = oy + big + gap // 2
        x = ox
        blit(render_tile(thumbs, fn), x, ty)            # app icon at about 88 px
        x += thumbs + 14
        blit(render_tile(48, fn), x, ty)                # 48 px
        x += 48 + 14
        # in-app mark: green ring on the cream screen (light theme), then soft green on dark (dark theme)
        blit(render_tile(thumbs, fn, corner=0.2, bg=LIGHT, fg=GREEN), x, ty)
        x += thumbs + 14
        blit(render_tile(thumbs, fn, corner=0.2, bg=DARK, fg=SAGE_LIGHT), x, ty)
    write_png(path, W, H, canvas)


if __name__ == "__main__":
    sheet2(sys.argv[1])
    print("ok")
