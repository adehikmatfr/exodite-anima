---
name: test-plan
description: Use when a feature, release, migration, or integration needs a documented test approach with scope, strategy, environments, entry/exit criteria and traceability; produces a registered TP- document.
---
# Test Plan

## Purpose
Create a concise, reviewable agreement on what will be tested, how, by whom, and what "enough" means, traceable to the requirement.

## When to use
- Every `FEAT-` that reaches production (required by the traceability rule in `_shared/index.md`).
- Migrations, integrations, major refactors, infrastructure changes.
- Skip a full plan for low-risk changes; a short plan with scope and exit criteria is enough.

## Principles
- One plan per coherent change, not per test type; keep it under ~3 pages of substance.
- Derived from risk ranking (`risk-based-testing`), not from a generic checklist.
- Exit criteria are measurable and agreed before execution starts.
- Plans are living: update on scope change, keep history, mark superseded plans.
- State environment parity gaps; results are only as valid as the environment.

## Steps / Checklist
1. Copy `templates/test-plan.md`; assign next `TP-` ID; register it in `_shared/index.md`.
2. Link the `FEAT-` and pull acceptance criteria into the traceability table.
3. Define scope: in, out (with reason), assumptions, dependencies.
4. Insert the risk table from `risk-based-testing`.
5. Choose levels and automation per risk (unit guidance, integration, contract, e2e, performance, resilience, security-adjacent, accessibility, exploratory).
6. Specify environments, data (synthetic or masked), access, and parity gaps.
7. Set entry and exit criteria (defaults below; tighten by risk).
8. Plan schedule, owners, defect triage cadence, and reporting.
9. Review with engineering and product; record approval; freeze baseline.
10. At completion, fill results summary and hand to `release-sign-off`.

### Default criteria
| Criterion | Entry | Exit |
|-----------|-------|------|
| Build | Deployed, smoke green | Release candidate frozen |
| Critical (P0) cases | Ready | 100% executed and passed |
| All planned cases | Ready | >= 95% executed, >= 95% pass, failures triaged |
| Defects | Triage process live | 0 open S1/S2; S3 accepted in writing |
| Regression | Suite stable | Full pass on release candidate |
| NFR | Targets recorded | Measured and within target (`nfr-catalog.md`) |
| Traceability | Criteria testable | Every acceptance criterion has a passing `TC-` |

## Output format
A filled `templates/test-plan.md` with ID `TP-<nnn>`, status, linked IDs, and a results summary. Registry row added with status `draft` then `active`.

## References
- `_shared/standards/definition-of-done.md`, `production-readiness-review.md`
- `_shared/standards/nfr-catalog.md`, `release-management.md`
- `_shared/index.md`

## Language notes
None. Tool names (tracker, runner) belong in `.assist/qa/context.md`, not in the plan.
