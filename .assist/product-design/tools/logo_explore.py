import math, struct, zlib, sys

GREEN = (0x4F, 0x6F, 0x5E)
CREAM = (0xFA, 0xF7, 0xF2)
SHEET_BG = (0xED, 0xE6, 0xDC)


def clamp(v):
    return 0.0 if v < 0 else 1.0 if v > 1 else v


# signed-distance helpers, coordinates in units of the tile size, origin at the centre
def d_circle(x, y, r):
    return math.hypot(x, y) - r


def d_ring(x, y, r, half):
    return abs(math.hypot(x, y) - r) - half


def d_rrect(x, y, hw, hh, cr):
    qx = abs(x) - hw + cr
    qy = abs(y) - hh + cr
    return math.hypot(max(qx, 0), max(qy, 0)) + min(max(qx, qy), 0) - cr


def d_arc(x, y, r, half, a0, a1):
    """Arc of radius r from angle a0 to a1 (radians, counter-clockwise from +x), round caps."""
    ang = math.atan2(-y, x) % (2 * math.pi)  # y grows downwards on screen
    lo, hi = a0 % (2 * math.pi), a1 % (2 * math.pi)
    inside = (lo <= ang <= hi) if lo <= hi else (ang >= lo or ang <= hi)
    if inside:
        return abs(math.hypot(x, y) - r) - half
    best = 1e9
    for a in (a0, a1):
        ex, ey = r * math.cos(a), -r * math.sin(a)
        best = min(best, math.hypot(x - ex, y - ey) - half)
    return best


def d_union(*ds):
    return min(ds)


def d_sub(a, b):  # a minus b
    return max(a, -b)


def logo_a(x, y):  # a ring around a small core
    return d_union(d_ring(x, y, 0.300, 0.062), d_circle(x, y, 0.078))


def logo_b(x, y):  # a page held inside a thin circle
    page = d_rrect(x, y + 0.005, 0.125, 0.160, 0.035)
    line1 = d_rrect(x, y + 0.055, 0.070, 0.0125, 0.0125)
    line2 = d_rrect(x, y + 0.010, 0.070, 0.0125, 0.0125)
    line3 = d_rrect(x + 0.03, y - 0.035, 0.040, 0.0125, 0.0125)
    page = d_sub(d_sub(d_sub(page, line1), line2), line3)
    return d_union(d_ring(x, y, 0.335, 0.020), page)


def logo_c(x, y):  # an open shell embracing a core
    return d_union(d_arc(x, y, 0.270, 0.058, math.radians(75), math.radians(75 + 300)), d_circle(x, y, 0.082))


def logo_d(x, y):  # a soft keyhole inside a ring
    head = d_circle(x, y + 0.045, 0.078)
    stem = d_rrect(x, y - 0.075, 0.032, 0.085, 0.030)
    return d_union(d_ring(x, y, 0.320, 0.036), head, stem)


LOGOS = [("A", logo_a), ("B", logo_b), ("C", logo_c), ("D", logo_d)]


def render_tile(size, fn, corner=0.2, bg=GREEN, fg=CREAM, sheet_bg=SHEET_BG):
    """RGB rows for a tile: green rounded square with the mark in cream. Returns list of bytearray rows."""
    rows = []
    px = 1.0 / size
    c = 0.5
    cr = corner
    for j in range(size):
        row = bytearray()
        y = (j + 0.5) / size - c
        for i in range(size):
            x = (i + 0.5) / size - c
            dm = fn(x, y)
            a = clamp(0.5 - dm / px)
            col = tuple(bg[k] * (1 - a) + fg[k] * a for k in range(3))
            # rounded-square mask over the sheet background
            m = clamp(0.5 - d_rrect(x, y, 0.5, 0.5, cr) / px)
            col = tuple(sheet_bg[k] * (1 - m) + col[k] * m for k in range(3))
            row += bytes(int(v + 0.5) for v in col)
        rows.append(row)
    return rows


def write_png(path, w, h, rows):
    raw = b"".join(b"\x00" + bytes(r) for r in rows)
    def chunk(tag, data):
        cc = struct.pack(">I", len(data)) + tag + data
        return cc + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def sheet(path, logos, big=380, gap=40):
    cols = 2
    small = [96, 48]
    cell_w = big + gap
    cell_h = big + gap + 96 + gap // 2
    rows_n = (len(logos) + cols - 1) // cols
    W = cols * cell_w + gap
    H = rows_n * cell_h + gap
    canvas = [bytearray(bytes(SHEET_BG) * W) for _ in range(H)]
    def blit(rows, ox, oy):
        for j, r in enumerate(rows):
            canvas[oy + j][ox * 3: ox * 3 + len(r)] = r
    for n, (name, fn) in enumerate(logos):
        cx, cy = n % cols, n // cols
        ox = gap + cx * cell_w
        oy = gap + cy * cell_h
        blit(render_tile(big, fn), ox, oy)
        sx = ox
        for s in small:
            blit(render_tile(s, fn), sx, oy + big + gap // 2)
            sx += s + 20
    write_png(path, W, H, canvas)


if __name__ == "__main__":
    sheet(sys.argv[1], LOGOS)
    print("ok")
