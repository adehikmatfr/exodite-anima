---
name: design-token-authoring
description: Use when creating, naming, restructuring or changing design tokens, adding a theme or mode, or setting up export and sync of tokens between the design tool and code.
---
# Design Token Authoring

## Purpose
Define tokens as a stable contract between design and code: predictable names, three tiers, mode support, automated export and a controlled change process.

## When to use
- Introducing tokens, or moving from raw values or styles to tokens.
- Adding a mode (dark, high contrast, density, brand).
- A token is proposed, renamed, split or removed.
- Design and code values have drifted.

## Principles
1. Three tiers: primitive (raw values: `color.blue.600`, `space.8`), semantic (purpose: `color.action.primary.bg`), component (scoped: `button.primary.bg`). Screens use semantic or component tokens, never primitives.
2. Names describe role, not value: `color.text.danger`, not `color.red`; not `space.16px`. Structure `category.property.role.variant.state`, lowercase, dot-separated.
3. Modes change semantic mappings only; primitives are mode-independent; component tokens rarely need their own values.
4. One source of truth (design tool variables or a tokens file in the repo); the other side is generated, never hand-edited.
5. Tokens are versioned and changes follow `design-system-governance`; deleting is a breaking change.

## Steps / Checklist
1. Inventory existing values; merge near-duplicates (colours within a tiny delta, spacing off the 8 px scale) before naming.
2. Categories: colour, typography (family, size, weight, line height), spacing (4, 8, 12, 16, 24, 32, 48, 64), sizing, radius, border width, elevation, opacity, motion (duration 100 / 150 / 200 / 300 ms; easing), breakpoint, z-index.
3. Create primitives, then semantic aliases that reference primitives (aliases, not copies).
4. Add modes; verify contrast pairs per mode (`colour-and-theming`: 4.5:1 text, 3:1 UI).
5. Add component tokens only where a component needs to diverge from the semantic default; avoid one-token-per-property explosions.
6. Document each token: description, intended use, do not use for, deprecated flag with replacement.
7. Export: use a standard format (W3C Design Tokens JSON) and a transform tool to produce platform outputs (CSS custom properties, iOS, Android); run in CI; commit generated files or publish a package with semver.
8. Sync direction and cadence: state it in `context.md`; a CI check fails when generated output differs from source.
9. Change process: propose (name, reason, affected components), review by system owner, classify (patch: value tweak within tolerance; minor: new token; major: rename or removal), changelog entry, deprecation window of at least one minor release, migration note for frontend.
10. Audit quarterly for unused tokens and hard-coded values in design files and code.

## Output format
Token table and change note:

| Token | Tier | Light | Dark | Use | Status |
|-------|------|-------|------|-----|--------|
| color.text.secondary | semantic | neutral.700 | neutral.300 | supporting text | stable |

Change note: token(s), change class (patch, minor, major), reason, migration, `ADR-NNN` if architectural.

## References
- Common skills `design-system-governance`, `design-file-hygiene-and-versioning`
- `colour-and-theming`, `visual-hierarchy-and-layout`, `interaction-and-motion-design`
- Frontend `component-design-system`
- `_shared/standards/release-management.md`
- IDs: `FEAT-NNN`, `ADR-NNN`, `TC-NNN` (token snapshot or visual regression)

## Language notes
Figma variables with collections per tier and modes; Tokens Studio or the native variables export; Style Dictionary for transforms. Web outputs: CSS custom properties scoped by `[data-theme]`.
