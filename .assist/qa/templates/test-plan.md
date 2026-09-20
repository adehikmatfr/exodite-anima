# TP-<nnn>: <Test plan title>

> Sections marked *(optional)* may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| ID | TP-<nnn> |
| Status | draft / active / superseded |
| Owner (QA) | |
| Linked FEAT | FEAT-<nnn> |
| Related | ADR-, THR-, SLO-, API-, RB- |
| Target release / build | |
| Last updated | YYYY-MM-DD |

## 1. Scope
- In scope:
- Out of scope (with reason):
- Assumptions and dependencies:

## 2. Risk assessment
| Risk ID | Area / behavior | Impact (1-5) | Likelihood (1-5) | Score | Test depth | Linked TC |
|---------|-----------------|--------------|------------------|-------|-----------|-----------|
| RISK-<nnn> | | | | | deep / standard / smoke / none | TC-<nnn> |

## 3. Strategy by level
| Level | Approach | Automated? | Owner |
|-------|----------|-----------|-------|
| Unit (guidance) | | | |
| Integration | | | |
| Contract | | | |
| End-to-end | | | |
| Performance / load | | | |
| Resilience / chaos | | | |
| Security-adjacent (authz, input) | | | |
| Accessibility / compatibility | | | |
| Exploratory (charters) | | | |

## 4. Environments and data
| Environment | Purpose | Parity gaps vs production | Data (synthetic/masked) |
|-------------|---------|---------------------------|-------------------------|

## 5. Entry criteria
- [ ] Build deployed to test environment and smoke test green
- [ ] Acceptance criteria of FEAT reviewed and testable
- [ ] Test data and access ready

## 6. Exit criteria
- [ ] 100% of critical TC executed and passed; >= 95% of all planned TC executed
- [ ] No open S1/S2 defects; S3 defects accepted in writing
- [ ] NFR targets met (see `nfr-catalog.md` values recorded in ADR)
- [ ] Every FEAT acceptance criterion traced to at least one passing TC

## 7. Traceability
| FEAT acceptance criterion | TC IDs | Status |
|---------------------------|--------|--------|

## 8. Schedule and resources (optional)
| Activity | Owner | Start | End |
|----------|-------|-------|-----|

## 9. Defect handling (optional)
Severity/priority per `bug-report` skill; triage cadence: <daily/twice weekly>.

## 10. Risks to the plan and mitigations (optional)
| Risk | Mitigation | Owner |
|------|-----------|-------|

## 11. Results summary (fill at completion)
| Executed | Passed | Failed | Blocked | Open defects S1/S2/S3/S4 | Recommendation |
|----------|--------|--------|---------|--------------------------|----------------|
