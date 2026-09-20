# FEAT-NNN: <Feature title>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| ID | FEAT-NNN |
| Type | new feature / adjustment |
| Status | draft / ready / in-progress / released / superseded / deprecated |
| Owner | <name> |
| Date | <YYYY-MM-DD> |
| Priority score | <RICE or weighted score, see `prioritization`> |
| Related capability | `<capability-slug>` |
| Related IDs | ADR-NNN, API-NNN, TC-NNN, SLO-NNN, THR-NNN |

## Problem
<What is wrong or missing, for whom, with evidence (data, tickets, interviews). Why now.>

## Current behaviour (adjustment only)
<Confirmed current behaviour. Unknowns go to Open questions.>

## Users
| Segment | Need | How they meet this feature |
|---------|------|----------------------------|
| `<segment from context.md>` | <need> | <touchpoint> |

## Goals
- <outcome, tied to a metric below>

## Non-goals
- <explicitly excluded; assumed out of scope if not listed as in scope>

## Proposed behaviour
<Concrete walk-through of the scenario, including the failure path. Add a diagram for multi-step or multi-actor flows.>

## User stories
- As a <persona>, I want <capability>, so that <outcome>.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`.
| # | Given | When | Then | TC |
|---|-------|------|------|----|
| AC-1 | <context> | <action> | <observable result> | TC-NNN |

## NFR and compliance impact
| Area | Requirement | Source |
|------|-------------|--------|
| Performance / availability | <quantified target> | `nfr-catalog.md`, SLO-NNN |
| Security / privacy | <data classes, authz rules> | `security-baseline.md`, THR-NNN |
| Compliance | <rows of `compliance-matrix.md` triggered, or "none, reason"> | `compliance-matrix.md` |
| Accessibility / localisation (optional) | <target> | <source> |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|--------|-----------|----------|--------|-----------|--------------------|
| `<metric>` | <formula> | <value, source> | <value> | <must not fall below> | <tool, date> |

## Rollout
<Stages, audience, gates, rollback trigger and owner. Reference the rollout plan if separate.>

## Risks
| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|-----------|--------|-----------|-------|
| RISK-NNN | <risk> | L/M/H | L/M/H | <action> | <name> |

## Dependencies
- <team, system, vendor, or FEAT-NNN this depends on, with date needed>

## Decisions
- <product decision made in this spec, date, reason; or link to `decisions/<slug>.md` or ADR-NNN>

## Open questions
| # | Question | Owner | Due |
|---|----------|-------|-----|
| 1 | <question> | <name> | <YYYY-MM-DD> |

## Estimate and hand-off (optional)
- Effort read from engineering: <S/M/L or person-days, who gave it>
- Hand-off date and assigned team: <...>

## Status log
| Date | Status | Note |
|------|--------|------|
| <YYYY-MM-DD> | draft | <created> |
