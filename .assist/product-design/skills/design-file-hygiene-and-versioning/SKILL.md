---
name: design-file-hygiene-and-versioning
description: Use when starting a design project, when files are hard to find or duplicated, when preparing a hand-off freeze, or when archiving finished work or checking the licence of fonts, icons and images.
---
# Design File Hygiene and Versioning

## Purpose

Keep design files findable, consistent and traceable so there is one source of truth, reviews are safe, and assets are legally usable.

## When to use

- Setting up a workspace or a new feature file.
- Before review, hand-off or release (freeze and tag).
- Cleaning up copies, "final_v2" files and orphaned pages.
- Adding fonts, icons, photos or third-party kits.

## Principles

- **One source of truth.** Libraries hold shared components and tokens; feature files consume them, never fork them.
- **Names carry meaning.** A stranger can find the file, its `FEAT-NNN` and its status in under 1 minute.
- **Versions are explicit.** Named checkpoints, not filename suffixes.
- **Nothing sensitive in files.** Synthetic data only; access is least-privilege (`_shared/standards/data-governance.md`).
- **Every asset has a licence on record.**

## Steps / Checklist

Structure and naming
- [ ] Workspace layout: `Libraries/` (design system, icons), `Features/<area>/`, `Research/`, `Archive/`, `Sandbox/` (personal, not referenced).
- [ ] File name: `<area> - FEAT-NNN - <short title>`; pages: `Cover`, `Flows`, `Screens`, `Components (local)`, `Handoff`, `Archive`; page status on the cover (draft / in review / approved / handed off).
- [ ] Layers and frames named by purpose (`Checkout / Error / Card declined`), no `Frame 123`; states in variants, not duplicated frames.
- [ ] Cover page lists owner, brief link, related IDs, changelog.

Single source of truth
- [ ] Tokens and components come from the library only; local components are labelled and reviewed via `design-system-governance`.
- [ ] Code repo, if it stores tokens, is the source for values and design consumes them (per `context.md`).

Branching and review
- [ ] Work in a branch (or duplicate labelled `WIP - <name>`) for changes to approved files; merge only after review by one other designer (T2/T3: recorded in `templates/design-review-record.md`).
- [ ] Comments resolved or converted to findings before freeze; no unresolved threads at hand-off.
- [ ] Checkpoint versions at: review start, approval, hand-off freeze, release (name: `FEAT-NNN v1.0 handoff YYYY-MM-DD`).

Archiving
- [ ] Move superseded work to `Archive/` with date and reason; delete nothing that a decision (`ADR-NNN`) or research finding cites.
- [ ] Archive files untouched for 6 months after release; review the Sandbox monthly.
- [ ] Access: edit for owners, view/comment for reviewers; remove leavers within 5 working days.

Assets and licences
- [ ] Register each font, icon set, image and kit: source, licence type, allowed uses (commercial, modification), attribution needed, expiry, seat count.
- [ ] Prefer stock and generated images with a recorded licence; no images copied from the web or from real customers; model releases for photos of people.
- [ ] Open-source icons: check licence compatibility with the product before use.

## Output format

Asset register (table: asset, source, licence, terms, owner, used in `FEAT-NNN`) and a workspace README on the cover page: structure, naming rule, version log, access list.

Worked mini-example: `Checkout - FEAT-NNN - Payment retry` with pages `Cover`, `Flows`, `Screens`, `Handoff`; checkpoint `FEAT-NNN v1.0 handoff YYYY-MM-DD` tagged; old copy moved to `Archive/2 - superseded by v1.0`.

## References

- `_shared/standards/data-governance.md`, `_shared/standards/security-baseline.md`, `_shared/standards/project-tiers.md` (T1: naming rule, one library, asset list).
- Related: `design-system-governance`, `design-handoff-and-design-qa`, `design-critique`.
- IDs: `FEAT-NNN`, `ADR-NNN`, `RISK-NNN` for licence gaps.

## Language notes

Example (Figma): use branching and named versions, library publishing, and Sandbox drafts. Other tools: use the equivalent of branches and version tags.
