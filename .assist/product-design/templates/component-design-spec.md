# Component Design Spec: <ComponentName>

Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Component | <name, as in code and design library> |
| Design system version | <semver> |
| Status | <draft / in review / approved / deprecated> |
| Owner | <designer> |
| Related | `FEAT-NNN`, `ADR-NNN` (if any) |
| Implementation spec | frontend component-spec template (fill after this spec is approved) |
| Design file | <link to library page> |

## 1. Purpose and Usage Rules

- What user need it serves: <one sentence>.
- Use when: <conditions>.
- Do not use when: <conditions and the component to use instead>.
- Related components: <list>.

## 2. Anatomy

Numbered diagram or list of parts (container, label, icon, helper text, indicator). Mark required vs optional parts.

| # | Part | Required | Notes |
|---|------|----------|-------|
| 1 | <container> | yes | <min size> |

## 3. Variants and Sizes

| Variant | Purpose | Sizes (height) | Notes |
|---------|---------|----------------|-------|
| <primary> | <main action> | <S 32 / M 40 / L 48 px> | <one per view> |

Touch target at least 44 x 44 pt even when the visible size is smaller.

## 4. States

| State | Visual change | Token(s) | Notes |
|-------|---------------|----------|-------|
| Default | | | |
| Hover | | | pointer only |
| Focus | visible ring, 3:1 against adjacent colours, never removed | | keyboard and programmatic focus |
| Active / pressed | | | |
| Disabled | | | explain why nearby if the reason is not obvious |
| Loading | | | prevents double submit; keeps size stable |
| Error | | | text plus icon, not colour alone |
| Empty | | | what is shown and the next action |

## 5. Tokens Used

| Property | Token | Mode differences |
|----------|-------|------------------|
| Background | <component.button.bg.default> | <dark: ...> |
| Text | | |
| Border and radius | | |
| Spacing | | |
| Typography | | |
| Motion | | |

Proposed new tokens (raise through `design-token-authoring`): <list or none>.

## 6. Spacing and Layout Rules

Internal padding, gaps between parts, alignment, minimum and maximum width, behaviour with long text (truncate, wrap, or grow; state which and where the full text is exposed). Spacing values are multiples of 8 px (4 px for tight internal gaps).

## 7. Responsive Behaviour

| Breakpoint | Behaviour |
|------------|-----------|
| <compact> | |
| <expanded> | |

## 8. Accessibility Notes

Role and accessible name source, keyboard interaction (keys and order), focus management, screen-reader announcements for state changes, contrast pairs verified (text 4.5:1, UI boundary 3:1), target size, reduced-motion behaviour. Verify built output with frontend `accessibility-audit`.

## 9. Motion (optional)

Transition per state change: property, duration (150-300 ms), easing token, reduced-motion alternative.

## 10. Do and Do Not

| Do | Do not |
|----|--------|
| <example image or description> | <counter-example image or description> |

## 11. Open Questions (optional)

| # | Question | Owner | Needed by |
|---|----------|-------|-----------|
| 1 | | | |
