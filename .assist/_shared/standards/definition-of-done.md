# Definition of Done

A change is done only when every applicable item is true. Mark N/A with a reason; do not silently skip.

Items tagged **(T2+)** or **(T3)** apply from that tier upward; untagged items apply to every tier. Tiers and escalation rules (personal data, money, and so on) are in `project-tiers.md`.

## Code and behavior
- [ ] Acceptance criteria of the linked `FEAT-` are met and demonstrated
- [ ] Reviewed by at least one other person; no unresolved comments (T1: self-review against this list)
- [ ] No dead code, debug output, or commented-out blocks
- [ ] Errors are handled and surfaced deliberately (see `reliability-patterns.md`)

## Quality
- [ ] Automated tests cover happy path, edge cases, and failure paths; tests are deterministic
- [ ] Critical paths fully covered; (T2+) coverage on changed code meets the project target (default 80% lines)
- [ ] Static analysis, lint, and type checks pass in CI
- [ ] Performance impact checked against `nfr-catalog.md` budgets

## Security and data
- [ ] Threat considered (`security-baseline.md`); inputs validated, authz enforced server-side
- [ ] No secrets in code, config, logs, or fixtures
- [ ] Data changes classified and handled per `data-governance.md`
- [ ] Dependencies scanned; new ones justified

## Operability
- [ ] Logs added for the new behavior; (T2+) metrics and traces
- [ ] (T2+) Alerts/SLO updated if user-facing (`slo-sli-template.md`)
- [ ] (T2+) Runbook (`RB-`) added or updated if it can page someone; T1: one "service down" runbook
- [ ] Config is externalised; safe defaults; (T2+) feature flag if risky

## Delivery
- [ ] Migrations are backward compatible and reversible (`release-management.md`)
- [ ] Rollback plan stated
- [ ] Docs and changelog updated; registry IDs updated in `index.md`
