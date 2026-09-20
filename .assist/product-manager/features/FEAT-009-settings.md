# FEAT-009: Settings

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-009 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-001, RISK-001, RISK-005, TP-001 |

## Problem
The user needs a few basic controls: appearance, security, and where to find export and import.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Adjust the app and manage security | Uses this feature in the app |

## Goals
- Only the settings that matter for v1, each simple and safe.

## Non-goals
- Notification settings, cloud settings, extra languages beyond those decided in `platforms-and-languages`.

## Proposed behaviour
1. Theme: follow the phone, light, or dark.
2. Change passcode: needs the current passcode, then a new one entered twice. All entries stay readable.
3. Biometrics: turn on or off.
4. Lock timeout: Immediately (default), 1 minute, 5 minutes, or 15 minutes.
5. Export and import: entry points to FEAT-006 and FEAT-007, with the last export time (FEAT-008).
6. About and privacy: a short, accurate statement of what the app does and does not do with data.
7. Language: follow the phone (default), English, or Indonesian. The change applies at once and is kept.

## User stories
- As a journal writer, I want to change my passcode, so that I can keep my journal secure over time.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | The settings screen | The user picks a theme | The app switches and keeps the choice after a restart | TC-075 |
| AC-2 | The user knows the current passcode | They change it | The new passcode opens the app | TC-076 |
| AC-3 | The user knows the current passcode | They change it | All entries are still readable | TC-077 |
| AC-4 | A wrong current passcode | The user tries to change it | The change is refused | TC-078 |
| AC-5 | A new lock timeout is chosen | The app stays in the background that long | The app locks | TC-079 |
| AC-6 | Biometrics are turned off | The app is locked | Only the passcode unlocks it | TC-080 |
| AC-7 | The privacy statement | It is reviewed | Every claim traces to a requirement and a test | TC-081 |
| AC-8 | The settings screen | The user picks Indonesian | All app text is in Indonesian and stays so after a restart | TC-098 |
| AC-9 | A phone set to a language other than English or Indonesian | The app is opened for the first time | The app is in English | TC-099 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Security | Changing the passcode never exposes content or leaves data unreadable | ADR-001, RISK-005 |
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Settings integrity | Settings that fail to apply, or a passcode change that loses access, found by tests | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-001 | User loses data (a failed passcode change could lock the user out) | Project owner |
| RISK-005 | Cryptography mistake weakens the privacy claim | Cyber-security |

## Dependencies
- FEAT-003, FEAT-004, FEAT-006, FEAT-007.
- Effort read from frontend-mobile (2026-09-20): size M, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- None.
- Two interface languages, English and Indonesian, switchable in Settings; the default follows the phone, English otherwise (decision `platforms-and-languages`, 2026-09-20).
- Lock timeout choices (decision `lock-and-passcode-policy`, 2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: two languages (English and Indonesian) with a switch in Settings.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | owner decisions applied: language setting and lock timeout choices; criteria AC-8 and AC-9 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size M); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked to finish all features; settings screen, change passcode, theme, language (English and Indonesian), lock timeout, biometrics switch and About built; AC-1 to AC-6, AC-8 and AC-9 tested; AC-7 partial; the Indonesian text is a draft for the owner to review |
