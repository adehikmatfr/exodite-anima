# FEAT-003: App lock and screen privacy

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-003 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-001, THR-001, THR-004, THR-007, RISK-003, TP-001 |

## Problem
Someone holding an unlocked phone (a partner, a friend, a borrowed device) must not be able to read the journal.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Only I can open my journal | Uses this feature in the app |

## Goals
- The journal is unreadable without biometrics or the passcode, including in the app switcher.

## Non-goals
- Remote wipe, decoy or duress passcode, intruder photos.

## Proposed behaviour
1. On a cold start the app shows a lock screen and asks for biometrics, with the passcode as a fallback.
2. The app locks when it has been in the background for longer than the chosen timeout: Immediately (the default), 1 minute, 5 minutes, or 15 minutes.
3. In the app switcher the app shows a blank or obscured preview instead of content.
4. Five wrong passcodes are free. After that the wait is 30 seconds and doubles with each further wrong attempt, up to one hour, and it continues after the app is closed and reopened.
5. If biometrics are cancelled, unavailable, or changed on the device, the passcode still unlocks the app.
6. On Android, screenshots and screen recording are blocked. On iOS the content is hidden in the app-switcher preview (iOS cannot block screenshots).

## User stories
- As a journal writer, I want the app to lock itself, so that nobody can read it if I hand over my phone.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | The app was closed | It is opened | The lock screen appears with no entries visible | TC-021 |
| AC-2 | The app is unlocked | It stays in the background longer than the timeout | It is locked when the user returns | TC-022 |
| AC-3 | The app is unlocked | The user opens the app switcher | No entry content is visible in the preview | TC-023 |
| AC-4 | The lock screen | Biometrics are cancelled or fail | The passcode field is offered | TC-024 |
| AC-5 | The lock screen | The correct passcode is entered | The app unlocks | TC-025 |
| AC-6 | The lock screen | Several wrong passcodes are entered | The wait before the next attempt grows | TC-026 |
| AC-7 | Several wrong passcodes were entered | The wait is running | No journal content is visible | TC-027 |
| AC-8 | Another fingerprint or face was added on the device | The user unlocks with the passcode | The app opens and all entries are intact | TC-028 |
| AC-9 | Five wrong passcodes were entered | Another wrong passcode is entered | The app waits 30 seconds before the next attempt, and the wait doubles with each further wrong attempt up to one hour | TC-093 |
| AC-10 | A wait is running after wrong passcodes | The app is closed and opened again | The wait continues and the count of wrong attempts is kept | TC-029 |
| AC-11 | The app is open on Android | The user takes a screenshot or records the screen | The capture is blocked | TC-094 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Security | Unlocking never exposes content to someone without the passcode or biometrics; content is hidden when the app is in the background | THR-001, THR-004, ADR-001 |
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Lock enforcement | Ways found by tests to see content while locked | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-003 | Content leaks through a side channel | Cyber-security |
| RISK-005 | Cryptography mistake weakens the privacy claim | Cyber-security |

## Dependencies
- FEAT-004 (the passcode is created at setup).
- Effort read from frontend-mobile (2026-09-20): size L, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- The passcode is always available as a fallback to biometrics (ADR-001).
- Wait after wrong passcodes, lock timeout choices, and Android screenshot blocking (decision `lock-and-passcode-policy`, 2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: wait rule (5 free, then 30 s doubling to 1 hour), timeout choices (Immediately, 1, 5, 15 minutes), Android screenshots blocked.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | owner decisions applied: wait rule, timeout choices, Android screenshot blocking; criteria AC-9 to AC-11 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size L); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked to continue; lock screen, wrong-try waits, auto-lock and screen privacy built; AC-1, AC-2, AC-5 to AC-7, AC-9, AC-10 tested on emulator; AC-3, AC-4, AC-8, AC-11 partly; real biometrics not tried |
