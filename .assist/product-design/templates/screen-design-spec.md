# Screen Design Spec: <Screen name>

Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Screen | <name and route or screen ID> |
| Feature | `FEAT-NNN` |
| Status | <draft / in review / approved> |
| Owner | <designer> |
| Design file | <link to frames> |
| Flow context | <link or ID from ux-design flow, previous and next screens> |
| Design system version | <semver> |

## 1. Goal

User goal and business goal in one sentence each. Primary action: <one>. Success signal: <metric or event>.

## 2. Layout at Each Breakpoint

| Breakpoint | Grid (columns, margin, gutter) | Layout notes | Frame link |
|------------|--------------------------------|--------------|-----------|
| <compact> | <4, 16, 16> | <single column, sticky primary action> | |
| <medium> | | | |
| <expanded> | | | |

Regions, reading order (must match DOM and focus order), what collapses or moves, safe-area handling on mobile.

## 3. Content and States

| Region | Content source | Loading | Empty | Error | Partial or stale |
|--------|----------------|---------|-------|-------|------------------|
| <header> | <API-NNN / static> | <skeleton> | <message + action> | <message + retry> | |

Copy: <link to copy deck or inline strings>; all strings externalised for translation.

## 4. Interactions

| Trigger | Response | Feedback timing | Notes |
|---------|----------|-----------------|-------|
| <tap Save> | <optimistic update> | <acknowledge under 100 ms> | <undo for 5 s> |

Keyboard path, focus after each action, and unsaved-changes behaviour.

## 5. Edge Cases

- Long text (names of 60+ characters, translations 40% longer): <truncate or wrap rule>.
- Missing data (no image, no name, null values): <fallback display>.
- Extreme values (0, 1, 1,000+ items; very large numbers): <behaviour>.
- Slow or lost network, session expiry, permission denied: <behaviour>.
- Right-to-left, large text (200%), zoom (400% reflow): <behaviour>.

## 6. Accessibility

Heading structure, landmarks, focus order, accessible names for icon-only controls, error announcement, contrast pairs verified, target sizes, motion alternatives. Reference `inclusive-and-accessible-design`; built UI is verified by frontend `accessibility-audit`.

## 7. Analytics Events (optional)

| Event | Trigger | Properties | Owner |
|-------|---------|------------|-------|
| <screen_viewed> | <on load> | <screen, source> | |

No personal data in event properties (`_shared/standards/data-governance.md`).

## 8. Acceptance Criteria

| AC | Criterion (testable) | Feature | Test |
|----|----------------------|---------|------|
| AC-1 | <at compact width the primary action stays visible without scrolling> | `FEAT-NNN` | `TC-NNN` |
| AC-2 | <empty state shows message and create action> | `FEAT-NNN` | QA will assign |

## 9. Open Questions (optional)

| # | Question | Owner | Needed by |
|---|----------|-------|-----------|
| 1 | | | |
