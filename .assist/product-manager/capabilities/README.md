# capabilities

One doc per **existing** capability of the product: what it does today, in product language.

`capabilities/` answers "what does the product already do". `features/` answers "what are we changing". When a `FEAT-` ships, update the matching capability doc so the two never disagree.

## Rules
- Naming: `capabilities/<capability-slug>.md`, kebab-case, matching the capability map in `../context.md`.
- Self-contained: write in product language, baked in as plain text. No code, file paths, or internal system names beyond what a stakeholder would recognise.
- Confirmed facts only. Anything uncertain goes under Known Limitations with an owner, not under Key Business Rules.
- Reference other artifacts by ID (`FEAT-NNN`, `ADR-NNN`, `API-NNN`), never by path.
- Set `Last reviewed` on every edit; a doc not reviewed in two cycles is flagged as stale in `../context.md` Known gaps.

## Template
`../templates/capability.md`. Copy, fill, delete nothing that is required.

## Index
| Capability | Status | Last reviewed |
|-----------|--------|---------------|
| `<capability-slug>` | live | <YYYY-MM-DD> |
