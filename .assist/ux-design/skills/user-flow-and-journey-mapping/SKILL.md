---
name: user-flow-and-journey-mapping
description: Use when designing or reviewing how users move through a task or across a service. Covers task flows with decision points and error paths, journey maps, service blueprints, and edge and recovery paths.
---
# User Flow and Journey Mapping

## Purpose
Make the whole path visible, including failures, so gaps are found before build and improvements are measured against real stages.

## When to use
- Specifying a new `FEAT-` with more than one screen or step.
- Diagnosing drop-off in a funnel.
- Coordinating product, support and operations around a multi-channel experience.

## Principles
- Flow is one user, one goal, one path family; a journey is the whole experience across time and channels. Do not mix them.
- The happy path is the minority case for high-volume flows: design error, empty, timeout, permission-denied and offline paths explicitly.
- Every decision point has labelled outcomes; every path ends in a defined state (success, recoverable failure, exit).
- Journey maps are evidence artefacts: cells without data are marked "assumed" (`templates/journey-map.md`).
- Recovery beats prevention alone: users must always know what happened, what is saved and what to do next.

## Steps / Checklist
1. State the user goal, entry points (at least 2: direct, deep link, notification), and the success outcome.
2. Draw the task flow: start, steps, decisions (diamonds with yes/no or labelled branches), end states. Keep to about 15 nodes; split into sub-flows above that.
3. For each step list the error and edge paths:
   - validation failure, system error, timeout, duplicate submit, back button, session expiry
   - no data / first use, partial data, permission or role denied, offline or slow network
   - abandoned and resumed later (what is preserved)
4. For each error path define: message, cause, user action, recovery (retry, edit, contact) and whether data is kept. Payments and destructive actions need confirm, undo or a reversal window.
5. Count effort per flow: steps, inputs, decisions; target the fewest that keep the user safe; flag flows above 7 steps for review.
6. Build the journey map: segment with evidence, stages, actions, thoughts, emotions, pain points, moments of truth, metrics per stage (`templates/journey-map.md`).
7. Add a service blueprint where staff or systems shape the outcome: frontstage, backstage, support process, and the line of visibility; mark hand-offs where delays occur.
8. Validate: walk the flow with 3 users or a cognitive walkthrough (`heuristic-evaluation`); compare with funnel data.
9. Convert unresolved risks to `RISK-` and edge paths to acceptance criteria for the `FEAT-` (QA assigns `TC-`).

## Output format
Flow diagram (tool-native or Mermaid), an edge-case table, and a journey map. Edge-case table:

| Step | Condition | System behaviour | User sees | Recovery | Linked |
|------|-----------|------------------|-----------|----------|--------|
| Pay | card declined | no charge, keep cart | "Card declined; try another card" | edit card or choose another method | FEAT-NNN, TC-NNN |

Mini-example: checkout funnel 5 steps, 100 start, step 3 (address) 68 continue, so a 32% loss; interviews with 6 of 8 leavers cite a forced account creation; opportunity: guest checkout; metric: step 3 continuation from 68% to 80%.

## References
`_shared/standards/project-tiers.md`, `_shared/standards/nfr-catalog.md` (timeouts, availability), `FEAT-NNN`, `RISK-NNN`, `TC-NNN`. Metrics per stage: `ux-metrics-and-experiment-design`; evidence: `research-synthesis`.

## Language notes
Tools are examples only: FigJam, Miro, Mermaid (`flowchart TD` with `-->|error|` edges), or the project's design tool.
