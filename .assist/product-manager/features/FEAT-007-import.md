# FEAT-007: Import

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-007 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-001, ADR-002, ADR-003, RISK-002, THR-008, TP-001 |

## Problem
After changing phones or reinstalling, the user must get the whole journal back from an export, safely, even if the export came from an older app version.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Restore my journal on a new device | Uses this feature in the app |

## Goals
- Importing an export restores all entries, and a bad or unsupported file never damages the existing journal.

## Non-goals
- Importing from other journaling apps, importing photos or audio (later versions).

## Proposed behaviour
1. The user picks a backup file. For an encrypted file, they enter the export password.
2. The app checks the file. A file from an older app version is upgraded. A file from a newer, unsupported version is refused with a message to update the app.
3. If the journal already has entries, entries already present are kept unchanged and missing ones are added. An entry with the same id but different text is never overwritten; it is counted as skipped.
4. The import either fully succeeds or leaves the journal unchanged.
5. On success the user sees how many entries were added and how many were skipped.

## User stories
- As a journal writer, I want to import my export on a new phone, so that I get my whole journal back.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | An export of N entries and a fresh install | It is imported | All N entries are present with the same text and dates | TC-058 |
| AC-2 | An encrypted file | A wrong password is entered | The import is refused and nothing changes | TC-059 |
| AC-3 | A damaged or cut-off file | It is imported | The import is refused and the journal is unchanged | TC-060 |
| AC-4 | A file made by an older app version | It is imported | All its entries are restored | TC-061 |
| AC-5 | A file made by a newer unsupported version | It is imported | A message asks the user to update the app and nothing changes | TC-062 |
| AC-6 | A journal that already has some of the file's entries | The file is imported | No duplicates are created | TC-063 |
| AC-7 | An import that is interrupted midway | The app is opened again | The journal is unchanged | TC-064 |
| AC-8 | An entry with the same id exists on the phone with different text | The file is imported | The entry already on the phone is kept unchanged and counted as skipped | TC-097 |
| AC-9 | A fresh install where the user chose to import a backup | The import starts | A passcode has already been set | TC-102 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Security | Imported files are treated as untrusted and checked before use; a malformed file cannot damage data | ADR-003, THR-008 |
| Durability | The import applies fully or not at all | ADR-002, THR-010 |
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Import round trip | Entries that differ after exporting and importing again, found by tests | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-002 | An export cannot be imported after an update | Software architect |

## Dependencies
- FEAT-006, ADR-003.
- Effort read from frontend-mobile (2026-09-20): size L, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- The import never partly applies (2026-09-20).
- Merge rule: keep the entry already on the phone, add the missing ones, report how many were skipped (2026-09-20).
- On a fresh install, passcode setup comes first and the import follows (2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: merge rule (existing entries kept, none overwritten) and restore after passcode setup.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | restore/setup order raised as an open question from the ux-design flow review |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | owner decisions applied: merge rule, restore order; criteria AC-8 and AC-9 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size L); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked to continue; import screens and the importer built; AC-1 to AC-3, AC-6 to AC-9 tested; AC-4 not testable (only formatVersion 1 exists); AC-5 partial; import limits are provisional |
