# ADR-<NNN>: <Short decision title in the imperative>

> Sections marked *(optional)* may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Status | proposed / accepted / superseded by ADR-<NNN> / deprecated |
| Date | <YYYY-MM-DD> |
| Deciders | <names or roles> |
| Consulted | <security, devops, backend, product ...> |
| Reversibility | one-way door / two-way door (cost to undo: <estimate>) |
| Related | FEAT-<NNN>, RISK-<NNN>, THR-<NNN>, SLO-<NNN>, ADR-<NNN> |
| Review date | <when to re-evaluate, or the trigger> |

## Context

<Forces at play: problem, constraints, deadlines, compliance rows that apply. Facts only, no solution.>

### Quantified requirements (drivers)

| NFR | Target | Measured by | Source |
|-----|--------|-------------|--------|
| <e.g. p95 latency, checkout> | < 300 ms | <load test / APM> | FEAT-<NNN> |

## Options considered

### Option A: <name>
- Summary: <one paragraph>
- Pros: <...>
- Cons: <...>
- Cost / effort: <estimate>
- Risks: <RISK-NNN or inline>

### Option B: <name>
- Summary / Pros / Cons / Cost / Risks as above

### Option C: do nothing (baseline)
- Consequence of not deciding: <...>

### Scoring (optional, see tradeoff-analysis)

| Criterion | Weight | A | B | C |
|-----------|--------|---|---|---|
| <criterion> | <1-5> | <1-5> | <1-5> | <1-5> |
| **Weighted total** | | | | |

## Decision

We will <chosen option>, because <top 2-3 reasons tied to the drivers above>.

## Consequences

- Positive: <...>
- Negative / trade-offs accepted: <...>
- Follow-up work: <tasks, owners>
- New risks: <RISK-NNN>
- Assumptions to validate: <assumption, owner, date>
- Exit strategy: <how to reverse or migrate away, and its cost>

## Validation

<How we will know the decision is working: metric, threshold, date. What result would trigger revisiting it.>

## Links (optional)

- Diagrams: <C4 view name>
- Threat model: THR-<NNN>
- Spike / benchmark: <reference>
- Supersedes: ADR-<NNN> (if any)
