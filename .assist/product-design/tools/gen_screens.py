"""Builds every v1 screen with all its states as .pen files, light and dark, from design/library/tokens.json.

Usage: python gen_screens.py <design dir>      (writes <design dir>/features/<area>/<area>-<mode>.pen)
Areas: setup-and-lock (FEAT-003, FEAT-004), journal (FEAT-001, FEAT-002, FEAT-005, FEAT-008),
       backup-and-settings (FEAT-006, FEAT-007, FEAT-009).
Copy on screen is draft; sample numbers in it (counts, times, dates) are illustrative and use made-up content.
"""
import os
import sys
import ui_kit as k
from ui_kit import (text, label, frame, spacer, button, field, search_field, checkbox_row, bullet, mark, banner, entry_row, day_heading, top_bar, setting_row, toggle_row,
                    radio_row, progress, skeleton, empty_state, card, screen, with_sheet, with_dialog, hstack, vstack, set_scale)

SUB = "type.body"
MUTED = "color.text.secondary"


# ============================================================ setup and lock (FEAT-003, FEAT-004)
def s1(scale=1.0):
    set_scale(scale)
    f = screen("S1 Welcome / " + ("Large text" if scale > 1 else "Default"), [
        spacer(), mark(), spacer(32),
        text("A journal only you can read", "type.display"), spacer(16),
        text("Everything you write stays on this phone. Nothing is uploaded, ever.", SUB, MUTED), spacer(24),
        bullet("No account or sign-up"), spacer(12), bullet("No ads, no tracking"), spacer(12), bullet("Free, for good"),
        spacer(), button("Get started"), spacer(8), button("Import your journal", "text")])
    set_scale(1.0)
    return f


def s2(state):
    if state == "empty":
        f = [field("Passcode", None, "Choose a passcode", secure=True, trailing="Show"), spacer(16), field("Repeat passcode", None, "Type it again", secure=True), spacer(8),
             text("Use at least 8 characters. Choose something you will remember. It cannot be recovered.", "type.caption", MUTED, lh=1.4), spacer(),
             text("Enter and repeat your passcode to continue.", "type.caption", MUTED, align="center", lh=1.4), spacer(8), button("Continue", state="disabled")]
    elif state == "valid":
        f = [field("Passcode", "correct horse", state="default", secure=True, trailing="Show"), spacer(16), field("Repeat passcode", "correct horse", secure=True, state="focus"), spacer(8),
             text("Use at least 8 characters. Choose something you will remember. It cannot be recovered.", "type.caption", MUTED, lh=1.4), spacer(), button("Continue")]
    elif state == "shown":
        f = [field("Passcode", "correct horse", secure=True, show=True, trailing="Hide", state="focus"), spacer(16), field("Repeat passcode", None, "Type it again", secure=True), spacer(8),
             text("Use at least 8 characters. Choose something you will remember. It cannot be recovered.", "type.caption", MUTED, lh=1.4), spacer(), button("Continue", state="disabled")]
    elif state == "mismatch":
        f = [field("Passcode", "correct horse", secure=True, trailing="Show"), spacer(16),
             field("Repeat passcode", "correct hors", secure=True, state="error", error="The two passcodes are different. Type them again."), spacer(), button("Continue", state="disabled")]
    else:  # too easy
        f = [field("Passcode", "123456", secure=True, state="error", error="This passcode is too easy to guess. Try a longer or less common one.", trailing="Show"), spacer(16),
             field("Repeat passcode", None, "Type it again", secure=True), spacer(), button("Continue", state="disabled")]
    return screen("S2 Create passcode / " + state.capitalize(), [top_bar(), spacer(8), text("Create a passcode", "type.display", lh=1.3), spacer(8),
                                                                  text("You'll use it to open your journal when your face or fingerprint isn't available.", SUB, MUTED), spacer(24)] + f)


def s3(state):
    if state == "default":
        body = [spacer(), mark(), spacer(32), text("Open it with a glance or a touch", "type.display"), spacer(16),
                text("Use your face or fingerprint for quick access. Your passcode always works as a backup.", SUB, MUTED), spacer(), button("Turn on"), spacer(8), button("Not now", "text")]
    else:
        body = [spacer(), mark(), spacer(32), text("Face and fingerprint are not set up on this phone", "type.display"), spacer(16),
                text("You can still open your journal with your passcode. If you set up a face or fingerprint on your phone later, you can turn it on in Settings.", SUB, MUTED), spacer(), button("Continue")]
    return screen("S3 Biometrics / " + ("Available" if state == "default" else "Not available"), [top_bar()] + body)


def s4(checked):
    return screen("S4 No-recovery warning / " + ("Acknowledged" if checked else "Not acknowledged"), [
        top_bar(), spacer(8), text("If you forget your passcode, your journal is gone", "type.display", lh=1.3), spacer(24),
        card([label("Important", "color.status.warning.fg", "type.caption"),
              text("Nobody can reset your passcode, including us. We never have your data.", SUB),
              text("Export your journal from time to time to keep a backup you control.", SUB)]),
        spacer(24), checkbox_row("I understand that a forgotten passcode can't be recovered", checked), spacer(),
        (text("Tick the box to continue.", "type.caption", MUTED, align="center", lh=1.4) if not checked else spacer(8)), spacer(8),
        button("Start journaling", state="default" if checked else "disabled")])


def s5(state, scale=1.0):
    set_scale(scale)
    if state == "switcher":
        f = screen("S5 Lock / App switcher preview", [spacer(), mark(96), spacer()], center=True)
        set_scale(1.0)
        return f
    kids = [spacer(), mark(), spacer(24), text("Enter your passcode", "type.title", align="center", lh=1.3), spacer(24)]
    if state == "default":
        kids += [field("Passcode", None, "Your passcode", secure=True, state="focus"), spacer(16), button("Unlock"), spacer(8), button("Use face or fingerprint", "text")]
        cap = "Default"
    elif state == "wrong":
        kids += [field("Passcode", "wrongcode", secure=True, state="error", error="That passcode is not right. Try again."), spacer(16), button("Unlock"), spacer(8), button("Use face or fingerprint", "text")]
        cap = "Wrong passcode"
    elif state == "wait":
        kids += [field("Passcode", None, "Your passcode", secure=True, state="disabled", helper="Too many tries. You can try again in 0:30."), spacer(16), button("Unlock", state="disabled")]
        cap = "Waiting after wrong tries"
    else:
        kids += [field("Passcode", None, "Your passcode", secure=True, state="focus"), spacer(16), button("Unlock"), spacer(8), button("Use face or fingerprint", "text")]
        cap = "Large text"
    kids.append(spacer())
    f = screen("S5 Lock / " + cap, kids, center=True)
    set_scale(1.0)
    return f


def s14():
    return screen("S14 Journal cannot be opened / Error", [spacer(), mark(), spacer(24), text("Your journal could not be opened", "type.title", align="center", lh=1.3), spacer(12),
                                                            text("Nothing has been deleted. Try again. If it keeps happening, import an export if you have one.", SUB, MUTED, align="center"), spacer(24),
                                                            button("Try again"), spacer(8), button("Import your journal", "secondary"), spacer()], center=True)


def setup_and_lock():
    fr = [(s1(), "S1 Welcome / Default"), (s1(2.0), "S1 Welcome / Large text 200%")]
    fr += [(s2(s), f"S2 Create passcode / {s}") for s in ["empty", "valid", "shown", "mismatch", "easy"]]
    fr += [(s3("default"), "S3 Biometrics / Available"), (s3("na"), "S3 Biometrics / Not available")]
    fr += [(s4(False), "S4 Warning / Not acknowledged"), (s4(True), "S4 Warning / Acknowledged")]
    fr += [(s5("default"), "S5 Lock / Default"), (s5("wrong"), "S5 Lock / Wrong passcode"), (s5("wait"), "S5 Lock / Waiting"), (s5("switcher"), "S5 Lock / App switcher preview"),
           (s5("large", 2.0), "S5 Lock / Large text 200%"), (s14(), "S14 Journal cannot be opened")]
    cover = ["Setup and lock - FEAT-003, FEAT-004", "Status: draft, owner product-design. Design system: tokens 0.2.0. Related: FEAT-003, FEAT-004, ADR-001, THR-001, THR-004, THR-007, THR-011.",
             "Screens: S1 Welcome, S2 Create passcode, S3 Biometrics, S4 No-recovery warning, S5 Lock, S14 Journal cannot be opened. Every state is drawn; S1 and S5 also at 200 percent text.",
             "Notes: copy is draft and drawn in English; Indonesian copy is drafted separately and reviewed by the owner (layouts wrap for text about 40 percent longer). Rules shown come from the owner's decisions of 2026-09-20 (lock-and-passcode-policy). Vocabulary follows the glossary (Export, Import) until RS-001 decides.",
             "Restore on a fresh install: passcode setup first, then import (decided 2026-09-20).",
             "Changelog: 0.2 (2026-09-20) rebuilt from tokens with all states; 0.1 first draft."]
    return fr, cover


# ============================================================ journal (FEAT-001, 002, 005, 008)
ENTRIES = [("Today", [("9:12", "Walked by the river before work. It was quiet, and I kept thinking about standing still."), ("7:40", "Coffee, a slow start. Decided to write a little every morning again.")]),
           ("Yesterday", [("21:05", "Long call with my sister. We laughed about the old house.")]),
           ("Thu, 18 Sep", [("18:30", "Rain all afternoon. Read for two hours.")])]


def entries_list(n_days=3):
    kids = []
    for day, rows in ENTRIES[:n_days]:
        kids.append(day_heading(day))
        kids += [entry_row(m, b) for m, b in rows]
        kids.append(spacer(8))
    return frame("Entry list", kids, width="fill_container", height="fill_container", layout="vertical", clip=True)


def new_entry_bar():
    pill = frame("Button New entry", [label("+  New entry", "color.action.primary.fg")], **({"width": 176} if k._scale[0] <= 1 else {}), cornerRadius=999, fill=k.v("color.action.primary.bg"), layout="horizontal", alignItems="center",
                 justifyContent="center", **k.sized(52), **k.pad())
    return frame("Bottom bar", [pill], width="fill_container", layout="horizontal", alignItems="center", justifyContent="center", **({"height": 76} if k._scale[0] <= 1 else {"padding": 8}))


REMINDER = lambda: banner("info", "Your journal has not been exported yet", "Export it so a lost phone doesn't mean lost memories.", [("Export now",), ("Later", "muted")])


def header():
    if k._scale[0] > 1:
        return vstack("Header", [text("Journal", "type.title", lh=1.3), text("Settings", "type.label", "color.action.primary.bg")], gap=8)
    return frame("Header", [text("Journal", "type.title", lh=1.3), frame("Link Settings", [label("Settings")], width=88, layout="horizontal", alignItems="center", justifyContent="flex-end", **k.sized(48), **k.pad())],
                 width="fill_container", layout="horizontal", alignItems="center", **({"height": 48} if k._scale[0] <= 1 else {}))


def s6(state, scale=1.0):
    set_scale(scale)
    if state == "empty":
        f = screen("S6 Timeline / Empty (first use)", [header(), spacer(), empty_state("Nothing here yet", "Write your first entry. It stays on this phone.", button("Write your first entry")), spacer()], center=True)
    elif state == "loading":
        f = screen("S6 Timeline / Loading", [header(), spacer(12), search_field(), spacer(16), skeleton(3), spacer(), text("Opening your journal...", "type.caption", MUTED, align="center", lh=1.4)])
    elif state == "banner":
        f = screen("S6 Timeline / With reminder", [header(), spacer(12), search_field(), spacer(16), REMINDER(), spacer(12), entries_list(2), new_entry_bar()])
    elif state == "large":
        f = screen("S6 Timeline / Large text", [header(), spacer(12), search_field(), spacer(16), entries_list(1), new_entry_bar()])
    else:
        f = screen("S6 Timeline / Entries", [header(), spacer(12), search_field(), spacer(16), entries_list(3), new_entry_bar()])
    set_scale(1.0)
    return f


LONG = ["Walked by the river before work. It was quiet, and I kept thinking about how long it has been since I just stood still.",
        "There was a heron on the far bank. It did not move for a long time, and neither did I.",
        "I want more mornings like this one. Maybe I can leave the phone in my bag and only bring a notebook, but then I would lose the search.",
        "On the way back I passed the bakery and the smell of bread nearly made me late. I would not change it.",
        "Notes for later: call Ana, renew the library card, water the plants, and write down the name of the song from the radio."]


def editor_body(kind, scale=1.0):
    bar = top_bar("Sat, 20 Sep 2026", "Save")
    status = text("Draft kept safely on this phone", "type.caption", MUTED, align="center", lh=1.4)
    if kind == "new":
        body = [text("Write what's on your mind", "type.journal", MUTED)]
        bottom = spacer(48)
    else:
        paras = LONG[:3] if kind != "long" else LONG
        body = [text(p, "type.journal") for p in paras]
        bottom = frame("Bottom row", [label("Delete entry", "color.status.danger.fg")], width="fill_container", layout="horizontal", alignItems="center", **k.sized(48), **k.pad())
    kids = [bar, status, spacer(16), frame("Entry text", body, width="fill_container", height="fill_container", layout="vertical", gap=16, clip=True), bottom]
    return kids


def s7(state, scale=1.0):
    set_scale(scale)
    if state in ("new", "edit", "long"):
        names = {"new": "New entry", "edit": "Editing", "long": "Long entry (scrolls)"}
        f = screen("S7 Editor / " + names[state], editor_body(state))
    elif state == "delete":
        f = with_sheet("S7 Editor / Delete confirmation", editor_body("edit"), [
            text("Delete this entry?", "type.title", lh=1.3), text("This cannot be undone. The entry is removed from search and from future exports.", "type.body", MUTED), spacer(8),
            button("Delete entry", "danger"), button("Cancel", "text")], 340)
    elif state == "resume":
        f = with_dialog("S7 Editor / Resume unsaved draft", editor_body("new"), [
            text("Continue your unsaved entry?", "type.title", lh=1.3), text("The app closed before you saved. Your text is still here.", "type.body", MUTED), spacer(8),
            button("Continue writing"), button("Discard draft", "secondary")])
    elif state == "error":
        body = editor_body("edit")
        body.insert(2, banner("warning", "Couldn't save your entry", "Your phone is almost out of space. Your text is kept. Free some space, then try again.", [("Try again",)]))
        f = screen("S7 Editor / Save error", body)
    else:
        f = screen("S7 Editor / Large text", editor_body("edit"))
    set_scale(1.0)
    return f


def s8(state):
    head = hstack("Search bar", [frame("Back", [label("←", "color.text.primary", "type.title")], width=48, height=48, layout="horizontal", alignItems="center", justifyContent="center"),
                                 search_field("river" if state != "empty" else None, True) if state != "none" else search_field("kite", True)], gap=4)
    if state == "empty":
        body = [spacer(48), text("Type a word you remember.", SUB, MUTED, align="center"), spacer()]
        cap = "Empty query"
    elif state == "none":
        body = [spacer(48), text("No entries contain \"kite\".", "type.title", align="center", lh=1.3), spacer(8), text("Try another word, or part of a word.", SUB, MUTED, align="center"), spacer()]
        cap = "No results"
    else:
        body = [text("2 entries", "type.caption", MUTED, lh=1.4), spacer(8), entry_row("Today, 9:12  -  matched: river", ENTRIES[0][1][0][1]),
                entry_row("Sun, 7 Sep  -  matched: river", "The river was high after the storm and the path was closed, so I took the long way round."), spacer()]
        cap = "Results"
    return screen("S8 Search / " + cap, [head, spacer(16)] + body)


def journal():
    fr = [(s6("entries"), "S6 Timeline / Entries"), (s6("banner"), "S6 Timeline / With reminder"), (s6("empty"), "S6 Timeline / Empty (first use)"), (s6("loading"), "S6 Timeline / Loading"),
          (s6("large", 2.0), "S6 Timeline / Large text 200%")]
    fr += [(s7("new"), "S7 Editor / New entry"), (s7("edit"), "S7 Editor / Editing"), (s7("long"), "S7 Editor / Long entry"), (s7("delete"), "S7 Editor / Delete confirmation"),
           (s7("resume"), "S7 Editor / Resume unsaved draft"), (s7("error"), "S7 Editor / Save error"), (s7("large", 2.0), "S7 Editor / Large text 200%")]
    fr += [(s8("empty"), "S8 Search / Empty query"), (s8("results"), "S8 Search / Results"), (s8("none"), "S8 Search / No results")]
    cover = ["Journal - FEAT-001, FEAT-002, FEAT-005, FEAT-008", "Status: draft, owner product-design. Design system: tokens 0.2.0. Related: FEAT-001, FEAT-002, FEAT-005, FEAT-008, ADR-002, THR-005.",
             "Screens: S6 Timeline, S7 Editor, S8 Search. Every state is drawn; S6 and S7 also at 200 percent text. Entry text uses the journal font (Lora); previews fall back to another font in OpenPencil.",
             "Notes: all entry text is made up. The \"Save\" action and the draft indicator are tested in RS-001 for confusion (ux-design review finding 7). Search highlights are shown as a matched-word note because inline highlight is not drawable here.",
             "Changelog: 0.2 (2026-09-20) rebuilt from tokens with all states; 0.1 first draft."]
    return fr, cover


# ============================================================ backup and settings (FEAT-006, 007, 009)
def titled(name, title, body, kids):
    return screen(name, [top_bar(), spacer(8), text(title, "type.title", lh=1.3), spacer(8), text(body, SUB, MUTED), spacer(24)] + kids)


def s9_children():
    return [top_bar("Settings"), spacer(8), day_heading("Appearance"), setting_row("Theme", "Match phone"), setting_row("Language", "Match phone"), spacer(16), day_heading("Security"),
            setting_row("Change passcode"), toggle_row("Face or fingerprint", True), setting_row("Lock when I leave the app", "Immediately", True), spacer(16),
            day_heading("Backup"), setting_row("Export your journal", "Last: 12 Sep 2026"), setting_row("Import your journal"), spacer(16), day_heading("About"),
            setting_row("About and privacy"), spacer()]


def s9():
    return screen("S9 Settings / Default", s9_children())


def s9_sheet(kind):
    if kind == "language":
        title, opts = "Language", [("Match phone", True, "Uses English unless your phone is set to Indonesian"), ("English", False, None), ("Bahasa Indonesia", False, None)]
    else:
        title, opts = "Lock when I leave the app", [("Immediately", True, "Recommended"), ("After 1 minute", False, None), ("After 5 minutes", False, None), ("After 15 minutes", False, None)]
    kids = [text(title, "type.title", lh=1.3)] + [radio_row(o, sel, sub) for o, sel, sub in opts] + [button("Cancel", "text")]
    height = 120 + 88 * len(opts)
    return with_sheet(f"S9 Settings / {title} choice", s9_children(), kids, height)


def s10(state):
    if state == "default":
        fields = [field("Current passcode", None, "Your current passcode", secure=True, state="focus"), spacer(16), field("New passcode", None, "Choose a new passcode", secure=True, helper="Use at least 8 characters."), spacer(16),
                  field("Repeat new passcode", None, "Type it again", secure=True), spacer(), button("Change passcode", state="disabled")]
        cap = "Default"
    elif state == "wrong":
        fields = [field("Current passcode", "oldpass1", secure=True, state="error", error="That is not your current passcode."), spacer(16), field("New passcode", "newpass22", secure=True), spacer(16),
                  field("Repeat new passcode", "newpass22", secure=True), spacer(), button("Change passcode")]
        cap = "Wrong current passcode"
    elif state == "mismatch":
        fields = [field("Current passcode", "oldpass1", secure=True), spacer(16), field("New passcode", "newpass22", secure=True), spacer(16),
                  field("Repeat new passcode", "newpass2", secure=True, state="error", error="The two passcodes are different. Type them again."), spacer(), button("Change passcode", state="disabled")]
        cap = "Passcodes differ"
    else:
        fields = [banner("info", "Passcode changed", "Your journal opens with the new passcode from now on. Your entries are unchanged."), spacer(), button("Done")]
        cap = "Done"
    return screen("S10 Change passcode / " + cap, [top_bar("Change passcode"), spacer(16)] + fields)


def s11(state):
    if state == "choose":
        return titled("S11 Export / Choose", "Export your journal", "Save a copy of everything you have written. You can bring it back on this phone or a new one.", [
            radio_row("Protected with a password", True, "Recommended. Only someone with the password can open it."), spacer(12),
            radio_row("Readable by anyone", False, "Not protected. Anyone who gets the file can read your entries."), spacer(), button("Continue")])
    if state == "password":
        return titled("S11 Export / Set password", "Choose an export password", "This is not your passcode. You need it to open the export, and it cannot be recovered.", [
            field("Export password", "river-stone-9", secure=True, trailing="Show", state="focus"), spacer(16), field("Repeat export password", None, "Type it again", secure=True), spacer(8),
            text("Use at least 8 characters. Keep it somewhere safe, apart from the file.", "type.caption", MUTED, lh=1.4), spacer(), button("Export", state="disabled")])
    if state == "warn":
        return with_sheet("S11 Export / Readable-by-anyone warning", [top_bar(), spacer(8), text("Export your journal", "type.title", lh=1.3), spacer()], [
            label("Important", "color.status.warning.fg", "type.caption"), text("Anyone who gets this file can read your journal.", "type.title", lh=1.3),
            text("Only choose this if you will keep the file somewhere safe. You can still choose a password instead.", SUB, MUTED), spacer(8), button("Export without protection", "danger"),
            button("Go back", "secondary")], 380)
    if state == "progress":
        return screen("S11 Export / Working", [spacer(), text("Preparing your export", "type.title", align="center", lh=1.3), spacer(8),
                                               text("Keep the app open. This can take a moment for a large journal.", SUB, MUTED, align="center"), spacer(24), progress("120 of 340 entries", 0.35), spacer(24),
                                               button("Cancel", "text"), spacer()])
    if state == "done":
        return screen("S11 Export / Done", [spacer(), mark(), spacer(24), text("Your export is ready", "type.title", align="center", lh=1.3), spacer(8),
                                            text("Choose where to save it on the next screen. Last export: today.", SUB, MUTED, align="center"), spacer(16),
                                            banner("warning", "Keep your export password", "Without it the file cannot be opened."), spacer(), button("Done")], center=True)
    return screen("S11 Export / Error", [spacer(), mark(), spacer(24), text("The export could not be saved", "type.title", align="center", lh=1.3), spacer(8),
                                         text("Your phone may be low on space. Nothing was changed. Free some space and try again.", SUB, MUTED, align="center"), spacer(24), button("Try again"), spacer(8),
                                         button("Cancel", "text"), spacer()], center=True)


def s12(state):
    if state == "pick":
        return titled("S12 Import / Choose file", "Import your journal", "Choose an export made by this app. Entries already on this phone are kept.", [spacer(), button("Choose a file")])
    if state == "password":
        return titled("S12 Import / Password", "Enter the export password", "This export is protected. Use the password you chose when you made it.", [
            field("Export password", None, "Export password", secure=True, trailing="Show", state="focus"), spacer(), button("Import", state="disabled")])
    if state == "wrong":
        return titled("S12 Import / Wrong password", "Enter the export password", "This export is protected. Use the password you chose when you made it.", [
            field("Export password", "river-stone", secure=True, state="error", error="That password does not open this export. Nothing was changed."), spacer(), button("Import")])
    if state == "progress":
        return screen("S12 Import / Working", [spacer(), text("Importing your journal", "type.title", align="center", lh=1.3), spacer(8),
                                               text("Keep the app open. Your journal only changes when everything is ready.", SUB, MUTED, align="center"), spacer(24), progress("200 of 316 entries checked", 0.63),
                                               spacer(), button("Cancel", "text")])
    if state == "result":
        return screen("S12 Import / Result", [spacer(), mark(), spacer(24), text("Your journal is back", "type.title", align="center", lh=1.3), spacer(8),
                                              text("312 entries added. 4 were already on this phone.", SUB, MUTED, align="center"), spacer(), button("Open my journal")], center=True)
    errs = {"damaged": ("This file is damaged", "It could not be read, so nothing was imported. Try another export."),
            "newer": ("This export needs a newer version of the app", "Update the app, then try again. Nothing was changed."),
            "wrongfile": ("This is not an export from this app", "Choose the file you saved when you exported your journal.")}
    t, b = errs[state]
    return screen("S12 Import / Error " + state, [spacer(), mark(), spacer(24), text(t, "type.title", align="center", lh=1.3), spacer(8), text(b, SUB, MUTED, align="center"), spacer(24),
                                                  button("Choose another file"), spacer(8), button("Cancel", "text"), spacer()], center=True)


def s13():
    pts = ["Nothing you write is uploaded or shared by the app.", "There is no account, no ads, and no tracking.", "The only way your writing leaves this phone is an export you choose to make.",
           "If you forget your passcode, your journal cannot be recovered."]
    return screen("S13 About and privacy / Default", [top_bar("About and privacy"), spacer(8), text("Your journal stays on this phone", "type.title", lh=1.3), spacer(16)] +
                  sum([[bullet(p), spacer(12)] for p in pts], []) + [spacer()])


def backup_and_settings():
    fr = [(s9(), "S9 Settings / Default"), (s9_sheet("language"), "S9 Settings / Language choice"), (s9_sheet("timeout"), "S9 Settings / Lock timeout choice")]
    fr += [(s10(s), f"S10 Change passcode / {s}") for s in ["default", "wrong", "mismatch", "done"]]
    fr += [(s11(s), f"S11 Export / {s}") for s in ["choose", "password", "warn", "progress", "done", "error"]]
    fr += [(s12(s), f"S12 Import / {s}") for s in ["pick", "password", "wrong", "progress", "result", "damaged", "newer", "wrongfile"]]
    fr += [(s13(), "S13 About and privacy")]
    cover = ["Backup and settings - FEAT-006, FEAT-007, FEAT-009", "Status: draft, owner product-design. Design system: tokens 0.2.0. Related: FEAT-006, FEAT-007, FEAT-009, ADR-003, THR-006, THR-008, RISK-001, RISK-002.",
             "Screens: S9 Settings (with the language and lock timeout choices), S10 Change passcode, S11 Export, S12 Import, S13 About and privacy. Every state is drawn.",
             "Notes: counts and dates are illustrative; lock timeout choices and password rules come from the owner's decisions of 2026-09-20. Drawn in English; Indonesian copy is reviewed by the owner. The privacy statement must trace to controls and tests (TC-081).",
             "Changelog: 0.2 (2026-09-20) rebuilt from tokens with all states; 0.1 did not exist for these screens."]
    return fr, cover


AREAS = {"setup-and-lock": setup_and_lock, "journal": journal, "backup-and-settings": backup_and_settings}

if __name__ == "__main__":
    out = sys.argv[1]
    for area, fn in AREAS.items():
        for mode in ("light", "dark"):
            k._n[0] = 0
            frames, cover = fn()
            os.makedirs(f"{out}/features/{area}", exist_ok=True)
            k.write(k.document(mode, frames, cover), f"{out}/features/{area}/{area}-{mode}.pen")
    print("ok")
