---
name: component-design-system
description: Use when creating, changing, reviewing or deprecating a shared UI component, design token or theme, or when a screen needs a visual pattern that may already exist in the design system.
---

# Component and Design System Use

## Purpose
Keep the UI consistent, accessible and cheap to change by building from tokens and a small set of well-specified components rather than one-off styling.

## When to use
- Building a screen: choose existing components before writing new ones.
- Proposing a new component, variant, token or theme (including dark and high contrast).
- Reviewing a PR for hard-coded styles or duplicated components.

## Principles
- Reuse, then extend, then create. A new component needs a reason an existing one cannot meet, recorded in its spec.
- Tokens are the only source of colour, spacing, type, radius, elevation and motion. Semantic tokens (`color.text.primary`, `space.4`) in components; raw values only in the token definition.
- Layers: primitives (button, input, text) -> composites (form field, dialog) -> feature components. Dependencies point downward only; primitives know nothing about the domain or the network.
- Components are controlled by props/inputs, own no business logic, and expose every state: default, loading, empty, error, disabled, focus.
- Accessibility is part of the component contract, not a later audit (`accessibility-audit`).
- Variants over forks: add a variant prop when behaviour is the same; fork only when semantics differ.
- Breaking a public prop follows a deprecation window (one minor release minimum, T2+: documented in the changelog).

## Checklist
- [ ] Searched the library and design file for an equivalent; result noted in the spec.
- [ ] Spec written from `templates/component-spec.md` (props, states, a11y, responsive, tests).
- [ ] Zero hard-coded colour, spacing, font or duration values (lint rule or grep in CI).
- [ ] Works in every supported theme and at 200% text scale without clipping.
- [ ] Touch target >= 44x44 pt / 48x48 dp on touch; >= 24x24 CSS px minimum on pointer UIs.
- [ ] Visible in a catalogue (Storybook, previews, gallery) with all states as examples.
- [ ] Component tests plus a visual baseline per state (`ui-testing-strategy`).
- [ ] No strings hard-coded; accepts localised text and grows 40% (`i18n-and-localisation`).
- [ ] Bundle/app size impact measured for new dependencies (`performance-budget-common`).

## Steps
1. Restate the need as user behaviour, not appearance.
2. Search existing components and tokens; try composition first.
3. If new: write the spec, get design and accessibility review, then build against tokens.
4. Add catalogue entries and tests; register the change in the design-system changelog.
5. Migrate at least one real usage in the same change, otherwise the component is speculative.

## Output format
A short decision record in the PR: `Need | Existing candidates checked | Decision (reuse / extend / new) | Tokens added | Spec link`.

Worked mini-example: a "status pill" is needed. Candidates: `Badge` (same shape, lacks icon slot). Decision: extend `Badge` with `icon` prop and `tone` variant (`success|warning|danger`) mapped to `color.status.*` tokens; no new component.

## References
`../_shared/standards/definition-of-done.md`, `nfr-catalog.md` (Accessibility, Compatibility); templates `component-spec.md`; IDs `FEAT-NNN`, `TC-NNN`; skills `accessibility-audit`, `ui-testing-strategy`.

## Language notes
- React/Vue/Angular: props/inputs and slots/content projection; style via CSS variables or theme provider. SwiftUI: `ViewModifier` and asset-catalog colours. Compose: `MaterialTheme` extensions and `CompositionLocal`. Flutter: `ThemeExtension`. Electron: same as web, plus OS theme sync.
