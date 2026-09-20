---
name: release-sign-off
description: Use when a release candidate is ready and QA must give a Go, Conditional Go, or No-Go decision, complete the Testing and Performance rows of the production readiness review, or record accepted risk.
---
# Release Sign-Off

## Purpose
Give an evidence-based, auditable QA release decision and make residual risk visible to the people accountable for accepting it.

## When to use
- A release candidate has finished its `TP-` execution.
- Before first production release, major change, or an emergency change (shortened but not skipped).
- When someone requests an override of a No-Go.

## Principles
- Decide from evidence tied to the exact build being released, not from earlier builds.
- Criteria are set in the `TP-` before execution; do not lower them at the end without recording it.
- QA advises with a clear recommendation; overriding a No-Go needs written acceptance by the accountable owner.
- Known issues are disclosed, not buried; unknowns (untested areas) are listed as risk.
- Emergency changes get minimum viable verification plus a retrospective within 5 business days (`release-management.md`).

## Steps / Checklist
1. Confirm the candidate build ID, artifact hash, and that it is the promoted artifact.
2. Verify traceability: every `FEAT-` acceptance criterion has passing `TC-`; no orphan requirements.
3. Check execution: critical cases 100% passed, overall executed >= 95%, regression suite green on this build.
4. Review defects: 0 open S1/S2; each open S3/S4 listed with workaround and owner.
5. Confirm NFR evidence from `load-and-chaos-testing`; rollback and migration rollback verified.
6. Confirm security-adjacent checks (authz tests, scan results) with the security role; observability and `RB-` exist.
7. Confirm flake and quarantine status: no quarantined P0 tests.
8. Decide using the matrix; record it; obtain other sign-offs per PRR.
9. Post-release: watch the agreed window, record the outcome, update the registry.

### Decision matrix
| Condition | Decision |
|-----------|----------|
| All exit criteria met, no open S1/S2 | Go |
| Minor gaps (S3/S4 open, non-critical TC pending) with mitigation and owner | Conditional Go (list conditions, deadlines) |
| Open S1/S2, critical TC failing, NFR miss, untested critical risk, rollback unverified | No-Go |

### Evidence bundle
- [ ] Build ID and environment
- [ ] `TP-` results summary and traceability table
- [ ] Defect list by severity with status
- [ ] Performance and resilience report
- [ ] Rollback/migration verification
- [ ] Accepted-risk register (risk, impact, owner, expiry)

## Output format
```
Release sign-off: <release / FEAT-ids>   Build: <id>   Date:
Decision: Go / Conditional Go / No-Go
Basis: TP-<n> results (executed/passed/failed), defects S1/S2/S3/S4 open
Conditions (if any): <item, owner, due>
Residual risks: <list with owner>
Overrides: <who, what, written reference>
QA signatory:
```
Add the outcome to the QA row of the sign-off table in `production-readiness-review.md`.

## References
- `_shared/standards/production-readiness-review.md`, `definition-of-done.md`
- `_shared/standards/release-management.md`, `severity-and-incident.md`
- `_shared/index.md`

## Language notes
None.
