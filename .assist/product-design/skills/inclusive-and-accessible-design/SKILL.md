---
name: inclusive-and-accessible-design
description: Use when creating or reviewing a design for WCAG 2.2 AA at design time, or when a screen involves colour, small targets, focus order, motion, dense content, forms, multiple languages, RTL scripts or imagery of people.
---
# Inclusive and Accessible Design

## Purpose

Make accessibility and inclusion decisions in the design file, where they cost minutes, instead of in code or after release, where they cost days. This skill covers design-time checks; the built result is audited with `accessibility-audit` (frontend role).

## When to use

- Every new or changed screen, flow or component, at first draft and again before hand-off.
- Introducing new colours, type, motion, charts, iconography or imagery.
- Adding a language, an RTL locale or user-generated content.

## Principles

- Target WCAG 2.2 AA unless `context.md` says stricter; T1 projects still run the quick check below.
- Design for a range of abilities and situations (permanent, temporary, situational): one hand, glare, noisy room, slow network.
- Never rely on one channel: colour, sound, position or gesture needs a second cue.
- Reduce load: fewer choices per screen, plain words, forgiving input.
- Use design-system tokens and components that already meet these values.

## Steps / Checklist

Perceivable
- [ ] Text contrast >= 4.5:1; large text (>= 24 px, or >= 18.66 px bold) and UI boundaries, icons, focus rings >= 3:1, in every theme (light, dark, high contrast).
- [ ] Information not conveyed by colour alone (add icon, text, pattern).
- [ ] Text resizes to 200% and reflows at 320 CSS px width without horizontal scroll or clipped content; line height >= 1.5 for body.
- [ ] Every meaningful image has alt text intent written in the design notes; decorative images marked as such; captions and transcripts planned for media.

Operable
- [ ] Target size >= 24x24 CSS px (WCAG 2.2 SC 2.5.8) with spacing; >= 44 pt (iOS) / 48 dp (Android) on touch. Primary touch actions in thumb reach.
- [ ] Focus order documented on the screen (numbered overlay); visible focus indicator designed, not default-removed; focus not obscured by sticky headers (SC 2.4.11).
- [ ] Any drag interaction has a single-pointer alternative (SC 2.5.7).
- [ ] Motion: durations <= 500 ms for UI transitions, a reduced-motion variant designed, no flash more than 3 times per second, no auto-play over 5 seconds without a pause control.
- [ ] No time limits without extend/turn-off; no gesture-only actions.

Understandable
- [ ] Plain language, reading level around lower secondary (grade 8-9), one idea per sentence, verbs on buttons ("Save changes", not "OK").
- [ ] Forms: visible labels (not placeholder-only), inline error text that says what happened and how to fix it, no re-entry of data already given (SC 3.3.7), accessible authentication without cognitive tests (SC 3.3.8).
- [ ] Cognitive load: <= 7 primary choices per view, progressive disclosure, clear undo/confirm for destructive actions.

Localisation and inclusion
- [ ] Text expansion +40% tolerated; no text in images; date, number and currency formats not hard-coded.
- [ ] RTL: layout, icons with direction (arrows, progress) and text alignment mirrored; numerals and logos exempt; verify with a pseudo-RTL mock.
- [ ] Imagery and examples show varied ages, abilities, body types and cultures without stereotyping; names and personas are synthetic; avoid idioms and gendered defaults.

## Output format

Accessibility notes attached to the brief or screen: pass/fail per checklist group, contrast pairs with ratios, focus-order overlay, reduced-motion behaviour, and open issues as findings (owner, severity) in `templates/design-review-record.md`.

Worked mini-example: grey helper text #767676 on white measures 4.54:1 (pass, AA); on a #F2F2F2 card it drops to 4.1:1 (fail): darken to #666666 (5.7:1) and record the token change in `design-system-governance`.

## References

- `_shared/compliance/compliance-matrix.md` (WCAG 2.2 AA / EN 301 549 row), `_shared/standards/nfr-catalog.md`, `_shared/standards/project-tiers.md`.
- Frontend role: `accessibility-audit` (audit of built UI), `component-design-system`, `i18n-and-localisation`.
- IDs: `FEAT-NNN`, `TC-NNN` (a11y test cases), `RISK-NNN` for accepted gaps.

## Language notes

Contrast tools: any WCAG-ratio checker or design-tool plugin; simulate colour-vision deficiency and low vision on final palettes.
