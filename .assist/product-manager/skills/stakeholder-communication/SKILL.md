---
name: stakeholder-communication
description: Use when announcing a decision, release, or delay, reporting status, escalating a risk, saying no to a request, or preparing release notes and support briefings for a FEAT-.
---
# Stakeholder Communication

## Purpose
Give each audience the information they need to act, at the right time, in the right depth, so expectations match reality and no one learns of a change from an incident.

## When to use
- A `FEAT-` changes status, slips, ships, or is cancelled.
- A decision or prioritisation outcome affects other teams or customers.
- A high `RISK-` needs escalation.
- A request is declined or deferred.

## Principles
- Lead with the decision or the ask, then the reason, then the detail.
- Audience first: executives get outcome, date, risk; operations and support get what changes for them and what to do; engineers get IDs and criteria.
- Be specific and dated: "ships to 5% on <date>", not "soon". State confidence honestly.
- Bad news early, with a plan. Never let a delay surface in a status meeting first.
- A "no" or "not now" names the reason, the criteria that would change it, and the next review date.
- Refer to artifacts by ID; do not paste sensitive data or real customer information.
- Match to decision rights in `context.md`: inform, consult, and decide are different messages.

## Steps
1. Identify audiences from the stakeholder table in `context.md` and the interest of each.
2. Choose the message type and channel: announcement, status report, escalation, decline, release note, support brief.
3. Draft using the structure below; verify every date and number against the spec, rollout plan, or decision record.
4. Check for sensitive content and for commitments you cannot keep.
5. Send; record what was sent, to whom, and when in the decision record or the `FEAT-` status log.
6. Track replies and open questions; close each with an owner.

## Templates
Status update: Status (on track / at risk / blocked), Since last update, Next (dated), Risks and asks (`RISK-NNN`), Decisions needed (owner, due).

Decline: What was asked; decision; reason (two lines, evidence); what would change it; when to revisit; alternatives.

Release note: what changed for the user in one sentence; who is affected; how to use it; known limits; where to get help; date and stage (`rollout-plan`).

Escalation: The problem in one sentence; impact and deadline; options with your recommendation; the decision needed and by when.

## Cadence by tier
T1: on change, plus a short monthly note. T2: fortnightly status, release note on each release. T3: also change-approval submissions and audit-ready records of communication.

## Output format
The message plus a log line in the `FEAT-` status log or decision record: date, audience, channel, IDs referenced.

## References
- `_shared/standards/release-management.md`, `severity-and-incident.md` (incident comms are owned by devops), `project-tiers.md`, `production-readiness-review.md` (Product sign-off, row 13)
- IDs: `FEAT-`, `RISK-`, `ADR-`, `RB-`; skills: `decision-record`, `rollout-plan`, `risk-register`
