# What goes into version 1, and what is deliberately left out?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided |
| Date | 2026-09-20 raised / 2026-09-20 decided |
| Decider | Project owner (solo) |
| Related | FEAT-001 to FEAT-009, RISK-006 |
| Supersedes / superseded by | none |

## Context
The owner works alone, so version 1 must be small enough to finish. The product's promise is free and fully private, with no cloud, so backup and moving to a new device (export and import) are essential, not optional. The owner said photos and audio can come later. No usage data exists to rank features, so scope is set by the owner's judgement, not by scores.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Text journal with lock, search, export and import (chosen) | Small, delivers the whole promise | No photos or audio at launch | Lowest | Lowest |
| 2 | Add photos and audio to version 1 | Richer entries | Much larger export files and storage work, longer to finish | High | Larger data-loss and privacy surface |
| 3 | Drop search and export from version 1 | Fastest to build | Breaks the backup and move-phone promise | Lowest | Users lose data (RISK-001) |


## Decision
Version 1 is FEAT-001 to FEAT-009: write and edit text entries, timeline, app lock and screen privacy, onboarding with the no-recovery warning, search, export, import, export reminder, and settings. Photos (v1.1), audio (v1.2), tags, mood, favourites, a daily writing reminder, and rich text are planned after version 1. Non-goals: accounts, cloud sync, ads, subscriptions, in-app purchases, analytics and tracking, social sharing, AI features, and web or desktop versions. Decided by the owner on 2026-09-20.

## Consequences
- Roadmap: Now is version 1; Next is photos; Later is the rest (see `context.md`).
- The export format must leave room for photos and audio (ADR-003).
- Prioritisation scoring is not used: there is no reach data and no effort read yet. Build order follows dependencies. Revisit when effort reads exist.
- Revisit when the first release is out and real feedback exists.
