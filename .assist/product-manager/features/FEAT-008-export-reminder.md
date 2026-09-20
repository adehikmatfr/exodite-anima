# FEAT-008: Export reminder

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-008 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | RISK-001, FEAT-006, TP-001 |

## Problem
There is no cloud copy. A user who never exports loses everything if the phone is lost or broken.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Be reminded to keep a backup | Uses this feature in the app |

## Goals
- Users are nudged to export regularly, without nagging and without any content in the reminder.

## Non-goals
- Push or scheduled notifications (v1 reminds only inside the app), automatic backup to a cloud.

## Proposed behaviour
1. Settings and the export screen show the last export time, or that no export was ever made.
2. The timeline shows a dismissible reminder when the journal has entries not covered by an export and either no export was ever made or the last one is more than 30 days old.
3. Dismissing hides the reminder for 7 days; it returns if the condition still holds.
4. The reminder never contains entry text.

## User stories
- As a journal writer, I want to be reminded to export, so that I do not lose my journal by accident.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | No export was ever made and the journal has entries | The timeline opens | The reminder is shown | TC-068 |
| AC-2 | A recent export and no new entries since | The timeline opens | No reminder is shown | TC-069 |
| AC-3 | The last export is more than 30 days old and new entries exist | The timeline opens | The reminder is shown | TC-070 |
| AC-4 | The reminder is shown | The user dismisses it | It is hidden for 7 days | TC-071 |
| AC-5 | A successful export | It completes | The reminder disappears | TC-072 |
| AC-6 | The reminder | It is shown | It contains no entry text | TC-073 |
| AC-7 | The last export is exactly 30 days old and new entries exist | The timeline opens | No reminder is shown; one day later it is shown | TC-074 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Privacy | The reminder never contains entry content | `project.md` principle 1, THR-005 |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Reminder rules | Wrong show or hide decisions found by tests | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-001 | User loses data | Project owner |

## Dependencies
- FEAT-006.
- Effort read from frontend-mobile (2026-09-20): size S, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- Reminders live inside the app only in v1 (2026-09-20).
- Reminder thresholds: more than 30 days since the last export, dismissed for 7 days (2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: the reminder appears after more than 30 days without an export and is hidden for 7 days when dismissed.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | owner decisions applied: reminder thresholds; criterion AC-7 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size S); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked to continue; reminder card on the timeline, last-export line on Settings and the export screen built; AC-1 to AC-7 tested (rules on the host, screens on the emulator); the clock is simulated; no notification is ever sent |
