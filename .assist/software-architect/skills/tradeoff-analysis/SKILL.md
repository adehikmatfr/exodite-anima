---
name: tradeoff-analysis
description: Use when two or more viable architectural options exist and the winner is unclear, when stakeholders disagree on an approach, or when you must justify a choice with weighted criteria and sensitivity checks.
---
# Trade-off Analysis

## Purpose
Compare options transparently against weighted, evidence-based criteria so the decision, and what is sacrificed, is visible and defensible.

## When to use
- Choosing between architectures, patterns, data stores, integration styles, or vendors.
- Input to `adr-writing` (Options and Scoring sections) or `build-vs-buy`.
- A decision is contested or the team is defaulting to preference.

## Principles
- Criteria come from quantified NFRs and business constraints (`nfr-analysis`), not from option features.
- Weights are set before scoring, and by stakeholders, to avoid rigging.
- Always include a baseline: the status quo or "do nothing".
- Score with evidence (benchmark, spike, reference, incident history); mark guesses as low confidence.
- Hard constraints are gates (pass/fail), not weighted criteria.
- Prefer reversible options when scores are close (two-way door tie-breaker).
- A trade-off is what you give up: state it in the decision.

## Steps / Checklist
1. State the decision and its reversibility (one-way / two-way).
2. List hard constraints (compliance, budget ceiling, must-integrate systems); eliminate options that fail.
3. Choose 5-8 criteria from: NFR fit, security, operability, team skill, time-to-deliver, cost (build + run), lock-in, ecosystem maturity, evolvability, risk.
4. Weight criteria 1-5 (sum not required; normalise later). Get stakeholder agreement.
5. Score each option 1-5 per criterion using the rubric: 1 = fails/unproven, 3 = acceptable, 5 = excellent with evidence.
6. Add a confidence tag per score (H/M/L). Plan a spike for any low-confidence, high-weight cell.
7. Compute weighted totals: sum(weight x score) / sum(weight x 5).
8. Sensitivity check: change the top two weights by +/-1 and drop each criterion in turn; if the winner flips, the decision is fragile, so say so and lean to the more reversible option.
9. Write the trade-off in words: "We gain X; we give up Y; we accept risk Z."
10. Carry the result into an `ADR-` and raise `RISK-` entries.

## Output format
| Criterion | Weight | Option A: Managed queue | Option B: Self-hosted broker | Option C: DB polling (baseline) |
|-----------|--------|------|------|------|
| NFR fit (throughput 5k msg/s) | 5 | 5 (H) | 5 (H) | 2 (M) |
| Operability | 4 | 5 (H) | 2 (M) | 4 (H) |
| Lock-in | 3 | 2 (H) | 4 (H) | 5 (H) |
| Run cost | 3 | 3 (M) | 3 (L) | 5 (H) |
| Time to deliver | 2 | 5 (H) | 2 (M) | 4 (H) |
| **Weighted %** | | 78% | 66% | 74% |

Sensitivity: if lock-in weight rises to 5, A falls to 74% and C leads narrowly, so the choice is sensitive to lock-in tolerance.
Conclusion: choose A; mitigate lock-in with an abstraction at the publish/consume boundary; revisit if monthly spend exceeds budget X.

## References
- `_shared/standards/nfr-catalog.md`
- `_shared/standards/cost-awareness.md`
- `_shared/standards/reliability-patterns.md`
- Companion skills: `adr-writing`, `build-vs-buy`
