# adr

Architecture decision records, one file per decision, owned by the software-architect role. Files are named `ADR-NNN-slug.md`. Accepted ADRs are immutable: a change is a new ADR that supersedes the old one, with the owner's confirmation. A review record may be appended to an accepted ADR without changing its body.

Template: `../templates/adr.md`. Method: skill `adr-writing`. Register every ADR in `../../_shared/index.md`.

## Index
| ID | Decision | Status | Reversibility |
|----|----------|--------|---------------|
| ADR-001 | Encrypt in the app, unlock with biometrics and passcode, no key recovery | accepted | one-way |
| ADR-002 | Encrypted SQLite (drift with SQLite3MultipleCiphers); media as separate encrypted files | accepted (spike passed on Android; iOS unverified) | one-way once users have data |
| ADR-003 | Export as a versioned ZIP of JSON and Markdown with an encrypted envelope | accepted (envelope open) | one-way once archives exist |
| ADR-004 | Flutter, one codebase for iOS and Android | accepted (owner decision) | one-way in effort |
| ADR-005 | Enforce "no network" through the build | accepted (2026-09-20) | one-way in trust |
| ADR-006 | Protect the journal during data migrations | accepted (2026-09-20) | two-way, high-care |
