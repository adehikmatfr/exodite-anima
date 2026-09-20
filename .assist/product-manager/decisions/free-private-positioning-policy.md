# Which money and data policies does the product hold to?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided |
| Date | 2026-09-20 raised / 2026-09-20 decided |
| Decider | Project owner (solo) |
| Related | RISK-006, RISK-008, all FEAT |
| Supersedes / superseded by | none |

## Context
The owner wants a journaling app that is 100% free and fully private, which is what should set it apart from other journaling apps.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | 100% free, no ads, no accounts, no tracking (chosen) | Clear promise, no data to protect on a server, matches the privacy design | No revenue to fund upkeep | Lowest | Maintenance risk (RISK-006) |
| 2 | Free with optional paid features or sync (listed by the assistant, not chosen) | Could fund upkeep | Needs accounts or servers and collects data, which contradicts the promise | High | Privacy promise weakened |
| 3 | Ad-supported (listed by the assistant, not chosen) | Free for users | Needs tracking and content-adjacent data, which contradicts the promise | Medium | Privacy promise broken |


## Decision
The product is 100% free with no ads, subscriptions, or in-app purchases. It has no accounts and no cloud sync. It uses no analytics or tracking of users. Any change to this needs a new decision and a review of the compliance matrix.

## Consequences
- No revenue; upkeep depends on the owner (RISK-006).
- Usage cannot be measured by the app, so success metrics rely on tests and on platform consoles (store ratings, crash-free rate).
- Any future data leaving the device turns the Confirm rows in `compliance-matrix.md` into binding ones (RISK-008).
