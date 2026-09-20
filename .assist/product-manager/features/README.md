# features

One spec per change request. Every change to product behaviour, new or adjusted, is a `FEAT-`.

## Naming
`features/FEAT-NNN-slug.md`, for example `FEAT-NNN-bulk-export.md`. Slug is kebab-case and short. The ID is assigned when the spec is created, registered in `../../_shared/index.md`, and never reused or renumbered.

## Lifecycle
| Status | Meaning | Exit criterion |
|--------|---------|----------------|
| `draft` | Being shaped | Problem, goals, non-goals, and a first set of criteria exist |
| `ready` | Approved for hand-off | Criteria testable, owner named, metrics and risks filled, open questions resolved or owned |
| `in-progress` | Under build | Backend and QA have acknowledged the spec |
| `released` | Live | Rollout complete, capability doc updated, post-release review scheduled |
| `superseded` / `deprecated` | Replaced or retired | Link to the replacing `FEAT-` |

Registry mapping (`_shared/index.md` allows only `draft`, `active`, `superseded`, `deprecated`): `draft` and `ready` register as `draft`; `in-progress` and `released` register as `active`; the last two map one to one.

## Rules
- Use `../templates/feature-spec.md`. Optional sections may be dropped for T1 projects only.
- A spec cannot move to `ready` with an acceptance criterion that is not verifiable, or without non-goals.
- Product-level decisions made while shaping the spec are recorded in the spec (Decisions section) or in `../decisions/<slug>.md` and referenced by the `FEAT-`.
- Link related `ADR-`, `RISK-`, `TC-`, `SLO-`, `API-` IDs in the spec header; QA and backend add their own back-references.
- Adjustments to live behaviour must state current behaviour from confirmed knowledge.

## Index
| ID | Title | Status | Owner | Priority score |
|----|-------|--------|-------|----------------|
| FEAT-001 | Entry management | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-002 | Timeline | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-003 | App lock and screen privacy | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-004 | Onboarding and passcode setup | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-005 | Search | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-006 | Export | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-007 | Import | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-008 | Export reminder | in-progress | Project owner | not scored (v1 must-have) |
| FEAT-009 | Settings | in-progress | Project owner | not scored (v1 must-have) |
