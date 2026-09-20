---
name: colour-and-theming
description: Use when defining or changing a colour palette, semantic colour tokens, dark mode, high-contrast mode, status colours or chart colours, or when checking contrast and colour-blind safety.
---
# Colour and Theming

## Purpose
Build a colour system that carries meaning consistently, meets contrast thresholds in every mode, and can be re-themed by changing tokens rather than screens.

## When to use
- Creating or auditing a palette or a new theme (dark, high contrast, white-label).
- Adding a status colour, chart palette or brand accent.
- A review flags low contrast or colour-only meaning.

## Principles
1. Use semantic tokens (`color.text.primary`, `color.surface.raised`, `color.status.danger.fg`) in designs; raw palette steps stay in the primitive tier (see `design-token-authoring`).
2. Contrast minimums: body text 4.5:1; large text (24 px, or 18.66 px bold) and UI component boundaries, icons and focus rings 3:1; verify every text/background pair in every mode.
3. Colour never carries meaning alone: add text, icon or shape.
4. Brand colours express identity; status colours express state. Do not reuse the brand red as the error colour or the brand green as success unless they are the same hue by decision.
5. Dark mode is a designed theme, not an inversion: lower surface elevation contrast, desaturate accents, avoid pure black (#000) and pure white text on it.
6. Support forced-colours / high-contrast modes with system colours for borders, focus and text.

## Steps / Checklist
1. Build a ramp per hue (10-12 steps, lightness-based) and pick text, surface, border and accent steps per mode.
2. Define semantic roles: text (primary, secondary, disabled, inverse, link), surface (base, raised, overlay), border (default, strong), action (default, hover, pressed, disabled), status (success, warning, danger, info; each with fg, bg, border).
3. Record a contrast matrix: role pair, ratio, mode, pass/fail. Secondary text stays at 4.5:1 or above; disabled text is exempt from the ratio but must remain distinguishable.
4. Check hover, pressed and selected states against their neighbours (3:1 for boundaries).
5. Simulate protanopia, deuteranopia, tritanopia and greyscale; every status and chart series must remain distinguishable by label, pattern or position.
6. Limit chart palettes to 6-8 categories; order for adjacency contrast; offer direct labels.
7. Check dark mode images, shadows (use borders or lighter surfaces for elevation) and brand logo variants.
8. Never introduce a one-off colour in a screen; propose a token.

## Output format
A contrast matrix table plus token mapping per mode:

| Role | Light value | Dark value | Pair | Ratio light / dark |
|------|-------------|------------|------|--------------------|
| color.text.secondary | neutral-700 | neutral-300 | on surface.base | 7.2 / 8.1 |

Attach it to the design-system release or the `templates/component-design-spec.md` tokens section.

## References
- Common skills `inclusive-and-accessible-design`, `design-system-governance`
- `design-token-authoring` (tiers and modes); frontend `component-design-system`, `accessibility-audit`
- `_shared/standards/nfr-catalog.md`
- IDs: `FEAT-NNN`, `ADR-NNN` (theming approach), `TC-NNN` (visual regression per mode)

## Language notes
Figma: variables with one collection per tier and modes Light, Dark, High contrast. Web: CSS custom properties with `prefers-color-scheme`, `prefers-contrast` and `forced-colors` media queries. Use APCA only as a supplement; WCAG ratios remain the gate.
