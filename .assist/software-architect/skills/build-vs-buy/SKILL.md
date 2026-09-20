---
name: build-vs-buy
description: Use when deciding whether to build a capability in-house, adopt open source, buy a SaaS/managed service, or license a product; also when evaluating a vendor, renewing a contract, or assessing lock-in.
---
# Build vs Buy

## Purpose
Decide sourcing (build, adopt open source, buy managed/SaaS, or hybrid) on total cost of ownership, strategic value, risk, and exit cost, not on enthusiasm.

## When to use
- New capability that a market already serves (auth, payments, search, observability, messaging, workflow).
- Existing in-house component that is costly to maintain.
- Vendor selection or renewal; a lock-in concern is raised.
- Input to `tradeoff-analysis` and an `ADR-`.

## Principles
- Build what differentiates the business; buy or adopt what is commodity.
- Compare total cost of ownership over 3 years, including people, on-call, upgrades, security, and migration, not just licence price.
- Operations cost is real: prefer managed when running it yourself costs more than the premium (`cost-awareness.md`).
- Lock-in is a cost with a probability, not a taboo: price the exit.
- Non-negotiables first: compliance, data residency, SLA, security posture.
- Reversibility: wrap vendors behind an interface you own at the boundary.
- Open source is not free: assess maintenance health and who patches CVEs.

## Steps / Checklist
1. Define the capability as requirements and NFRs (`nfr-analysis`); separate must-have from nice-to-have.
2. Classify strategic value: differentiating / important / commodity. Commodity defaults to buy.
3. Gate check (pass/fail) each candidate: compliance (`compliance-matrix.md`), data location, security baseline, SLA vs. required availability, licence terms.
4. Shortlist 2-4 options including Build and, if relevant, Adopt OSS.
5. Estimate 3-year TCO per option:
   - Build: design + build effort, team size x loaded cost, run/on-call, security and upgrades, opportunity cost.
   - Buy: subscription at projected volume (with growth and price-step tiers), integration effort, admin effort, overage.
   - OSS: adoption effort, hosting, ops, upgrades, support contract if any.
6. Score non-cost factors (1-5): fit, time to value, maturity, vendor viability, extensibility, security, lock-in, exit cost, team skill.
7. Vendor due diligence: SLA history, roadmap, financial health, data export format, sub-processors, breach history, support tiers.
8. Define exit plan: data export path, abstraction layer, estimated migration effort and duration.
9. Run a time-boxed proof of concept against the top NFRs and one hard integration.
10. Record in an `ADR-` with review date (contract renewal or volume threshold); raise `RISK-` for lock-in and vendor failure.

## Output format
| Option | 3-yr TCO | Time to value | Fit | Risk | Lock-in / exit cost | Gate |
|--------|----------|---------------|-----|------|---------------------|------|
| Build | 420k (6 eng-months + 0.5 FTE run) | 6 mo | 5 | Med (staffing) | None | Pass |
| SaaS X | 180k (at 3x volume: 260k) | 3 wk | 4 | Med (vendor) | 2 mo to migrate | Pass |
| OSS Y self-hosted | 150k + ops 0.3 FTE = 250k | 2 mo | 4 | Med (patching) | Low | Pass |

Recommendation: SaaS X behind an internal interface; revisit if annual spend exceeds 120k or SLA misses twice in a quarter.

## References
- `_shared/standards/cost-awareness.md`
- `_shared/standards/security-baseline.md` (supply chain, new dependency review)
- `_shared/compliance/compliance-matrix.md`
- `_shared/standards/data-governance.md`
