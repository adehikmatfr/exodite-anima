# Sharing images

Images for posts, the repository social preview and logo use. Built by `make_social.py` (headless Chrome, the app fonts and colours from the design tokens).

| File in `out/` | Use |
|----------------|-----|
| `post-1-hero.png` to `post-4-open.png` | A four-image post, 1080 x 1350 (4:5) |
| `repo-banner.png` | GitHub social preview, 1280 x 640 |
| `logo-icon.png` | App icon, 1024 x 1024, rounded, on the brand green |
| `logo-mark-green.png`, `logo-mark-cream.png` | The mark alone on a transparent background (green for light backgrounds, cream for dark) |
| `logo-lockup-light.png`, `logo-lockup-dark.png` | Mark and name side by side |

`screens/` holds real screenshots of a **debug** build on an emulator with made-up entries. The release build blocks screenshots on purpose (`FLAG_SECURE`), so never take these from a release build or a phone with real entries. To refresh them, run a debug build, use the demo-mode status bar, and replace the files; then run `python make_social.py`.

Vector sources of the mark are in `../logo/`.
