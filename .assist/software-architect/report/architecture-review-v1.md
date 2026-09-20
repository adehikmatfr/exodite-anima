# Architecture Review Checklist

Review of: exodite-anima version 1 design (ADR-001 to ADR-005, C4 diagrams, NFR analysis) | Date: 2026-09-20 | Reviewer: software-architect role | Author: software-architect role

**This is a self-review: the same role wrote the design, so it is not independent.** It should be repeated by the owner or by the qa and cyber-security roles at their stages.

Scoring per row: 0 = missing, 1 = partial, 2 = satisfied, N/A = not applicable (justified). Rows marked **B** are blockers: a 0 stops approval.

| # | Area | Check | B | Score | Evidence / finding |
|---|------|-------|---|-------|--------------------|
| 1 | Requirements | Linked `FEAT-` with acceptance criteria | B | 1 | Nine specs with criteria exist but are `draft` with open questions |
| 2 | Requirements | NFRs quantified (number, percentile, window, method) | B | 1 | `nfr-analysis-v1.md` quantifies, but many targets are unconfirmed `ASSUMPTION`s |
| 3 | Decisions | Significant decisions have `ADR-`; options and trade-offs stated | B | 2 | ADR-001 to ADR-006, all accepted |
| 4 | Decisions | Reversibility classified; exit strategy for one-way doors | | 2 | Each ADR classifies it and states an exit |
| 5 | Structure | Boundaries follow domain language; each data set has one owner | | 2 | C4 level 3 uses glossary terms; the repository owns all stored data |
| 6 | Structure | Dependencies acyclic; no shared mutable database across services | | N/A | One app, no services |
| 7 | Structure | Complexity justified by a numbered requirement | | 2 | Each container maps to an ADR and an NFR |
| 8 | Integration | Contracts versioned; backward-compatible evolution path | | 1 | The export format is the only contract and is versioned (ADR-003); fixtures do not exist yet |
| 9 | Integration | Sync vs async chosen deliberately; consistency model stated | | N/A | No integrations |
| 10 | Reliability | Timeouts, retries, idempotency, backpressure | B | N/A | No network or remote dependencies; atomic writes and all-or-nothing import are covered in row 11 |
| 11 | Reliability | Failure modes and degradation documented per dependency | | 1 | Flows and the threat model cover most; the OS key store and file dialog failure modes are not written down |
| 12 | Reliability | Single points of failure identified and accepted or removed | | 2 | The single device is the point of failure, accepted as RISK-001 with export as mitigation |
| 13 | Security | Trust boundaries drawn; `THR-` exists for new boundaries | B | 2 | C4 boundaries and THR-001 to THR-013 (draft, to be migrated) |
| 14 | Security | Authn/authz, secrets, keys, audit per `security-baseline.md` | B | 1 | Key handling is designed (ADR-001) but unverified until the spike; no server-side items apply |
| 15 | Data | Classification, retention, residency per `data-governance.md` | B | 2 | Journal text is Restricted, stored on device only, kept until the user deletes it (specs and THR) |
| 16 | Data | Backup/restore, RPO/RTO defined and testable | B | 1 | Export and import are designed; RPO is user-driven; the RTO target is an assumption; no restore test exists |
| 17 | Operations | Observability: logs, metrics, traces, `SLO-` | B | N/A | No telemetry by design; stability comes from the store consoles (NFR-14) |
| 18 | Operations | Deployment, rollback, migration path | B | 1 | Schema and format versioning are designed; the rollout plan is pending; a shipped build cannot be rolled back |
| 19 | Capacity | Load model, headroom, scaling limits documented | | 1 | Journal-size assumptions only |
| 20 | Cost | Unit cost and monthly estimate | | 2 | No infrastructure cost; only store fees (NFR-19) |
| 21 | Compliance | Applicable rows of `compliance-matrix.md` addressed | B | 1 | Update 2026-09-20: the three Confirm rows were self-assessed from the official texts (`legal-self-assessment-v1.md`); owner sign-off pending |
| 22 | Third parties | SLAs, lock-in, exit cost, licence reviewed | | 1 | Update 2026-09-20: packages chosen, pinned and reviewed (`dependency-review.md`); verified on Android only |
| 23 | Documentation | C4 diagrams current at context and container level | | 2 | `c4-diagrams.md` written today |
| 24 | Evolvability | Team can build and operate it with current skills and headcount | | 1 | Solo developer; iOS cannot be built on the current machine |

## Result
- Score: 28 / 40 (20 applicable rows) = 70%
- Outcome: **Approve with conditions** (70 to 84%, no blocker row at 0). The score sits at the lower edge of the band and several rows are partial for the same reasons, so the conditions below matter.

## Findings
| ID | Severity | Finding | Recommendation | Owner | Due |
|----|----------|---------|----------------|-------|-----|
| F1 | major | NFR targets were unconfirmed assumptions | Owner accepted them as provisional targets on 2026-09-20; confirm by measurement | Software-architect | At the spike |
| F2 | major | Cloud backup exclusion (ADR-001): **Android done 2026-09-20** (`allowBackup=false`, verified in the release APK); iOS not built. Original finding: the Android main manifest set no `allowBackup` | Disable backup for app data on Android and set the exclude-from-backup attribute on iOS files | frontend-mobile | Before the first release build |
| F3 | major | Encryption and database packages are not chosen or verified; ADR-001, ADR-002, ADR-003 depend on them | Run the technical spike, then pin packages after checking maintenance and licence | software-architect, frontend-mobile | Closed for Android 2026-09-20 (spike S1, S2, S6, S7, S8; packages pinned and reviewed); iOS still unverified |
| F4 | major | No round-trip test or fixture archives exist for the export format | Write the test plan and fixtures | qa | Partly closed 2026-09-20: round-trip, tamper and hostile-file tests exist for `formatVersion` 1 (`app/test/backup_test.dart`); no older-version fixture because none exists yet |
| F5 | major | Compliance rows marked Confirm are unresolved | Decide `legal-applicability-confirmation` | Project owner | Before the first store release in each region |
| F6 | minor | iOS cannot be built or verified on the current machine | Decide how iOS is built (Mac or cloud CI) | Project owner | Before the first iOS release |
| F7 | minor | Rollout and rollback plan is pending | Decide `v1-rollout-plan` | Project owner, qa | Before the readiness review |
| F8 | minor | OS key store and file-dialog failure modes are not written down | Add failure modes to the workflow docs | software-architect | Next review |
| F9 | observation | ADR-001 to ADR-003 predate the process; their drivers contain assistant-proposed numbers | Review records added; confirm through `nfr-targets-v1` | Project owner | With F1 |
| F10 | observation | ADR-005 was only proposed | Accepted by the owner on 2026-09-20 | Project owner | closed |

New `RISK-` entries raised: none; F2 and F3 are covered by RISK-003 and RISK-004. Follow-up `ADR-` needed: a superseding ADR for the export envelope if the spike picks a standard format; an ADR to record the confirmed NFR targets once `nfr-targets-v1` is decided.
