# FEAT-004: Onboarding and passcode setup

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-004 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-001, RISK-001, THR-011, TP-001 |

## Problem
There is no account and no recovery, so the user must set a passcode and clearly understand that a forgotten passcode cannot be recovered.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Understand the privacy model and set up safely | Uses this feature in the app |

## Goals
- Every user sets a passcode and knowingly accepts the no-recovery rule before writing anything.

## Non-goals
- Account creation, long tutorials.

## Proposed behaviour
1. First launch explains in a few lines that everything stays on the phone, nothing is uploaded, and there is no account.
2. The user chooses a passcode of at least 8 characters and confirms it. A passcode on a list of very common passcodes is refused.
3. The user can turn on biometrics, or skip.
4. The app states plainly that a forgotten passcode cannot be recovered and that export is the backup. The user must acknowledge it to continue.
5. The user can also restore from a backup file: passcode setup comes first, then the import (FEAT-007).
6. After setup the empty timeline opens.

## User stories
- As a new user, I want to know what happens if I forget my passcode, so that I can decide before I start writing.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | First launch | No passcode has been set | The timeline cannot be reached | TC-032 |
| AC-2 | The passcode step | The confirmation does not match | An error is shown and setup does not continue | TC-033 |
| AC-3 | The passcode step | The passcode does not meet the passcode rules | An error explains the rule and setup does not continue | TC-034 |
| AC-4 | The warning step | The user has not acknowledged it | Setup cannot be completed | TC-035 |
| AC-5 | Setup is completed | The app is closed and opened again | The lock screen appears and the passcode opens the empty journal | TC-036 |
| AC-6 | The onboarding text | It is reviewed against the privacy statements | Every claim traces to a requirement and a test | TC-037 |
| AC-7 | The passcode step | A passcode of fewer than 8 characters, or one on the list of very common passcodes, is entered | The passcode is refused with a reason and setup does not continue | TC-038 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Security | The passcode is never kept in readable form | ADR-001, THR-007 |
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Store privacy labels must match what onboarding states | `compliance-matrix.md` (app store row), RISK-007 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Setup integrity | Ways found by tests to reach the journal without a passcode or acknowledgment | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-001 | User loses data | Project owner |

## Dependencies
- ADR-001.
- Effort read from frontend-mobile (2026-09-20): size M, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- No recovery key (ADR-001, 2026-09-20).
- Passcode rules (decision `lock-and-passcode-policy`, 2026-09-20).
- On a fresh install, passcode setup comes first and the import follows (2026-09-20).
- The interface is in English or Indonesian, following the phone by default (decision `platforms-and-languages`, 2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: passcode rules (at least 8 characters, common-passcode list), restore after passcode setup, English and Indonesian.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | restore/setup order raised as an open question from the ux-design flow review |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | owner decisions applied: passcode rules, restore order, languages; criterion AC-7 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size M); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked to continue; welcome, passcode, biometrics and warning screens built with the vault; AC-1 to AC-5 and AC-7 tested on emulator; AC-6 (privacy claims review) not done |
