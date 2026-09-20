"""Builds the component sheet (every component, every state) as .pen files, light and dark.

Usage: python gen_components.py <design dir>   (writes <design dir>/library/components-<mode>.pen)
"""
import os
import sys
import ui_kit as k
from ui_kit import (text, label, frame, spacer, button, field, search_field, checkbox_row, banner, entry_row, setting_row, toggle_row, radio_row, progress, skeleton, mark, vstack, card)


def cell(title, children, width=k.W):
    """One captioned sample on a neutral surface, width of a phone screen."""
    return frame("Sample " + title, [text(title, "type.caption", "color.text.secondary", lh=1.4)] + children, width=width, fill=k.v("color.surface.base"), layout="vertical", gap=12, padding=k.M,
                 stroke=k.stroke("color.border.default"))


def sheet():
    fr = []
    fr.append((cell("Button primary: default, pressed, disabled, loading",
                    [button("Continue"), button("Continue", state="pressed"), button("Continue", state="disabled"), button("Continue", state="loading")]), "Button primary"))
    fr.append((cell("Button secondary and danger", [button("Go back", "secondary"), button("Go back", "secondary", "pressed"), button("Delete entry", "danger"), button("Delete entry", "danger", "pressed"),
                                                   button("Delete entry", "danger", "disabled")]), "Button secondary and danger"))
    fr.append((cell("Text link: default and disabled", [button("Not now", "text"), button("Not now", "text", "disabled")]), "Text link"))
    fr.append((cell("Text field: default, focus, error, disabled", [
        field("Passcode", None, "Your passcode", secure=True), field("Passcode", "correct horse", secure=True, state="focus", trailing="Show"),
        field("Passcode", "123456", secure=True, state="error", error="This passcode is too easy to guess."), field("Passcode", None, "Your passcode", secure=True, state="disabled")]), "Text field"))
    fr.append((cell("Search field: default and focus", [search_field(), search_field("river", True)]), "Search field"))
    fr.append((cell("Checkbox row and toggle", [checkbox_row("I understand", False), checkbox_row("I understand", True), toggle_row("Face or fingerprint", True), toggle_row("Face or fingerprint", False)]),
                "Checkbox and toggle"))
    fr.append((cell("Option (radio)", [radio_row("Protected with a password", True, "Recommended"), radio_row("Readable by anyone", False, "Not protected")]), "Option"))
    fr.append((cell("Banner: info and warning", [banner("info", "Your journal has not been exported yet", "Export it so a lost phone doesn't mean lost memories.", [("Export now",), ("Later", "muted")]),
                                                banner("warning", "Keep your export password", "Without it the file cannot be opened.")]), "Banner"))
    fr.append((cell("Entry row and list row", [entry_row("9:12", "Walked by the river before work. It was quiet."), setting_row("Change passcode"), setting_row("Export your journal", "Last: 12 Sep 2026")]), "Rows"))
    fr.append((cell("Progress and loading skeleton", [progress("120 of 340 entries", 0.35), skeleton(2)]), "Progress and skeleton"))
    fr.append((cell("Card and logo placeholder", [card([text("Card content", "type.body")]), mark()]), "Card and logo"))
    return fr


if __name__ == "__main__":
    out = sys.argv[1]
    os.makedirs(f"{out}/library", exist_ok=True)
    cover = ["Component sheet - design library", "Status: draft, owner product-design. Design system: tokens 0.2.0. Every component is drawn in every state it has; hover is not drawn because the app is touch-first.",
             "Specs: docs/component-specs.md. Tokens: design/library/tokens.json. Changelog: 0.2 (2026-09-20) first component sheet."]
    for mode in ("light", "dark"):
        k._n[0] = 0
        k.write(k.document(mode, sheet(), cover, cols=4), f"{out}/library/components-{mode}.pen")
    print("ok")
