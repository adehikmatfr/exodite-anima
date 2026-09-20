# How is version 1 released and how is a bad release handled?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided (numbers to follow) |
| Date | 2026-09-20 raised |
| Decider | Project owner (solo) |
| Related | all FEAT, RISK-007 |
| Supersedes / superseded by | none |

## Context
A shipped mobile app cannot be rolled back; old versions stay in use, and both stores review each release. For T1 the rule is a repeatable release with a written rollback. The stage gates need numbers (halt triggers) that do not exist yet because there is no baseline.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Internal testing, then a small production percentage, then full release, with a halt rule | Limits the damage of a bad release | Needs numeric halt triggers, which need a baseline | Low | Low |
| 2 | Release to everyone at once | Simplest | A bad release reaches all users and cannot be recalled | Lowest | High |
| 3 | Do nothing | None | No rollback plan; the readiness review row fails | None | Blocks release |


## Decision
Decided by the project owner on 2026-09-20: option 1, **a staged release with a halt rule**: internal testing first, then a small percentage of production, then everyone (Google Play staged rollout 1%, 10%, 50%, 100%; iOS phased release later), holding each step at least 24 hours, as proposed in `frontend-mobile` release plan.

- Rollback path: a shipped build cannot be recalled, so the levers are halting the rollout and shipping a fixed build (there is no remote kill switch, by design: the app has no network).
- The halt triggers (for example a crash-free rate under a number) need a baseline from the first stage, so their numbers are set after the internal test. Until then the rule is: halt on any report of lost or unreadable journals.
- **Android first:** the first release is Android only (see `v1-choices-2026-09-20`).

## Consequences
- Feeds the Release row of `production-readiness-review.md` (frontend-mobile owns store release).
- Halt triggers to be set from the first release baseline (crash-free rate from the store consoles).
