# Component Spec: <ComponentName>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Component | `<ComponentName>` |
| Layer | <primitive / composite / feature> |
| Related | `FEAT-NNN`, design link <url or id> |
| Status | <draft / active / deprecated> |

## 1. Purpose

<One or two sentences: the user problem it solves and when to use it. When NOT to use it, and which existing component to use instead.>

## 2. Anatomy (optional)

<Named parts (container, label, icon, helper text, ...) with the token used for each: spacing, colour, type.>

## 3. Props / Inputs

| Name | Type | Default | Required | Description |
|------|------|---------|----------|-------------|
| `<name>` | `<type>` | `<default>` | <yes/no> | <purpose, allowed values> |

Events / callbacks: `<onChange(value)>` - <when fired, payload>. Slots / children: <list>.

## 4. States

| State | Trigger | Visual / behaviour | Announced to assistive tech |
|-------|---------|--------------------|-----------------------------|
| Default | - | <...> | <...> |
| Loading | <async in flight> | <skeleton / spinner, layout stable> | <status message> |
| Empty | <no data> | <message + next action> | <...> |
| Error | <failure> | <safe message, retry action> | <alert> |
| Disabled | <condition> | <visual + not focusable or aria-disabled> | <...> |
| Hover / pressed / focus | input | <token refs> | - |

## 5. Interactions

<Pointer, touch, keyboard and (where relevant) gamepad/remote behaviour. Debounce, long-press, drag, gestures, and cancel/undo behaviour.>

## 6. Accessibility

- Role / semantics: <native element or platform role>; accessible name from: <label source>.
- Keyboard: <keys and result, tab order, no traps>.
- Focus: <where focus goes on open/close/error; visible indicator meeting 3:1 contrast>.
- Contrast: text >= 4.5:1, large text and UI boundaries >= 3:1 in every theme.
- Target size: >= 24x24 CSS px minimum (WCAG 2.2 AA), >= 44 pt / 48 dp on touch platforms.
- Motion: respects reduced-motion; no flashing above 3 per second.

## 7. Responsive / Adaptive Behaviour

<Breakpoints or size classes, orientation, density, text scaling to 200%, min and max widths, truncation rules.>

## 8. i18n (optional)

<Strings and catalog keys, text expansion tolerance (+40%), RTL mirroring, locale-specific formats.>

## 9. Telemetry Events (optional)

| Event | When | Properties (no personal data) |
|-------|------|-------------------------------|
| `<component_action>` | <trigger> | `<non-identifying props>` |

## 10. Tests

| ID | Level | Scenario |
|----|-------|----------|
| TC-NNN | unit / component / visual / a11y | <what is verified> |

## 11. Open Questions (optional)

- <question, owner, needed by>
