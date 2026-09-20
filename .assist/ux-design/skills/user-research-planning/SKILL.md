---
name: user-research-planning
description: Use when a product question needs user evidence, or before recruiting or contacting any participant. Chooses the method by question, sets sample size and its limits, plans recruitment, consent, incentives and data retention.
---
# User Research Planning

## Purpose
Pick the cheapest method that can answer the question, and run it ethically. A study without a decision to inform, or without consent handling, is not started.

## When to use
- A `FEAT-` has unknowns about users, needs, behaviour or comprehension.
- Before any interview, survey, diary, field visit, card sort or test.
- When a stakeholder asks "let's just ask users" without a question.

## Principles
- Question and decision first; method second. Reuse existing evidence before new fieldwork.
- Behaviour (what people do) answers "what and how much"; attitudes (what they say) answer "why and how they feel". Do not answer "how many" with interviews.
- Sample size follows the method's purpose, not a fixed rule; state what the number cannot show.
- Consent, minimisation and retention are decided before recruiting, not after.

## Steps / Checklist
1. Write the question, the decision, the decider and the deadline (`templates/study-protocol.md`).
2. Search the research repository and analytics; stop if the question is already answered.
3. Choose the method:

| Question | Method | Typical sample | Limit |
|----------|--------|----------------|-------|
| Why do users behave this way; unknown needs | Interviews | 5-8 per segment; stop when 2 consecutive sessions add no new theme | not generalisable, no frequencies |
| How many, how often, how much | Survey | 100+ per analysed group; 385 for +/-5% at 95% on a large population | self-report, response bias, low response (5-20%) |
| Behaviour over days or weeks | Diary study | 10-15 for 1-2 weeks, expect 20-30% drop-out | fatigue, reactive reporting |
| Real context, workarounds | Field / contextual inquiry | 4-8 visits | costly, small n |
| How users group content | Card sort (open) | 15-30 (open), 30+ (closed) | mental models only, not findability |
| Can users find things | Tree test | 50+ for stable percentages | tests structure, not visual design |
| Can users complete tasks | Usability test | see `usability-testing` | finds problems, not prevalence |

4. Define screening criteria (must-have, exclusions), quotas per segment, and include at least one assistive-technology user for interface studies.
5. Choose recruitment channel from `context.md`; do not recruit only from friendly or internal contacts for external products; expect 20% no-shows (over-recruit by 1 in 5).
6. Write the consent form: purpose, what is recorded, who sees it, retention, withdrawal, contact. Get explicit yes to recording separately.
7. Set incentive: fair for time (for example the local hourly rate for the segment), never contingent on answers, approved by the budget owner. Employees and customers under contract: check policy for gifts.
8. Set retention: recordings deleted N days after synthesis (default 90 unless the project says otherwise), transcripts pseudonymised, deletion date in the protocol.
9. Pilot with one person; fix wording; then field.
10. Risk-check topics: minors, health, finance, distress. Route through the compliance owner (`compliance-matrix.md`) before recruiting.

## Output format
A completed `study-protocol.md` with `RS-NNN`, consent form, screener, and instrument. Mini-example: question "Why do 40% of new users stop at step 3?"; decision "redesign or keep step 3 by sprint 14"; method 7 interviews with drop-outs (analytics gives the 40%, interviews give the why); recruit 9 for 20% no-shows; recordings deleted 60 days after readout.

## References
`_shared/standards/data-governance.md`, `_shared/standards/project-tiers.md`, `_shared/compliance/compliance-matrix.md` (consent and personal data), `FEAT-NNN`, `RISK-NNN`. Sample sizes: qualitative saturation research (about 6-12 interviews for a homogeneous group); use the data-analyst skill `experiment-analysis` for powered quantitative sizing.

## Language notes
Tools are examples only: survey (Typeform, Google Forms, Qualtrics), scheduling (Calendly), recording (Zoom, Lookback), repository (Dovetail, Notion).
