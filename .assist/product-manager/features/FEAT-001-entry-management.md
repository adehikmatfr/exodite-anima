# FEAT-001: Entry management

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-001 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-001, ADR-002, RISK-001, THR-010, TP-001, ADR-006 |

## Problem
A writer needs to record entries, revise them, and remove them for good, and must never lose what they typed because the app was interrupted.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Write freely and trust nothing is lost | Uses this feature in the app |

## Goals
- Writing an entry takes few steps.
- Text the user typed is never lost by an interruption.
- Deleting an entry is permanent and unambiguous.

## Non-goals
- Rich text, photos, audio, tags, mood, templates, or multiple journals (later versions).

## Proposed behaviour
1. The user starts a new entry. The date defaults to today and can be changed.
2. The user types plain text. The app keeps an unsaved draft as the user types.
3. The user saves. Empty entries are not saved.
4. The user can reopen an entry, edit it, and save again.
5. Deleting asks for confirmation. After confirmation the entry is gone for good.
6. Failure path: if the app is closed while the user is typing, the unsaved text is offered back at the next unlock.
7. If the journal cannot be opened (damaged data, or a key that does not match), the app says nothing was deleted and offers Try again and Import your journal.
8. After an update whose data migration fails, the journal is restored to its state before the update. A journal saved by a newer version of the app is never changed by an older version; the older version asks the user to update.

## User stories
- As a journal writer, I want my text kept as I type, so that an interruption never loses it.
- As a journal writer, I want to delete an entry permanently, so that it is really gone.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | The app is unlocked | The user writes text and saves | A new entry with that text and today's date appears in the timeline | TC-001 |
| AC-2 | An existing entry | The user changes its text and saves | The entry shows the new text | TC-002 |
| AC-3 | A saved entry | The app is closed and opened again | The saved text is unchanged | TC-003 |
| AC-4 | The user is typing an unsaved entry | The app is force-closed | The unsaved text is offered back at the next unlock | TC-004 |
| AC-5 | An existing entry | The user changes its date and saves | The entry appears under the chosen date in the timeline | TC-005 |
| AC-6 | An existing entry | The user deletes it and confirms | The entry no longer appears in the timeline | TC-006 |
| AC-7 | An existing entry | The user starts to delete and then cancels | The entry is unchanged | TC-007 |
| AC-8 | An empty editor | The user tries to save | No entry is created | TC-008 |
| AC-9 | The journal cannot be opened (damaged data, or a key that does not match) | The app starts and unlocks | A message says nothing was deleted and offers Try again and Import your journal | TC-092 |
| AC-10 | A journal last saved by a newer version of the app | An older version of the app opens it | The older version refuses to change it and asks the user to update the app | TC-101 |
| AC-11 | An update whose data migration fails | The app starts | The journal is restored to its state before the update and opens | TC-100 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Durability | A crash or forced close never loses or alters a saved entry | THR-010, ADR-002 |
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Performance | Opening and saving an entry must stay responsive; provisional targets: save within 300 ms, cold start within 2 s at the 95th percentile, confirmed by measurement | decision `nfr-targets-v1` (decided 2026-09-20) |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Saved-entry integrity | Entries lost or altered after saving, found by crash and restart tests | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-001 | User loses data | Project owner |

## Dependencies
- FEAT-003 (the journal is unlocked before writing).
- Effort read from frontend-mobile (2026-09-20): size L, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- Plain text only in v1 (`v1-scope-and-non-goals`).
- No artificial maximum entry length in version 1; the technical bound is set by the software-architect from the spike (2026-09-20).
- When the journal cannot be opened the app shows screen S14: a message, Try again, and Import your journal (2026-09-20).
- Data migrations follow ADR-006 (2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: no artificial maximum entry length; the behaviour when the journal cannot be opened is screen S14.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | open question added by product-design: behaviour when the journal cannot be opened |
| 2026-09-20 | draft | owner decisions applied: no maximum length, journal-cannot-be-opened behaviour, migration safety (ADR-006); criteria AC-9 to AC-11 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size L); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked for FEAT-001 to be built first and approved setting it ready; effort read and every question are done; storage spike S1, S2, S8 passed on Android |
| 2026-09-20 | in-progress | storage layer and screens (editor, delete confirmation, draft dialog, save error, S14) built; AC-1 to AC-6 and AC-8 to AC-10 covered by automated tests on host and Android emulator; AC-7 covered on the emulator; AC-11 not built (no migration exists yet) |
| 2026-09-23 | in-progress | ADR-006's copy-before-migrate and restore-on-failure mechanics built (`app/lib/data/journal_database.dart`); AC-11 now Partial (TC-100), proven with a real migration failure (no `onUpgrade` step exists yet) rather than a real second schema, which arrives with FEAT-010 |
