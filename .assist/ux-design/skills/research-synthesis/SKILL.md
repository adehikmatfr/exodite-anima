---
name: research-synthesis
description: Use after fieldwork or when raw notes, recordings, survey text or support tickets need turning into insights. Covers coding, affinity mapping, insight statements with evidence strength, evidence-based personas and reporting with confidence.
---
# Research Synthesis

## Purpose
Convert observations into a small number of defensible insights that a team can act on, each with visible evidence and stated confidence.

## When to use
- After a study (`RS-NNN`) or when accumulated feedback needs a pattern view.
- Before creating or updating a persona, segment or journey map.
- When a stakeholder quotes one participant as "what users want".

## Principles
- Observations first, interpretation second; keep them in separate columns.
- Every insight is traceable to sessions (P01, P04, P07), never to a single vivid quote alone.
- Count and disclose: "6 of 8" not "many". Qualitative counts describe the sample, not the population.
- Disconfirming evidence is recorded, not discarded.
- Personas exist only when data supports the differences; otherwise use segments or jobs-to-be-done statements.

## Steps / Checklist
1. Clean and pseudonymise raw data (P## only); remove identifiers before sharing with the team.
2. Break notes into atomic observations (one behaviour or quote each), tagged with session, task, segment.
3. Code: start with 10-20 open codes on the first 2-3 sessions, agree a codebook, then apply to the rest. Two coders on at least 20% of the data; aim for agreement of 80% or higher, resolve the rest by discussion; record the codebook version.
4. Affinity map: cluster codes into themes bottom-up (typically 5-9 themes for 8 sessions); name themes as findings, not topics ("Users cannot tell which plan they are on", not "Pricing").
5. Write insight statements: `<who> <does or experiences> <what>, because <why>, which affects <outcome>`.
6. Rate evidence strength:

| Strength | Criteria |
|----------|----------|
| Strong | 2+ methods agree, or 6+ participants across 2+ segments with behavioural evidence |
| Moderate | one method, 3-5 participants consistent, or 1 method plus analytics |
| Weak | 1-2 participants, self-report only, or contradicted by other data |

7. Attach confidence to each recommendation: high (strong evidence, reversible or low cost), medium, low (needs validation before large investment).
8. Check bias: leading prompts, recruitment skew, moderator effect, recency, over-weighting articulate participants.
9. Personas (only if evidenced): base on 2+ behavioural dimensions that differ across at least 3 participants per persona plus analytics share; include evidence, date, share of users, goals, obstacles; no invented names-with-stock-photo biography, no demographics that are not data. Review after 12 months.
10. Report answer-first: decision, top findings, recommendation, confidence, what would change our mind, limits. Link to `FEAT-` and `RISK-`.

## Output format
Insight table:

| ID | Insight | Evidence (sessions, count) | Strength | Recommendation | Confidence | Linked ID |
|----|---------|----------------------------|----------|----------------|------------|-----------|
| INS-NNN | New users cannot tell which plan is active, because the badge is below the fold | 6 of 8 (P01-P06); analytics: 31% open pricing twice | Strong | Move plan badge to header | High | FEAT-NNN |

Plus a one-page readout and the tagged evidence stored in the research repository. Quotes carry P## only.

## References
`_shared/standards/data-governance.md` (retention, pseudonymisation), `_shared/standards/project-tiers.md`, `FEAT-NNN`, `RISK-NNN`. For quantitative confirmation hand off to the data-analyst (`report-narrative-and-insights`).

## Language notes
Tools are examples only: Dovetail, Miro or FigJam for mapping, spreadsheets for the codebook and inter-coder agreement.
