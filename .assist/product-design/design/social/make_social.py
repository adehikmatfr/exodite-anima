#!/usr/bin/env python3
"""Builds the sharing images (logo pack, post slides, repository banner) from HTML with headless Chrome.

Run from this folder:  python make_social.py
Needs Chrome or Edge installed. Screens in screens/ are real screenshots of a debug build on an
emulator with made-up entries (release builds block screenshots on purpose).
Colours and fonts come from the design tokens (sage 600 #4F6F5E, warm 50 #FAF7F2, Inter, Lora).
"""
import os
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "src")
OUT = os.path.join(HERE, "out")
FONTS = "../../../../../app/assets/fonts"
CHROMES = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
]
SAGE, SAGE_D, SAGE_L, SAGE_950 = "#4F6F5E", "#3F5A4B", "#A6C4B3", "#14201A"
CREAM, CREAM_D = "#FAF7F2", "#EDE6DC"
INK, INK_SOFT = "#2A2622", "#6B6259"
NIGHT = "#1C1917"

BASE_CSS = f"""
@font-face {{ font-family: Inter; src: url({FONTS}/Inter.ttf); font-weight: 100 900; }}
@font-face {{ font-family: Lora; src: url({FONTS}/Lora.ttf); font-weight: 400 700; }}
* {{ box-sizing: border-box; margin: 0; padding: 0; }}
html, body {{ width: 100%; height: 100%; }}
body {{ font-family: Inter, sans-serif; overflow: hidden; }}
"""


def mark(color, size, core=None):
    core = core or color
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">'
            f'<circle cx="512" cy="512" r="322.56" fill="none" stroke="{color}" stroke-width="94.21"/>'
            f'<circle cx="512" cy="512" r="90.11" fill="{core}"/></svg>')


def icon(size):
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">'
            f'<rect width="1024" height="1024" rx="204.8" fill="{SAGE}"/>'
            f'<circle cx="512" cy="512" r="322.56" fill="none" stroke="{CREAM}" stroke-width="94.21"/>'
            f'<circle cx="512" cy="512" r="90.11" fill="{CREAM}"/></svg>')


def phone(img, width, style=""):
    """A phone with the status and navigation bars of the screenshot cropped away (1080x1920 source)."""
    bez = width * 0.03
    inner_w = width - 2 * bez
    inner_h = inner_w * 1731 / 1080
    top = -inner_w * 63 / 1080
    full_h = inner_w * 1920 / 1080
    return (f'<div style="position:relative;width:{width}px;padding:{bez}px;background:#141414;'
            f'border-radius:{width * 0.13}px;box-shadow:0 30px 60px rgba(0,0,0,.28),0 0 0 2px rgba(255,255,255,.14);{style}">'
            f'<div style="position:relative;width:{inner_w}px;height:{inner_h}px;overflow:hidden;'
            f'border-radius:{width * 0.105}px;background:#000">'
            f'<img src="../screens/{img}" style="position:absolute;left:0;top:{top}px;width:{inner_w}px;height:{full_h}px"></div></div>')


def page(name, w, h, body, css="", transparent=False):
    bg = "" if transparent else ""
    html = f"<!doctype html><html><head><meta charset='utf-8'><style>{BASE_CSS}{css}</style></head><body>{body}</body></html>"
    path = os.path.join(SRC, name + ".html")
    open(path, "w", encoding="utf-8").write(html)
    return (name, w, h, transparent)


def slides():
    out = []
    # 1 hero
    out.append(page("post-1-hero", 1080, 1350, f"""
<div style="position:absolute;inset:0;background:{SAGE}"></div>
<div style="position:absolute;left:80px;top:84px;display:flex;align-items:center;gap:22px">{mark(CREAM, 84)}
  <div style="color:{CREAM};font-size:34px;font-weight:600;letter-spacing:.2px">Exodite Anima</div></div>
<div style="position:absolute;left:80px;top:230px;width:900px;color:{CREAM};font-size:98px;line-height:1.04;font-weight:700;letter-spacing:-2px">A journal only you can read.</div>
<div style="position:absolute;left:80px;top:530px;width:800px;color:{SAGE_L};font-size:36px;line-height:1.35">Free. On your phone.<br>No account, no ads, no tracking.</div>
<div style="position:absolute;left:340px;top:700px">{phone("timeline-light.png", 520)}</div>
<div style="position:absolute;left:80px;top:740px;width:230px;color:{CREAM};font-size:24px;line-height:1.4;opacity:.85">Early version.<br>Android, in testing.<br>Open source.</div>
"""))
    # 2 nothing leaves
    out.append(page("post-2-private", 1080, 1350, f"""
<div style="position:absolute;inset:0;background:{CREAM}"></div>
<div style="position:absolute;left:80px;top:100px;width:920px;color:{INK};font-size:88px;line-height:1.05;font-weight:700;letter-spacing:-2px">Nothing leaves your phone.</div>
<div style="position:absolute;left:80px;top:330px;width:820px;color:{INK_SOFT};font-size:34px;line-height:1.4">The app does not even ask for internet permission. Your entries are encrypted on the device.</div>
<div style="position:absolute;left:70px;top:560px">{phone("welcome-light.png", 470)}</div>
<div style="position:absolute;left:560px;top:660px">{phone("settings-light.png", 470)}</div>
<div style="position:absolute;left:560px;top:560px;color:{SAGE};font-size:26px;font-weight:600;letter-spacing:.3px">YOU DECIDE WHEN IT LOCKS</div>
"""))
    # 3 lock
    out.append(page("post-3-lock", 1080, 1350, f"""
<div style="position:absolute;inset:0;background:{NIGHT}"></div>
<div style="position:absolute;left:80px;top:100px;width:920px;color:#F1ECE3;font-size:88px;line-height:1.05;font-weight:700;letter-spacing:-2px">Locked the moment you leave.</div>
<div style="position:absolute;left:80px;top:330px;width:840px;color:#B9AFA3;font-size:34px;line-height:1.4">Passcode, or face and fingerprint. Screenshots and the app switcher show nothing.</div>
<div style="position:absolute;left:70px;top:560px">{phone("lock-light.png", 470)}</div>
<div style="position:absolute;left:560px;top:660px">{phone("timeline-dark.png", 470)}</div>
<div style="position:absolute;left:560px;top:560px;color:{SAGE_L};font-size:26px;font-weight:600;letter-spacing:.3px">LIGHT AND DARK</div>
"""))
    # 4 open source
    out.append(page("post-4-open", 1080, 1350, f"""
<div style="position:absolute;inset:0;background:{SAGE}"></div>
<div style="position:absolute;left:80px;top:100px">{icon(150)}</div>
<div style="position:absolute;left:80px;top:320px;width:920px;color:{CREAM};font-size:88px;line-height:1.05;font-weight:700;letter-spacing:-2px">Open source.<br>Yours to keep.</div>
<div style="position:absolute;left:80px;top:590px;width:900px;color:{CREAM};font-size:42px;line-height:1.3">
  {"".join(f'<div style="display:flex;gap:28px;align-items:center;margin-bottom:34px"><span style="width:14px;height:14px;border-radius:50%;background:{SAGE_L};flex:none"></span><span>{s}</span></div>' for s in ["MIT licence, code and notes in the open", "Encrypted export and import you control", "English and Bahasa Indonesia", "Android first, in testing"])}</div>
<div style="position:absolute;left:80px;top:1010px;width:920px;color:{SAGE_L};font-size:32px;line-height:1.4">Not audited by an outside reviewer yet. Feedback and contributions are welcome.</div>
<div style="position:absolute;left:80px;top:1230px;color:{CREAM};font-size:30px;font-weight:600;letter-spacing:.4px">Exodite Anima</div>
"""))
    # banner for the repository social preview
    out.append(page("repo-banner", 1280, 640, f"""
<div style="position:absolute;inset:0;background:{SAGE}"></div>
<div style="position:absolute;left:90px;top:120px">{mark(CREAM, 150)}</div>
<div style="position:absolute;left:90px;top:320px;color:{CREAM};font-size:88px;font-weight:700;letter-spacing:-2px">Exodite Anima</div>
<div style="position:absolute;left:90px;top:440px;width:700px;color:{SAGE_L};font-size:38px;line-height:1.35">A journal only you can read. Free, private, on your phone.</div>
<div style="position:absolute;left:850px;top:70px">{phone("timeline-light.png", 330)}</div>
"""))
    return out


def logos():
    out = []
    out.append(page("logo-icon", 1024, 1024, f'<div style="position:absolute;inset:0">{icon(1024)}</div>', transparent=True))
    out.append(page("logo-mark-green", 1024, 1024, f'<div style="position:absolute;inset:0">{mark(SAGE, 1024)}</div>', transparent=True))
    out.append(page("logo-mark-cream", 1024, 1024, f'<div style="position:absolute;inset:0">{mark(CREAM, 1024)}</div>', transparent=True))
    lock = lambda m, c: (f'<div style="position:absolute;left:120px;top:120px;display:flex;align-items:center;gap:56px">{m}'
                         f'<div style="color:{c};font-size:170px;font-weight:700;letter-spacing:-4px;white-space:nowrap">Exodite Anima</div></div>')
    out.append(page("logo-lockup-light", 1660, 420, lock(mark(SAGE, 180), SAGE_950).replace("top:120px", "top:120px"), css=f"body{{background:{CREAM}}}"))
    out.append(page("logo-lockup-dark", 1660, 420, lock(mark(SAGE_L, 180), "#F1ECE3"), css=f"body{{background:{NIGHT}}}"))
    return out


def render(items):
    chrome = next((c for c in CHROMES if os.path.exists(c)), None)
    if not chrome:
        sys.exit("Chrome or Edge not found")
    os.makedirs(OUT, exist_ok=True)
    for name, w, h, transparent in items:
        png = os.path.join(OUT, name + ".png")
        args = [chrome, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                f"--window-size={w},{h}", f"--screenshot={png}", "--allow-file-access-from-files",
                "file:///" + os.path.join(SRC, name + ".html").replace("\\", "/")]
        if transparent:
            args.insert(2, "--default-background-color=00000000")
        subprocess.run(args, capture_output=True, timeout=120)
        print(name, os.path.getsize(png) if os.path.exists(png) else "FAILED")


if __name__ == "__main__":
    render(slides() + logos())
