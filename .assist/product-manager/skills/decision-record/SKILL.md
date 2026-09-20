---
name: decision-record
description: Use when a product call is made, a trade-off is settled, an open product question must be tracked, or a prioritisation outcome needs a durable record. Routes architectural decisions to ADR-.
---
# Decision Record

## Purpose
Keep the reasoning behind product calls durable and findable, so the team does not re-litigate them and new members understand why the product behaves as it does.

## When to use
- Choosing between scope options, behaviours, policies, or rollout approaches.
- Ranking outcomes from `prioritization`, including overrides.
- An open question blocks a `FEAT-` and needs an owner and a date.
- Reversing or refining an earlier decision.

## Principles
- Route first: architectural decisions (structure, technology, data model, trust boundary, NFR trade-off) become an `ADR-` owned by the software architect; this skill records the product side and links to it.
- Feature-local decisions live in the `FEAT-` spec Decisions section; cross-feature or long-lived ones live in `decisions/<slug>.md` and are referenced by each `FEAT-`.
- A pending decision is valid and useful: it needs an owner, a decider, and a due date.
- Record options that lost and why; that is the part people need later.
- Decisions are not edited to hide history: supersede and link.
- Name the decider from the decision rights in `context.md`; a call made by someone without the right is a proposal.

## Steps
1. Classify: architectural (hand to architect and reference `ADR-NNN`), feature-local (spec), or cross-feature (decision file).
2. State the question and context: constraints, evidence, deadline for the call.
3. List at least two options, including "do nothing". Give pros, cons, effort, and risk. Use weighted scoring when criteria conflict.
4. Record the decider, date, and the chosen option with the deciding reasons. Record dissent.
5. State consequences: roadmap, other `FEAT-`, new `RISK-`, follow-up tasks, and the metric or date to revisit.
6. Link from every affected `FEAT-`, capability doc, and risk entry.
7. Communicate to affected stakeholders (`stakeholder-communication`).
8. When reversed, set the old record to `superseded` and link the new one.

## Quality bar
- Someone reading only this record in a year can tell what was decided, why, and what was rejected.
- The decision is falsifiable: there is a trigger or metric that would reopen it.
- No option was scored using an effort guess; effort came from engineering.

## Output format
`decisions/<slug>.md` from `templates/decision-record.md`: status, date, decider, related IDs, context, options table, decision, consequences. Add a row to `decisions/README.md`.

## References
- `_shared/index.md` (ID routing), `_shared/standards/project-tiers.md`, `release-management.md` (change approvals at T3)
- IDs: `ADR-`, `FEAT-`, `RISK-`; skills: `prioritization`, `risk-register`, `stakeholder-communication`
