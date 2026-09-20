# Design Brief: <title>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Feature | `FEAT-NNN` |
| Designer | <name / role> |
| Status | <draft / in review / approved / handed off> |
| Design link | <url or id> |
| Last updated | <YYYY-MM-DD> |

## 1. Problem

<The user problem in 2-4 sentences, with evidence (research, support tickets, analytics). State what is broken, for whom, and the cost of not solving it. No solution language.>

## 2. Users

| User / segment | Context of use | Key needs | Accessibility or inclusion needs |
|----------------|----------------|-----------|----------------------------------|
| <segment> | <device, place, connectivity> | <needs> | <needs> |

## 3. Constraints

- Technical: <platform, API limits `API-NNN`, performance budget>.
- Business / legal: <policy, regulation, contract>.
- Design system: <components and tokens available; known gaps>.
- Timeline and team: <dates, capacity>.

## 4. Success Criteria

| Criterion | Metric | Baseline | Target | How measured | Owner |
|-----------|--------|----------|--------|--------------|-------|
| <outcome> | <e.g. task completion rate> | <value or unknown> | <value by date> | <usability test / analytics event> | ux-design |

## 5. Scope and Non-goals

- In scope: <flows, screens, states, platforms>.
- Non-goals: <explicitly excluded, and why>.

## 6. Accessibility and Privacy Considerations

- Accessibility: <target from `context.md`; specific risks such as dense forms, charts, motion, time limits>.
- Privacy: <personal data displayed or collected, consent moments, dark-pattern risks>; threats raised as `THR-NNN`.
- Content and localisation: <languages, RTL, text expansion, plain-language needs>.

## 7. States to Cover

| Screen / component | Default | Loading | Empty | Error | Offline | Permission denied | Long / extreme content |
|--------------------|---------|---------|-------|-------|---------|-------------------|------------------------|
| <name> | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

## 8. Deliverables

| Deliverable | Format | Due | Consumer |
|-------------|--------|-----|----------|
| <flows / screens / prototype / spec / copy> | <link> | <date> | <frontend / qa / technical-writer> |

## 9. Options and Decisions (optional)

| Option | Pros | Cons | Chosen |
|--------|------|------|--------|
| <option A> | <...> | <...> | <yes/no + rationale> |

System-level decisions are recorded as `ADR-NNN`.

## 10. Review and Approval

| Reviewer | Role | Scope | Date | Decision |
|----------|------|-------|------|----------|
| <name> | <product-manager / frontend / qa / cyber-security> | <what they check> | <date> | <approve / changes> |

Review record: `design-review-record` for this brief, if held.

## 11. Risks

| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|-----------|--------|------------|-------|
| RISK-NNN | <risk> | <L/M/H> | <L/M/H> | <action> | ux-design |

## 12. Open Questions (optional)

- <question, owner, needed by>
