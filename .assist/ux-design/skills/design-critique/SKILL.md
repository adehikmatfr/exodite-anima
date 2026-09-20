---
name: design-critique
description: Use when a design needs structured feedback before approval or hand-off, when a critique session is being planned or run, or when feedback is vague, opinion-driven or conflicting and must become actionable findings.
---
# Design Critique

## Purpose

Improve a design against stated goals by turning group feedback into specific, evidence-based, prioritised findings, and by keeping taste out of the decision.

## When to use

- Before a brief moves to approved or a design moves to hand-off.
- After a design QA pass finds systemic issues.
- When stakeholders give conflicting or subjective feedback.
- Not for status updates or approvals of unchanged work.

## Principles

- **Goals first.** Critique against the brief (`FEAT-NNN`, success criteria, constraints), not against what a reviewer would have done.
- **Observation before interpretation before suggestion.** "The primary button is 32 px high and grey on grey (contrast 2.1:1)" is an observation; "it looks weak" is preference.
- **Preference is allowed, labelled as such.** Record it as a suggestion, never as a blocker.
- **Criteria are named in advance** so every finding maps to one.
- **Critique the work, not the person.** Blameless, specific, kind.
- **Output is a decision plus owned actions**, not a discussion transcript.

## Steps / Checklist

1. Prepare (designer, 1 day before): share the brief link, the goal of the session, the exact question ("is the checkout error recovery clear?") and what feedback is NOT wanted (for example brand colours already approved).
2. Assign roles: presenter (5 min max, problem and constraints first), facilitator (timekeeper, keeps to criteria), scribe (writes findings live), reviewers (2-6, mix of design, product, engineering, qa), decider (one named person, usually the brief owner).
3. Present without defending: the presenter states intent and open doubts, then stays silent while reviewers speak.
4. Round 1, clarifying questions only (5 min). Round 2, reviewers give findings in the form: observation, criterion, impact, optional suggestion (20-30 min).
5. Facilitator parks off-topic items and solution debates; scribe tags each finding as blocker / major / minor / suggestion.
6. Close: read back the findings, the decider records the decision (approve, approve with follow-ups, changes required), assign an owner and date to every open finding.
7. Follow up within 1 working day: publish the record, re-review only the changed parts.

Timebox: 45-60 minutes per session; one artifact or flow per session.

## Output format

Use `templates/design-review-record.md`. Each finding:

`Finding: <observation with location> | Criterion: <brief section / WCAG SC / design-system rule> | Impact: <who is affected, how> | Severity | Owner | Due`

Worked mini-example:

- Observation: on the payment error state, the message "Error 4021" appears only in red, no text explaining the fix.
- Criterion: brief section 7 (error state), WCAG 1.4.1 use of colour, 3.3.3 error suggestion.
- Severity: major. Owner: designer. Due: before hand-off.
- Reviewer preference ("prefer a modal") recorded as a suggestion, not a blocker.

## References

- `templates/design-brief.md`, `templates/design-review-record.md`.
- `_shared/standards/definition-of-done.md`, `_shared/standards/project-tiers.md` (T1: notes in the brief are enough; T2/T3: recorded review).
- Related: `inclusive-and-accessible-design`, `design-handoff-and-design-qa`.
- IDs: `FEAT-NNN`, `RISK-NNN` for unresolved major findings, `ADR-NNN` when the outcome is a system-level decision.
