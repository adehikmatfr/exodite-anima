---
name: ux-metrics-and-experiment-design
description: Use when defining how UX quality will be measured, designing events and funnels, or planning an A/B test of a design change. Covers the HEART framework, event design, guardrails, and A/B basics with power and common pitfalls.
---
# UX Metrics and Experiment Design

## Purpose
Choose a small set of metrics that reflect user experience and business goals, instrument them correctly, and test design changes without fooling ourselves.

## When to use
- Kicking off or launching a `FEAT-` that should improve an experience.
- Analytics shows a funnel problem, or a stakeholder wants "an A/B test".
- Specifying analytics events with engineering and the data analyst.

## Principles
- Goals, then signals, then metrics; never start from available data.
- Attitudinal (survey) and behavioural (event) metrics together; neither alone is enough.
- Every optimising metric has a guardrail that must not degrade (errors, accessibility, support contacts, latency).
- Experiments answer causal questions only if randomised, pre-registered and sized; otherwise report as associations.
- Collect the minimum; events respect consent and `data-governance.md`; no personal data in event payloads.
- The data analyst owns metric definitions and analysis; UX owns the hypothesis and the design variants (`experiment-analysis` in data-analyst).

## Steps / Checklist
1. Apply HEART per product area; use only the dimensions that matter (3-4 rows are normal):

| Dimension | Goal | Signal | Metric example |
|-----------|------|--------|----------------|
| Happiness | users feel positive | survey | SUS, CSAT, NPS |
| Engagement | users return and use depth | events | sessions per week, key actions per user |
| Adoption | new users start | first-use events | % new users completing onboarding within 7 days |
| Retention | users stay | repeated events | 30-day retention |
| Task success | users complete tasks | funnel events, errors | completion rate, time, error rate |

2. Design events: verb-noun names (`checkout_address_submitted`), one event per user-meaningful step, properties for step, outcome, variant, error code; funnel = ordered steps with a defined window. Review with the data analyst; register schema location in `context.md`.
3. Baseline first: at least 4 weeks (covering weekly cycles) before setting targets; record as-of date.
4. Set guardrails, for example: error rate not up by more than 10% relative, support contacts per 1,000 users not up, page load p75 within budget, no drop in accessibility checks.
5. A/B test design:
   - Hypothesis: "If we <change>, then <metric> moves from A to B for <segment>, because <insight INS-NNN>."
   - One primary metric, pre-set minimum detectable effect (MDE), significance 5%, power 80%.
   - Sample per arm for a conversion rate: approximately 16 x p(1-p) / delta^2. Example: baseline 20%, MDE +2 points (delta 0.02): 16 x 0.16 / 0.0004 = 6,400 per arm; with 2,000 eligible users a day, split 50/50, run at least 7 days, whole weeks only.
   - Randomise by user, not by session; keep exposure consistent.
6. Pitfalls: peeking and stopping early; many metrics without correction; novelty effect (run 2+ weeks); sample ratio mismatch (check the split, tolerance about 1%); segmenting after the fact; underpowered tests read as "no effect"; changing the design mid-test; small traffic (use usability tests or qualitative research instead).
7. Decide in advance: ship if primary improves at the MDE and no guardrail fails; hold if flat; roll back on guardrail breach.
8. Read out with interval, effect size, guardrails, and what we learnt; record the result against the `FEAT-`.

## Output format
Measurement plan and experiment brief: goal, HEART table with definitions and baselines, event schema list, guardrails, hypothesis, sample size calculation, duration, decision rule, owner, and link to the analysis plan. Mini-example: metric "onboarding completion" baseline 42%, target 48%; guardrail support contacts; 4,900 per arm at MDE 6 points, about 10 days.

## References
`_shared/standards/data-governance.md`, `_shared/standards/nfr-catalog.md`, `_shared/standards/project-tiers.md`, `FEAT-NNN`, `RISK-NNN`, `DS-NNN`, `TC-NNN` (event instrumentation acceptance). Cross-reference: data-analyst skills `experiment-analysis` and `metric-definition-and-kpi-tree`.

## Language notes
Tools are examples only: product analytics (Amplitude, Mixpanel, GA4), an experiment platform or feature flags for assignment, a power calculator or a stats library for sizing.
