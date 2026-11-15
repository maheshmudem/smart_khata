"""Draws the Smart Khata launcher icon as PNG files for Android versions
that have no adaptive icons (API 24 and 25).

The icon is a white open ledger with amber entry lines on the brand
green. It is drawn from the same numbers as the vector in
android/app/src/main/res/drawable/ic_launcher_foreground.xml, so the two
match. Standard library only; run from the repository root:

    python tool/generate_launcher_icons.py
"""

import os
import struct
import zlib

GREEN = (0x1B, 0x6B, 0x4A)
WHITE = (0xFF, 0xFF, 0xFF)
AMBER = (0xF2, 0xA5, 0x16)
SPINE = (0x14, 0x52, 0x39)

# The drawing lives on a 108 x 108 grid, like an adaptive icon. A legacy
# icon shows the middle 72 x 72 of it.
VIEW = 72.0
OFFSET = 18.0

# (left, top, right, bottom, colour) in grid units.
SHAPES = [
    (30, 36, 53, 72, WHITE),  # left page
    (55, 36, 78, 72, WHITE),  # right page
    (53, 36, 55, 72, SPINE),  # spine
    (34, 43, 49, 46, AMBER),
    (34, 51, 49, 54, GREEN),
    (34, 59, 45, 62, GREEN),
    (59, 43, 74, 46, GREEN),
    (59, 51, 74, 54, GREEN),
    (59, 59, 70, 62, AMBER),
]

SIZES = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192}
SAMPLES = 4  # per axis, for smooth edges


def colour_at(x, y):
    """Colour of grid point (x, y), or None outside the rounded square."""
    radius = 16.0
    left, top, right, bottom = OFFSET, OFFSET, OFFSET + VIEW, OFFSET + VIEW
    cx = min(max(x, left + radius), right - radius)
    cy = min(max(y, top + radius), bottom - radius)
    if (x - cx) ** 2 + (y - cy) ** 2 > radius ** 2:
        return None
    colour = GREEN
    for l, t, r, b, shape_colour in SHAPES:
        if l <= x < r and t <= y < b:
            colour = shape_colour
    return colour


def render(size):
    rows = []
    step = VIEW / (size * SAMPLES)
    for py in range(size):
        row = bytearray([0])  # PNG filter type: none
        for px in range(size):
            red = green = blue = alpha = 0
            for sy in range(SAMPLES):
                for sx in range(SAMPLES):
                    x = OFFSET + (px * SAMPLES + sx + 0.5) * step
                    y = OFFSET + (py * SAMPLES + sy + 0.5) * step
                    colour = colour_at(x, y)
                    if colour is not None:
                        red += colour[0]
                        green += colour[1]
                        blue += colour[2]
                        alpha += 1
            total = SAMPLES * SAMPLES
            if alpha:
                row += bytes([red // alpha, green // alpha, blue // alpha,
                              255 * alpha // total])
            else:
                row += bytes([0, 0, 0, 0])
        rows.append(bytes(row))
    return b''.join(rows)


def chunk(kind, data):
    body = kind + data
    return (struct.pack('>I', len(data)) + body
            + struct.pack('>I', zlib.crc32(body) & 0xFFFFFFFF))


def write_png(path, size):
    header = struct.pack('>IIBBBBB', size, size, 8, 6, 0, 0, 0)
    png = (b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', header)
           + chunk(b'IDAT', zlib.compress(render(size), 9))
           + chunk(b'IEND', b''))
    with open(path, 'wb') as out:
        out.write(png)


def main():
    res = os.path.join('android', 'app', 'src', 'main', 'res')
    for density, size in SIZES.items():
        path = os.path.join(res, 'mipmap-' + density, 'ic_launcher.png')
        write_png(path, size)
        print(path, size)


if __name__ == '__main__':
    main()
