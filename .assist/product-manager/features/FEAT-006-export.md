# FEAT-006: Export

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-006 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-001, ADR-003, RISK-001, RISK-002, THR-006, TP-001 |

## Problem
With no cloud, export is the only backup and the only way to move to a new device. It must be simple, safe, and must not lock the user in.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Back up the journal and keep it when changing phones | Uses this feature in the app |

## Goals
- One action produces a single file that fully restores the journal, protected by default.

## Non-goals
- Automatic or scheduled export, upload by the app to any service, photos and audio (later versions, but the format must allow them).

## Proposed behaviour
1. The user starts an export and chooses encrypted (default) or plaintext.
2. For encrypted, the user enters and confirms an export password of at least 8 characters that is separate from the passcode.
3. For plaintext, a warning says anyone with the file can read the entries; the user must confirm. The plaintext file contains every entry in a form people can read and in a form other software can read.
4. The app creates one file and hands it to the phone's share or save dialog, so the user chooses where it goes. The app never uploads it.
5. On success the app records the time as the last export (FEAT-008).
6. Failure path: if creating or saving fails, no last export is recorded and the user is told.

## User stories
- As a journal writer, I want to export my journal to a file, so that I can restore it on a new phone.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | An encrypted export | The file is opened without the password | The entries cannot be read | TC-048 |
| AC-2 | An encrypted export | A wrong password is used | No entries are revealed | TC-049 |
| AC-3 | The plaintext option | The user selects it | A warning is shown before anything is created | TC-050 |
| AC-4 | A finished export | Its entry count is read | The count equals the number of entries in the journal | TC-051 |
| AC-5 | An entry that was deleted | An export is made | The deleted entry is not in the file | TC-052 |
| AC-6 | A successful export | It completes | The last export time is updated | TC-053 |
| AC-7 | A failed export | It ends with an error | The last export time is not changed | TC-054 |
| AC-8 | A very large journal | An export runs | Progress is shown | TC-055 |
| AC-9 | The export password step | The user enters a password of fewer than 8 characters | The password is refused with a reason and no file is created | TC-096 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Security | Encrypted exports are unreadable without the export password; no content in logs | ADR-001, ADR-003, THR-006, THR-007 |
| Durability | Every format version stays importable; verified by round-trip and cross-version tests | ADR-003, RISK-002 |
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Export round trip | Entries that differ after exporting and importing again, found by tests | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-001 | User loses data | Project owner |
| RISK-002 | An export cannot be imported after an update | Software architect |

## Dependencies
- ADR-001, ADR-002, ADR-003.
- Effort read from frontend-mobile (2026-09-20): size L, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- Encrypted by default, plaintext is an explicit opt-in (2026-09-20).
- Plaintext export contains both a readable and a machine-readable form (2026-09-20, ADR-003).
- Export password: at least 8 characters, separate from the passcode (decision `lock-and-passcode-policy`, 2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: export password rules (at least 8 characters).

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | open question added by product-design: export password rules |
| 2026-09-20 | draft | owner decision applied: export password rules; criterion AC-9 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size L); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked to continue; export screens (choose, password, warning, progress, done, error) and the file format built; AC-1 to AC-7 and AC-9 tested; AC-8 partial (progress not determinate); share dialog is faked in tests, the real Android share sheet was not exercised |
