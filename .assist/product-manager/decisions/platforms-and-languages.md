# Which operating system versions and interface languages does version 1 support?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided |
| Date | 2026-09-20 raised / 2026-09-20 decided |
| Decider | Project owner (solo) |
| Related | FEAT-004, FEAT-009 |
| Supersedes / superseded by | none |

## Context
The frontend-mobile role needs a minimum iOS and Android version and a device list; the catalog default for compatibility is n-1 versions. The interface language affects all text in the app, including the onboarding warning. The owner has not decided either yet.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Latest and previous major version of each OS, English only | Smallest test effort | Excludes some users and Indonesian speakers | Low | Low |
| 2 | Latest two major versions of each OS, English and Indonesian | Reaches more users in the owner's likely audience | More text to write and test, longer to finish | Medium | Low |
| 3 | Do nothing | None | No device matrix, no language plan | None | Blocks build and QA planning |


## Decision
Decided by the project owner on 2026-09-20.

- **Operating systems:** the Flutter 3.44.4 defaults are the minimum for version 1: Android 7.0 (API 24) and iOS 13. There is no usage data to justify more; revisit after release. The device list and the low-end reference device are still to be chosen.
- **Languages:** two interface languages, English and Indonesian, and the user can switch between them in Settings. The default follows the phone's language, and English is used when the phone's language is neither. The Indonesian text is drafted by the assistant and must be reviewed by the owner before release.
- Right-to-left layouts are not needed for these two languages.

## Consequences
- Adds a language setting to Settings (FEAT-009) and a language switch requirement to every screen; all strings are externalised in both languages.
- Indonesian text is often longer than English, so layouts must wrap (tested in TC-088).
- Copy in two languages must be written and reviewed (a copy deck is a follow-up for product-design and the owner).
- Feeds `frontend-mobile/context.md` (minimum OS, device matrix) and the test plan.
- Feeds `nfr-targets-v1`.
