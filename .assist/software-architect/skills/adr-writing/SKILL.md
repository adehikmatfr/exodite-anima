---
name: adr-writing
description: Use when a significant, hard-to-reverse, or cross-team technical decision is being made, changed, or needs to be recorded; also when an existing ADR must be superseded or a decision's rationale is asked about.
---
# ADR Writing

## Purpose
Capture a decision, its context, the alternatives rejected, and the consequences, so future engineers can understand why, and can change it knowingly.

## When to use
- Choice of data store, messaging style, service boundary, auth model, cloud/vendor, public API shape, or NFR targets.
- A decision that took more than one meeting, or that someone will later ask "why?" about.
- Superseding or deprecating an earlier ADR.
- Not for: reversible, local choices (naming, a library used in one module), or routine implementation detail.

## Principles
- One decision per ADR. Small and numerous beats large and rare.
- Context before solution: an ADR that starts with the answer is a justification, not a decision.
- At least two genuine options plus "do nothing". A strawman does not count.
- Record consequences honestly, including negative ones and accepted risks.
- ADRs are immutable once accepted; change them by superseding, never by rewriting history.
- IDs are stable and never reused (`_shared/index.md`).

## Steps / Checklist
1. Allocate the next `ADR-NNN` from `_shared/index.md`; set status `proposed`.
2. Copy `templates/adr.md`.
3. Write Context: forces, constraints, compliance rows, deadlines. Facts only.
4. List quantified drivers (NFRs) with target and measurement (see `nfr-analysis`).
5. Describe options with pros, cons, cost, risks. Score with `tradeoff-analysis` if not obvious.
6. State the decision in one sentence: "We will X, because Y and Z."
7. Classify reversibility (one-way / two-way) and write the exit strategy.
8. List consequences, follow-up tasks, new `RISK-` entries, assumptions with owners and dates.
9. Set a review date or trigger (e.g. "revisit if p95 > 400 ms for 2 weeks").
10. Circulate to deciders and consulted roles; move to `accepted` when agreed.
11. Register in the index; link related `FEAT-`, `THR-`, `SLO-`, `RISK-`.
12. If superseding: set the old ADR to `superseded by ADR-NNN`, and list it under the new one's Links.

Quality gate before accepting:
- [ ] Decision fits in one sentence
- [ ] Two or more real options
- [ ] Numbers in the drivers
- [ ] Negative consequences named
- [ ] Owner and review trigger set

## Output format
A filled `templates/adr.md`, plus an updated registry row:

`| ADR-014 | Use outbox for order events | active | software-architect | <location> | FEAT-031, SLO-004 |`

Worked mini-example (decision line): "We will publish order events via a transactional outbox, because we need no lost events (RPO 0 for orders) and cannot afford distributed transactions across the DB and broker. Trade-off accepted: 1-3 s publish delay and an extra relay component."

## References
- `_shared/index.md` (ID rules, status values)
- `_shared/standards/nfr-catalog.md`
- `_shared/standards/reliability-patterns.md`
- `templates/adr.md`

## Language notes
Optional. Store ADRs as plain Markdown next to the code or docs; a one-file-per-ADR layout with the ID in the filename keeps diffs and links clean.
