---
name: rollout-plan
description: Use when a FEAT- is approaching release and needs a staged rollout, feature flags, pilot, communication, and rollback plan. Also use when a launch date is proposed without gates.
---
# Rollout Plan

## Purpose
Release a feature in controlled stages with objective go/no-go gates, so a defect or a bad adoption signal affects few users and is reversible.

## When to use
- A `FEAT-` moves to `ready` or `in-progress` and will reach users.
- Changing live behaviour, data, pricing, or permissions.
- Preparing the Product row of `production-readiness-review.md`.

## Principles
- Depth follows tier (`project-tiers.md`): T1 repeatable release with written rollback; T2 staged rollout with tested rollback; T3 canary with automatic halt and change approvals.
- Every stage has entry criteria, an exit gate with numbers, and a named decider.
- Rollback is decided before launch: trigger, who pulls it, how long it takes, what happens to data created meanwhile.
- Separate deploy from release: use flags so exposure changes without a redeploy.
- Money, personal data, and irreversible migrations get a smaller first stage and a longer soak.

## Steps
1. Define audience slices: internal, pilot customers, 5%, 25%, 100% (adjust to volume; T1 may use internal then all).
2. For each stage set duration or sample, entry criteria, and exit gate.
3. Set halt triggers from the metrics in the spec, for example error rate above baseline +0.5 points, guardrail `SLO-` burn above 2x, or complaint spike.
4. Confirm with QA that critical `TC-` pass and with devops that `RB-`, dashboards, and alerts exist before stage 1.
5. Plan data and migration handling: reversible or not, backfill, dual-write period.
6. Plan communication: who is told what, when (`stakeholder-communication`); support briefing and user-facing notes.
7. Schedule the post-release review against the metric targets.
8. Record approvals and the go/no-go outcome; store waivers per `production-readiness-review.md`.

## Stage gate example
| Stage | Audience | Duration | Exit gate | Decider |
|-------|----------|----------|-----------|---------|
| 0 Internal | staff | 3 days | No S1/S2 defects; all critical `TC-` pass | QA + PM |
| 1 Pilot | 5% of users | 7 days | Error rate at or below baseline +0.2 pts; latency within `SLO-NNN`; no P0/P1 | PM + devops |
| 2 Expand | 25% | 7 days | Primary metric trend positive; support tickets within +10% | PM |
| 3 General | 100% | soak 14 days | Targets on track; flag cleanup scheduled | PM + product owner |

## Rollback
Trigger list, owner, method (flag off / redeploy / data restore), expected time, user impact, communication text.

## Output format
Rollout section in `FEAT-NNN` or `decisions/<slug>.md`: stage table, halt triggers, rollback, communication plan, review date.

## References
- `_shared/standards/release-management.md`, `project-tiers.md`, `production-readiness-review.md` (rows 10, 13), `severity-and-incident.md`
- IDs: `FEAT-`, `TC-`, `TP-`, `RB-`, `SLO-`, `RISK-`
