---
name: responsive-and-adaptive-design
description: Use when defining breakpoints, adapting a layout across phone, tablet, desktop or foldable, handling touch versus pointer input, safe areas, zoom or content reflow.
---
# Responsive and Adaptive Design

## Purpose
Specify how layouts and components change across viewport, input and device, so engineers do not invent behaviour and no user loses content or function.

## When to use
- Defining the breakpoint set or reviewing a screen at each width.
- Designing for touch and pointer, notches, foldables or split-screen.
- A screen breaks at 200% text size or 400% zoom.

## Principles
1. Design content-first and mobile-first; add layout at larger widths rather than removing at smaller ones.
2. Breakpoints are few and named by size class, for example compact (0-599), medium (600-839), expanded (840-1199), large (1200+); change layout where content breaks, not per device model.
3. Prefer container-relative behaviour (a card adapts to its container) over viewport-only rules.
4. Function parity: nothing available on large screens is unreachable on compact.
5. Touch targets at least 44 x 44 pt (never below 24 x 24 CSS px with spacing); pointer-only affordances (hover menus, tooltips) need a touch and keyboard equivalent.
6. Reflow: content must work at 320 CSS px width and 400% zoom without two-dimensional scrolling (except data tables, maps, diagrams).

## Steps / Checklist
1. List the size classes and orientations supported (`context.md`).
2. For each screen, draw compact, medium and expanded; note what stacks, collapses (navigation to bar, side panel to sheet), reorders (visual order must match DOM and focus order) or hides behind a control.
3. Define fluid rules: max content width (about 1200 px, text 75 characters), column counts (4 / 8 / 12), margins (16 / 24 / 32 px).
4. Components: specify container-based variants (for example card horizontal at 480 px and above).
5. Input: primary actions within thumb reach on compact (bottom sheet or bottom bar); 8 px minimum between adjacent targets; no hover-only information.
6. Safe areas: respect device insets (notch, home indicator, system bars) for fixed elements; keep critical content out of curved-edge zones.
7. Foldables and split-screen: avoid placing controls across the hinge; layout adapts to window size class, not device type; state posture behaviour if supported.
8. Text scaling to 200%: no truncation of essential text, no overlap; test long translations.
9. Images and media: define aspect ratios and crops per class; avoid text baked into images.
10. Print and landscape: state support or non-support explicitly.

## Output format
Breakpoint table in the screen spec (breakpoint, grid, layout changes, frame link). Worked mini-example: order list, compact = cards with actions in an overflow menu; expanded = table with inline actions; selection persists when resized.

## References
- Common skill `inclusive-and-accessible-design`
- `visual-hierarchy-and-layout`, `component-and-state-design`
- Frontend `component-design-system`, `accessibility-audit`; frontend-web `browser-support-and-progressive-enhancement`
- IDs: `FEAT-NNN`, `TC-NNN`

## Language notes
Web: CSS container queries, `clamp()`, `env(safe-area-inset-*)`, `@media (pointer: coarse)`. iOS: safe area layout guides, size classes. Android: window size classes, WindowInsets.
