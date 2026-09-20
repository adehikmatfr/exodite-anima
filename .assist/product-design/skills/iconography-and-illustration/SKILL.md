---
name: iconography-and-illustration
description: Use when creating, sourcing or reviewing icons, illustrations, empty-state art or brand imagery, including grid, stroke, optical alignment, alt text and licence checks.
---
# Iconography and Illustration

## Purpose
Keep icons and illustrations consistent, legible at size, accessible to assistive technology and legally usable.

## When to use
- Adding an icon or illustration, or choosing an external set.
- Reviewing inconsistent stroke, size or style.
- Deciding alternative text for an image or icon-only control.

## Principles
1. Icons support text; they do not replace it except for universally understood glyphs (close, search). Icon-only controls need an accessible name and a tooltip or label.
2. One icon family per product: same grid, stroke, corner radius, terminal style and visual weight.
3. Meaning is tested, not assumed: check with users or at least two teammates for ambiguous metaphors.
4. Illustrations are limited to purposeful moments (empty, onboarding, error, marketing); they never hold essential text or the only explanation.
5. Every asset has a known licence and source before use.

## Steps / Checklist
1. Grid: 24 px base with 2 px padding (20 px live area); supported sizes 16, 20, 24, 32 px. Keylines: circle 20 px, square 18 px, portrait 16 x 20, landscape 20 x 16.
2. Stroke: 1.5 or 2 px consistently (pick one), round or square joins as the set defines, corner radius 2 px; stroke centred and pixel-snapped at 24 px.
3. Optical alignment: adjust shapes so visual weight matches (triangles and circles overshoot keylines by about 0.5 px); centre by optical, not bounding-box, centre.
4. Fill vs outline: outline default, filled for selected or active state; do not mix within one control group.
5. Colour: icons inherit text colour via token (`color.icon.default`), 3:1 minimum against background for meaningful icons; illustration palette drawn from the brand and neutral tokens, checked in dark mode.
6. Accessibility: decorative icons hidden from assistive tech; informative icons and icon-only buttons get a concise name describing the action ("Delete invoice"), not the picture ("trash can"); complex images (charts, diagrams) get a short alt plus a long description or data table nearby; text in images is avoided.
7. Export: SVG, optimised, `currentColor` for fills, no embedded raster or fonts, consistent viewBox; named `icon-<name>-<size>`; keep a source file and an exported sprite or component set.
8. Illustration: define style rules (line weight, shape language, people depiction, skin tone diversity), max file size (about 50 KB SVG), and light and dark variants.
9. Licensing: record source, licence, attribution requirement, modification rights and commercial use in the asset register; prefer open licences (MIT, Apache, CC0, SIL) or purchased with seat and distribution terms; no AI-generated or scraped art without legal sign-off; check trademarks in logos.
10. New icon requests go through `design-system-governance` intake with use case and search of existing icons first.

## Output format
Asset register row: name, size(s), meaning, source, licence, attribution text, alt text pattern, owner, date. Worked mini-example: `icon-download-24`, 2 px padding, 1.5 px stroke, `currentColor`, alt pattern "Download <file name>".

## References
- Common skills `inclusive-and-accessible-design`, `design-system-governance`, `design-file-hygiene-and-versioning`
- `colour-and-theming`, `design-token-authoring`; frontend `component-design-system`, `accessibility-audit`
- IDs: `FEAT-NNN`, `ADR-NNN` (icon delivery format)

## Language notes
Web: inline SVG or sprite with `aria-hidden="true"` for decorative use and `role="img"` plus a label otherwise. Native: use platform vector formats (SF Symbols alignment, Android vector drawables) with the same names.
