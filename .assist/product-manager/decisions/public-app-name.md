# What is the app's public name, and is it available on both stores?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided (name); store availability unconfirmed |
| Date | 2026-09-20 raised |
| Decider | Project owner (solo) |
| Related | RISK-007 |
| Supersedes / superseded by | none |

## Context
The working name is exodite-anima. The bundle identifier `io.github.adehikmatfr.exoditeanima` is chosen and cannot change after the first store release. The public display name and its availability on Apple and Google stores are unconfirmed, and the logo design waits for this.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Keep exodite-anima if available | No rename work | May not suit a public audience | Low | Name may be taken |
| 2 | Choose a new public name (the identifier can stay) | Fits the product better | Delays the logo and store listing | Low | Low |
| 3 | Do nothing | None | No store listing possible | None | Blocks release |


## Decision
Decided by the project owner on 2026-09-20: the public name is **exodite-anima** (option 1).

Display name (owner, 2026-09-20): the launcher and store-facing display name is written **Exodite Anima** (capitalised, with a space); the repository, the package (`exoditeanima`) and the bundle identifier stay as they are. Set in `android:label` and the iOS display name.

Not yet checked: whether the name is free on the Apple App Store and Google Play, and whether it conflicts with a trademark. Owner to search both stores before submission; if the name is taken, this decision is reopened (the bundle identifier `io.github.adehikmatfr.exoditeanima` stays either way). The logo work is no longer blocked by the name; the logo (A2) was chosen the same day.

**Informal web search, 2026-09-23:** a general web search for `"Exodite Anima" app Play Store OR App Store` found no existing app named "Exodite Anima" on either store; the closest name matches are unrelated apps ("Exodite - Space action shooter", `com.afrodude.exodite`, and "AnimA ARPG", both different names and different apps). This is evidence, not a confirmation: it does not check trademark registers and does not test whether the exact name can be registered in Play Console or App Store Connect, which only happens at submission. The "not yet checked" line above still stands until that submission-time check is done.

Sources: [Exodite - Space action shooter – Google Play](https://play.google.com/store/apps/details?id=com.afrodude.exodite&hl=en_GB&gl=US), [AnimA ARPG – Google Play](https://play.google.com/store/apps/details?id=com.ExiliumGames.Anima&hl=en_US), [AnimA ARPG – App Store](https://apps.apple.com/us/app/anima-arpg-action-rpg/id1500448965)

## Consequences
- Blocks the logo and icon work.
- Store listing text and privacy labels depend on the name.
