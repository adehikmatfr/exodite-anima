# Production Readiness Review (PRR)

Run before first production release and before any major change. Each row: Pass / Partial / Fail / N/A + evidence (ID or link).

Tier columns (see `project-tiers.md`): **B** = blocker (must Pass), **R** = recommended (Fail is recorded as a risk, does not block), **-** = not applicable. Apply the escalation rules in `project-tiers.md` first (personal data, money, and so on); they can turn an R into a B.

**Decision rule:** any blocker row that is Fail or Partial means **No-Go**, unless a written waiver names the owner, the risk, and an expiry date. Record the decision and evidence as `PRR-<NNN>` in `../index.md`.

Two columns keep the record honest and actionable:
- **Verified in** says where the evidence was produced: `docs` (read, not run), `local` (a developer machine or container), `staging`, or `production`. A row that needs a real environment cannot reach Pass on `local` evidence alone.
- **Unblocked by** says who or what can clear a row that is not Pass: a role (`devops`, `Library lead`) and, for a decision that is not engineering work, the `RISK-` or `ADR-` that tracks it. A blocked row with an empty "Unblocked by" is unfinished.

| # | Area | Check | T1 | T2 | T3 | Status | Verified in | Evidence | Unblocked by |
|---|------|-------|----|----|----|--------|-------------|----------|--------------|
| 1 | Requirements | Linked `FEAT-` with acceptance criteria and a named owner (`check-registry` confirms each criterion cites a real test) | B | B | B | | | | |
| 2 | Architecture | `ADR-` for significant decisions; NFRs quantified | R | B | B | | | | |
| 3 | Testing | Test plan `TP-` executed; critical `TC-` pass; no open S1/S2 bugs | B | B | B | | | | |
| 4 | Performance | Load test meets `nfr-catalog.md` targets with headroom (T1: smoke test at expected peak) | R | B | B | | | | |
| 5 | Reliability | Timeouts, retries, idempotency, graceful shutdown verified | R | B | B | | | | |
| 6 | Security | Threat model `THR-` reviewed; scans clean; authn/authz tested | B | B | B | | | | |
| 7 | Data | Backup and restore tested; RPO/RTO defined; PII handling reviewed | B* | B | B | | | | |
| 8 | Observability | Logs with correlation IDs; health check; T2+: dashboards, alerts, `SLO-` | R | B | B | | | | |
| 9 | Operations | Runbook `RB-` (T1: "service down"; T2+: one per alert); on-call owner named | R | B | B | | | | |
| 10 | Release | Repeatable release; rollback written (T2+: tested); migration reversible | R | B | B | | | | |
| 11 | Capacity | Capacity and cost estimate; limits and autoscaling configured | - | R | B | | | | |
| 12 | Compliance | Applicable rows of `compliance-matrix.md` satisfied | B** | B** | B | | | | |
| 13 | Docs | User/API docs, changelog, support handoff | R | R | B | | | | |
| 14 | Dependencies | Third-party SLAs, licences, and failure modes understood | R | R | B | | | | |

\* B when the data cannot be recreated from elsewhere. \*\* B when any framework in the matrix is marked applicable; otherwise `-`.

## Conditions
A row may pass **on a condition** that can only be checked at go-live (for example TLS in front of the service). List each one; the release is not Go until every condition is met and its evidence recorded.

| Row | Condition | Verified when | Owner | Met (date, evidence) |
|-----|-----------|---------------|-------|----------------------|

## Sign-off
| Role | Name | Date | Decision |
|------|------|------|----------|
| Engineering | | | |
| QA | | | |
| Security | | | |
| Operations | | | |
| Product | | | |

## Waivers
| Row | Risk accepted | Owner | Expires |
|-----|---------------|-------|---------|
