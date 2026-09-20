# FEAT-002: Timeline

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (see the decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-002 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-20 |
| Priority score | Not scored. v1 must-have by decision `v1-scope-and-non-goals`; relative effort read obtained, not scored |
| Related capability | none (new) |
| Related IDs | ADR-002, RISK-004, TP-001 |

## Problem
A writer needs to browse and re-read past entries.

Evidence: none yet. This is the owner's hypothesis; the product has no users and collects no usage data (see `context.md`).

## Users
| Segment | Need | How they meet this feature |
|---|---|---|
| Journal writer (primary, hypothesis) | See past entries by date | Uses this feature in the app |

## Goals
- The entry list opens quickly and stays smooth however large the journal grows.

## Non-goals
- Calendar view, filters, tags, favourites (later versions).

## Proposed behaviour
1. After unlock the main screen lists entries newest first, grouped by day, each with a short preview of the text.
2. Tapping an entry opens it (FEAT-001).
3. With no entries, an empty state invites the user to write the first one.
4. If a backup is overdue, a reminder is shown above the list (FEAT-008).

## User stories
- As a journal writer, I want to scroll through my entries by date, so that I can re-read what I wrote.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases are in `TP-001`.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | Entries on different dates | The timeline opens | Entries are listed newest first, grouped by day | TC-016 |
| AC-2 | No entries | The timeline opens | An empty state with an action to write the first entry is shown | TC-017 |
| AC-3 | An entry in the list | The user taps it | The entry opens | TC-018 |
| AC-4 | A very large journal | The user scrolls quickly | Scrolling stays smooth: at least 95% of frames render within 16.7 ms (`nfr-targets-v1`, a journal of 20,000 entries, provisional until measured) | TC-019 |
| AC-5 | The app is locked | The timeline would be shown | No entry text is visible | TC-020 |

## NFR and compliance impact
| Area | Requirement | Source |
|---|---|---|
| Privacy | Journal content never leaves the device unless the user explicitly exports it | `project.md` principle 1, THR-002, THR-005, ADR-001 |
| Performance | Start-up to the entry list and scrolling must stay responsive; provisional targets: cold start within 2 s at the 95th percentile, 95% of frames within 16.7 ms at 20,000 entries, confirmed by measurement on the reference device | decision `nfr-targets-v1` (decided 2026-09-20) |
| Accessibility | Meets WCAG 2.2 AA: text contrast, touch targets, screen-reader labels, system font scaling | `compliance-matrix.md` (WCAG row), `nfr-catalog.md` |
| Compliance | Journal text is Restricted data (`data-governance.md`), stored on the device only, no recipients, kept until the user deletes it; UU PDP and GDPR rows are Confirm, not binding until confirmed | `compliance-matrix.md`, RISK-008 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|---|---|---|---|---|---|
| Timeline correctness | Ordering and grouping defects found by tests | none (no prior version) | 0 defects at each release | Crash-free sessions from the store consoles (platform data, not app telemetry); target to be set after the first release | Automated tests before each release, owned by qa; store consoles after release |

## Rollout
Ships with v1 in a staged release with a halt rule (decision `v1-rollout-plan`); rollback means halting the rollout and shipping a fixed build.

## Risks
| ID | Risk | Owner |
|---|---|---|
| RISK-004 | Encrypted storage misbehaves on a platform | Software architect |

## Dependencies
- FEAT-001, FEAT-003, FEAT-008.
- Effort read from frontend-mobile (2026-09-20): size M, relative, low confidence until the technical spike; drivers and constraints are in the frontend-mobile effort read. Not a schedule.

## Decisions
- None.
- Journal size to design for: 20,000 entries (decision `nfr-targets-v1`, provisional until measured, 2026-09-20).

## Open questions
None. Closed by the owner on 2026-09-20: the journal size to design for is 20,000 entries (provisional until measured).

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-20 | draft | migrated from the earlier draft and rewritten to role rules (behaviour only, no invented numbers) |
| 2026-09-20 | draft | test cases assigned by qa (TP-001); acceptance criteria unchanged |
| 2026-09-20 | draft | owner decisions applied: journal size 20,000 entries, scrolling target |
| 2026-09-20 | draft | effort read obtained from frontend-mobile (size M); waiting for the owner to confirm `ready` |
| 2026-09-20 | in-progress | owner asked for FEAT-002 to be built next; timeline built on FEAT-001's host screen; AC-1 to AC-3 tested on the Android emulator; AC-4 measured on the emulator only (see the test case); AC-5 waits for FEAT-003; reminder (FEAT-008) and search (FEAT-005) not included |
