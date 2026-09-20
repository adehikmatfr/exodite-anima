"""UI kit for generating OpenPencil .pen files from design tokens.

Every colour is a token reference ($color-...); values come from design/library/tokens.json per mode.
Components take a `state` so that every state can be drawn. `set_scale` multiplies font sizes to draw the
200 percent text-size variants.
"""
import json
import tokens_lib as tl

TK = tl.load()
W = TK["scale"]["screen"]["width"]
H = TK["scale"]["screen"]["height"]
M = TK["scale"]["screen"]["margin"]
_n = [0]
_scale = [1.0]


def set_scale(s):
    _scale[0] = s


def v(name):
    """Token name -> .pen variable reference."""
    return "$" + tl.var_name(name)


def nid(p="n"):
    _n[0] += 1
    return f"{p}{_n[0]}"


def px(size):
    return round(size * _scale[0])


# ------------------------------------------------------------------ primitives
def text(content, style="type.body", color="color.text.primary", align=None, name=None, width="fill_container", lh=None, weight=None, size=None):
    st = TK["typography"][style]
    fam = TK["typography"][st["family"]]
    fsize = size or st["size"]
    t = {"type": "text", "id": nid("t"), "name": name or content[:28], "content": content, "fontFamily": fam,
         "fontSize": px(fsize), "fontWeight": str(weight or st["weight"]), "lineHeight": lh or round(st["line"] / st["size"], 3),
         "fill": v(color), "textGrowth": "fixed-width", "width": width}
    if align:
        t["textAlign"] = align
    return t


def label(content, color="color.action.primary.bg", style="type.label", name=None):
    st = TK["typography"][style]
    return {"type": "text", "id": nid("t"), "name": name or content, "content": content, "fontFamily": TK["typography"][st["family"]],
            "fontSize": px(st["size"]), "fontWeight": str(st["weight"]), "fill": v(color)}


def frame(name, children, **kw):
    f = {"type": "frame", "id": nid("f"), "name": name, "children": children}
    f.update(kw)
    return f


def spacer(h=None):
    return frame("spacer", [], width="fill_container", **({"height": h} if h else {"height": "fill_container"}))


def stroke(color, thickness=1):
    return {"align": "inside", "thickness": thickness, "fill": v(color)}


def hstack(name, children, gap=8, align="center", **kw):
    return frame(name, children, width="fill_container", layout="horizontal", gap=gap, alignItems=align, **kw)


def vstack(name, children, gap=8, **kw):
    return frame(name, children, width="fill_container", layout="vertical", gap=gap, **kw)


def sized(height):
    """Fixed height at normal text size; no fixed height at large text size, so the box grows with its text."""
    return {"height": height} if _scale[0] <= 1.0 else {}


def pad():
    """Breathing room for boxes that have no padding of their own once their fixed height is dropped."""
    return {} if _scale[0] <= 1.0 else {"padding": 12}


# ------------------------------------------------------------------ components
def button(txt, kind="primary", state="default"):
    """kind: primary | secondary | danger | text. state: default | pressed | disabled | loading."""
    r = TK["scale"]["radius"]["lg"]
    common = dict(width="fill_container", layout="horizontal", alignItems="center", justifyContent="center", cornerRadius=r, **sized(52), **pad())
    if kind == "text":
        col = "color.action.primary.bg" if state != "disabled" else "color.text.secondary"
        return frame(f"Link {txt}", [text(txt, "type.label", col, align="center", lh=1.3)], width="fill_container", layout="horizontal", alignItems="center", justifyContent="center", **sized(48), **pad())
    if state == "disabled":
        return frame(f"Button {txt} (disabled)", [label(txt, "color.text.secondary")], fill=v("color.surface.raised"), stroke=stroke("color.border.default"), **common)
    if state == "loading":
        txt = "Working..."
    if kind == "primary":
        fill = "color.action.primary.pressed" if state == "pressed" else "color.action.primary.bg"
        return frame(f"Button {txt} ({state})", [label(txt, "color.action.primary.fg")], fill=v(fill), **common)
    if kind == "danger":
        return frame(f"Button {txt} ({state})", [label(txt, "color.status.danger.on-solid")], fill=v("color.status.danger.solid"), **common)
    return frame(f"Button {txt} ({state})", [label(txt, "color.text.primary")], fill=v("color.surface.base"), stroke=stroke("color.border.strong"), **common)


def error_line(msg):
    icon = frame("error icon", [label("!", "color.status.danger.fg", "type.caption")], width=20, height=20, cornerRadius=999,
                 stroke=stroke("color.status.danger.fg"), layout="horizontal", alignItems="center", justifyContent="center")
    return hstack("Error message", [icon, text(msg, "type.caption", "color.status.danger.fg", lh=1.4, width=W - 2 * M - 28)], gap=8, align="start")


def field(lab, value=None, hint=None, state="default", helper=None, error=None, secure=False, show=False, trailing=None):
    """A labelled text field. state: default | focus | error | disabled. Label is always visible above."""
    if state == "error":
        border = stroke("color.status.danger.fg", 2)
    elif state == "focus":
        border = stroke("color.focus.ring", 2)
    else:
        border = stroke("color.border.strong")
    inner = W - 2 * M - 32 - (56 if trailing else 0)
    if value:
        shown = value if (show or not secure) else "•" * len(value)
        content = text(shown, "type.body", "color.text.primary" if state != "disabled" else "color.text.secondary", width=inner, weight=500 if secure else 400)
    else:
        content = text(hint or "", "type.body", "color.text.secondary", width=inner)
    row = [content]
    if trailing:
        row.append(label(trailing, "color.action.primary.bg"))
    box = frame(f"Input {lab}", row, width="fill_container", fill=v("color.surface.raised"), cornerRadius=TK["scale"]["radius"]["md"], padding=16,
                layout="horizontal", gap=8, alignItems="center", stroke=border, **sized(56))
    kids = [text(lab, "type.caption", "color.text.primary", weight=500, lh=1.4), box]
    if error:
        kids.append(error_line(error))
    elif helper:
        kids.append(text(helper, "type.caption", "color.text.secondary", lh=1.4))
    return vstack(f"Field {lab} ({state})", kids, gap=8)


def search_field(query=None, focus=False):
    inner = [label("Search", "color.text.secondary", "type.caption"), text(query or "your entries", "type.body", "color.text.primary" if query else "color.text.secondary", width="fill_container")]
    return frame("Search field", inner, width="fill_container", fill=v("color.surface.raised"), cornerRadius=TK["scale"]["radius"]["md"], padding=16, layout="horizontal", gap=8,
                 alignItems="center", stroke=stroke("color.focus.ring", 2) if focus else stroke("color.border.strong"), **sized(56))


def checkbox_row(txt, checked=False):
    if checked:
        box = frame("Checkbox (checked)", [label("✓", "color.action.primary.fg", "type.caption")], width=24, height=24, cornerRadius=6, fill=v("color.action.primary.bg"),
                    layout="horizontal", alignItems="center", justifyContent="center")
    else:
        box = frame("Checkbox (unchecked)", [], width=24, height=24, cornerRadius=6, stroke=stroke("color.border.strong", 2))
    return frame("Acknowledge row", [box, text(txt, "type.body", width=W - 2 * M - 24 - 12, lh=1.4)], width="fill_container", layout="horizontal", gap=12, alignItems="center", **sized(56), **pad())


def bullet(txt):
    dot = frame("dot", [], width=8, height=8, cornerRadius=999, fill=v("color.action.primary.bg"))
    return hstack("Point", [dot, text(txt, "type.body", width=W - 2 * M - 20)], gap=12)


def mark(size=72):
    """The logo mark (option A2): a ring with a core. Ring stroke 0.127 of the diameter, core 0.244 of it."""
    core = frame("Logo core", [], width=max(round(size * 0.244), 4), height=max(round(size * 0.244), 4), cornerRadius=999, fill=v("color.brand.mark"))
    hole_d = round(size * 0.745)
    hole = frame("Logo hole", [core], width=hole_d, height=hole_d, cornerRadius=999, fill=v("color.surface.base"), layout="horizontal", alignItems="center", justifyContent="center")
    return frame("Logo mark", [hole], width=size, height=size, cornerRadius=999, fill=v("color.brand.mark"), layout="horizontal", alignItems="center", justifyContent="center")


def banner(kind, title, body, actions=()):
    warn = kind == "warning"
    kids = []
    if warn:
        kids.append(label("Important", "color.status.warning.fg", "type.caption"))
    kids += [text(title, "type.body", weight=600, lh=1.4), text(body, "type.caption", "color.text.secondary", lh=1.45)]
    if actions:
        links = [label(a[0], "color.action.primary.bg" if (len(a) < 2 or a[1] == "primary") else "color.text.secondary") for a in actions]
        kids.append(frame("Actions", links, layout="horizontal" if _scale[0] <= 1 else "vertical", gap=24 if _scale[0] <= 1 else 8, alignItems="center" if _scale[0] <= 1 else "flex-start", **sized(48), **pad()))
    return frame("Banner " + kind, kids, width="fill_container", fill=v("color.surface.raised"), cornerRadius=TK["scale"]["radius"]["md"], padding=16, layout="vertical", gap=8,
                 stroke=stroke("color.status.warning.fg") if warn else stroke("color.border.default"))


def entry_row(meta, body, first=False):
    return frame("Entry", [text(meta, "type.caption", "color.text.secondary", lh=1.4), text(body, "type.journal")],
                 width="fill_container", layout="vertical", gap=4, padding=16, stroke={"align": "inside", "thickness": {"bottom": 1}, "fill": v("color.border.default")})


def day_heading(txt):
    return text(txt, "type.caption", "color.text.secondary", weight=500, name="Day " + txt)


def top_bar(title=None, right=None, back=True):
    if _scale[0] > 1 and title:
        row = [frame("Back", [label("←", "color.text.primary", "type.title")], width=64, layout="horizontal", alignItems="center", **pad())] if back else []
        row.append(spacer(8) if False else frame("gap", [], width="fill_container", height=8))
        if right:
            row.append(label(right))
        return vstack("Top bar", [frame("Top row", row, width="fill_container", layout="horizontal", alignItems="center"), text(title, "type.body", "color.text.primary", weight=500, name="Title")], gap=8)
    kids = []
    if back:
        kids.append(frame("Back", [label("←", "color.text.primary", "type.title")], width=48, height=48, layout="horizontal", alignItems="center", justifyContent="center"))
    kids.append(text(title or "", "type.body", "color.text.primary", align="center" if back else None, weight=500, name="Title") if title else spacer(8))
    if right:
        kids.append(frame("Link " + right, [label(right)], width=72, height=48, layout="horizontal", alignItems="center", justifyContent="flex-end"))
    elif back:
        kids.append(frame("balance", [], width=48, height=48))
    return frame("Top bar", kids, width="fill_container", layout="horizontal", alignItems="center", **({"height": 48} if _scale[0] <= 1 else {}))


def setting_row(lab, value=None, chevron=True):
    used = (len(value) * 9 + 8 if value else 0) + (24 if chevron else 0)
    kids = [text(lab, "type.body", width=W - 2 * M - 32 - used)]
    if value:
        kids.append(label(value, "color.text.secondary", "type.body"))
    if chevron:
        kids.append(label(">", "color.text.secondary", "type.body"))
    return frame("Row " + lab, kids, width="fill_container", layout="horizontal", gap=8, alignItems="center", padding=16,
                 stroke={"align": "inside", "thickness": {"bottom": 1}, "fill": v("color.border.default")}, **({"height": 56} if _scale[0] <= 1 else {}))


def toggle_row(lab, on=True):
    track = frame("Switch " + ("on" if on else "off"), [frame("knob", [], width=24, height=24, cornerRadius=999, fill=v("color.surface.base"))], width=52, height=32, cornerRadius=999,
                  fill=v("color.action.primary.bg") if on else v("color.surface.raised"), stroke=None if on else stroke("color.border.strong", 2), layout="horizontal", padding=4,
                  alignItems="center", justifyContent="flex-end" if on else "flex-start")
    if track["stroke"] is None:
        del track["stroke"]
    return frame("Row " + lab, [text(lab, "type.body", width=W - 2 * M - 32 - 52 - 40 - 24), label("On" if on else "Off", "color.text.secondary", "type.body"), track], width="fill_container", layout="horizontal", gap=12,
                 alignItems="center", padding=16, stroke={"align": "inside", "thickness": {"bottom": 1}, "fill": v("color.border.default")}, **({"height": 56} if _scale[0] <= 1 else {}))


def radio_row(txt, selected, sub=None):
    ring = frame("Radio", [frame("dot", [], width=12, height=12, cornerRadius=999, fill=v("color.action.primary.bg"))] if selected else [], width=24, height=24, cornerRadius=999,
                 stroke=stroke("color.action.primary.bg" if selected else "color.border.strong", 2), layout="horizontal", alignItems="center", justifyContent="center")
    kids = [text(txt, "type.body", weight=500, width=W - 2 * M - 24 - 12 - 32)]
    if sub:
        kids.append(text(sub, "type.caption", "color.text.secondary", width=W - 2 * M - 24 - 12 - 32, lh=1.4))
    return frame("Option " + txt, [ring, frame("text", kids, layout="vertical", gap=4, width=W - 2 * M - 24 - 12 - 32)], width="fill_container", layout="horizontal", gap=12, alignItems="center", padding=16,
                 cornerRadius=TK["scale"]["radius"]["md"], stroke=stroke("color.action.primary.bg", 2) if selected else stroke("color.border.strong"), fill=v("color.surface.raised"))


def progress(caption, fraction):
    total = W - 2 * M
    bar = frame("Progress track", [frame("Progress fill", [], width=max(8, int(total * fraction)), height=8, cornerRadius=999, fill=v("color.action.primary.bg"))], width="fill_container", height=8,
                cornerRadius=999, fill=v("color.surface.raised"), stroke=stroke("color.border.strong"), layout="horizontal")
    return vstack("Progress", [bar, text(caption, "type.caption", "color.text.secondary", lh=1.4)], gap=8)


def skeleton(n=3):
    rows = []
    for _ in range(n):
        rows.append(vstack("Loading entry", [frame("bar", [], width=80, height=12, cornerRadius=6, fill=v("color.surface.raised")),
                                             frame("bar", [], width="fill_container", height=16, cornerRadius=6, fill=v("color.surface.raised")),
                                             frame("bar", [], width=240, height=16, cornerRadius=6, fill=v("color.surface.raised"))], gap=8, padding=16))
    return vstack("Loading list", rows, gap=8)


def empty_state(title, body, action=None):
    kids = [mark(), spacer(24), text(title, "type.title", align="center", lh=1.3), spacer(8), text(body, "type.body", "color.text.secondary", align="center")]
    if action:
        kids += [spacer(24), action]
    return vstack("Empty state", kids, gap=0, alignItems="center")


def card(kids):
    return frame("Card", kids, width="fill_container", fill=v("color.surface.raised"), cornerRadius=TK["scale"]["radius"]["md"], padding=20, layout="vertical", gap=12, stroke=stroke("color.border.default"))


def screen(name, children, center=False, pad_top=24):
    kw = {"alignItems": "center"} if center else {}
    return frame(name, [spacer(pad_top)] + children, width=W, height=H, fill=v("color.surface.base"), layout="vertical", padding=M, clip=True, **kw)


def with_sheet(name, base_children, sheet_children, sheet_height, dim=True):
    base = frame("Screen behind", [spacer(24)] + base_children, x=0, y=0, width=W, height=H, fill=v("color.surface.base"), layout="vertical", padding=M, clip=True)
    layers = [base]
    if dim:
        layers.append(frame("Scrim", [], x=0, y=0, width=W, height=H, fill=v("color.overlay.scrim"), opacity=0.5))
    layers.append(frame("Sheet", sheet_children, x=0, y=H - sheet_height + 20, width=W, height=sheet_height, fill=v("color.surface.raised"), cornerRadius=TK["scale"]["radius"]["lg"], padding=M,
                        layout="vertical", gap=12))
    return frame(name, layers, width=W, height=H, layout="none", clip=True)


def with_dialog(name, base_children, dialog_children):
    base = frame("Screen behind", [spacer(24)] + base_children, x=0, y=0, width=W, height=H, fill=v("color.surface.base"), layout="vertical", padding=M, clip=True)
    scrim = frame("Scrim", [], x=0, y=0, width=W, height=H, fill=v("color.overlay.scrim"), opacity=0.5)
    dlg = frame("Dialog", dialog_children, x=M, y=260, width=W - 2 * M, fill=v("color.surface.raised"), cornerRadius=TK["scale"]["radius"]["lg"], padding=M, layout="vertical", gap=12)
    return frame(name, [base, scrim, dlg], width=W, height=H, layout="none", clip=True)


# ------------------------------------------------------------------ document assembly
def document(mode, frames, cover_lines, cols=5):
    """Places captioned frames on a grid under a cover frame and returns the .pen document."""
    r = tl.resolve(TK, mode)
    variables = {tl.var_name(k): {"type": "color", "value": val} for k, val in r.items()}
    top = 440
    gx, gy = W + 60, H + 140
    placed = []
    for i, (fr, cap) in enumerate(frames):
        col, row = i % cols, i // cols
        fr["x"], fr["y"] = col * gx, top + row * gy
        placed.append({"type": "text", "id": nid("c"), "name": "Caption " + cap, "x": col * gx, "y": top + row * gy - 36, "content": cap, "fontFamily": "Inter", "fontSize": 16,
                       "fontWeight": "500", "fill": v("color.text.primary")})
        placed.append(fr)
    cover_kids = [text(cover_lines[0], "type.title", width=900)] + [text(l, "type.body", "color.text.secondary", width=900, lh=1.5) for l in cover_lines[1:]]
    cover = frame("Cover", cover_kids, x=0, y=0, width=960, fill=v("color.surface.base"), layout="vertical", gap=8, padding=24, stroke=stroke("color.border.default"))
    return {"version": "2.14", "variables": variables, "children": [cover] + placed}


def write(doc, path):
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        json.dump(doc, f, indent=2, ensure_ascii=False)
