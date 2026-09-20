"""Loads design tokens from design/library/tokens.json and resolves them per mode.

Used by the .pen generators and by gen_token_docs.py, so design files and documentation always come from the
same source. Contrast is computed here (WCAG 2 relative luminance).
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
TOKENS_PATH = os.path.normpath(os.path.join(HERE, "..", "design", "library", "tokens.json"))


def load():
    with open(TOKENS_PATH, encoding="utf-8") as f:
        return json.load(f)


def resolve(tokens, mode):
    """Returns {semantic token name: hex} for a mode."""
    prim = tokens["primitive"]
    return {name: prim[spec[mode]] for name, spec in tokens["semantic"].items()}


def var_name(token_name):
    """Token name -> .pen variable name (dots to dashes)."""
    return token_name.replace(".", "-")


def luminance(hexcolor):
    h = hexcolor.lstrip("#")
    r, g, b = [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)]

    def f(c):
        return c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4
    return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b)


def contrast(a, b):
    la, lb = luminance(a), luminance(b)
    if la < lb:
        la, lb = lb, la
    return (la + 0.05) / (lb + 0.05)


# pairs that must pass, with the minimum ratio (WCAG 2.2 AA)
PAIRS = [
    ("color.text.primary", "color.surface.base", 4.5),
    ("color.text.primary", "color.surface.raised", 4.5),
    ("color.text.secondary", "color.surface.base", 4.5),
    ("color.text.secondary", "color.surface.raised", 4.5),
    ("color.action.primary.fg", "color.action.primary.bg", 4.5),
    ("color.action.primary.fg", "color.action.primary.pressed", 4.5),
    ("color.action.primary.bg", "color.surface.base", 4.5),
    ("color.action.primary.bg", "color.surface.raised", 4.5),
    ("color.status.danger.fg", "color.surface.base", 4.5),
    ("color.status.danger.fg", "color.surface.raised", 4.5),
    ("color.status.danger.on-solid", "color.status.danger.solid", 4.5),
    ("color.status.warning.fg", "color.surface.base", 4.5),
    ("color.status.warning.fg", "color.surface.raised", 4.5),
    ("color.border.strong", "color.surface.base", 3.0),
    ("color.border.strong", "color.surface.raised", 3.0),
    ("color.focus.ring", "color.surface.base", 3.0),
    ("color.focus.ring", "color.surface.raised", 3.0),
]


def matrix(tokens):
    rows = []
    for fg, bg, need in PAIRS:
        vals = []
        for mode in tokens["modes"]:
            r = resolve(tokens, mode)
            vals.append(contrast(r[fg], r[bg]))
        rows.append((fg, bg, need, vals))
    return rows
