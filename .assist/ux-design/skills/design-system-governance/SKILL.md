---
name: design-system-governance
description: Use when proposing, changing, versioning or deprecating a design token or component, when duplicate or one-off patterns appear, or when measuring and improving design-system adoption.
---
# Design System Governance

## Purpose

Keep the design system a trusted single vocabulary shared by design and code: changes are proposed, reviewed, versioned and communicated, and adoption is measured. Implementation in code is covered by `component-design-system` (frontend role).

## When to use

- A design needs something the system lacks (new token, variant, component, pattern).
- A token value or component behaviour changes.
- A component is unused, duplicated or drifting from its coded twin.
- Quarterly health review.

## Principles

- **Reuse before create.** Two real use cases (or one plus a committed roadmap item) justify a new component; one-offs stay local and are labelled.
- **Tokens are the contract.** Colour, spacing, type, radius, elevation and motion values come from named tokens (semantic layer over raw values, for example `color.text.muted` over `grey-600`); no raw values in components.
- **Design and code stay in sync.** One source of truth for tokens (`context.md`), with a defined sync direction and a drift check.
- **Accessibility built in.** A component cannot reach beta without meeting `inclusive-and-accessible-design` checks.
- **Breaking changes are announced, dated and migratable.**

## Steps / Checklist

Component lifecycle: proposed -> beta -> stable -> deprecated -> removed.

| Stage | Entry criteria | Rules |
|-------|----------------|-------|
| proposed | Request with problem, 2 use cases, audit of existing components | Design only, no production use |
| beta | Spec (anatomy, states, a11y, responsive), tokens only, coded twin exists | Usable with a warning; breaking changes allowed with notice |
| stable | >= 2 consuming features, a11y audit passed, docs and tests complete | Semantic versioning; breaking change needs a major release |
| deprecated | Replacement named, migration guide written | Supported >= 2 minor releases or 90 days; warning in docs and code |
| removed | Usage = 0 or approved exceptions closed | Recorded in changelog |

Contribution and review:
1. Open a proposal: problem, `FEAT-NNN`, alternatives considered, spec draft.
2. Review by system owner, one designer, one frontend engineer (T2/T3 add accessibility reviewer); target decision within 5 working days.
3. Build in design library and code together; verify token parity.
4. Publish: version bump, changelog entry, release note to consumers. System-level changes (token model, theming, naming) get an `ADR-NNN`.

Versioning: major = removed or behaviour-breaking; minor = new component, variant or token; patch = fix or value tweak without visual break. Token renames are breaking; provide an alias for one minor cycle.

Adoption metrics (review monthly): component coverage (% of screens built from system components, target >= 85%), token coverage (% of styles bound to tokens, target >= 95%), detached or overridden instances (trend down), design-code parity gaps (target 0 stable components), open proposals older than 30 days.

## Output format

Proposal or change record: name, stage, problem, `FEAT-NNN`, spec link, a11y result, version impact, migration notes, approver, date. Health report: metrics table with previous value, trend, top 3 actions.

Worked mini-example: request for a "chip" component; audit finds `Tag` with an interactive variant already exists, so the decision is "extend Tag (minor), do not create Chip", recorded with rationale.

## References

- `_shared/standards/definition-of-done.md`, `_shared/standards/project-tiers.md` (T1: owner review and changelog line suffice).
- Frontend role: `component-design-system`. Related: `inclusive-and-accessible-design`, `design-file-hygiene-and-versioning`.
- IDs: `ADR-NNN`, `FEAT-NNN`, `RISK-NNN` for parity debt.
