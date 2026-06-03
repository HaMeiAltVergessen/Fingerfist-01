#!/usr/bin/env python3
"""Ersetzt ungueltige ASCII-Text-Platzhalter (.png) durch gueltige RGBA-PNGs.

Hintergrund: Einige Sprite-Dateien sind keine Bilder, sondern Text der Form
    # PNG Placeholder
    # Size: 64x64
    # Color: #ff4500
    # Replace with actual PNG sprite
Godot kann sie nicht importieren -> Szenen laden nicht. Dieses Skript erkennt
solche Fakes (kein PNG-Header) und schreibt ein einfarbiges, gueltiges PNG der
im Text angegebenen Groesse/Farbe. Echte PNGs werden uebersprungen.

Dependency-frei (nur Stdlib: zlib, struct, re). Ausfuehren mit dem py-Launcher:
    py tools\\gen_placeholder_pngs.py
"""
import os
import re
import zlib
import struct

PNG_SIG = b"\x89PNG\r\n\x1a\n"
ASSETS_ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets")


def _chunk(typ: bytes, data: bytes) -> bytes:
    body = typ + data
    return struct.pack(">I", len(data)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)


def make_png(width: int, height: int, rgba) -> bytes:
    """Baut ein gueltiges 8-bit RGBA-PNG (color type 6).

    Frame-Variation/Rand: leichter dunkler 1px-Rand zur Sichtbarkeit der
    Sprite-Grenzen gegen den Hintergrund.
    """
    r, g, b, a = rgba
    # Randfarbe etwas dunkler
    br, bg, bb = int(r * 0.6), int(g * 0.6), int(b * 0.6)
    border = bytes((br, bg, bb, a))
    fill = bytes((r, g, b, a))

    raw = bytearray()
    for y in range(height):
        raw.append(0)  # Filter-Typ 0 (None) pro Scanline
        for x in range(width):
            is_edge = x == 0 or y == 0 or x == width - 1 or y == height - 1
            raw += border if is_edge else fill

    idat = zlib.compress(bytes(raw), 9)
    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    return PNG_SIG + _chunk(b"IHDR", ihdr) + _chunk(b"IDAT", idat) + _chunk(b"IEND", b"")


def hex_to_rgba(h: str):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16), 255)


def is_real_png(path: str) -> bool:
    with open(path, "rb") as f:
        return f.read(8) == PNG_SIG


def main():
    converted = 0
    skipped = 0
    for root, _dirs, files in os.walk(ASSETS_ROOT):
        for name in files:
            if not name.lower().endswith(".png"):
                continue
            path = os.path.join(root, name)
            if is_real_png(path):
                skipped += 1
                continue
            # Text-Platzhalter -> Hints parsen
            with open(path, "r", errors="ignore") as f:
                txt = f.read()
            m_size = re.search(r"Size:\s*(\d+)\s*x\s*(\d+)", txt)
            m_col = re.search(r"Color:\s*(#[0-9a-fA-F]{6})", txt)
            w, h = (int(m_size.group(1)), int(m_size.group(2))) if m_size else (64, 64)
            rgba = hex_to_rgba(m_col.group(1)) if m_col else (255, 0, 255, 255)
            with open(path, "wb") as f:
                f.write(make_png(w, h, rgba))
            converted += 1
            rel = os.path.relpath(path, ASSETS_ROOT)
            print(f"  converted {rel}  ({w}x{h} {m_col.group(1) if m_col else '#ff00ff'})")

    print(f"\nDone. converted={converted}  skipped_real_png={skipped}")


if __name__ == "__main__":
    main()
