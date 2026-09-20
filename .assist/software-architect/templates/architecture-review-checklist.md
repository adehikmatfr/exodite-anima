# Architecture Review Checklist

Review of: <system / change / ADR-NNN> | Date: <YYYY-MM-DD> | Reviewer: <name> | Author: <name>

Scoring per row: 0 = missing, 1 = partial, 2 = satisfied, N/A = not applicable (justify). Rows marked **B** are blockers: a 0 stops approval.

| # | Area | Check | B | Score | Evidence / finding |
|---|------|-------|---|-------|--------------------|
| 1 | Requirements | Linked `FEAT-` with acceptance criteria | B | | |
| 2 | Requirements | NFRs quantified (number, percentile, window, method) | B | | |
| 3 | Decisions | Significant decisions have `ADR-`; options and trade-offs stated | B | | |
| 4 | Decisions | Reversibility classified; exit strategy for one-way doors | | | |
| 5 | Structure | Boundaries follow domain language; each data set has one owner | | | |
| 6 | Structure | Dependencies acyclic; no shared mutable database across services | | | |
| 7 | Structure | Complexity justified by a numbered requirement | | | |
| 8 | Integration | Contracts (`API-`) versioned; backward-compatible evolution path | | | |
| 9 | Integration | Sync vs async chosen deliberately; consistency model stated | | | |
| 10 | Reliability | Timeouts, retries, idempotency, backpressure per `reliability-patterns.md` | B | | |
| 11 | Reliability | Failure modes and degradation behaviour documented per dependency | | | |
| 12 | Reliability | Single points of failure identified and accepted or removed | | | |
| 13 | Security | Trust boundaries drawn; `THR-` exists for new boundaries | B | | |
| 14 | Security | Authn/authz server-side; secrets, keys, audit per `security-baseline.md` | B | | |
| 15 | Data | Classification, retention, residency per `data-governance.md` | B | | |
| 16 | Data | Backup/restore, RPO/RTO defined and testable | B | | |
| 17 | Operations | Observability: logs, metrics, traces, `SLO-`; alerts map to `RB-` | B | | |
| 18 | Operations | Deployment, rollback, migration path (expand/migrate/contract) | B | | |
| 19 | Capacity | Load model, headroom, scaling limits documented | | | |
| 20 | Cost | Unit cost and monthly estimate per `cost-awareness.md`; tags planned | | | |
| 21 | Compliance | Applicable rows of `compliance-matrix.md` addressed | B | | |
| 22 | Third parties | SLAs, lock-in, exit cost, licence reviewed | | | |
| 23 | Documentation | C4 diagrams current at context and container level | | | |
| 24 | Evolvability | Team can build and operate it with current skills and headcount | | | |

## Result

- Score: <sum> / <2 x applicable rows> = <percent>
- Outcome: Approve (>= 85%, no blocker at 0) / Approve with conditions (70-84%, no blocker at 0) / Reject (< 70% or any blocker at 0)

## Findings

| ID | Severity (blocker / major / minor) | Finding | Recommendation | Owner | Due |
|----|-----------------------------------|---------|----------------|-------|-----|
| F1 | | | | | |

New `RISK-` entries raised: <list>. Follow-up `ADR-` needed: <list>.
