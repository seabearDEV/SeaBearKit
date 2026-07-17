#!/usr/bin/env python3
"""Compose the seabear.dev product-page banner for SeaBearKit.

Four raw simulator captures, status bar cropped, butted edge-to-edge into a
1712x856 strip — the site's documented 2:1 hero spec at 2x (see the
seabear.dev repo's Reverie store, conventions.project_screenshots). Matches
the treatment of the Cairn, Reverie, and Tesserae banners.

Reads AppStore/screenshots/raw/<name>.png, writes
AppStore/screenshots/banner/seabearkit-banner.png. Copy it into the
seabear.dev repo as assets/images/work/SeaBearKit-<yyyy_mm_dd>-01.png (plus a
.webp sibling) and update src/_data/projects.js dimensions to 1712x856.
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "AppStore/screenshots/raw"
OUT = ROOT / "AppStore/screenshots/banner"
OUT.mkdir(parents=True, exist_ok=True)

PANELS = ["menu", "palettes", "depth", "dark"]
PANEL_W, PANEL_H = 428, 856          # 4 x 428 = 1712, the 2x site spec
STATUS_BAR_CROP = 62                 # rows to drop at panel scale (~9:41 bar)

banner = Image.new("RGB", (PANEL_W * len(PANELS), PANEL_H), (255, 255, 255))
for i, name in enumerate(PANELS):
    shot = Image.open(RAW / f"{name}.png").convert("RGB")
    scaled_h = round(shot.height * PANEL_W / shot.width)
    shot = shot.resize((PANEL_W, scaled_h), Image.LANCZOS)
    panel = shot.crop((0, STATUS_BAR_CROP, PANEL_W, STATUS_BAR_CROP + PANEL_H))
    banner.paste(panel, (i * PANEL_W, 0))

path = OUT / "seabearkit-banner.png"
banner.save(path)
print(f"banner: {banner.size} -> {path}")
