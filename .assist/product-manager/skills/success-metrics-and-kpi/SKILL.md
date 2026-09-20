---
name: success-metrics-and-kpi
description: Use when defining how a FEAT- will be judged successful, setting baselines, targets, and guardrails, or reviewing KPI health after release. Trigger on "how will we know it worked".
---
# Success Metrics and KPIs

## Purpose
Define, before build starts, the few measurable outcomes that prove a feature worked and the guardrails that show it did no harm.

## When to use
- Writing or reviewing the Success metrics section of a `FEAT-`.
- Setting the goals table in `context.md`.
- A post-release review, or a KPI that moved unexpectedly.

## Principles
- Outcome over output: "task completion rate" beats "screens shipped".
- One primary metric per feature, at most two supporting metrics, and at least one guardrail.
- Every metric has a precise definition (numerator, denominator, window, exclusions), a baseline with date and source, a target with a date, and an owner.
- No baseline means the first deliverable is instrumentation; do not invent a baseline.
- Leading indicators (adoption, activation) predict; lagging indicators (retention, revenue, cost) confirm. Use both.
- Instrumentation must respect `data-governance.md`: no personal data in event payloads beyond what is justified.

## Steps
1. Restate the goal as an outcome for a segment ("cut time to resolve a request for support agents").
2. Choose the primary metric and write its definition.
3. Add supporting metrics: one adoption, one quality or efficiency.
4. Add guardrails: reliability (`SLO-`), cost, support volume, complaint rate, and any compliance measure.
5. Capture the baseline: value, period, source, sample size. If missing, schedule measurement.
6. Set the target and the date, and the minimum detectable change so a small sample is not over-read.
7. Define the review points (for example day 7, 30, 90) and who decides continue, iterate, or roll back.
8. Ask devops and backend for events, dashboards, and alerts; link `SLO-` where it is user-facing.

## Definition example
| Field | Value |
|-------|-------|
| Metric | Request completion rate |
| Definition | Completed requests within one session / requests started, excluding test accounts, weekly |
| Baseline | 62% (weeks of <YYYY-MM-DD>, source: `<analytics tool>`, n = 4,100) |
| Target | 75% within 60 days of full rollout |
| Guardrails | p95 latency at or below the `SLO-NNN` target; support tickets per 1,000 requests not above baseline +10%; error rate not above 0.5% |
| Owner / review | <name>; day 7, 30, 60 |

## Output format
Metrics table inside `FEAT-NNN` (baseline, target, guardrail, measured by) and, for durable KPIs, a row in the goals table of `context.md`. Post-release review note: result vs target, decision (keep / iterate / revert), follow-up `FEAT-`.

## References
- `_shared/standards/slo-sli-template.md`, `nfr-catalog.md`, `data-governance.md`, `production-readiness-review.md` (row 8)
- IDs: `FEAT-`, `SLO-`, `RISK-`; skills: `rollout-plan`, `write-feature-spec`
