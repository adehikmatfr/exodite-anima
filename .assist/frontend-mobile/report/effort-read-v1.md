# Effort read: version 1 features

Given by frontend-mobile (the assistant acting in this role) on 2026-09-20 for `write-feature-spec` step 9. It answers FEAT-001 to FEAT-009, plus FEAT-010 added 2026-09-23. Status: relative sizes only, not measured, not a schedule.

## How to read this
- Sizes are relative: S = a small self-contained piece, M = several screens or one hard integration, L = a hard integration plus a security or data-safety burden. They are not days. The project has no velocity data, so converting sizes to days would be inventing a number.
- Confidence is **low** for every row until the technical spike (`technical-spike-plan.md`) has run. The largest unknowns are the encrypted database packages, the key store flow, and the export envelope.
- Sizes cover the build and its own tests. They do not cover the Indonesian copy review or the store release (`release-plan-v1.md`).
- iOS work is included in the size but cannot be checked locally (RISK-004).

## Per feature
| FEAT | Title | Size | Main drivers | Depends on (by ID) | Constraint from the architecture |
|------|-------|------|--------------|--------------------|----------------------------------|
| FEAT-001 | Entry management | L | Encrypted store, crash-safe drafts, migrations that keep a copy (ADR-006), the screen for a journal that cannot be opened | ADR-001, ADR-002, ADR-006 | Nothing is written unencrypted, including drafts |
| FEAT-002 | Timeline | M | Grouped list that stays smooth at 20,000 entries, empty and loading states | ADR-002, FEAT-001 | Paging from the database, not loading the whole journal |
| FEAT-003 | App lock and screen privacy | L | Key store, biometrics, wait after wrong tries that survives closing the app, hiding the app switcher preview, Android screenshot blocking | ADR-001 | The wait state is stored on the device and must not be resettable by clearing app memory alone |
| FEAT-004 | Onboarding and passcode setup | M | Setup flow, passcode rules, the warning that nothing can be recovered, passcode first then restore | ADR-001, FEAT-003 | Key derivation parameters come from spike S4 |
| FEAT-005 | Search | M | Matching rules, results within the search target at 20,000 entries | ADR-002 | The index lives inside the encrypted file (spike S2) |
| FEAT-006 | Export | L | Archive writing, encrypted envelope, password rules, sharing the file through the system | ADR-003, ADR-005 | Envelope choice comes from spike S6; large journals must not be built fully in memory |
| FEAT-007 | Import | L | Reading untrusted archives, limits, merge rule that keeps existing entries, wrong password and damaged file handling | ADR-003, ADR-006 | Limits come from spike S7; every failure leaves the current journal untouched |
| FEAT-008 | Export reminder | S | Thresholds, a banner, no entry text | FEAT-006 | Reminder is local, no notification content |
| FEAT-009 | Settings | M | Lock timeout, language switch with two complete languages, export and import entry points | FEAT-003, FEAT-006, FEAT-007 | All strings are externalised in English and Indonesian; the language change applies without restart |
| FEAT-010 | Tags, mood, and On this day | L | Updated 2026-09-23: ADR-006's generic safety net (copy-before-migrate, restore-on-failure, refuse-newer-schema) is now built and tested (`app/lib/data/journal_database.dart`, `app/test/migration_safety_test.dart`), which lowers this row's risk from "the rules exist only on paper" to "apply an existing, tested mechanism to a real second schema for the first time." Remaining size driver is still real: the actual `onUpgrade` step (schema 1 -> 2), its own migration test against a real fixture (not yet possible, since schema 2 does not exist), and rule 4 (transactional/resumable) which has never been exercised. On top of that: mood-icon picker with accessible labels, tag input (preset chips plus free text) in the editor, mood/tag display in the timeline, the "On this day" query across every past year, and additive fields in export/import | ADR-002 (update 2026-09-23), ADR-003 (update 2026-09-23), ADR-006 (update 2026-09-23), FEAT-001, FEAT-002, FEAT-006, FEAT-007 | Migration must keep an encrypted copy until the first successful launch on schema 2 and restore it on failure (ADR-006, built); a database on a schema newer than the app knows is refused, never opened for writing (built) |

## Order of building (by dependency)
1. Storage and key handling (FEAT-001 base, FEAT-003 base, FEAT-004), because every other feature reads or writes through them.
2. Writing and reading (FEAT-001, FEAT-002, FEAT-005).
3. Lock behaviour and settings (FEAT-003 rest, FEAT-009).
4. Export, import, reminder (FEAT-006, FEAT-007, FEAT-008), with export before import so import has real files to read.

## Unknowns that could change a size
| Unknown | Feature | Answered by |
|---------|---------|-------------|
| Whether the encrypted database packages work with full-text search and stay free of network permission | FEAT-001, 002, 005 | Spike S1, S2, S8 |
| Whether device-bound key wrapping (R1) is worth its complexity | FEAT-003, 004 | Spike S5 |
| Custom envelope or an existing standard | FEAT-006, 007 | Spike S6 |
| Import limits that are safe on a low-end phone | FEAT-007 | Spike S7 and the reference device |
| How iOS will be built and tested | all | Owner decision, not yet made |
| Whether the copy-before-migrate/restore-on-failure implementation (ADR-006) works cleanly with the encrypted database on both platforms | FEAT-010 | Not yet spiked; first real exercise of ADR-006 |

## Not covered
- No person-day estimate, no calendar, no capacity figure.
- No estimate for photos and audio (out of version 1).
- Not reviewed by anyone other than the assistant.
