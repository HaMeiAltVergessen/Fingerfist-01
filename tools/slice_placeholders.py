#!/usr/bin/env python3
"""Slice the AI placeholder spritesheets into the per-frame PNGs the game expects.

The source sheets live in assets/Placeholder/AIPlaceholder/ and are a mix of:
  * RGBA sheets with real transparency (Char*, Insekten, Feuerteufel, ProjectileFire,
    Walls, UI_Icons, ItemsIcons) -- background already alpha=0, but baked-in text
    labels are opaque, so cells are cropped to avoid them.
  * RGB sheets with a painted grey background and NO alpha (Coins, Vasenmonster) --
    the grey is removed per cell with a border flood-fill (keeps low-saturation
    silver coins, because their dark outline stops the fill).

Run:  py -3 tools/slice_placeholders.py            # writes staging + contact sheet
      py -3 tools/slice_placeholders.py --apply     # also copies into assets/sprites
"""
import sys
from pathlib import Path
from collections import deque
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "assets" / "Placeholder" / "AIPlaceholder"
STAGE = ROOT / "tools" / "_preview" / "out"
DST = ROOT / "assets" / "sprites"

# ---------------------------------------------------------------------------- helpers

def load_rgba(name):
    return Image.open(SRC / name).convert("RGBA")

def alpha_bbox(rgba, thresh=12):
    a = np.array(rgba)[:, :, 3]
    ys, xs = np.where(a > thresh)
    if len(xs) == 0:
        return None
    return (xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)

def tight(rgba, pad=2):
    bb = alpha_bbox(rgba)
    if bb is None:
        return None
    x0, y0, x1, y1 = bb
    x0 = max(0, x0 - pad); y0 = max(0, y0 - pad)
    x1 = min(rgba.width, x1 + pad); y1 = min(rgba.height, y1 + pad)
    return rgba.crop((x0, y0, x1, y1))

def flood_bg_to_alpha(rgb_cell, lum_lo, lum_hi, sat_max=22):
    """Return RGBA where a flat/checker background (connected to the border) is
    alpha=0.

    A pixel is 'background' only if it is low-saturation, its luminance is inside
    [lum_lo, lum_hi], AND it is reachable from the cell border through other
    background pixels. The dark sprite outline (luminance below lum_lo) blocks the
    fill, so enclosed greys (e.g. a silver coin face, brighter than lum_hi) survive.
    """
    arr = np.array(rgb_cell.convert("RGB")).astype(np.int16)
    h, w, _ = arr.shape
    mx = arr.max(axis=2); mn = arr.min(axis=2)
    lum = arr.mean(axis=2)
    bgish = (mx - mn <= sat_max) & (lum >= lum_lo) & (lum <= lum_hi)

    visited = np.zeros((h, w), bool)
    dq = deque()
    for x in range(w):
        for y in (0, h - 1):
            if bgish[y, x] and not visited[y, x]:
                visited[y, x] = True; dq.append((y, x))
    for y in range(h):
        for x in (0, w - 1):
            if bgish[y, x] and not visited[y, x]:
                visited[y, x] = True; dq.append((y, x))
    while dq:
        y, x = dq.popleft()
        for ny, nx in ((y-1, x), (y+1, x), (y, x-1), (y, x+1)):
            if 0 <= ny < h and 0 <= nx < w and not visited[ny, nx] and bgish[ny, nx]:
                visited[ny, nx] = True; dq.append((ny, nx))

    out = np.dstack([np.array(rgb_cell.convert("RGB")),
                     np.where(visited, 0, 255).astype(np.uint8)])
    return Image.fromarray(out, "RGBA")

def content_x_extent(rgba, band, thresh=20):
    """x-range of opaque content within a [y0,y1] band -- used to split a row into
    equal columns regardless of where the sprites actually sit."""
    y0, y1 = band
    a = np.array(rgba)[y0:y1, :, 3]
    cols = np.where((a > thresh).sum(axis=0) > 1)[0]
    if len(cols) == 0:
        return None
    return cols.min(), cols.max() + 1

def fit_to_target(img, relpath, default=(96, 96)):
    """Down-scale a sliced sprite to the canvas size the scenes already expect (the
    existing placeholder it replaces), keeping aspect ratio and centring on a
    transparent canvas -- so sprite scale stays in sync with the tuned hitboxes."""
    from PIL import ImageOps
    existing = DST / relpath
    size = Image.open(existing).size if existing.exists() else default
    fitted = ImageOps.contain(img, size, Image.LANCZOS)
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    canvas.paste(fitted, ((size[0] - fitted.width) // 2,
                          (size[1] - fitted.height) // 2))
    return canvas

def save(img, relpath):
    img = fit_to_target(img, relpath)
    dst = STAGE / relpath
    dst.parent.mkdir(parents=True, exist_ok=True)
    img.save(dst)
    return relpath

# ---------------------------------------------------------------------------- sheets

results = []

def do_player():
    # Char2 = boxing glove -> default skin; Char1 = wrapped fist -> 'metal' skin slot.
    # Each is a single fist; fill all 8 attack frames with the same image.
    for src, skin in (("Char2.png", "default"), ("Char1.png", "metal")):
        fist = tight(load_rgba(src), pad=4)
        for i in range(8):
            results.append(save(fist, f"player/{skin}/fist_frame_{i:02d}.png"))

def erase_rect(rgba, x0, y0, x1, y1):
    a = np.array(rgba)
    a[y0:y1, x0:x1, 3] = 0
    return Image.fromarray(a, "RGBA")

def do_insects():
    sheet = load_rgba("Insekten.png")
    # Each row has its colour name baked top-left (AGGRESSIVE / TOXIC / FASTEST);
    # wipe that label strip before measuring/splitting the 4 bug columns.
    rows = {"red": (28, 200), "green": (205, 398), "blue": (400, 592)}
    for color, (y0, y1) in rows.items():
        sheet = erase_rect(sheet, 0, y0, 215, y0 + 40)
    sheet = erase_rect(sheet, 0, 28, 1200, 44)   # thin divider line above the red row
    for color, (y0, y1) in rows.items():
        ext = content_x_extent(sheet, (y0, y1))
        x0, x1 = ext
        cw = (x1 - x0) / 4.0
        for i in range(4):
            cx0 = int(x0 + i * cw); cx1 = int(x0 + (i + 1) * cw)
            cell = sheet.crop((cx0, y0, cx1, y1))
            t = tight(cell)
            if t:
                results.append(save(t, f"enemies/insect/{color}/insect_frame_{i:02d}.png"))

def do_fire_devil():
    sheet = load_rgba("Feuerteufel.png")
    # IDLE row (top, 4 frames) and CHARGE row (lower, 2 frames); labels sit between.
    idle = (70, 325)
    charge = (505, 762)
    ext = content_x_extent(sheet, idle)
    x0, x1 = ext; cw = (x1 - x0) / 4.0
    for i in range(4):
        cell = sheet.crop((int(x0 + i*cw), idle[0], int(x0 + (i+1)*cw), idle[1]))
        t = tight(cell)
        if t: results.append(save(t, f"enemies/fire_devil/fire_idle_{i:02d}.png"))
    ext = content_x_extent(sheet, charge)
    x0, x1 = ext; cw = (x1 - x0) / 2.0
    for i in range(2):
        cell = sheet.crop((int(x0 + i*cw), charge[0], int(x0 + (i+1)*cw), charge[1]))
        t = tight(cell)
        if t: results.append(save(t, f"enemies/fire_devil/fire_charge_{i:02d}.png"))

def do_vase():
    sheet = Image.open(SRC / "Vasenmonster.png").convert("RGB")
    # grey checker uses two tones (~128 and ~182); band covers both, terracotta
    # vases stay (saturated). Black label bars are below lum_lo and stop the fill.
    LO, HI, SAT = 100, 205, 20
    rows = [((60, 250), 2, "idle"), ((350, 545), 5, "windup"), ((635, 840), 3, "attack")]
    for (y0, y1), n, label in rows:
        keyed = flood_bg_to_alpha(sheet.crop((0, y0, sheet.width, y1)), LO, HI, SAT)
        ext = content_x_extent(keyed, (0, keyed.height))
        if ext is None:
            continue
        x0, x1 = ext; cw = (x1 - x0) / n
        for i in range(n):
            cell = sheet.crop((int(x0 + i*cw), y0, int(x0 + (i+1)*cw), y1))
            cell = flood_bg_to_alpha(cell, LO, HI, SAT)
            t = tight(cell)
            if t: results.append(save(t, f"enemies/vase/vase_{label}_{i:02d}.png"))

def do_coins():
    sheet_rgb = Image.open(SRC / "Coins.png").convert("RGB")
    LO, HI, SAT = 50, 135, 22       # narrow band keeps the bright silver coin face
    row_y = {"bronze": (18, 198), "silver": (205, 378),
             "gold": (388, 568), "platinum": (572, 768)}
    col_x = [(20, 235), (250, 430), (490, 650), (695, 905)]  # first 4 of 6 columns
    for ctype, (y0, y1) in row_y.items():
        for i, (x0, x1) in enumerate(col_x):
            cell = sheet_rgb.crop((x0, y0, x1, y1))
            keyed = flood_bg_to_alpha(cell, LO, HI, SAT)
            t = tight(keyed)
            if t: results.append(save(t, f"coins/{ctype}/coin_frame_{i:02d}.png"))

def do_projectile():
    sheet = load_rgba("ProjectileFire.png")
    ext = content_x_extent(sheet, (250, 520))
    x0, x1 = ext; cw = (x1 - x0) / 4.0
    for i in range(4):
        cell = sheet.crop((int(x0 + i*cw), 250, int(x0 + (i+1)*cw), 520))
        t = tight(cell)
        if t: results.append(save(t, f"enemies/projectile/projectile_{i:02d}.png"))

def do_walls():
    # Walls.png: top-left block is Level 1 with 3 vertical states (intact/damaged/critical)
    sheet = load_rgba("Walls.png")
    # Level 1 occupies the first column group; three sub-cells left->right under "Level 1".
    band = (30, 285)
    cells = [(8, 132, "wall_intact"), (138, 262, "wall_damaged"), (278, 392, "wall_critical")]
    for x0, x1, fname in cells:
        cell = sheet.crop((x0, band[0], x1, band[1]))
        if fname == "wall_critical":
            # this tile sits on a light glow rectangle; key the bright halo (stone is
            # mid-grey and stays, the orange cracks are saturated and stay).
            cell = flood_bg_to_alpha(cell.convert("RGB"), 178, 255, 30)
        t = tight(cell)
        if t: results.append(save(t, f"walls/level_1/{fname}.png"))

def do_ui_icons():
    sheet = load_rgba("UI_Icons.png")
    # 3 icons in a row: coin | fire-X (combo) | heart
    cols = [(60, 430, "coin_icon"), (520, 850, "combo_icon"), (940, 1300, "hp_icon")]
    for x0, x1, fname in cols:
        cell = sheet.crop((x0, 150, x1, 560))
        t = tight(cell)
        if t: results.append(save(t, f"ui/{fname}.png"))

def do_items():
    sheet = load_rgba("ItemsIcons.png")
    # 4 cols x 2 rows, icon square on top, name label below -> crop top ~70% only.
    # NOTE: the sheet's 7th icon is "Thunder Charge", but SaveSystem.ITEMS has no
    # such key -- its 5th defence item is "golem_blessing". Map that cell to
    # golem_blessing so every item id has an icon (and keep a thunder_charge alias).
    names = [["greed_magnet", "iron_knuckles", "shockwave_fist", "time_crystal"],
             ["golem_skin", "fire_shield", "golem_blessing", "call_of_wrath"]]
    aliases = {("golem_blessing"): "thunder_charge"}
    col_x = [(6, 294), (306, 594), (605, 893), (905, 1193)]
    row_y = [(6, 300), (450, 745)]   # icon-only bands (exclude name text)
    for r, (y0, y1) in enumerate(row_y):
        for c, (x0, x1) in enumerate(col_x):
            cell = sheet.crop((x0, y0, x1, y1))
            t = tight(cell)
            if t:
                name = names[r][c]
                results.append(save(t, f"ui/items/{name}.png"))
                if name in aliases:
                    results.append(save(t, f"ui/items/{aliases[name]}.png"))

# ---------------------------------------------------------------------------- contact sheet

def contact_sheet():
    cells = []
    for rel in results:
        im = Image.open(STAGE / rel).convert("RGBA")
        cells.append((rel, im))
    cols = 8
    cw, ch = 110, 128
    rows = (len(cells) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cw, rows * ch), (30, 30, 36, 255))
    from PIL import ImageDraw
    d = ImageDraw.Draw(sheet)
    for idx, (rel, im) in enumerate(cells):
        gx = (idx % cols) * cw; gy = (idx // cols) * ch
        thumb = im.copy(); thumb.thumbnail((cw - 8, ch - 30))
        sheet.alpha_composite(thumb, (gx + (cw - thumb.width)//2, gy + 4))
        d.text((gx + 2, gy + ch - 22), rel.split("/")[-1][:16], fill=(220, 220, 120))
        d.text((gx + 2, gy + ch - 12), "/".join(rel.split("/")[:-1])[-18:], fill=(140, 160, 220))
    sheet.convert("RGB").save(ROOT / "tools" / "_preview" / "contact_sheet.png")

# ---------------------------------------------------------------------------- main

def main():
    if STAGE.exists():
        import shutil; shutil.rmtree(STAGE)
    do_player(); do_insects(); do_fire_devil(); do_vase(); do_coins()
    do_projectile(); do_walls(); do_ui_icons(); do_items()
    print(f"sliced {len(results)} frames into {STAGE}")
    contact_sheet()
    print("contact sheet -> tools/_preview/contact_sheet.png")
    if "--apply" in sys.argv:
        import shutil
        n = 0
        for rel in results:
            dst = DST / rel
            dst.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(STAGE / rel, dst)
            n += 1
        print(f"applied {n} frames into {DST}")

if __name__ == "__main__":
    main()
