# Local data design (version 1)

Method: skill `offline-and-sync`, adapted: the app has no server, so there is no outbox, no sync, and no server-side conflict handling. Status: draft, 2026-09-20. Decisions come from ADR-001 (keys), ADR-002 (database), ADR-003 (export format), ADR-006 (migration safety). This note adds the mobile-side rules those ADRs leave open.

## Entities
| Entity | Class | Conflict rule | Retention | Sensitivity | Size assumption |
|--------|-------|---------------|-----------|-------------|-----------------|
| Entry | user-authoritative: the device is the only source | none (one writer); import merge rule: existing entries are kept (FEAT-007 AC-8) | Until the user deletes it | Restricted | about 2 KB of text (`ASSUMPTION` in `nfr-analysis-v1.md`) |
| Draft (unsaved text) | user-authoritative | none | Until saved or discarded | Restricted | small |
| Last export time | user-authoritative | none | Kept | low | tiny |
| Settings (theme, lock timeout, biometrics on or off) | user-authoritative | none | Kept | low; lock timeout affects security | tiny |
| Wrapped data key and its parameters | user-authoritative | none | Lives with the journal | Restricted | tiny |
| Media (v1.1 and later) | user-authoritative | none | Deleted with its entry | Restricted | large: needs a cap and a plan |

## Storage
- Structured data (entries, drafts, last export time) in the encrypted database (ADR-002).
- Small key-values that are not secret (theme) in the platform preference store; anything security-relevant (lock timeout, biometrics flag) goes in the encrypted database so it cannot be changed from outside.
- Keys only in the OS key store, plus the passcode-wrapped copy (ADR-001). Never in preferences, never in logs.
- Local size: no cap for text entries. Media needs a cap and a clear message before v1.1.

## Write path
User action, then one local transaction, then the UI updates. A success message is never shown before the local commit is durable (skill rule). There is no outbox because nothing is sent anywhere. Drafts are written as the user types, in a separate small table, so a crash loses at most the last few seconds (NFR-7).

## Schema and migrations
- Numbered, forward-only migrations, each in one transaction.
- Every supported previous schema has a fixture database, and a test opens it with the new code (TC-015).
- **There is no server to rebuild from.** The skill's failure path ("rebuild the cache from the server") does not exist, so a failed migration is a data-loss event (RISK-001, THR-010). Therefore, four rules, **approved by the owner on 2026-09-20 and recorded as ADR-006**:
  1. Before a migration, keep an encrypted copy of the database file. Delete it only after the next successful launch on the new schema.
  2. If a migration fails, restore the copy and show S14 with an offer to import an export; never leave a half-migrated file.
  3. A database written by a **newer** schema than the app knows is never opened for writing: the app refuses with a message to update (downgrade and reinstall safety).
  4. Large migrations run resumably in the background with progress.
- Export archives carry their own `formatVersion` and `schemaVersion` (ADR-003); the importer supports every past `formatVersion`.
- **Built 2026-09-23**: rules 1 to 3 above are implemented in `app/lib/data/journal_database.dart` (`backupBeforeMigration`, `restoreFromBackup`, `cleanupOldMigrationBackup`, `JournalTooNewException`), tested in `app/test/migration_safety_test.dart` (TC-100, TC-101). Rule 4 has no `onUpgrade` step to apply to yet, since the schema is still version 1; it is the responsibility of the first migration that bumps it (FEAT-010).

## Lifecycle
The app must survive process death, rotation, backgrounding, low-memory kill, calls, and low storage at any moment: drafts and transactions cover writing; the lock screen appears on return; low storage shows the save error (S7) with the text kept.

## State management
Decided at implementation (2026-09-20): no state-management package; widgets read drift streams, and one shell object holds the lock state and clears the key on lock. No ADR was needed. The rule from this note still holds: Requirement from this note: the UI reads from the local store and never blocks on anything else; the lock state is held in one place and clears the key from memory when it locks.

## Tests (linked case IDs from TP-001)
| Behaviour | Case |
|-----------|------|
| Kill the process at every step of saving | TC-010 |
| Draft recovered after a kill | TC-004 |
| Database from the previous schema opens | TC-015 |
| Clock and time-zone change keeps entry dates | TC-013 |
| Export and import round trip | TC-058 |
| Stress-size journal (20,000 entries, decided) | performance cases TC-014, TC-019, TC-045, run on the reference device |
| Airplane mode | not applicable: the app never uses the network |

## Open items
| # | Item | Owner | Due |
|---|------|-------|-----|
| 2 | Media size cap and eviction rules | frontend-mobile | Before v1.1 |
| 3 | State-management choice | frontend-mobile | At implementation |
