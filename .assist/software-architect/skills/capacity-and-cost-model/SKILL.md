---
name: capacity-and-cost-model
description: Use when sizing a system, estimating load and headroom, planning scaling limits, producing a monthly cost or unit-cost estimate, or when a design needs a budget check before approval.
---
# Capacity and Cost Model

## Purpose
Turn NFRs and usage assumptions into resource needs, scaling limits, and a cost estimate with unit economics, so designs are affordable and headroom is known.

## When to use
- New system or feature; expected traffic or data growth changes.
- Choosing between architectures with different cost curves.
- PRR row 11 (capacity and cost); FinOps review; budget request.
- After an incident caused by saturation.

## Principles
- Model from demand: users -> requests -> resources -> cost. Write every assumption down.
- Size for peak, not average; include growth (12 months) and failure headroom (lose one zone or node and still meet NFRs).
- Find the bottleneck first (DB connections, single-writer, egress, third-party rate limit); scale that.
- Unit cost (per 1k requests, per active user, per GB, per 1M tokens) is the metric that survives growth.
- Give ranges (low / expected / high), not a single number.
- Validate with a load test; a model is a hypothesis until measured.
- Cost is a quality attribute with an owner and tags (`cost-awareness.md`).

## Steps / Checklist
1. Gather demand: users, active ratio, actions per user per day, peak-to-average factor (often 3-10x), growth rate.
2. Derive load: rps_avg = daily_requests / 86,400; rps_peak = rps_avg x peak factor.
3. Derive per-request resource: CPU-ms, memory, DB queries, bytes in/out (from spike or benchmark).
4. Compute instances/capacity: needed = rps_peak x cpu_ms / 1000 / target_utilisation (use 60% target), then add N+1 or zone-loss headroom.
5. Data: rows/day x bytes x retention x replication factor + indexes (x1.3-2). Note growth and archival tiers.
6. Bottlenecks table: component, limit, current, headroom, scaling action, lead time.
7. Cost lines: compute, storage, network egress, managed services, third-party APIs, licences, observability, on-call/ops time, non-prod environments.
8. Compute monthly total and unit cost; do low/expected/high.
9. Identify savings levers: right-size, autoscaling, reserved/committed use, caching, lifecycle policies, off-hours shutdown.
10. Define alerts: budget threshold, unit-cost drift, saturation at 70%.
11. Record in an `ADR-`; feed load test targets into the test plan.

## Output format
Assumptions: 200k DAU, 20 req/user/day, peak factor 5, growth 3x in 12 months.
Load: 4.0M req/day = 46 rps avg, 230 rps peak now; 690 rps peak at month 12.

| Component | Sizing basis | Now | Month 12 | Limit / bottleneck | Monthly cost (exp.) |
|-----------|--------------|-----|----------|--------------------|--------------------|
| API | 12 ms CPU/req, 60% target | 4 vCPU x3 (N+1) | 12 vCPU x3 | Autoscale max 20 | 900 -> 2,400 |
| DB | 6 queries/req | 1 primary + 1 replica | Read replicas x3 | Primary write ~2k tps | 1,800 -> 4,200 |
| Egress | 30 KB/resp | 3.5 TB | 10 TB | none | 300 -> 900 |
| **Total** | | **3,000** | **7,500** | Unit cost: 0.75 -> 0.36 per 1k req | range +/-25% |

## References
- `_shared/standards/cost-awareness.md`
- `_shared/standards/nfr-catalog.md`
- `_shared/standards/production-readiness-review.md` (rows 4 and 11)
- `_shared/standards/reliability-patterns.md` (backpressure, limits)
