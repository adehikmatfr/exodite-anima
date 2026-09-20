---
name: heuristic-evaluation
description: Use for a fast expert review of an interface before or alongside user testing, when users are not yet available, or to audit a legacy flow. Covers Nielsen's 10 heuristics, evaluator count, severity scale, cognitive walkthrough and combining with tests.
---
# Heuristic Evaluation

## Purpose
Find likely usability problems cheaply by inspecting a design against recognised principles, and hand a prioritised list to the team.

## When to use
- Early designs, or before spending participants on a test.
- Regression audit of a changed flow.
- Complement to `usability-testing` to widen coverage. It is not a substitute: experts miss problems real users hit and flag some that never matter.

## Principles
- Several independent evaluators beat one: a single evaluator finds about 35% of problems, 3 find about 60%, 5 find about 75%. Use 3-5, working alone first, then merging.
- Evaluate against a stated scope, task list and user profile, not personal taste.
- Every finding names the heuristic violated, the location, the evidence and a severity; "I don't like it" is not a finding.
- Judge the design, be specific and constructive, also note what works.

## Steps / Checklist
1. Fix scope: screens or flows, user segment, device, 3-5 representative tasks from the `FEAT-`.
2. Brief 3-5 evaluators (at least one with domain knowledge); provide the heuristic list and severity scale.
3. Two passes each: first for flow and overall feel, second per screen against every heuristic. Budget 1-2 hours.
4. Nielsen's 10 heuristics:

| # | Heuristic | Quick probe |
|---|-----------|-------------|
| 1 | Visibility of system status | does the user know what is happening, and progress? |
| 2 | Match between system and real world | users' language and order? |
| 3 | User control and freedom | undo, cancel, exit? |
| 4 | Consistency and standards | same word or action, same result; platform norms? |
| 5 | Error prevention | confirmation, constraints, safe defaults? |
| 6 | Recognition rather than recall | options visible, context kept? |
| 7 | Flexibility and efficiency of use | shortcuts, defaults for experts? |
| 8 | Aesthetic and minimalist design | only relevant information? |
| 9 | Help users recognise, diagnose and recover from errors | plain-language message, cause, fix? |
| 10 | Help and documentation | findable, task-focused? |

5. Log each problem: ID, location, heuristic, description, evidence (screenshot with no personal data), severity, suggested fix.
6. Severity scale (same as tests): 0 not a problem; 1 cosmetic; 2 minor; 3 major; 4 blocker. Each evaluator rates alone; use the median; discuss differences of 2 or more.
7. Merge duplicates and rank by severity times reach (how many users and how often).
8. Optional cognitive walkthrough for learnability (first-time users): for each step ask (a) will the user try to achieve the right effect, (b) will they notice the correct action, (c) will they connect it with their goal, (d) will they see progress after acting? Any "no" is a problem with a note on the cause.
9. Feed unresolved severity 3-4 items to the next usability test as tasks to confirm; add accessibility checks with `inclusive-and-accessible-design`.

## Output format
Consolidated list:

| ID | Location | Heuristic | Problem | Evaluators (of 4) | Severity | Fix |
|----|----------|-----------|---------|-------------------|----------|-----|
| HE-NNN | Checkout, step 3 | 9 error recovery | "Error 4021" shown with no cause | 4 | 4 | plain message plus field highlight |

Summary: counts by severity, top 5 fixes, method limits, linked `FEAT-` and `RISK-`. Mini-example: 4 evaluators, 27 unique problems, 3 severity 4, 8 severity 3; 5 of 6 severity 3-4 items were later confirmed in a 5-user test.

## References
`_shared/standards/project-tiers.md`, `_shared/standards/definition-of-done.md`, `FEAT-NNN`, `RISK-NNN`, `TC-NNN`. Related: `design-critique` (stakeholder feedback, a different activity), `usability-testing`.

## Language notes
Tools are examples only: annotated screenshots in the design tool, a shared spreadsheet for independent logging and merge.
