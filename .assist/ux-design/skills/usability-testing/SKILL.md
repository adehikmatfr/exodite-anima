---
name: usability-testing
description: Use when a prototype or product must be tested with real users, or task success, time, errors or satisfaction need measuring. Covers moderated vs unmoderated, task design, the five-user heuristic and its limits, SUS bands, severity rating and reporting.
---
# Usability Testing

## Purpose
Find where real users fail, hesitate or misunderstand, rate how bad it is, and give the team fixes ranked by impact.

## When to use
- A flow or prototype is ready for users (low fidelity is enough for structure and flow).
- Before release of a `FEAT-` with a new or changed key journey.
- To benchmark or compare designs with metrics.

## Principles
- Test tasks people actually need, not features you built. Observe behaviour; opinions are secondary.
- Neutral moderation: no leading, no rescuing; log every assist.
- Five users is a heuristic for formative rounds: with a problem that affects 31% of users, 5 participants reveal about 85% of such problems; rarer problems (10%) need about 18 participants for the same coverage. Run several small rounds (3-5) with fixes between, rather than one big round. It does not give percentages: use 20+ for summative metrics.
- Include users of assistive technology and each key segment; one segment's success does not transfer to another.
- Consent and data handling per `user-research-planning`.

## Steps / Checklist
1. Choose the mode:

| Mode | Use when | Limit |
|------|----------|-------|
| Moderated (remote or in person) | exploring why, early prototypes, complex tasks | 45-60 min per session, cost |
| Unmoderated | many participants, simple tasks, benchmarks | no probing, lower data quality (screen out speeders and low-effort runs) |

2. Write 4-6 scenario tasks (`templates/usability-test-script.md`) with one observable success criterion, a time limit (about 2-3x expert time) and a maximum number of assists.
3. Prepare a build or prototype with synthetic accounts only; pilot with one person.
4. Run sessions; record outcome codes (success, success with assist, partial, fail, abandoned, timed out), time, errors, assists.
5. Collect the post-task Single Ease Question (SEQ, 1-7; average benchmark about 5.5) and, at the end, SUS.
6. Compute metrics and rate each problem; rate severity after the session, ideally by two raters.

| Metric | Benchmark and reading |
|--------|----------------------|
| Task success (unaided) | 78% is a common average; below 70% investigate; 90%+ good for frequent tasks |
| Time on task | compare to expert or previous version; report median (skewed) |
| Errors | count per task; any error on destructive tasks is a finding |
| SUS (0-100) | below 51 poor (F); 51-68 below average; 68 average; 68-80.3 good; above 80.3 excellent (top 10%); above 85 best-in-class. Meaningful only with roughly 12+ responses; report with confidence interval |

7. Severity scale: 0 not a problem; 1 cosmetic; 2 minor (slows, recovers); 3 major (fails or seriously delays many); 4 blocker (cannot complete a critical task). Weigh by frequency (how many of the participants), impact and persistence.
8. Combine with a heuristic evaluation (`heuristic-evaluation`): experts find breadth cheaply, tests confirm which matter.
9. Report answer-first within 3 working days; distribute highlight clips only with consent.

## Output format
Report: goal and decision; participants (n, segments); task results table (success, time, errors, SEQ); SUS with interval; problems ranked by severity with evidence and a recommendation; what worked; limits. Mini-example: 6 participants, task 3 "Change plan": 2 of 6 unaided success (33%), 3 assists, median 4:10 vs 2:00 limit; cause: "Plan" hidden under "Account"; severity 3 (5 of 6 hesitated); recommendation: add to top menu; retest in the next round. Severity 3-4 items link to `FEAT-` and become `TC-` regression tests via qa; hazards become `RISK-`.

## References
`_shared/standards/data-governance.md`, `_shared/standards/project-tiers.md`, `_shared/standards/definition-of-done.md`, `FEAT-NNN`, `RISK-NNN`, `TC-NNN`. Related: `user-research-planning`, `inclusive-and-accessible-design`, `research-synthesis`.

## Language notes
Tools are examples only: Zoom or Meet for moderated sessions, Maze or UserTesting for unmoderated, a spreadsheet for SUS scoring (odd items score-1, even items 5-score, sum times 2.5).
