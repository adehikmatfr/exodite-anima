---
name: visual-hierarchy-and-layout
description: Use when composing or reviewing a screen layout, choosing grid, spacing or type scale, or when a screen feels cluttered, flat or misaligned. Covers hierarchy, proximity, alignment and density.
---
# Visual Hierarchy and Layout

## Purpose
Make the most important thing on a screen obvious within a few seconds, and make every other element sit in a predictable, aligned place.

## When to use
- Designing a new screen or reworking a crowded one.
- Choosing the grid, spacing scale or type scale for a product.
- A critique finds "everything looks equally important" or inconsistent gaps.

## Principles
1. One primary focal point per view; at most one primary action.
2. Hierarchy comes from size, weight, contrast, position and space, in that order of strength. Use two or three levels, not six.
3. Proximity groups: space inside a group is at most half the space between groups.
4. Align to a grid and to a shared baseline; near-misses of 1-2 px read as errors.
5. Space is a token, not a guess: 8 px steps (4 px for tight internal gaps).
6. Density is a product decision (comfortable, compact) applied consistently by token, never per screen.

## Steps / Checklist
1. Write the screen goal and the one primary action (from the `FEAT-NNN` brief).
2. Rank content: primary, secondary, tertiary. Cut or demote anything that fits none.
3. Choose the grid per breakpoint (see `responsive-and-adaptive-design`), for example 4 columns / 16 px margin on compact, 12 columns / 24 px gutter on expanded.
4. Apply the spacing scale: 4, 8, 12, 16, 24, 32, 48, 64 px. Section gaps 32 px or more, related items 8-16 px.
5. Apply the type scale with a ratio of about 1.125 to 1.25 between steps; body at least 16 px (14 px only for dense data), line height 1.4 to 1.6 for body, line length 45 to 75 characters.
6. Limit weights to two or three per screen; do not use colour alone to rank.
7. Check alignment: left edges of text and controls share one line; numbers in tables right-aligned or tabular figures.
8. Squint test: blur the frame; the primary action and title must still stand out.
9. Test with worst-case content (long names, 1,000+ counts, translations 40% longer).

## Output format
Layout notes in the screen spec (`templates/screen-design-spec.md` section 2): grid values, spacing tokens used, type roles used, reading order, and a one-line hierarchy rationale, for example "Primary: Pay now button; secondary: order summary; tertiary: policy links."

Worked mini-example: a settings card with title (20/28, semibold), description (14/20, neutral text at 4.5:1), and controls 16 px below; card padding 24 px; gap between cards 32 px. The gap between groups (32) is double the gap inside (16), so grouping reads without borders.

## References
- `_shared/standards/nfr-catalog.md` (usability and accessibility rows)
- Common skill `design-critique`; `inclusive-and-accessible-design` (reflow, text spacing)
- Frontend `component-design-system` for token implementation
- IDs: `FEAT-NNN`, `TC-NNN`

## Language notes
Figma: use auto layout with spacing variables; set text styles from the type scale and avoid detached styles. Code: spacing and type tokens map to CSS custom properties or platform equivalents.
