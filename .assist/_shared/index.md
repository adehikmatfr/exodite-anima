# ID Registry

Every cross-role artifact gets a stable ID. Reference IDs, never file paths. IDs are never reused or renumbered.

## Prefixes

| Prefix | Artifact | Owner role |
|--------|----------|-----------|
| FEAT | Feature / change request | product-manager |
| ADR | Architecture decision record | software-architect |
| TC | Test case | qa |
| TP | Test plan | qa |
| PRR | Production readiness review record | qa |
| RB | Runbook | devops |
| INC | Incident / postmortem | devops |
| RISK | Risk register entry | product-manager / architect |
| THR | Threat (threat model entry) | cyber-security |
| SLO | Service level objective | devops |
| API | API contract | backend |
| WF | As-built workflow doc | backend |
| MODEL | ML model / model card | machine-learning |
| DS | Dataset / data contract | data-engineer |
| RS | Research study (evidence a FEAT or design decision cites) | ux-design |

## Registry

| ID | Title | Status | Owner role | Location | Related |
|----|-------|--------|-----------|----------|---------|
| ADR-001 | Encrypt data in the app, unlock with biometrics and passcode, no key recovery | active | software-architect | `software-architect/adr/ADR-001-encryption-and-key-recovery.md` | |
| ADR-002 | Encrypted SQLite database (drift + SQLite3MultipleCiphers), media as separate encrypted files | active | software-architect | `software-architect/adr/ADR-002-local-database.md` | ADR-001 |
| ADR-003 | Export as versioned ZIP of JSON and Markdown with encrypted envelope | active | software-architect | `software-architect/adr/ADR-003-export-archive-format.md` | FEAT-006, FEAT-007, ADR-001, ADR-002, RISK-002 |
| ADR-004 | Flutter, one codebase for iOS and Android | active | software-architect | `software-architect/adr/ADR-004-flutter-single-codebase.md` | ADR-001, ADR-002, RISK-004 |
| ADR-005 | Enforce no network through the build | active | software-architect | `software-architect/adr/ADR-005-no-network-enforced-by-build.md` | THR-005, THR-012, THR-013, RISK-003 |
| ADR-006 | Protect the journal during data migrations | active | software-architect | `software-architect/adr/ADR-006-migration-safety-rules.md` | ADR-002, ADR-003, FEAT-001, RISK-001, RISK-002, THR-010 |
| THR-001..015 | Threat model for v1 | active | cyber-security | `cyber-security/report/threat-model-v1.md` | ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, RISK-001, RISK-003, RISK-005, RISK-009, RISK-010 |
| RS-001 | Usability study: first run and changing phones | draft | ux-design | `ux-design/report/RS-001-first-run-and-new-phone-usability.md` | FEAT-001, FEAT-004, FEAT-006, FEAT-007, RISK-001 |
| TP-001 | Version 1 release test plan | draft | qa | `qa/test-plans/TP-001-v1-release.md` | FEAT-001..010, RISK-001..010, THR-001..015, ADR-006 |
| PRR-001 | Version 1 (Android) production readiness review | draft | qa | `qa/report/PRR-001-v1-android.md` | FEAT-001..009, TP-001, ADR-001..006, THR-001..015, RISK-005 |
| TC-001..015 | Test cases: Entry management | draft | qa | `qa/test-cases/FEAT-001-entry-management.md` | FEAT-001 |
| TC-016..020 | Test cases: Timeline | draft | qa | `qa/test-cases/FEAT-002-timeline.md` | FEAT-002 |
| TC-021..031 | Test cases: App lock and screen privacy | draft | qa | `qa/test-cases/FEAT-003-app-lock.md` | FEAT-003 |
| TC-032..039 | Test cases: Onboarding and passcode setup | draft | qa | `qa/test-cases/FEAT-004-onboarding.md` | FEAT-004 |
| TC-040..047 | Test cases: Search | draft | qa | `qa/test-cases/FEAT-005-search.md` | FEAT-005 |
| TC-048..057 | Test cases: Export | draft | qa | `qa/test-cases/FEAT-006-export.md` | FEAT-006 |
| TC-058..067 | Test cases: Import | draft | qa | `qa/test-cases/FEAT-007-import.md` | FEAT-007 |
| TC-068..074 | Test cases: Export reminder | draft | qa | `qa/test-cases/FEAT-008-export-reminder.md` | FEAT-008 |
| TC-075..082 | Test cases: Settings | draft | qa | `qa/test-cases/FEAT-009-settings.md` | FEAT-009 |
| TC-083..091 | Test cases: Cross-cutting | draft | qa | `qa/test-cases/cross-cutting.md` | THR-003, THR-005, THR-014, THR-015, ADR-005 |
| TC-092..102 | Test cases added after the owner's decisions | draft | qa | `qa/test-cases/decisions-2026-09-20.md` | FEAT-001, FEAT-003, FEAT-005, FEAT-006, FEAT-007, FEAT-009, ADR-006 |
| TC-103..111 | Test cases: Tags, mood, and On this day | draft | qa | `qa/test-cases/FEAT-010-tags-mood-and-on-this-day.md` | FEAT-010, FEAT-003, ADR-002, ADR-003, RISK-001, RISK-002 |
| TC-112..120 | Test cases: Photos | draft | qa | `qa/test-cases/FEAT-011-photos.md` | FEAT-011, FEAT-003, ADR-002, ADR-003, RISK-002, RISK-003, RISK-011 |
| RISK-001..014 | Product and technical risk register | active | product-manager | `product-manager/report/risk-register.md` | ADR-001, ADR-002, ADR-003, ADR-006, FEAT-001..011 |
| FEAT-001 | Entry management | active | product-manager | `product-manager/features/FEAT-001-entry-management.md` | ADR-001, ADR-002 |
| FEAT-002 | Timeline | active | product-manager | `product-manager/features/FEAT-002-timeline.md` | ADR-002 |
| FEAT-003 | App lock and screen privacy | active | product-manager | `product-manager/features/FEAT-003-app-lock.md` | ADR-001, RISK-003 |
| FEAT-004 | Onboarding and passcode setup | active | product-manager | `product-manager/features/FEAT-004-onboarding.md` | ADR-001, RISK-001 |
| FEAT-005 | Search | active | product-manager | `product-manager/features/FEAT-005-search.md` | ADR-002 |
| FEAT-006 | Export | active | product-manager | `product-manager/features/FEAT-006-export.md` | ADR-001, RISK-001, RISK-002 |
| FEAT-007 | Import | active | product-manager | `product-manager/features/FEAT-007-import.md` | ADR-001, ADR-002, RISK-002 |
| FEAT-008 | Export reminder | active | product-manager | `product-manager/features/FEAT-008-export-reminder.md` | RISK-001, FEAT-006 |
| FEAT-009 | Settings | active | product-manager | `product-manager/features/FEAT-009-settings.md` | ADR-001, FEAT-003 |
| FEAT-010 | Tags, mood, and On this day | active | product-manager | `product-manager/features/FEAT-010-tags-mood-and-on-this-day.md` | ADR-002, ADR-003, ADR-006, RISK-001, RISK-002, FEAT-001, FEAT-002, FEAT-003, FEAT-006, FEAT-007 |
| FEAT-011 | Photos | active | product-manager | `product-manager/features/FEAT-011-photos.md` | ADR-001, ADR-002, ADR-003, ADR-006, FEAT-001, FEAT-006, FEAT-007, FEAT-010 |

Labels used inside a single document (`AC-n` acceptance criteria, `INV-n` invariants, `DA-n` documentation criteria, `JRN`, `INS`, `HE`, `PT`, `KI`) are local to that document and are **not** registered. Register an artifact only when another role cites it.

Status values: `draft`, `active`, `superseded`, `deprecated`.

Run `node tools/check-registry.js` to verify that every location exists and every ID used in role docs is registered. Replace the example row; use 3-digit numbers (`FEAT-001`), ranges as `TC-001..005`.

## Traceability rule

A `FEAT` that reaches production should link to: at least one `TC`/`TP`, an `SLO` (if user-facing), an `RB` (if operable), and any `ADR`/`THR` that shaped it. `production-readiness-review.md` checks this.
