"""
Cut the device mockups out of hero.png.

The source is a 1920x774 image: a smooth light-grey vertical gradient with a laptop and
phone sitting right of centre. As a full-bleed `cover` background it can only be scaled,
not resized independently of the text. Keying out the flat background produces a
transparent PNG that can be laid out as a normal element at any size.

Alpha is derived from each pixel's distance to its own row's background colour, so the
soft drop shadow under the devices fades out naturally instead of being hard-cut.
"""
import zlib, struct

SRC = '/home/pro/Repositories/torii-srs-site-java/public/images/hero.png'
DST = '/home/pro/Repositories/torii-srs-site-java/public/images/hero-devices.png'


def read_png(path):
    d = open(path, 'rb').read()
    pos, idat = 8, b''
    w = h = ct = None
    while pos < len(d):
        ln = struct.unpack('>I', d[pos:pos + 4])[0]
        typ = d[pos + 4:pos + 8]
        if typ == b'IHDR':
            w, h, _bd, ct = struct.unpack('>IIBB', d[pos + 8:pos + 18])
        elif typ == b'IDAT':
            idat += d[pos + 8:pos + 8 + ln]
        pos += 12 + ln
    raw = zlib.decompress(idat)
    ch = {0: 1, 2: 3, 3: 1, 4: 2, 6: 4}[ct]
    stride = w * ch
    out = bytearray()
    prev = bytearray(stride)
    p = 0
    for _ in range(h):
        f = raw[p]; p += 1
        line = bytearray(raw[p:p + stride]); p += stride
        if f:
            for i in range(stride):
                a = line[i - ch] if i >= ch else 0
                b = prev[i]
                c = prev[i - ch] if i >= ch else 0
                if f == 1:
                    line[i] = (line[i] + a) & 255
                elif f == 2:
                    line[i] = (line[i] + b) & 255
                elif f == 3:
                    line[i] = (line[i] + (a + b) // 2) & 255
                else:
                    pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                    pr = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                    line[i] = (line[i] + pr) & 255
        out += line
        prev = line
    return w, h, ch, out


def write_png(path, w, h, rgba):
    raw = bytearray()
    for y in range(h):
        raw.append(0)                      # filter: none
        raw += rgba[y * w * 4:(y + 1) * w * 4]

    def chunk(tag, data):
        return (struct.pack('>I', len(data)) + tag + data
                + struct.pack('>I', zlib.crc32(tag + data) & 0xFFFFFFFF))

    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(bytes(raw), 9))
    png += chunk(b'IEND', b'')
    open(path, 'wb').write(png)


w, h, ch, px = read_png(SRC)
stride = w * ch

# Each row's background colour, sampled from the far-left edge (always empty).
row_bg = [tuple(px[y * stride + i] for i in range(3)) for y in range(h)]

SOFT, HARD = 6.0, 26.0          # distance thresholds for alpha ramp
rgba = bytearray(w * h * 4)
for y in range(h):
    br, bg_, bb = row_bg[y]
    base = y * stride
    o = y * w * 4
    for x in range(w):
        i = base + x * ch
        r, g, b = px[i], px[i + 1], px[i + 2]
        dist = max(abs(r - br), abs(g - bg_), abs(b - bb))
        if dist <= SOFT:
            a = 0
        elif dist >= HARD:
            a = 255
        else:
            a = int(255 * (dist - SOFT) / (HARD - SOFT))
        j = o + x * 4
        rgba[j] = r; rgba[j + 1] = g; rgba[j + 2] = b; rgba[j + 3] = a

# Bounding box of everything that survived.
minx, miny, maxx, maxy = w, h, -1, -1
for y in range(h):
    o = y * w * 4
    for x in range(w):
        if rgba[o + x * 4 + 3] > 8:
            if x < minx: minx = x
            if x > maxx: maxx = x
            if y < miny: miny = y
            if y > maxy: maxy = y

pad = 6
minx = max(0, minx - pad); miny = max(0, miny - pad)
maxx = min(w - 1, maxx + pad); maxy = min(h - 1, maxy + pad)
cw, chh = maxx - minx + 1, maxy - miny + 1

crop = bytearray(cw * chh * 4)
for y in range(chh):
    src = ((y + miny) * w + minx) * 4
    dst = y * cw * 4
    crop[dst:dst + cw * 4] = rgba[src:src + cw * 4]

write_png(DST, cw, chh, crop)
print(f'source      : {w}x{h}')
print(f'device bbox : x {minx}-{maxx}, y {miny}-{maxy}')
print(f'written     : {cw}x{chh} -> {DST}')
