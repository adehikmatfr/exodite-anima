# Project Tiers

Standards scale with what a failure costs. Pick a tier once in `../project.md`, record the reason, and apply the tier columns in `production-readiness-review.md` and `definition-of-done.md`. Review the tier when scope, users, or data change.

## Tiers

| Tier | Typical project | Outage tolerance | Users / impact | Team |
|------|-----------------|------------------|----------------|------|
| **T1 Small** | Internal tool, hobby, community or pilot service | hours, manual restart is fine | up to about 1,000 users; no money moves | 1-3 people, no formal on-call |
| **T2 Business** | Product the business runs on; customers depend on it | minutes; on-call | thousands of users or revenue impact | team with on-call rotation |
| **T3 Regulated / critical** | Payments, lending, health, safety, or contractual SLAs; audited | seconds to minutes; tested DR | large user base or legal exposure | multiple teams, change control, audits |

## Escalation rules (override the tier)

Apply the stricter rule when any of these hold, even for a small project:

- Stores or processes **personal data**: rows Security, Data, and Compliance in the PRR are blockers at every tier (`data-governance.md`, `compliance-matrix.md`).
- Moves or records **money**: at least T2, and audit trail plus reconciliation are required.
- **Health data, card data, or safety impact**: T3.
- **Public internet exposure** with authentication: Security row is a blocker at every tier.
- A regulator or customer contract names a control: that control is mandatory regardless of tier.

## What scales with the tier

| Concern | T1 | T2 | T3 |
|---------|----|----|----|
| Availability target | best effort (for example 99.5%) | 99.9% | 99.95% or contractual |
| Review | self-review against the checklist | second reviewer required | second reviewer plus security review on risky change |
| Test coverage on changed code | critical paths | 80% lines | 80% lines plus mutation or property tests on critical logic |
| Load testing | smoke test at expected peak | load test at 2x peak | load, soak, and failure-injection tests |
| Observability | structured logs and a health check | metrics, dashboards, SLO alerts | plus tracing, audit-grade logs, SLO reporting |
| Rollout | repeatable release with a written rollback | staged rollout with rollback tested | canary with automatic halt, change approvals |
| Runbooks | one for "service down" | one per alert | per alert, drilled |
| Backup / restore | backup exists, restore tested once | scheduled restore test | DR drill at least yearly, RPO/RTO proven |
| Incident process | note what happened | blameless postmortem for P0/P1 | postmortem plus tracked actions and audit evidence |
| Threat model | short STRIDE table | per major feature | per change to trust boundaries, reviewed by security |

Rule of thumb: never lower a tier to avoid work. Lower it only when the failure cost is genuinely small, and write the reason in `project.md`.
