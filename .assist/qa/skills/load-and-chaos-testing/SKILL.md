---
name: load-and-chaos-testing
description: Use before launch or major change to verify performance, capacity, and resilience against NFR targets and SLOs, or when planning load, stress, soak, spike, failover, or fault-injection experiments.
---
# Load and Chaos Testing

## Purpose
Prove with measurements that the system meets its non-functional targets with headroom, and that it degrades and recovers as designed when dependencies fail.

## When to use
- Production Readiness Review rows Performance and Reliability.
- New user-facing service, changed critical path, expected traffic growth, or infrastructure change.
- After an incident that involved capacity or a dependency failure.

## Principles
- Targets come first: numeric, from `nfr-catalog.md` and `SLO-` entries; no target means no pass/fail.
- Test a production-like environment (size, data volume, config); state every difference.
- Realistic workload mix and data distribution; include think time and cold caches.
- Measure percentiles (p50/p95/p99), error rate, saturation (CPU, memory, connections, queue depth), not averages.
- Chaos experiments start from a steady-state hypothesis, have a limited blast radius, an abort condition, and are run in staging before any production use.
- Results are repeatable: fixed scripts, seeds, versions; store raw results.
- Never run load tests against production or third parties without written approval and rate limits.

## Steps / Checklist
1. Define SLIs/targets: latency p95/p99, throughput, error rate, RPO/RTO where relevant.
2. Model workload from production analytics: journey mix, peak, growth (default target: 3x current peak, 10x in 12 months for scale checks).
3. Prepare environment, data volume, monitoring, and baseline run.
4. Run the test types below; record metrics with build and config versions.
5. Find and document the bottleneck for each limit; retest after fixes.
6. Run failure experiments (below); observe alerts, degradation, and recovery time.
7. Verify alerts fire and link to a runbook `RB-`.
8. Report against targets with headroom; open defects for misses.

### Test types
| Type | Profile | Pass criteria (defaults) |
|------|---------|-------------------------|
| Load | Expected peak, 30-60 min | Meets latency and error targets, resources < 70% |
| Stress | Ramp to 2-3x peak until failure | Graceful degradation, no data loss, recovery < RTO |
| Spike | Sudden 5-10x for minutes | Autoscale or shed load; errors < 1% after ramp |
| Soak | 70% peak, 8-24 h | No memory/handle leaks; latency drift < 10% |
| Capacity | Step increments | Documented max sustainable throughput |

### Chaos experiments (from `reliability-patterns.md`)
| Fault | Expect |
|-------|--------|
| Kill instance/pod | No failed requests beyond retry budget; traffic rebalanced |
| Dependency latency/5xx | Timeouts, retries with backoff, circuit opens, fallback works |
| Dependency down | Defined degraded mode; no cascading failure |
| Queue backlog / poison message | Dead-letter, alert, replay works |
| DB failover / restore | RTO/RPO met; no duplicate side effects |
| Network partition, clock skew, disk full | Fails safe; alerts fire |

## Output format
Report: targets, environment and differences, workload model, results table (metric, target, measured, headroom, pass/fail), bottlenecks, chaos outcomes with recovery times, defects opened, and a recommendation feeding `release-sign-off`.

## References
- `_shared/standards/nfr-catalog.md`, `slo-sli-template.md`, `reliability-patterns.md`
- `_shared/standards/production-readiness-review.md` (rows 4, 5, 8, 9)

## Language notes
Load generators and fault-injection tools are stack-specific; record choices and script locations in `.assist/qa/context.md`.
