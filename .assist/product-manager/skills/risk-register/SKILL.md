---
name: risk-register
description: Use when a FEAT- carries uncertainty, dependencies, unvalidated assumptions, or compliance exposure, or when the register needs a periodic review. Creates and maintains RISK- entries.
---
# Risk Register

## Purpose
Make product risks visible, scored, owned, and reviewed, so surprises become planned responses. The register is shared with the software architect, who owns technical risks.

## When to use
- Drafting a spec (risks section) or moving it to `ready`.
- A dependency slips, an assumption is disproved, or a stakeholder raises a concern.
- Scheduled review (each cycle for T2+, each quarter for T1).

## Principles
- A risk is a possible future event with a cause and an effect; an issue has already happened and goes to the backlog or incident process.
- Write it as "If <cause>, then <effect>, causing <impact>".
- Every risk has one named owner, a response, and a review date. No owner means it does not exist.
- Score consistently: Likelihood 1-5 x Impact 1-5.
- Personal data, money, and regulatory exposure are never scored below Medium without written reasoning.
- Register unvalidated assumptions as risks with a test, not as facts.
- Coordinate with the architect: a technical risk is a `RISK-` owned by the architect; link, do not duplicate.

## Steps
1. Identify from: spec assumptions, dependencies, `compliance-and-legal-check` findings, QA and security input, past incidents.
2. Classify: market, delivery, adoption, compliance, dependency, data, technical.
3. Score L and I; compute score. Rating: 1-6 low, 8-12 medium, 15-25 high.
4. Choose a response: avoid, mitigate, transfer, accept. High risks need a mitigation with a date and a fallback.
5. Define an early-warning trigger that is observable (metric, date slip, vendor notice).
6. Register `RISK-NNN` in `_shared/index.md`; link from the `FEAT-`.
7. Review on cadence; re-score, close as retired or occurred, record lessons.

## Scoring example
| Risk | L | I | Score | Rating |
|------|---|---|-------|--------|
| If the vendor API changes its rate limit, then batch jobs fail, causing missed deliveries | 3 | 4 | 12 | Medium |
| If consent wording is not approved before launch, then release is blocked, causing a 4-week slip | 2 | 5 | 10 | Medium |
| If adoption assumption of 40% is wrong, then the payback target is missed | 4 | 3 | 12 | Medium |

Escalation: any score of 15 or more is raised to the decision owner in `context.md` before hand-off. A risk at 20 or more blocks `ready` unless waived in writing.

## Output format
Rows in the register from `templates/risk-register.md` (ID, title, category, related `FEAT-`, L, I, score, response, mitigation, owner, trigger, status, review date), plus a registry entry per risk.

## References
- `_shared/standards/project-tiers.md`, `production-readiness-review.md` (waivers, row 14), `severity-and-incident.md`, `data-governance.md`
- IDs: `RISK-`, `FEAT-`, `ADR-`, `THR-`, `SLO-`; skills: `compliance-and-legal-check`, `prioritization`, `rollout-plan`
