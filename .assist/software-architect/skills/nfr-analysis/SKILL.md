---
name: nfr-analysis
description: Use when requirements mention quality attributes vaguely (fast, scalable, secure, reliable), when starting a new system or major feature, or before choosing an architecture, to derive measurable non-functional requirements.
---
# NFR Analysis

## Purpose
Convert vague quality wishes into quantified, testable targets that drive design and can be verified before release.

## When to use
- New service or feature with no stated performance, availability, or security targets.
- Stakeholders say "must be fast/highly available/scalable".
- Before `tradeoff-analysis`, `capacity-and-cost-model`, or writing an ADR.
- Before a production readiness review (row 2 and 4).

## Principles
- A requirement without a number, a percentile, a time window, and a measurement method is a wish.
- Targets come from user impact and business cost, not from what is easy. Ask "what happens if we miss it?"
- Each target has a cost; higher targets cost disproportionately (99.9% to 99.99% is often 3-10x the spend).
- Different journeys deserve different targets (checkout vs. report export).
- Conflicting NFRs are surfaced, not hidden (e.g. strong consistency vs. latency).
- Use `_shared/standards/nfr-catalog.md` as the menu; defaults there are starting points.

## Steps / Checklist
1. List the key user journeys and system-to-system flows.
2. For each, walk the catalog categories: availability, latency, throughput, scalability, durability (RPO), recoverability (RTO), security, privacy, observability, maintainability, compatibility, accessibility, localisation, cost, portability. Mark N/A with a reason.
3. Elicit with questions:
   - How many users/requests now, in 12 months, at peak? Peak-to-average ratio?
   - What is the cost of one hour of downtime? Of losing 5 minutes of data?
   - What response time makes users abandon?
   - Which regulations apply (`compliance-matrix.md`)?
4. Write each NFR in the form: "For `<journey>`, `<metric>` shall be `<target>` measured `<how>` over `<window>`."
5. Add a source (FEAT-, contract, regulation) and the consequence of a miss.
6. Derive error budget: 99.9% monthly = 43 min; 99.95% = 21 min; 99.99% = 4.3 min.
7. Detect conflicts and rank NFRs (must / should / nice).
8. Define the verification: load test, chaos test, restore drill, pen test, SLO dashboard.
9. Record in an `ADR-` and propose `SLO-` entries for user-facing targets.

Quality gate:
- [ ] Every row has number + percentile/window + method
- [ ] Peak and growth assumptions written down as `ASSUMPTION:`
- [ ] Conflicts listed with a proposed resolution

## Output format
| ID | Journey | Category | Target | Measurement | Priority | Source | Verification |
|----|---------|----------|--------|-------------|----------|--------|--------------|
| NFR-1 | Place order | Latency | p95 < 300 ms, p99 < 1 s at 200 rps | APM, 5-min windows | Must | FEAT-012 | Load test at 2x peak |
| NFR-2 | Place order | Availability | 99.95% monthly | Synthetic probe | Must | Contract | SLO-004 dashboard |
| NFR-3 | Orders DB | Durability | RPO <= 1 min, RTO <= 30 min | Restore drill | Must | Finance | Quarterly drill |

Also list open questions and assumptions with owners.

## References
- `_shared/standards/nfr-catalog.md`
- `_shared/standards/slo-sli-template.md`
- `_shared/standards/reliability-patterns.md`
- `_shared/compliance/compliance-matrix.md`
