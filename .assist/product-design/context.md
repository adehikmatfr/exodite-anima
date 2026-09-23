# Product Design Context: exodite-anima

Project identity and shared rules live in `../_shared/project.md`. This file holds only product-design facts. It overrides the parent `context.md`.

## Product and Audience

- A free, fully private journaling app: everything stays on the phone; no account, cloud, or tracking.
- Users write text entries, search them, lock the app, and export and import their journal to move phones.
- Primary audience (hypothesis, no evidence yet): people who want a private journal without paying and without trusting a company. Context of use: phone, often one-handed, often at night.
- Languages and scripts: English and Indonesian, switchable in Settings (decided 2026-09-20); both left-to-right, so no RTL layouts.
- Related `FEAT-`: FEAT-001 to FEAT-009.

## Design System

| Item | Value |
|------|-------|
| Design-system name and version | exodite-anima tokens 0.2.0 (`design/library/tokens.json`); changelog in `docs/design-tokens.md` |
| Design library location | `design/library/` (tokens and the component sheet as `.pen` files) |
| Code component library | Flutter theme and widgets in `app/lib/theme/` and `app/lib/widgets/` (tokens copied by hand; `AppIcons` for icons, `LogoMark` for the mark) |
| Token source of truth | `design/library/tokens.json` in the repository; the `.pen` variables and `docs/design-tokens.md` are generated from it; the Flutter theme must match it |
| Token export pipeline | `tools/gen_docs.py` and the generators; no Flutter export yet (a Dart theme file is to be generated or hand-checked by frontend-mobile) |
| System owner and change process | product-design owns it; changes follow `design-system-governance` and the change process in `docs/design-tokens.md` |

## Tools

| Purpose | Tool |
|---------|------|
| Interface design | OpenPencil `.pen` files, written by generators (`tools/`); the owner opens them to verify |
| Prototyping | none (static frames only) |
| Handoff and inspection | `docs/screen-specs.md`, `docs/component-specs.md`, and the `.pen` files |
| Contrast and accessibility checks | `tools/tokens_lib.py` computes WCAG contrast for 17 token pairs; no colour-blindness simulator yet |
| Asset management | `docs/asset-register.md` |
| Preview rendering | `openpencil export` (CLI 0.15.1, patched for Windows, see `../_shared/project.md`); it ignores per-frame themes, so light and dark are separate files |

## Accessibility Target and Platforms

| Item | Value |
|------|-------|
| Accessibility target | WCAG 2.2 AA; the compliance matrix lists it as adopted, not a legal requirement |
| Platforms | iOS and Android phones; minimum OS versions pending (`platforms-and-languages`) |
| Breakpoints | compact only (390 x 844 design frame); tablets and landscape not designed |
| Input modes | touch; screen reader (VoiceOver, TalkBack); keyboard or switch access through the focus state |
| Themes | light and dark; default follows the phone; high contrast not designed (open question) |

## Brand Guidelines

Location: none. Owner: project owner. Logo: option A2, a ring with a core in the brand green, chosen by the owner on 2026-09-20 (`design/logo/`, `docs/asset-register.md`). Tone of voice: calm, plain, second person, sentences that say what happened and what to do next; no jargon; no exclamation marks. Non-negotiable brand rules: never claim more privacy than is built (`../_shared/project.md`, principle 4); never use fear or guilt to prompt an export.

## Type Scale

| Role | Font | Size / line height | Weight |
|------|------|--------------------|--------|
| `type.display` | Inter | 28 / 36 | 600 |
| `type.title` | Inter | 22 / 30 | 600 |
| `type.body` | Inter | 16 / 24 | 400 |
| `type.label` | Inter | 15 / 20 | 600 |
| `type.caption` | Inter | 13 / 18 | 400 |
| `type.journal` | Lora | 17 / 28 | 400 |

Body text minimum 16 px. Both fonts are under the SIL Open Font License (`docs/asset-register.md`). Previews substitute Lora and show Inter in one weight; the app implements the tokens as written.

## Colour System

| Group | Tokens | Notes |
|-------|--------|-------|
| Brand | `color.brand.mark`, `color.action.primary.*` | one soft green accent; used for actions and the logo placeholder |
| Neutral | `color.surface.*`, `color.text.*`, `color.border.*` | warm neutral ramp; `border.strong` for controls |
| Status | `color.status.danger.*`, `color.status.warning.fg` | always paired with an icon and words |
| Data visualisation | none | no charts in version 1 |

Verified contrast pairs and modes: `docs/design-tokens.md` (computed). Last audit date: 2026-09-20.

## Icon and Illustration Library

| Item | Value |
|------|-------|
| Icon set, grid and stroke | Lucide (24 px grid, 2 px stroke), chosen 2026-09-20 to replace Flutter's Material Icons; 8 icons in `app/lib/theme/app_icons.dart` |
| Illustration style and library | none; the logo placeholder only |
| Licences | see `docs/asset-register.md` |
| Request process for new assets | register in the asset register before use |

## Motion Principles

Motion confirms an action or shows progress; it never decorates. Durations 100 to 300 ms (`duration.*` tokens), fades and slides only, and everything stops under the system "reduce motion" setting. Motion tokens: `design/library/tokens.json`.

## Component Coverage Status

| Component or pattern | Design | Code | States complete | Owner | Notes |
|----------------------|--------|------|-----------------|-------|-------|
| Button, text field, search field | draft | built | yes | product-design | `docs/component-specs.md` |
| Checkbox row, switch, option | draft | built | yes | product-design | |
| Banner, rows, sheet, dialog | draft | built | yes | product-design | |
| Progress, skeleton, empty state | draft | built (progress is not determinate) | yes | product-design | |
| Logo | A2 chosen | built | n/a | product-design | waits for the app name |

## Review Cadence

| Activity | Cadence | Participants |
|----------|---------|--------------|
| Design critique | per design change | product-design, project owner |
| Design QA on built UI | per release | product-design, frontend-mobile, qa |
| Accessibility and contrast audit | each token change and each release | product-design, qa |
| Design-system governance review | when a token or component changes | product-design |

## Known Gaps

- No user evidence: the design is a hypothesis until RS-001 runs.
- No high-contrast theme, no tablet layouts (RTL is not needed for the two languages).
- Logo is a placeholder (waits for a final logo; the name is decided).
- The owner tried the built app on a phone (reported as smooth); the `.pen` files were not reviewed again in OpenPencil after the rebuild, and no independent accessibility check exists.
- Indonesian copy is not written; a copy deck in both languages needs the owner's review. Screens are drawn in English only.
- Feasibility is proven by the built app (all screens exist), but the built screens were not compared against the `.pen` previews one by one.
- FEAT-010 (mood, tags, "On this day"): S6 and S7 specs updated 2026-09-23 with the new states, accessible names, and AC rows (`docs/screen-specs.md`). Correction, same day: the `.pen` files were initially left un-regenerated while frontend-mobile built the "On this day" card in code, which is out of the gate order (G2 needs a visual the owner can actually see before G4 build, not just spec text) - caught by the owner. Fixed: `tools/gen_screens.py` now draws "S6 Timeline / With On this day" (`design/features/journal/journal-*.pen`, changelog 0.3), self-checked by rendering both themes to PNG in the scratchpad (not saved in the repo; shown inline to the owner in this session). Reviewed and approved by the owner 2026-09-23 (both themes). S7 "Mood and tags" drawn the same day (changelog 0.4): mood shown as a filled/outlined circle (this tool draws no font-icon glyphs) with its mandatory text label, and tag chips (preset plus one free-text example) wrapped across rows by an estimated width, not real text measurement. Self-checked by rendering both themes; awaiting the owner's look before this counts as reviewed. Neither the schema nor the editor code exists yet. Update: the owner approved it, and the schema, repository, and editor UI were built the same day. S6 "With mood and tags" drawn next (changelog 0.5), design-first again: a mood dot plus label, and read-only outlined tag chips, on one entry; a second entry with neither. Self-checked by rendering both themes; owner approved it ("next"), and the matching timeline code (`TimelinePage`'s `_EntryMeta`) was built the same day. No widget or emulator test of `TimelinePage` exists yet.
- FEAT-011 (Photos): design-first, before any code, matching the corrected order above. Drew S7 "With photos" (a thumbnail row, one with a caption, one without, plus an "Add photo" button; changelog 0.6) and a new screen, S15 Photo viewer (full-size photo with its caption and a Remove action, plus the remove-confirmation state). Thumbnails and the full photo are placeholder squares, since this tool draws no real image content. Self-checked by rendering both themes to PNG. Awaiting the owner's review before the schema and any code is built.
