---
name: ui-testing-strategy
description: Use when planning or reviewing tests for UI code, deciding between unit, component, visual regression and end-to-end tests, fixing flaky UI tests, or defining the device and browser matrix with qa.
---

# UI Testing Strategy

## Purpose
Get fast, trustworthy evidence that the UI works, at the lowest level that can prove each behaviour, with a small stable set of end-to-end journeys.

## When to use
- Starting a feature: decide the test mix from the screen spec.
- A UI test is flaky, slow or brittle.
- Preparing the test scope handed to qa (`TP-`, `TC-`).

## Principles
- Pyramid, roughly 70% unit, 20% component, 10% e2e by count. Push checks down; e2e covers only critical journeys (sign-in, core transaction, recovery).
- Test behaviour a user can observe (roles, labels, visible text), not implementation details (internal state, CSS classes, private methods).
- Deterministic by construction: fake clocks, seeded data, mocked network at the client-layer boundary, no sleeps (wait on conditions), isolated state per test.
- Every state in the spec (loading, empty, error, offline, disabled) has at least one component test.
- Accessibility is tested: automated a11y assertions in component tests plus the manual pass in `accessibility-audit`.
- Visual regression guards the design system, not every screen: baseline per component state per theme; approvals reviewed by a human; pixel tolerance set to avoid font-rendering noise.
- Flaky tests are defects: quarantine with an owner and a deadline (5 working days, per qa rules), never retry-until-green.
- Never real user data or production secrets in fixtures.

## Checklist
- [ ] Each acceptance criterion in `screen-spec.md` maps to a `TC-NNN` at a stated level.
- [ ] Unit: pure logic, formatters, reducers, mappers (error envelope to message key). Target 80% lines on changed code for T2+ (`project-tiers.md`); T1 critical paths.
- [ ] Component: rendering per state, interactions, keyboard operation, accessible names, i18n pseudo-locale render.
- [ ] Contract: client layer tested against schema-generated mocks for success and each mapped error (`API-NNN`).
- [ ] Visual: baselines for shared components (T2+); reviewed diffs only.
- [ ] E2E: 3-10 journeys, run on every merge to main or nightly; each under 5 minutes; against a stable test backend.
- [ ] Network faults: offline, slow, 5xx, expired token exercised at least at component level.
- [ ] Device and browser matrix defined by qa in `TP-NNN` (versions from `context.md`); this file does not duplicate it. Real devices for gestures, permissions and performance; emulators for the rest.
- [ ] Test run time budget: unit + component under 5 minutes in CI.

## Steps
1. From the spec, list behaviours; assign each to the lowest effective level.
2. Write tests first for logic and state; then component tests for states; e2e last.
3. Wire into CI with lint, type check and a11y assertions; publish reports.
4. Track flake rate (target < 1%) and slowest tests monthly.

## Output format
| TC | Level | Behaviour | Criterion (`FEAT-NNN` #) | Automated | Matrix |
|----|-------|-----------|--------------------------|-----------|--------|
| TC-NNN | component | Error state shows retry and announces alert | FEAT-NNN #3 | yes | primary |

## References
`../_shared/standards/definition-of-done.md`, `project-tiers.md`, `nfr-catalog.md`; qa skills `test-plan`, `test-case-writing`, `contract-and-e2e-strategy`; skills `accessibility-audit`, `api-integration-and-resilience`; IDs `FEAT-NNN`, `TC-NNN`, `TP-NNN`.

## Language notes
- Web: Vitest/Jest + Testing Library, Playwright, Storybook snapshots. iOS: XCTest, XCUITest, snapshot testing. Android: JUnit, Compose test rule, Espresso, screenshot tests. Flutter: `flutter_test` widget tests, golden files, integration_test. Electron: Playwright with Electron support.
