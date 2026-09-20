# Which key-derivation settings protect the passcode (security gap G1)?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided (provisional until a second phone is measured) |
| Date | 2026-09-20 |
| Decider | Project owner (solo) |
| Related | ADR-001, FEAT-003, FEAT-004, G1, RISK-005 |
| Supersedes / superseded by | none |

## Context
The passcode opens the journal through Argon2id. The first setting (32 MiB, 3 passes, 1 lane) took a median 2.95 s on a physical phone (Android 11, arm64), against 0.34 s on the emulator (spike S4 in `frontend-mobile/report/technical-spike-plan.md`). Only this one phone was measured, in a profile build.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Keep 32 MiB, 3 passes, 1 lane | No change | About 3 s to open with the passcode | None | Users may pick weak passcodes to avoid the wait, or give up |
| 2 | 64 MiB, 3 passes, 2 lanes | About 1.3 s on the measured phone; double the memory per guess for an attacker | More memory needed on the phone; measured on one device only | Small code change | A phone with little memory may fail to unlock |
| 3 | 19 MiB, 2 passes, 1 lane | About 1.3 s | Lowest cost per guess for an attacker | Small code change | Weaker protection |
| 4 | Measure a second phone first | Better evidence | Delay | Owner's time | None |

## Decision
Decided by the project owner on 2026-09-20: **option 2, 64 MiB, 3 passes, 2 lanes.** The default in `app/lib/security/key_vault.dart` was changed; a vault keeps the settings it was written with (a test covers this), and a passcode change writes the new default. The export and import setting (64 MiB, 3 passes, 1 lane, about 5.8 s on the same phone) was not part of this decision and is unchanged.

## Consequences and open items
- Measured before the change only; the in-app time after the change was not measured (a scripted run showed that unlock works, but its timing includes the tool's own delay).
- G1 stays open until a second phone, ideally with little memory, is measured and an independent reviewer has read the design (RISK-005).
- The owner may want the export setting reviewed for the same reason (5.8 s per export or import on the measured phone).
