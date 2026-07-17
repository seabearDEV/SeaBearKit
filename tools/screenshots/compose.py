#!/usr/bin/env python3
"""Compose the SeaBearKit screenshots: caption band + rounded screenshot on a
cool sea-light gradient, 1320x2868 (the 6.9-inch portrait class).

Reads AppStore/screenshots/raw/<name>.png (captured by shoot.sh), writes
AppStore/screenshots/final/NN-<name>.png in presentation order, plus a
_contact.png sheet for quick review. Captions are set here; one uniform size
fits them all.
"""
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "AppStore/screenshots/raw"
OUT = ROOT / "AppStore/screenshots/final"
OUT.mkdir(parents=True, exist_ok=True)

W, H = 1320, 2868
INK = (27, 58, 85)            # deep sea navy
BG_TOP = (244, 247, 250)      # sea-light
BG_BOTTOM = (226, 235, 242)   # slightly deeper at the foot
SHOT_W = 1010
SHOT_TOP = 400
RADIUS = 56

# Presentation order. Captions: developer register, one claim per slide.
CAPTIONS = [
    ("menu", "One background, every screen"),
    ("depth", "Persistent five levels deep"),
    ("palettes", "Nine palettes built in"),
    ("custom", "Or bring any SwiftUI view"),
    ("list", "Lists stay translucent"),
    ("form", "Forms and pickers, too"),
    ("dark", "At home in dark mode"),
]


def charter_bold(size: int) -> ImageFont.FreeTypeFont:
    path = "/System/Library/Fonts/Supplemental/Charter.ttc"
    for index in range(8):
        try:
            font = ImageFont.truetype(path, size, index=index)
        except OSError:
            break
        if font.getname()[1] == "Bold":
            return font
    return ImageFont.truetype(path, size)


def gradient() -> Image.Image:
    base = Image.new("RGB", (1, H))
    for y in range(H):
        t = y / (H - 1)
        base.putpixel((0, y), tuple(
            round(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)))
    return base.resize((W, H))


def fitted_size(caption: str, probe: ImageDraw.ImageDraw) -> int:
    size = 92
    font = charter_bold(size)
    while probe.textlength(caption, font=font) > W - 140 and size > 56:
        size -= 4
        font = charter_bold(size)
    return size


_probe = ImageDraw.Draw(Image.new("RGB", (1, 1)))
UNIFORM = min(fitted_size(c, _probe) for _, c in CAPTIONS)


def compose(order: int, name: str, caption: str) -> None:
    canvas = gradient()
    draw = ImageDraw.Draw(canvas)

    font = charter_bold(UNIFORM)
    tw = draw.textlength(caption, font=font)
    ascent, descent = font.getmetrics()
    ty = (SHOT_TOP - (ascent + descent)) // 2 + 14
    draw.text(((W - tw) // 2, ty), caption, font=font, fill=INK)

    # Screenshot: scaled, rounded, hairline, soft shadow.
    shot = Image.open(RAW / f"{name}.png").convert("RGB")
    sh = round(shot.height * SHOT_W / shot.width)
    shot = shot.resize((SHOT_W, sh), Image.LANCZOS)

    mask = Image.new("L", (SHOT_W, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, SHOT_W - 1, sh - 1], RADIUS, fill=255)

    x = (W - SHOT_W) // 2
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [x, SHOT_TOP + 22, x + SHOT_W, SHOT_TOP + sh + 22],
        RADIUS, fill=(27, 58, 85, 60))
    shadow = shadow.filter(ImageFilter.GaussianBlur(36))
    canvas.paste(Image.new("RGB", (W, H), (0, 0, 0)), (0, 0),
                 shadow.split()[3])

    canvas.paste(shot, (x, SHOT_TOP), mask)
    ImageDraw.Draw(canvas).rounded_rectangle(
        [x, SHOT_TOP, x + SHOT_W - 1, SHOT_TOP + sh - 1], RADIUS,
        outline=(27, 58, 85, 40), width=2)

    canvas.save(OUT / f"{order:02d}-{name}.png")
    print(f"{order:02d}-{name}: {canvas.size}, caption {UNIFORM}px")


for i, (name, caption) in enumerate(CAPTIONS, start=1):
    compose(i, name, caption)

# Contact sheet for quick review.
import math
rows = math.ceil(len(CAPTIONS) / 3)
sheet = Image.new("RGB", (3 * 440, rows * 956), (255, 255, 255))
for i, (name, _) in enumerate(CAPTIONS):
    img = Image.open(OUT / f"{i + 1:02d}-{name}.png").resize(
        (440, 956), Image.LANCZOS)
    sheet.paste(img, ((i % 3) * 440, (i // 3) * 956))
sheet.save(OUT / "_contact.png")
print("contact sheet written")
