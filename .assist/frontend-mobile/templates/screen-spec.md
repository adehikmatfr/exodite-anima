# Screen / Flow Spec: <ScreenOrFlowName>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Screen / flow | `<name>` |
| Route / screen id | `<route pattern or screen id>` |
| Feature | `FEAT-NNN` |
| Platforms | <web / iOS / Android / desktop> |
| Status | <draft / active / deprecated> |

## 1. Goal

<What the user accomplishes here, in one sentence, and the success signal.>

## 2. Entry Points and Exits

| From | Trigger | Parameters | Auth / role required |
|------|---------|------------|----------------------|
| `<screen or deep link>` | <tap, link, redirect> | `<params, validated>` | <...> |

Exits: <next screens, back behaviour, unsaved-changes prompt>.

## 3. Layout and Components

<Wireframe or design link. List of components used (existing design-system components first) with `component-spec.md` links for new ones.>

## 4. Data Needs

| Data | Contract | Trigger | Cache / freshness | Failure impact |
|------|----------|---------|-------------------|----------------|
| `<entity>` | `API-NNN` | <on load / on action> | <ttl, revalidate> | <blocks screen / degrades section> |

## 5. States

| State | Condition | What the user sees |
|-------|-----------|--------------------|
| Loading | <first load> | <skeleton, layout stable> |
| Empty | <no data> | <message + primary action> |
| Partial | <one section failed> | <section-level error, rest usable> |
| Error | <load failed> | <safe message, retry, correlation id on request> |
| Success | <data ready> | <...> |
| Permission denied | <403 / missing OS permission> | <explanation + path forward> |

## 6. Error and Offline Handling

- Error mapping from the API error envelope: <code -> user message key -> action>.
- Offline: <read-only cached view / queued writes / blocked with message>; reconnect behaviour: <auto-retry, manual refresh>.
- Timeouts and retries: <values>; duplicate-submit protection: <disable + idempotency key>.

## 7. Accessibility

<Screen title / heading structure, focus on entry and after errors, reading order, live-region announcements, form error association. Detail per component lives in its spec.>

## 8. Analytics (optional)

| Event | When | Properties (no personal data) | Consent |
|-------|------|-------------------------------|---------|
| `<screen_viewed>` | <on display> | `<props>` | <required / not> |

## 9. Performance Budget (optional)

<Render budget, interaction latency, payload size for this screen against `context.md` targets.>

## 10. Security and Privacy Notes (optional)

<Sensitive fields (masking, no screenshots/autofill where needed), deep-link validation, related `THR-NNN`.>

## 11. Acceptance Criteria

| # | Criterion (Given / When / Then) | FEAT | Test |
|---|---------------------------------|------|------|
| 1 | <criterion> | `FEAT-NNN` | `TC-NNN` |

## 12. Open Questions (optional)

- <question, owner, needed by>
