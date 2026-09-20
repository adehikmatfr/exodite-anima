# Cost Awareness (FinOps)

- Every workload has an owner, a budget, and cost tags (`project`, `env`, `owner`, `cost-center`).
- Estimate cost in the design (`ADR-`): compute, storage, network egress, third-party APIs, licences, on-call time.
- Track unit cost (per 1k requests, per active user, per pipeline run, per 1M tokens) and alert on drift.
- Right-size, autoscale, and shut down non-production outside working hours.
- Use retention and lifecycle policies for logs, backups, and object storage.
- Prefer managed services when operations cost outweighs price; document lock-in trade-offs.
- Review cost monthly; anomalies get an owner and an action.
