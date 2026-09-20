---
name: write-feature-spec
description: Use when a new request, change, or adjustment arrives and needs to become a FEAT- spec that backend and QA can build and verify. Also use when reviewing a spec for readiness before hand-off.
---
# Write a Feature Spec

## Purpose
Turn a request into a `FEAT-` spec that is unambiguous, testable, and sized to the project tier, so engineering and QA never have to guess intent.

## When to use
- A stakeholder, ticket, or data signal proposes new or changed behaviour.
- A draft spec is about to move to `ready`.
- QA or backend reports an ambiguous or untestable criterion.

## Principles
- Problem before solution: a spec that cannot state the problem and evidence is not ready.
- Behaviour, not implementation: no code, paths, or table names.
- Non-goals are mandatory; whatever is not stated in scope is out.
- Every acceptance criterion is observable and maps to at least one `TC-`.
- Unknowns are written down as open questions with an owner and date; never filled with guesses.
- Depth scales with tier (`project-tiers.md`): T1 may drop optional sections; T3 needs compliance and rollout in full.

## Steps
1. Reserve the next `FEAT-NNN`; register it in `_shared/index.md` as `draft`.
2. Read the related `capabilities/` doc. For an adjustment, record confirmed current behaviour only.
3. State the problem with evidence (numbers, tickets, interviews), the affected segments from `context.md`, and why now.
4. List goals (each tied to a metric) and non-goals.
5. Walk through the proposed behaviour including the failure and edge paths. Add a diagram if more than one actor or branch.
6. Write user stories, then acceptance criteria in Given/When/Then. Split any criterion containing "and" across two outcomes.
7. Add NFR targets (quantified, from `nfr-catalog.md`), data classes, and compliance triggers (run `compliance-and-legal-check`).
8. Define success metrics (`success-metrics-and-kpi`), rollout intent (`rollout-plan`), and risks (`risk-register`).
9. Ask backend for an effort read and the architect for constraints; record who answered and when.
10. Run the readiness check, then set status `ready` and hand off by ID.
11. `TC-` IDs written in a spec are provisional until QA registers the tests; when the tests exist, re-check every criterion-to-`TC-` mapping (numbers were reused once, so a spec pointed at the wrong tests). `check-registry` verifies that IDs exist, not that a criterion maps to the right test.

## Readiness checklist
- [ ] Owner named; problem and evidence stated
- [ ] Goals, non-goals, and out-of-scope items listed
- [ ] Every criterion is Given/When/Then, measurable, and has a `TC-` or a note that QA will assign one
- [ ] NFRs quantified; no adjectives such as "fast" or "secure" without a number or a standard
- [ ] Personal data, money, or regulated impact assessed
- [ ] Metrics have baseline, target, and guardrail
- [ ] Risks registered as `RISK-`; open questions owned and dated

## Output format
`features/FEAT-NNN-slug.md` from `templates/feature-spec.md`, plus a registry row in `_shared/index.md`. Example criterion:

| # | Given | When | Then |
|---|-------|------|------|
| AC-1 | A signed-in user with the export permission | They request an export of more than the row limit | The system rejects the request with a message stating the limit, and no file is created |

## References
- `_shared/standards/project-tiers.md`, `definition-of-done.md`, `nfr-catalog.md`, `production-readiness-review.md` (row 1)
- IDs: `FEAT-`, `TC-`, `TP-`, `ADR-`, `RISK-`, `SLO-`, `API-`
- Skills: `success-metrics-and-kpi`, `compliance-and-legal-check`, `risk-register`, `rollout-plan`
