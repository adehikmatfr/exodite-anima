# Which legal frameworks actually apply to the app?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided (approach); assessment not yet written |
| Date | 2026-09-20 raised |
| Decider | Project owner (solo) |
| Related | RISK-008 |
| Supersedes / superseded by | none |

## Context
`compliance-matrix.md` marks UU PDP, PP 71/2019, and GDPR as Confirm. This is engineering guidance, not legal advice, and counsel or the owner must confirm.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Confirm with counsel | Authoritative | Costs money and time | Medium | Low |
| 2 | Self-assess from official texts and record the reasoning | Cheap | May be wrong | Low | Medium |
| 3 | Do nothing | None | Risk of a blocked release or distribution | None | RISK-008 |


## Decision
Decided by the project owner on 2026-09-20: option 2, **self-assess from the official texts and record the reasoning**. This is not legal advice and can be wrong; the owner accepts that for a free app with no server.

Done on 2026-09-20: the assistant wrote the assessment (`product-manager/report/legal-self-assessment-v1.md`). Result: no controller role and no registration duty on this reading, with stated residual doubts; owner sign-off pending. The assessment was to be written from the official texts of UU PDP No. 27/2022, PP 71/2019 (registration of private electronic system operators) and the GDPR, per region, with the quoted articles, and turns each Confirm row in `compliance-matrix.md` into Yes or No with the reasoning. The owner reads it and signs off. The assessment must be re-done if any data ever starts reaching the developer (telemetry, crash reports, sync). Counsel remains an option later, for example if a store or a regulator asks.

## Consequences
- Turns Confirm rows into Yes or No in `compliance-matrix.md`.
- Updates RISK-008.
