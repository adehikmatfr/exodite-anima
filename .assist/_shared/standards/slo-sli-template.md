# SLO / SLI Template

Registered as `SLO-<n>` in `index.md`.

## Definition
| Field | Value |
|-------|-------|
| Service / journey | |
| SLI (what is measured) | e.g. proportion of requests with status < 500 and latency < 300 ms |
| Measurement source | e.g. load balancer metrics |
| SLO target | e.g. 99.9% over 30 days |
| Error budget | 100% - target (e.g. 43 min per 30 d) |
| Owner | |

## Alerting (multi-window burn rate)
| Severity | Condition | Action |
|----------|-----------|--------|
| Page | Burn rate >= 14x over 1 h and 5 min | Page on-call, follow `RB-` |
| Page | Burn rate >= 6x over 6 h and 30 min | Page on-call |
| Ticket | Burn rate >= 1x over 3 d | Create ticket |

## Error budget policy
- Budget remaining > 50%: ship normally.
- Budget < 25%: prioritise reliability work over features.
- Budget exhausted: freeze non-critical releases until restored.

## Every alert must
- map to user impact, be actionable, and link to a runbook.
- have an owner; delete alerts nobody acts on.
