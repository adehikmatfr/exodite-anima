# What numeric targets apply to speed and size in version 1?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided (provisional targets) |
| Date | 2026-09-20 raised / 2026-09-20 decided |
| Decider | Project owner (solo) |
| Related | FEAT-001, FEAT-002, FEAT-005, RISK-004 |
| Supersedes / superseded by | none |

## Context
Several acceptance criteria need numbers (start-up time, search time, largest journal, export time). The role rules forbid guessing them. `nfr-catalog.md` gives templates, not values for an offline mobile app, and says to record final values in an ADR.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Adopt targets after measuring on the lowest-tier device in the device list | Numbers come from evidence | Needs the device list and a working prototype | Medium | Low |
| 2 | The owner sets the numbers now | Fast | May be unrealistic, and would be guesses | Lowest | Criteria fail later |
| 3 | Do nothing | None | Criteria stay incomplete and specs cannot reach `ready` | None | Blocks readiness |


## Decision
Decided by the project owner on 2026-09-20 with the condition "only realistic targets".

The following are the version 1 targets, measured on the lowest-tier reference device in a release build. They are **provisional**: each is confirmed or corrected by measurement in the technical spike, and a target that turns out to be unrealistic is corrected, not shipped as a claim.

| Target | Value |
|--------|-------|
| Unlock after a biometric success to the timeline | 95th percentile at most 1 s |
| Cold start to the lock or timeline screen | 95th percentile at most 2 s |
| Saving an entry acknowledged | 95th percentile at most 300 ms |
| Search results, for a journal of 20,000 entries | 95th percentile at most 300 ms |
| Journal size to design for (stress case) | 20,000 entries |
| Restore of a stress-size export | at most 60 s, with progress shown |
| Scrolling | at least 95% of frames within 16.7 ms (mobile-skill default) |
| Memory in the foreground | at most 250 MB on a 3 GB device (mobile-skill default) |
| Store download size | not set: the empty template is already a 41.4 MB universal APK; set after the first bundle size is measured |
| Stability after release | crash-free sessions of at least 99.5% in the store consoles |

On 2026-09-20 the owner chose an emulator with limited resources as the reference. Emulator graphics speed is not stable between sessions, so it cannot prove the frame-rate target; CPU-bound numbers are indications only. The targets stay provisional until a physical phone is measured. Still needed to measure: a physical low-end phone (owner) and the Android and iOS versions chosen in `platforms-and-languages`.

## Consequences
- Specs FEAT-001, FEAT-002, FEAT-005 no longer wait for this decision; their performance criteria carry the numbers above, provisional until measured.
- Needs the device list from `platforms-and-languages`.

## Input from frontend-mobile (2026-09-20)
The mobile skills give default budgets. They are candidates with a documented source, not decisions; the owner still decides (measured on the low-end reference device, release build).

| Metric | Skill default (low-end device) | Note |
|--------|-------------------------------|------|
| Cold start to first interactive frame | p90 at most 2.0 s | Matches the assumption in NFR-2 |
| Warm start | p90 at most 0.8 s | |
| Frame rate | At least 95% of frames under 16.7 ms; frozen frames under 0.1% | |
| Screen transition to content from local data | p90 at most 500 ms | |
| Memory in the foreground | At most 250 MB on 3 GB devices | |
| Store download size | At most 50 MB | **Measured: the empty template app is a 41.4 MB universal release APK** (the store download for Android is smaller, but this shows the budget needs an explicit owner decision) |
| Battery | Under 2% per hour of active use | |
| Crash-free sessions and ANR | At least 99.5% and under 0.47% | Only visible in the store consoles |

Still needed before deciding: the low-end reference device and the supported OS versions (`platforms-and-languages`).
