# UX Design Context: exodite-anima

Overrides the parent design `context.md`, so the common design items are included. Project identity and shared rules live in `../_shared/project.md`. This file holds only UX and design facts.

## Summary

- exodite-anima is a free, fully private journaling app. Everything stays on the user's phone; there is no account, cloud, or tracking.
- Users write text entries, find them again, and can export and import their journal to move phones.
- The main experience risks are data loss (no cloud, no recovery), understanding the no-recovery rule, and completing backup and restore without help.
- Surfaces: mobile only (iOS and Android). Design maturity: none before this project; a first set of screens (S1 to S7) exists but was drawn before flows and research, so it is treated as a hypothesis.

## Design Tooling and Sources (common)

| Item | Value |
|------|-------|
| Design tool and workspace | OpenPencil, local. The assistant writes `.pen` files; the owner opens them only to verify (`../_shared/project.md`). No shared workspace. |
| Design system | Tokens in `../product-design/design/library/tokens.json` (docs: `../product-design/docs/design-tokens.md`); owned by product-design. Design system governance follows the parent skill `design-system-governance`. |
| File structure and naming | `../product-design/design/features/<area>/<area>-light.pen` and `-dark.pen`; frames named like `S6 Timeline / Empty (first use)`. |
| Handoff channel | By ID in `_shared/index.md`; UX hands validated flows and IA to product-design, findings to product-manager and qa. |
| Accessibility target | WCAG 2.2 AA (`../_shared/compliance/compliance-matrix.md`); mobile touch targets at least 44 pt (iOS) and 48 dp (Android). Quick design-time check on every screen; audit of the built app by frontend-mobile. |
| Brand and content guidelines | None yet. The logo is a placeholder (`../product-manager/decisions/public-app-name.md`). Terms follow `../_shared/glossary.md`. |

## User Segments and Evidence

No segment without evidence. Unevidenced segments are hypotheses and are labelled so.

| Segment | Definition (behaviour or need, not demographics alone) | Size or share | Evidence (study ID, analytics, support) | Strength | As-of date |
|---------|--------------------------------------------------------|---------------|------------------------------------------|----------|------------|
| Journal writer | Someone who wants to write privately, without paying and without trusting a company with their writing | unknown | none | hypothesis | 2026-09-20 |

Excluded or hard-to-reach users: people who use assistive technology (screen reader, large text) are not yet covered by any evidence; RS-001 plans at least one participant. The interface is in English and Indonesian (decided 2026-09-20); participants in RS-001 can use either.

## Research Repository

| Item | Value |
|------|-------|
| Location | `report/` in this role folder holds study protocols and syntheses. Raw recordings and consent forms are never stored in the repository. |
| Study ID convention | `RS-NNN` per study; sessions `RS-NNN-P01` |
| Tags | journey, feature `FEAT-`, method, segment, evidence strength, theme |
| Raw data classification | Restricted while it contains recordings or identifiers (`../_shared/standards/data-governance.md`) |
| Retention | Recordings deleted 90 days after synthesis (skill default, unless the owner sets otherwise); transcripts pseudonymised; insights kept. Deletion owner: ux-design. |
| Review cadence | Insights older than 12 months re-validated before reuse |

## Recruitment and Consent

| Item | Value |
|------|-------|
| Channels | Decided 2026-09-20: friends and acquaintances of the owner (known bias, to be stated in the report) |
| Contact rules | Nobody is contacted until the protocol is approved and consent wording is written |
| Consent process | Written consent form stating purpose, what is recorded, who sees it, retention, and the right to withdraw; separate yes for recording. Not written yet. |
| Incentives | None: no payment (owner decision 2026-09-20). Never contingent on answers. |
| Special groups | Journaling can touch on emotional topics. Participants never write real personal content; a distress protocol is part of RS-001. Minors are excluded. |
| Applicable law | `../_shared/compliance/compliance-matrix.md` rows marked Confirm; participant data is minimised and pseudonymised regardless. |

## Analytics Sources

| Source | What it answers | Owner | Refresh | Limits |
|--------|-----------------|-------|---------|--------|
| In-app analytics | none, by design | none | none | The app collects no usage data (`../product-manager/decisions/free-private-positioning-policy.md`) |
| Store reviews and ratings | Sentiment, reports of lost data | ux-design | after release | Self-selected |
| Usability tests (RS-001) | Where users fail and why | ux-design | per round | Small samples, no percentages |

Event schema: none. Metric definitions: none.

## Key Journeys and Current Metrics

| Journey | Owner | Linked `FEAT-` | Task success | Time on task | Drop-off point | SUS or CSAT | As-of |
|---------|-------|----------------|--------------|--------------|----------------|-------------|-------|
| First run: set up and write the first entry | ux-design | FEAT-004, FEAT-001 | not measured | not measured | not measured | not measured | 2026-09-20 |
| Changing phones without losing the journal | ux-design | FEAT-006, FEAT-007, FEAT-004 | not measured | not measured | not measured | not measured | 2026-09-20 |
| Daily writing and finding an old entry | ux-design | FEAT-001, FEAT-002, FEAT-005 | not measured | not measured | not measured | not measured | 2026-09-20 |

Journey maps: `report/JRN-001-changing-phones.md`. Flows: `report/user-flows.md`.

## Known Gaps

- No evidence for the segment or for any journey; every journey map cell is "assumed" (RS-001 planned).
- No assistive-technology testing yet.
- Screens S1 to S7 were drawn before flows and research; findings are in `report/design-review-ui-s1-s7.md`.
- Vocabulary is unsettled ("backup" versus "export" and "import"); see `report/information-architecture.md`.
- The order of passcode setup and restore is decided (passcode first, 2026-09-20); it is tested in RS-001 (task T5).
- FEAT-010 (mood, tags, "On this day"): flow F8 added 2026-09-23 (`report/user-flows.md`), not yet validated with users; the "On this day" card's ordering when several years match is a **Proposal**, still open for the owner.
- No consent form written; recruitment channel and incentive undecided.
