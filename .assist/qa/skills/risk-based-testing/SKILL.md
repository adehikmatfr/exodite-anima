---
name: risk-based-testing
description: Use when a feature, change, or release needs a decision on where and how deeply to test, when time is limited, or when asked "what should we test first". Produces a ranked risk table that drives test depth.
---
# Risk-Based Testing

## Purpose
Allocate finite test effort to the areas where failure would be most costly and most likely, and make the untested remainder an explicit, accepted decision.

## When to use
- At the start of any `TP-` (before writing test cases).
- When scope, schedule, or architecture changes mid-cycle.
- When a defect escapes to production (re-score the area).
- Not needed for trivial, fully reversible, flag-guarded changes; a smoke check suffices.

## Principles
- Risk = Impact x Likelihood. Score both; never rank by gut alone.
- Impact is judged by users, money, data, safety, legal exposure, and blast radius.
- Likelihood rises with: new code, complexity, many integrations, weak existing coverage, high churn, a defect history, an unfamiliar team or dependency.
- Test depth is a consequence of the score, not of effort already spent.
- Risk is re-evaluated as evidence arrives; a passing deep test lowers likelihood.
- Uncovered risk is stated, owned, and signed off, never silently dropped.

## Steps / Checklist
1. Read the `FEAT-`, related `ADR-`, `THR-`, `SLO-`, and the change diff/scope.
2. List risk items: features, integrations, data migrations, NFRs, failure modes, security threats, compatibility.
3. Score each item using the matrix below.
4. Map score to test depth; add exploratory charters for high-uncertainty areas.
5. Link each item to `TC-` IDs; register serious ones as `RISK-` entries.
6. Review with engineering and product; agree on accepted residual risk.
7. Re-score at each milestone and after each escaped defect.

### Scoring (1-5 each)
| Impact | Meaning | Likelihood | Meaning |
|--------|---------|-----------|---------|
| 5 | Data loss, breach, money loss, outage | 5 | New, complex, multi-service, no coverage |
| 4 | Core journey broken for many | 4 | Significant change or known-fragile area |
| 3 | Feature degraded, workaround | 3 | Moderate change, some coverage |
| 2 | Minor feature or few users | 2 | Small change, good coverage |
| 1 | Cosmetic | 1 | Untouched, stable, well covered |

### Score to depth
| Score (I x L) | Band | Test depth |
|---------------|------|-----------|
| 15-25 | Critical | Deep: positive, negative, boundary, failure, security, NFR; automated regression; exploratory |
| 8-14 | High | Standard: positive, key negatives, boundaries; automated where stable |
| 4-7 | Medium | Light: happy path plus one negative; smoke automation |
| 1-3 | Low | Smoke or none; record as accepted |

## Output format
Risk table in the `TP-` (see `templates/test-plan.md` section 2): Risk ID, area, Impact, Likelihood, Score, depth, linked `TC-`; plus a list "Not tested and why" with an accepting owner.

## References
- `_shared/standards/nfr-catalog.md`, `security-baseline.md`, `reliability-patterns.md`
- `_shared/standards/production-readiness-review.md` (Testing row)
- `_shared/index.md` (RISK-, THR-, FEAT-)

## Language notes
None; the method is stack-independent. Use code-churn and defect-history data from your VCS and tracker to inform Likelihood.
