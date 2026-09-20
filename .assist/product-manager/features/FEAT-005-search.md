# FEAT-005: Search

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-005 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-002, RISK-004, TP-001 |

## Problem
A writer needs to find something written earlier without scrolling through the whole timeline.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | Find past entries by words | Uses this feature in the app |

## Goals
- Fast text search across all entries, fully offline.

## Non-goals
- Filters by date range, tag, or mood (later versions).

## Proposed behaviour
1. The user types in a search field on the timeline.
2. Matching entries are listed newest first with the matching words highlighted in the preview.
3. Tapping a result opens the entry.
4. When nothing matches, a no-results message is shown.
5. Deleted entries never appear.

## User stories
- As a journal writer, I want to search my entries, so that I can find a memory or a detail quickly.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | Entries that contain a word | The user searches for that word | The matching entries are listed with the word highlighted | TC-040 |
| AC-2 | No entry contains the query | The user searches | A no-results message is shown | TC-041 |
| AC-3 | A result in the list | The user taps it | The entry opens | TC-042 |
| AC-4 | An entry that was deleted and contained the word | The user searches for it | The entry is not listed | TC-043 |
| AC-5 | No network connection | The user searches | Search works normally | TC-044 |
| AC-6 | A very large journal | The user searches | Results appear within 300 ms (`nfr-targets-v1`, provisional until measured) | TC-045 |
| AC-7 | An entry that contains the word Café | The user searches for cafe or CAFÉ | The entry is listed | TC-047 |
| AC-8 | An entry that contains the word river | The user searches for riv, and then for iver | The first search lists the entry and the second does not | TC-095 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Performance | Search results must stay responsive; provisional target: results within 300 ms at 20,000 entries, confirmed by measurement | decision `nfr-targets-v1` (decided 2026-09-20) |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Search correctness | Missing, extra, or stale results found by tests | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-004 | Encrypted storage misbehaves on a platform | Software architect |

## Dependencies
- FEAT-001, FEAT-002.
- Effort read from frontend-mobile (2026-09-20): size M, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- Search is part of v1 (`v1-scope-and-non-goals`).
- Matching: not case-sensitive, accents ignored, matches from the start of a word (2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: matching is not case-sensitive, ignores accents, and matches from the start of a word.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | owner decisions applied: matching rules, search time target; criteria AC-7 and AC-8 added |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size M); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked to finish all features; search built on the encrypted journal (full-text index kept in step by triggers); AC-1 to AC-5, AC-7 and AC-8 tested; AC-6 measured on an emulator only (21 ms median at 20,000 entries) |
