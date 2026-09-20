---
name: prioritization
description: Use when there are more FEAT- candidates than capacity, when a stakeholder asks what to build first, or when the roadmap horizon must be re-ranked. Produces scored ranking with recorded overrides.
---
# Prioritization

## Purpose
Rank competing `FEAT-` candidates with a consistent, written method so the order can be explained and defended, and so overrides are visible rather than silent.

## When to use
- Planning a cycle or quarter; new urgent request competes with committed work.
- Two stakeholders disagree on order.
- Re-basing the "Now / Next / Later" horizon in `context.md`.

## Principles
- Use a framework, not gut feel; write down the scores, not only the order.
- Effort comes from engineering's read, never a PM guess. No effort read means send the item back.
- Scores rank; they do not decide alone. Compliance, security, and incident-driven work may jump the queue, but as a labelled override.
- Low confidence lowers the score; it is a reason to run a discovery task first.
- Choose one method per cycle and keep it stable.

## Method A: RICE (default for product growth and improvement work)
`RICE = (Reach x Impact x Confidence) / Effort`
- Reach: users or events affected per cycle (integer, state the window).
- Impact: 3 massive, 2 high, 1 medium, 0.5 low, 0.25 minimal.
- Confidence: 100% evidence, 80% some evidence, 50% opinion.
- Effort: person-weeks from engineering.

Worked example (cycle = one quarter):
| Candidate | Reach | Impact | Confidence | Effort | RICE |
|-----------|-------|--------|-----------|--------|------|
| FEAT-NNN bulk export | 2,000 | 1 | 80% | 4 | 400 |
| FEAT-NNN saved filters | 6,000 | 0.5 | 100% | 3 | 1,000 |
| FEAT-NNN audit trail view | 300 | 2 | 50% | 5 | 60 |

Ranking: saved filters, bulk export, audit trail view.

## Method B: Weighted scoring (use when value is not one number, or when strategy matters)
`Score = sum(weight_i x rating_i) / Effort_factor`, ratings 1-5, weights sum to 100%.
Example weights: revenue or cost impact 30%, user pain 25%, strategic fit 20%, risk reduction 15%, learning value 10%.
| Candidate | Rev 30 | Pain 25 | Fit 20 | Risk 15 | Learn 10 | Weighted |
|-----------|--------|---------|--------|---------|----------|----------|
| FEAT-NNN A | 4 | 3 | 5 | 2 | 3 | 3.55 |
| FEAT-NNN B | 2 | 5 | 3 | 5 | 2 | 3.40 |
A: 1.2 + 0.75 + 1.0 + 0.3 + 0.3 = 3.55. Divide by an effort factor (S=1, M=2, L=3) only when capacity is the binding constraint.

## Steps
1. Confirm each candidate has a spec (at least `draft`) and an engineering effort read.
2. Score with the chosen method; two people score independently when stakes are high, then reconcile.
3. Rank. List overrides separately with reason and approver (compliance, incident, contractual, executive mandate).
4. Check dependencies and capacity; resequence without changing scores.
5. Record the outcome as `decisions/<slug>.md` with scores; update `FEAT-` priority fields and the roadmap horizon.
6. Announce using `stakeholder-communication`.

## Output format
Ranked table (ID, title, scores, rank, override flag, reason) plus a decision record. Ties break on risk reduction, then lowest effort.

## References
- `_shared/standards/project-tiers.md`, `cost-awareness.md`
- IDs: `FEAT-`, `RISK-`; skills: `decision-record`, `risk-register`, `stakeholder-communication`
