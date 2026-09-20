# Risk Register: exodite-anima

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

Product-side risks, shared with the software architect for technical risks. Each entry is registered in `_shared/index.md` as `RISK-NNN`. IDs are never reused.

## Scoring
Likelihood (L) and Impact (I) each 1-5. Score = L x I. Rating: 1-6 low, 8-12 medium, 15-25 high. High risks need a named owner and a dated mitigation before a `FEAT-` moves to `ready`.

## Register
| ID | Title | Category | Related FEAT | L | I | Score | Response | Mitigation / contingency | Owner | Trigger / early warning | Status | Review date |
|----|-------|----------|--------------|---|---|-------|----------|--------------------------|-------|-------------------------|--------|-------------|
| RISK-NNN | <short title> | market / delivery / compliance / dependency / adoption / data / technical | FEAT-NNN | 3 | 4 | 12 | avoid / mitigate / transfer / accept | <action and fallback> | <name> | <observable signal> | open | <YYYY-MM-DD> |

Response values: avoid (change scope), mitigate (reduce L or I), transfer (vendor, insurance, contract), accept (written, with owner).

## Assumptions to validate (optional)
| # | Assumption | Evidence today | How to test | Due | Linked RISK |
|---|-----------|----------------|-------------|-----|-------------|
| A-1 | <assumption> | <none / weak / strong> | <experiment or data pull> | <YYYY-MM-DD> | RISK-NNN |

## Closed risks (optional)
| ID | Outcome | Date | Lesson |
|----|---------|------|--------|
| RISK-NNN | occurred / retired / accepted | <YYYY-MM-DD> | <what to change in the process> |

## Review log
| Date | Reviewer | Changes |
|------|----------|---------|
| <YYYY-MM-DD> | <name> | <new, re-scored, closed> |
