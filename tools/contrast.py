#!/usr/bin/env python3
"""tools/contrast.py — measure the design tokens' text/ground contrast (WCAG 2).

    python3 tools/contrast.py [ide/tokens.css]

ide/tokens.css is the one home of the palette (docs/DESIGN_SYSTEM.md §4
points at it). Every text and accent token is measured against every
ground it can stand on, in both themes; body text must reach AA (4.5:1),
accent text and UI labels 3:1. A pairing below its floor is a red line and a
nonzero exit — the gate reads this, so a colour is never chosen by eye.
"""
import re, sys

path = sys.argv[1] if len(sys.argv) > 1 else "ide/tokens.css"
css = open(path, encoding="utf-8").read()

def block(name):
    # the :root block (obsidian) or the parchment override block
    m = re.search(name + r"\s*\{(.*?)\n\}", css, re.S)
    return m.group(1) if m else ""

def tokens(text):
    return {k: v for k, v in re.findall(r"--([a-z0-9-]+):\s*(#[0-9A-Fa-f]{6})\b", text)}

obsidian = tokens(block(r":root"))
parchment = dict(obsidian); parchment.update(tokens(block(r':root\[data-theme="parchment"\]')))

def lum(hexs):
    r, g, b = (int(hexs[i:i+2], 16) / 255 for i in (1, 3, 5))
    f = lambda c: c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)

def ratio(a, b):
    la, lb = lum(a), lum(b)
    hi, lo = max(la, lb), min(la, lb)
    return (hi + 0.05) / (lo + 0.05)

BODY = ["primary", "bright", "muted"]                        # read as sentences: AA 4.5
LABEL = ["faint", "whisper", "comment", "gold", "gold-b", "sky", "sky-b", "blue", "blue-b",
         "green", "green-b", "verm", "verm-b", "mag", "mag-b", "wheat"]   # short labels, code tokens: 3.0
GROUNDS = ["canvas", "raised1", "raised2", "abyss"]
bad = 0
for theme, t in (("obsidian", obsidian), ("parchment", parchment)):
    for g in GROUNDS:
        for name, floor in [(n, 4.5) for n in BODY] + [(n, 3.0) for n in LABEL]:
            if name not in t or g not in t:
                continue
            r = ratio(t[name], t[g])
            mark = "ok " if r >= floor else "RED"
            if r < floor:
                bad += 1
            print(f"{mark} {theme:9s} --{name:9s} on --{g:8s} {r:5.2f}:1  (floor {floor})")
print(f"contrast: {'every pairing clears its floor' if bad == 0 else str(bad) + ' pairing(s) below the floor'}")
sys.exit(1 if bad else 0)
