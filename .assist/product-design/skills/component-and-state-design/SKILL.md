---
name: component-and-state-design
description: Use when designing a component, form, table or dense data view, or when a design lacks hover, focus, loading, error or empty states. Covers variants, all states, validation messaging and data-heavy layouts.
---
# Component and State Design

## Purpose
Ensure every component and view is specified in all the states users will meet, with variants that are few, distinct and reusable.

## When to use
- Creating or extending a component (before `templates/component-design-spec.md`).
- Designing forms, validation, tables, lists or data-dense screens.
- A design review finds default-only mockups.

## Principles
1. Variants differ by purpose (primary, secondary, destructive), not decoration. Cap at 4-5 per component; more signals a missing component.
2. Every interactive element has eight states: default, hover, focus, active, disabled, loading, error, empty (where applicable).
3. Focus is always visible, at least 2 px, 3:1 against adjacent colours; never removed for mouse users only.
4. Loading keeps layout stable (skeletons or fixed-size spinners); show progress after 1 s, indicate immediately for actions.
5. Errors say what happened, why if known, and what to do next; they appear next to the cause and are announced to assistive tech.
6. Empty states explain the situation and offer one next action; first-use, no-results and cleared are different empties.
7. Disabled controls are a last resort; prefer enabled with explanatory validation.

## Steps / Checklist
1. Define purpose and anatomy; list variants and sizes (for example 32 / 40 / 48 px height); confirm touch target of at least 44 x 44 pt.
2. Draw all states for each variant using tokens only; check contrast per state (`colour-and-theming`).
3. Forms: visible label above the field (never placeholder-only), helper text, required marker with text, error message below the field, group errors in a summary linking to fields, validate on blur then on change after first error, never clear valid input on failure, preserve input on reload where safe.
4. Choose input types to match data (numeric keypad, date picker, autocomplete attributes); default values and units shown.
5. Tables: left-align text, right-align numbers with tabular figures, sticky header, row height by density (48 comfortable, 40 compact, 32 dense), sortable state indicator, column truncation rules with full text on focus or hover, selection and bulk-action pattern, pagination or virtualisation above about 100 rows, responsive fallback (horizontal scroll with sticky first column, or card list on compact).
6. Long text: choose truncate, wrap or grow per element and state where full text is reachable.
7. Destructive actions: confirm with consequence named, or offer undo for 5-10 s.
8. Add a Do / Do not pair for the two most common misuses.

## Output format
State matrix in the component spec (state, visual change, token, note). Worked mini-example, text input error state: border `color.status.danger.border` (3:1), icon plus message "Enter a date as DD/MM/YYYY" below the field, `aria-describedby` linked, message announced on submit.

## References
- Common skills `design-system-governance`, `design-handoff-and-design-qa`, `inclusive-and-accessible-design`
- Frontend `component-design-system`, `accessibility-audit`
- `visual-hierarchy-and-layout`, `responsive-and-adaptive-design`
- IDs: `FEAT-NNN`, `TC-NNN` (state coverage tests)

## Language notes
Figma: component properties for variant and boolean states; one variant set per component; add a "long content" and "error" example frame. Storybook stories should mirror the state matrix one to one.
