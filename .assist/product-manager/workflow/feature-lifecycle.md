# Feature lifecycle in exodite-anima

As-built description of how a change becomes a released feature in this project. Written after the process was set up on 2026-09-20; update it when the process changes.

## 1. Overview
Every change to product behaviour is a `FEAT-`. The project owner is the only stakeholder, so the product-manager role shapes each spec and the owner decides. The project has no backend, so the usual hand-off to a backend role does not exist; its duties are split as described below.

## 2. Trigger / entry points
- A new idea or request from the owner.
- A finding from a test, threat model, or store review that changes behaviour.
- A pending decision in `../decisions/` that unblocks a spec.

## 3. Step-by-step flow
1. Read `../../_shared/project.md`, this role's `prompts/role.md` and `context.md`, and `../../_shared/index.md`.
2. Reserve the next `FEAT-NNN` in `../../_shared/index.md` as `draft`.
3. Write the spec from `../templates/feature-spec.md` into `../features/FEAT-NNN-slug.md` (skill `write-feature-spec`). Behaviour only; no invented numbers; unknowns become open questions with an owner and due.
4. Define success metrics (`success-metrics-and-kpi`), check compliance (`compliance-and-legal-check`), and register risks (`risk-register`, in `../report/risk-register.md`).
5. Record cross-feature product decisions in `../decisions/<slug>.md`; architectural decisions go to the software-architect as `ADR-`.
6. Hand off by ID:
   - software-architect: trust boundary, data model, or NFR change; returns `ADR-`.
   - cyber-security: personal data or new exposure; returns `THR-`.
   - qa: criteria for `TP-` and `TC-`; ambiguities are fixed in the spec.
   - frontend-mobile: takes the place of backend; gives the effort read and builds the feature. It also owns store release and rollout.
7. When open questions are resolved and every criterion is testable, set the spec to `ready`.
8. After release, update the capability doc in `../capabilities/` and hold a post-release review.

## 4. Statuses and data model
Spec statuses: `draft`, `ready`, `in-progress`, `released`, `superseded`, `deprecated` (see `../features/README.md`). The shared registry maps them to `draft`, `active`, `superseded`, `deprecated`.

## 5. External calls and events
None. The product-manager role has no external system. Store consoles are read after release for crash-free rate and reviews.

## 6. Decisions and gotchas
- The source of truth for specs, decisions, and risks is in `.assist/`. Public copies in `docs/` are made only from these, never the reverse.
- Acceptance criteria cite "QA will assign" until qa writes the test plan; re-check every mapping once tests exist (`write-feature-spec` step 11).
- A risk score of 20 or more blocks `ready` unless waived in writing. RISK-001 is waived through ADR-001.
- Prioritisation scoring is not used until effort reads exist (`../decisions/v1-scope-and-non-goals.md`).
- On 2026-09-20 the owner answered every open question on FEAT-001 to FEAT-009. The specs stay `draft` until an effort read exists (step 9 of `write-feature-spec`) and the owner confirms them as `ready`.
- The `devops` role was removed; see `../../_shared/project.md` for where its duties went.
