# Non-Functional Requirements Catalog

Pick applicable categories, replace defaults with real, measurable targets, and record them in an `ADR-`. A requirement without a number is not a requirement.

| Category | Requirement template | Typical default (tune!) |
|----------|----------------------|-------------------------|
| Availability | Monthly uptime for `<service>` | 99.9% (43 min/month) |
| Latency | p95 / p99 for `<operation>` | p95 < 300 ms, p99 < 1 s |
| Throughput | Sustained and peak requests/sec | `<n>` rps, peak 3x |
| Scalability | Growth handled without redesign | 10x in 12 months |
| Durability | Data loss tolerance (RPO) | RPO <= 5 min (critical data) |
| Recoverability | Time to restore (RTO) | RTO <= 1 h |
| Security | Authn, authz, encryption, audit | see `security-baseline.md` |
| Privacy | Data minimisation, retention, consent | see `data-governance.md` |
| Observability | Logs, metrics, traces coverage | 100% of requests traced |
| Maintainability | Test coverage, complexity, docs | >= 80% coverage |
| Compatibility | API/browser/OS support matrix | n-1 versions |
| Accessibility | WCAG level | WCAG 2.2 AA |
| Localisation | Languages, time zones, currencies | `<list>` |
| Cost | Monthly budget / unit cost | `<amount>` / 1k requests |
| Portability | Cloud/vendor lock-in tolerance | `<...>` |
