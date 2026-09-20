# Test process in exodite-anima

As-built description of how testing is planned and traced in this project. Written after the process was set up on 2026-09-20; update it when the process changes.

## 1. Overview
QA derives test cases from the acceptance criteria of each `FEAT-`, ranks effort by risk, and records everything in one plan for the version 1 release (`TP-001`). QA does not invent expected results or acceptance criteria: gaps are raised to the product-manager. Because the project has no code and no CI yet, every case is a design, not a result.

## 2. Trigger / entry points
- A spec reaches `draft` with acceptance criteria, or a criterion changes.
- A defect or an escaped problem re-scores a risk.
- A release candidate is ready for sign-off.

## 3. Step-by-step flow
1. Read `../../_shared/project.md`, this role's `prompts/role.md` and `context.md`, and `../../_shared/index.md`.
2. Read the `FEAT-`, and the `ADR-`, `THR-`, and `RISK-` that shaped it.
3. Rank by risk (`risk-based-testing`): impact x likelihood, 1 to 5 each; the score sets the depth.
4. Write or update the plan (`test-plan`) and register it in `../../_shared/index.md`.
5. Write cases (`test-case-writing`): one case per acceptance criterion, plus negative, boundary, and failure cases by risk. Register `TC-` ranges in the index.
6. Put each `TC-` in the last column of its criterion in the spec, so `check-registry.js` can verify the link.
7. Raise gaps (no criterion, unmeasurable criterion, missing decision) to the product-manager by ID; mark dependent cases `blocked` and name the decision.
8. Run the cases as builds become available, record results in each case's execution log, and file defects. Automated tests live in `app/test/` (host) and `app/integration_test/` (device or emulator); a log names the test file that produced the result and says what was not covered.
9. At release, give a Go, Conditional Go, or No-Go (`release-sign-off`) from evidence on the exact build.

## 4. Statuses and data model
Case status: draft, blocked, active, deprecated. Plan status: draft, active, superseded. Priority: P0 blocks the release if it fails, P1 important, P2 secondary, P3 rare. Case files: `../test-cases/FEAT-NNN-slug.md` and `../test-cases/cross-cutting.md`; plan: `../test-plans/TP-001-v1-release.md`.

## 5. External calls and events
None. No tracker or CI is connected yet (`../context.md`).

## 6. Decisions and gotchas
- The first cases were generated from the spec text by a script, then reviewed for wording; steps are deliberately short. They are refined into exact steps when the screens and code exist. **From 2026-09-20 the case files are edited by hand** (execution logs were added to TC-084, TC-085, and TC-091): do not regenerate them, or the logs are lost.
- `check-registry.js` reports a warning for each case linked to a FEAT that no criterion cites. The 26 cases without a criterion produce these warnings on purpose; they disappear as the product-manager adds criteria or the cases are re-linked. Use `--strict` only after that.
- Cases that need a number or a rule (targets, passcode rules, matching rules, thresholds, limits) stay blocked until the owner decides; QA never fills in the number.
- Release builds are tested separately from debug builds because their permissions and logging differ (ADR-005).
- iOS execution is out of reach on the current machine; the owner must accept that residual risk in writing or provide a Mac or cloud CI.
