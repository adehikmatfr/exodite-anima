---
name: c4-diagramming
description: Use when documenting or explaining system structure, onboarding engineers, preparing a design or ADR, or when existing architecture diagrams are missing, inconsistent, or unreadable; produces C4 model diagrams as text.
---
# C4 Diagramming

## Purpose
Describe a system at four consistent zoom levels (Context, Container, Component, Code) so different audiences get the right level of detail from one shared vocabulary.

## When to use
- New system or major change needs a picture for review or an ADR.
- Threat modelling needs trust boundaries (`threat-informed-design`).
- Onboarding, or after an architecture drift finding in `architecture-review`.
- Use Level 1-2 always; Level 3 only for complex containers; Level 4 rarely (generate from code).

## Principles
- Diagrams are views of one model; names must match across views and the glossary (`_shared/glossary.md`).
- One diagram, one question, one level of abstraction. Do not mix levels.
- Every box: name, type, one-line responsibility, and technology (in the ADR or label, not the principle).
- Every arrow: direction, purpose, protocol/sync-or-async; unlabeled arrows are bugs.
- Include a title, scope, date/version, and a legend; mark trust boundaries and external systems.
- Diagrams as text (Mermaid, PlantUML, Structurizr DSL) so they diff, review, and live with the code.
- Keep them current: update in the same change that alters the structure.

## Steps / Checklist
1. Define audience and question for each diagram.
2. Level 1 System Context: the system as one box, users/roles, external systems. No technology.
3. Level 2 Container: deployable/runnable units (apps, services, databases, queues, functions), their technology, and communication. Add trust boundaries.
4. Level 3 Component: major building blocks inside one container, only where complexity warrants.
5. Add dynamic view (numbered sequence) for one critical flow, e.g. checkout, including failure path.
6. Add deployment view where infrastructure matters: regions, zones, networks, scaling units.
7. Review: unlabeled arrows, orphan boxes, more than ~12 elements, mixed levels, names not in glossary.
8. Link from the relevant `ADR-` and note the diagram version.

## Output format
Mermaid container-level example (renders in most Markdown tools):

```
flowchart LR
  user([Customer]) -->|HTTPS| web[Web App]
  web -->|REST, sync| api[Orders API]
  api -->|SQL| db[(Orders DB)]
  api -->|publishes OrderPlaced, async| bus{{Event Bus}}
  bus --> ship[Shipping Service]
  api -->|HTTPS, 3 s timeout| pay[[Payment Provider - external]]
```

Caption template: "Title: Orders, Container view | Version 3 | 2026-09-19 | Scope: production | Related: ADR-014, THR-021. Dashed border = external; solid = owned."

Element checklist per box: `Name [type]: responsibility (technology)`.

## References
- `_shared/glossary.md`, `_shared/domain-context.md`
- `_shared/index.md` (link diagrams from `ADR-`)
- `_shared/standards/security-baseline.md` (trust boundaries)

## Language notes
Optional. Mermaid `flowchart`/`sequenceDiagram`, PlantUML C4 extension, or Structurizr DSL all work; pick one per repository and stay consistent.
