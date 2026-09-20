# <Decision title, phrased as the question>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

Use this for product-level decisions. Architectural decisions belong in an `ADR-` owned by the software architect; reference it here.

| Field | Value |
|-------|-------|
| Status | pending / decided / superseded |
| Date | <YYYY-MM-DD raised> / <YYYY-MM-DD decided> |
| Decider | <name or role with decision right, see `context.md`> |
| Related | FEAT-NNN, ADR-NNN, RISK-NNN, `<capability-slug>` |
| Supersedes / superseded by | <slug or none> |

## Context
<What prompted this, constraints, evidence, deadline for the call.>

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | <option> | <...> | <...> | <...> | <...> |
| 2 | <option> | <...> | <...> | <...> | <...> |

## Criteria and scoring (optional)
| Criterion | Weight | Option 1 | Option 2 |
|-----------|--------|----------|----------|
| <criterion> | <%> | <1-5> | <1-5> |
| Weighted total | 100% | <sum> | <sum> |

## Decision
<What was chosen and why, or `Pending` with the owner and due date. State what was explicitly rejected.>

## Consequences
- Roadmap and scope: <...>
- Other features and teams: <...>
- New risks or follow-ups: RISK-NNN, FEAT-NNN
- Metric or date to revisit this decision: <...>

## Communication (optional)
| Audience | Channel | Sent by / date |
|----------|---------|----------------|
| <stakeholder group> | <channel> | <name, date> |
