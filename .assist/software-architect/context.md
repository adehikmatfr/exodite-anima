# Architecture Context: exodite-anima

Project identity and shared rules live in `../_shared/project.md`. This file holds only architecture-specific facts.

## Architecture at a glance
A single mobile app for iOS and Android, built with Flutter (ADR-004), with no backend. All logic and data live on the phone: a user interface layer, a journal-logic layer, and a data-and-crypto layer, with an encrypted local database (ADR-002), encrypted media files reserved for later versions, and keys held in the operating system's key store (ADR-001). The only path out of the app is an export file the user saves where they choose (ADR-003). No network access is used, and ADR-005 proposes to enforce that through the build. Diagrams: `report/c4-diagrams.md` (context, container, component, and two sequences).

## Quality goals (top, ranked)
| Rank | Quality | Target | Source |
|------|---------|--------|--------|
| 1 | Durability of saved entries | 0 lost or altered by a crash or forced close | NFR-6, THR-010 |
| 2 | Confidentiality on the device | 0 bytes of plaintext text in stored files | NFR-9, ADR-001, ADR-002 |
| 3 | No content leaves the device | 0 network requests carrying content | NFR-12, ADR-005 |
| 4 | Portability and recoverability through export | Every past format version importable; round trip exact | NFR-20, ADR-003 |
| 5 | Speed and size on the lowest-tier device | Provisional targets accepted 2026-09-20 (NFR-1 to NFR-5) | `nfr-analysis-v1.md`, `nfr-targets-v1` |

## Key constraints
- Regulatory: see `../_shared/compliance/compliance-matrix.md` (WCAG 2.2 AA and store rules apply; other rows Confirm).
- Technology: Flutter and Dart; encrypted SQLite through drift and SQLite3MultipleCiphers (unverified until the spike); vetted cryptography libraries only, no custom cryptography.
- Team and time: one person, no deadline. iOS cannot be built on the current Windows machine.
- Budget: no infrastructure cost; store developer fees only.
- Product rules that bind the design: free, no accounts, no analytics, no ads (`../product-manager/decisions/free-private-positioning-policy.md`).

## Decision index (most important)
| ADR | Decision | Status |
|-----|----------|--------|
| `ADR-001` | Encrypt in the app, biometrics plus passcode, no key recovery | accepted |
| `ADR-002` | Encrypted SQLite with drift; media as separate encrypted files | accepted (spike passed on Android; iOS unverified) |
| `ADR-003` | Export as a versioned ZIP of JSON and Markdown with an encrypted envelope | accepted (envelope open) |
| `ADR-004` | Flutter, one codebase | accepted (owner decision) |
| `ADR-005` | Enforce "no network" through the build | accepted |
| `ADR-006` | Protect the journal during data migrations | accepted |

## Diagrams
| Diagram | Level (C4) | Location |
|---------|-----------|----------|
| System context | context | `report/c4-diagrams.md` |
| Containers | container | `report/c4-diagrams.md` |
| App components | component | `report/c4-diagrams.md` |
| Unlock and export sequences | dynamic | `report/c4-diagrams.md` |

## Reviews and analyses
| Item | Location |
|------|----------|
| NFR analysis | `report/nfr-analysis-v1.md` |
| Architecture review (self-review, 70%, approve with conditions) | `report/architecture-review-v1.md` |
| Decided flows | `workflow/` |

## Known gaps and open risks
- NFR numbers are provisional until measured on a physical phone (`nfr-targets-v1`, F1 in the review).
- Cloud backup exclusion: Android done and checked in the release APK; iOS not built (F2, RISK-003).
- Encrypted storage, key handling, envelope and ZIP reading were chosen and tested on Android (spike results in `../frontend-mobile/report/technical-spike-plan.md`); not verified on iOS (F6, RISK-004).
- Export fixtures exist only for `formatVersion` 1; older-version fixtures come with the first format change (F4, RISK-002).
- The device-bound key idea (ADR-001 R1) was not evaluated (spike S5).
- No independent review of ADR-001 or ADR-003 (RISK-005).
- FEAT-010 (tags, mood, and On this day) needs `journalSchemaVersion` 1 -> 2 and manifest `schemaVersion` 2 (updates recorded in ADR-002 and ADR-003, 2026-09-23); this is the first schema step to actually exercise ADR-006's migration safety rules, and frontend-mobile has not implemented them yet.

