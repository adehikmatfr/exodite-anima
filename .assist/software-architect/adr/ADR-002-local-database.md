# ADR-002: Store entries in an encrypted SQLite database (drift + SQLite3MultipleCiphers), media as separate encrypted files

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-09-20 |
| Deciders | Project owner |
| Consulted | none (solo project); software-architect and cyber-security roles applied |
| Reversibility | one-way door once users have data (cost to undo: versioned migration of every user's database) |
| Related | ADR-001, ADR-004, FEAT-001, FEAT-002, FEAT-005, RISK-004, THR-002, THR-010 |
| Review date | After the spike passes, and before the first store release |

## Context

The app is a Flutter journaling app (iOS and Android) with all data on the device (ADR-001: application-level encryption, random data key, no recovery). Users will want to search their entries, and the store must support versioned schema migrations, because every persisted format is versioned (project rule).

Facts checked on 2026-09-20 (documentation pages, to be re-verified at install time):

- `sqlcipher_flutter_libs` is end-of-life (version 0.7.0+eol does nothing) and points to `sqlite3` 3.x.
- drift documents that from drift 2.32.0 and `sqlite3` 3.x, SQLite3MultipleCiphers is the recommended way to encrypt a database, and that SQLCipher is no longer supported with a straightforward setup.

### Quantified requirements (drivers)

| NFR | Target | Measured by | Source |
|-----|--------|-------------|--------|
| No plaintext entry text in the database file | 100% | Test reading the raw file without the key | ADR-001 |
| Full-text search over entries | Results shown quickly for a journal of several thousand entries (target: under 300 ms on a mid-range device) | Benchmark with generated data | Product requirement (search in v1) |
| Schema changes are safe | Every migration tested from every previous version | drift migration tests in CI | project.md working rules |
| Photos and audio do not bloat the database | Media stored outside the database | Inspection of storage layout | Product requirement (optional media) |

## Options considered

### Option A: drift with SQLite3MultipleCiphers (whole-file encryption)
- Summary: drift for typed SQL access and migrations, `sqlite3` 3.x with SQLite3MultipleCiphers to encrypt the entire database file with the ADR-001 data key. Search uses SQLite full-text search, which works because the whole file, including the index, is encrypted.
- Pros: Current path recommended by drift. Whole-file encryption. Search and migrations supported. Single dependency family.
- Cons: Newer path, less community material than SQLCipher. Requires SQL knowledge.
- Cost / effort: Medium.
- Risks: Build or runtime problems on one platform (mitigated by the spike below).

### Option B: drift with sqflite_sqlcipher (legacy SQLCipher path)
- Summary: `encrypted_drift` on top of `sqflite_sqlcipher`.
- Pros: Long-used approach.
- Cons: Documented as legacy and discouraged for new projects. Risk of being stranded on an unmaintained path.
- Cost / effort: Medium.
- Risks: Deprecation, conflicts between SQLite native libraries on iOS.

### Option C: NoSQL database with built-in encryption
- Summary: A Flutter NoSQL store with its own encryption.
- Pros: Simple object storage.
- Cons: Weaker search and migration story. Maintenance and encryption status of candidates not verified.
- Cost / effort: Medium.
- Risks: Unknown maintenance state.

### Option D: plain database with per-field encryption in our code
- Summary: Encrypt selected columns ourselves.
- Pros: Works with any database.
- Cons: Breaks search, leaks structure and metadata, and is hand-rolled cryptography, which the project forbids.
- Cost / effort: High.
- Risks: Cryptographic mistakes.

### Option E: do nothing (baseline)
- Consequence of not deciding: no storage layer, and the export format and search cannot be designed.

## Decision

We will use **Option A**: drift with SQLite3MultipleCiphers for the entry database, because it is the encryption path drift now recommends, it keeps search (full-text) and versioned migrations available, and it encrypts the whole file with the ADR-001 data key.

Supporting decisions:

1. **Media**: photos and audio are stored as separate files in the app's private storage, encrypted with the ADR-001 data key using a unique nonce per file. The database stores only a reference, size, type, and content hash.
2. **Search**: full-text search is in version 1. It uses SQLite FTS inside the encrypted database.
3. **Migrations**: the database has a schema version, a migration per version step, and drift's migration tests run in CI for every step.
4. **Atomic writes**: entry saves run in a transaction so a crash never leaves a half-written entry. Media is written to a temporary file, then moved into place, then referenced.
5. **Spike gate**: before feature work depends on this, a spike proves on real iOS and Android builds that the database can be created encrypted, written, closed, reopened with the right key, and rejected with a wrong key, and that FTS works on it.

## Consequences

- Positive: One encrypted store with search and safe schema evolution. Media size does not affect database performance.
- Negative / trade-offs accepted: Depends on a newer encryption path. Wrong choice discovered late is costly, hence the spike gate. Encrypted media files need cleanup logic for orphaned files.
- Follow-up work:
  - Run the spike on iOS and Android and record the result here.
  - ADR for the export/import archive format (must map database rows and media to a versioned archive).
  - Define the entry data model and FTS schema.
  - Verify exact package versions at install time.
- New risks: orphaned media files after crashes or deletes; database and media falling out of sync (mitigated by hash check and a consistency scan).
- Assumptions to validate: SQLite3MultipleCiphers works on both platforms with the pinned versions (owner, at spike); FTS performance target is met with several thousand entries (owner, at spike).
- Exit strategy: export to the versioned archive and import into a new store, or a versioned in-app migration that reads the old database and writes the new one.

## Validation

- Spike passes on iOS and Android (create, write, reopen with right key, reject wrong key, FTS query).
- Test reading the raw database file without the key shows no plaintext entry text.
- Migration tests pass for every schema version step in CI.
- Revisit if the spike fails on either platform, if the dependency becomes unmaintained, or if search performance misses the target.

## Review record (2026-09-20)
Added when the ADR was moved into the software-architect role and checked against `adr-writing`. The decision is unchanged and remains accepted; nothing above was rewritten.

- **Quality gate:** decision in one sentence: yes. Two or more real options: yes. Numbers in the drivers: partly. Negative consequences named: yes. Owner and review trigger: yes.
- **Unconfirmed numbers:** "under 300 ms" for search and "several thousand entries" were proposed by the assistant, not confirmed by the owner. Treat them as `ASSUMPTION` (owner: project owner; validate in the spike) until `nfr-targets-v1` is decided. See `nfr-analysis-v1.md` for the assumptions about journal size.
- **Library facts are unverified:** the statements about drift and SQLite3MultipleCiphers came from documentation pages read on 2026-09-20 and have not been exercised. The spike gate (supporting decision 5) still applies, and if it fails this ADR must be reopened and superseded.
- **Trade-off scoring** (optional for T1) was not done; the choice rests on the documentation of the recommended path and on the spike.
- **Consulted:** none. The cyber-security role reviews the key-handling parts with the threat model.

## Update 2026-09-23 (FEAT-010: mood and tags)
FEAT-010 (tags, mood, and On this day) needs two additive changes to the entry data model. This is the first real schema step since release readiness work began (`journalSchemaVersion` is still 1, `../../frontend-mobile/report/local-data-design.md`), so it is also the first time ADR-006's four safety rules are actually exercised end to end, not just written down.

**Schema change (bumps `journalSchemaVersion` 1 -> 2):**
- `mood`: a nullable small integer on the entry, one of 5 fixed values (product proposal in FEAT-010: Great, Good, Okay, Bad, Awful). Nullable because mood is optional.
- Tags: a `tags` table (`id`, `name`, unique on `name`) plus an `entry_tags` join table (`entry_id`, `tag_id`), rather than a comma-separated string column.
  - Considered and rejected: a single delimited-string column on the entry. It is simpler to write but conflates the preset list with free text, cannot enforce uniqueness or rename a tag across entries, and would need re-parsing if tag filtering (an explicit non-goal today) is ever built. Cost/effort difference is small; the join table is the boring, query-safe choice and costs one more table and one more join.
  - Preset tags (FEAT-010's 8-item proposal) and free-text tags live in the same `tags` table; nothing distinguishes them at storage level, matching the product decision that both are just tags.

**Migration:** this schema step must ship with ADR-006 Option A fully implemented (copy-before-migrate, restore-on-failure, refuse-newer-schema, transactional/resumable), because it is additive but still a real migration for any phone that already has entries under schema 1. Follow-up work for frontend-mobile: fixture database at schema 1, migration test to schema 2, and the failure-injection test named in ADR-006 (TC-015, TC-100, TC-101) — done 2026-09-23, see the "Built" note below.

**Built 2026-09-23**: `journalSchemaVersion` is now 2 in `app/lib/data/journal_database.dart`: a nullable `mood` column on `entries`, and `tags`/`entry_tags` tables, exactly as decided above. The real `onUpgrade` step (1 -> 2) is written; a schema-1 fixture was built by hand (no schema-snapshot tooling exists in this project) from a real version-1 database's own `sqlite_master.sql`, and a test proves the migration against it, keeping the old entry's data and adding no mood or tags to it (`app/test/migration_safety_test.dart`, TC-015/TC-100 style). The repository layer (`EntryRepository`) and the editor UI (mood picker, tag input) are also built and unit/widget tested. Update, same day: the timeline now shows an entry's mood and tags too, and export/import carries the new fields (see the ADR-003 update below). Not yet done for any of this: a widget or emulator test of the real screens.

**Export impact:** see the ADR-003 update below; `schemaVersion` in the manifest moves to 2, `formatVersion` does not change.

No new risk beyond what RISK-001 and ADR-006 already cover. This is an application of accepted decisions, not a new trade-off, so it is recorded here rather than as a new ADR.

## Update 2026-09-23 (FEAT-011: photos)
FEAT-011 (Photos) applies this ADR's existing "Media" supporting decision (media as separate encrypted files, database holds only a reference) to a real feature, for the first time. Bumps `journalSchemaVersion` 2 -> 3 (FEAT-010's schema step, above).

**Schema change:**
- A `media` table: `id` (autoincrement), `uid` (a random, stable identifier, the same role `entries.uid` plays — never reused, travels in exports), `entry_id` (references `entries.id`), `caption` (nullable text, owner decision 2026-09-23: optional), `mime_type`, `byte_size`, `sha256` (the content hash of the *decrypted* bytes, per this ADR's original "database stores only a reference, size, type, and content hash"), `created_at_ms`. No `width`/`height`: not decided anywhere, and nothing in FEAT-011 needs them yet; add them later if a real need appears rather than storing unused columns now.
- No change to `entries`: a photo belongs to an entry through `media.entry_id`, the same shape as FEAT-010's `entry_tags`, not a column on `entries`.
- File layout: one file per photo at `<app support dir>/media/<uid>.enc`, encrypted with the ADR-001 data key using AES-256-GCM with a unique nonce per file (the same primitive already used for the export envelope and key wrapping, `app/lib/backup/envelope.dart`, `app/lib/security/key_vault.dart` — not a new choice). Written via a temp-file-then-move (this ADR's atomic-write supporting decision), so a crash mid-write never leaves a half-written photo referenced by a `media` row.
- Deleting an entry deletes its `media` rows and their files (FEAT-011 AC-4); an orphaned file with no matching row, or a row with no matching file, is the consistency-scan case this ADR's Consequences section already names as a known risk (RISK-011).
- Compression (owner decision 2026-09-23: photos are resized/compressed on the way in) happens before encryption, on the plaintext bytes that `sha256` is computed from; the exact target (max dimension or quality) is a technical bound for frontend-mobile to set, not specified here.
- EXIF and other embedded metadata is kept as-is inside the (compressed) plaintext bytes before encryption (owner decision 2026-09-23); this ADR does not strip or inspect it. RISK-013 (a real residual privacy consideration, not mitigated by this schema) stands as recorded in the FEAT-011 spec.

**Migration:** additive only (a new table, no change to `entries`), but still a real migration for ADR-006's rules to protect, the same way FEAT-010's schema step was. No code exists yet for this feature.

**Export impact:** `docs/export-format.md`'s reserved, currently-empty `media/` folder becomes real: one file per photo, at its original (decrypted) plaintext bytes, the same treatment `entries.json` already gives entry text (decrypted from the device key, then optionally wrapped by the export's own password-derived envelope, never double-encrypted). `entries.json` gains a `media` field per entry (a list of photo references, additive, same `formatVersion` per ADR-003 rule 2) — see the ADR-003 update, once this spec reaches that stage.

No new architecture decision beyond what this ADR and ADR-001 already made; this update applies them, so it is recorded here rather than as a new ADR.

**Built 2026-09-23**: `journalSchemaVersion` is now 3 in `app/lib/data/journal_database.dart`: the `media` table exactly as decided above, with a real `onUpgrade` step (2 -> 3). Proven against a genuine hand-built schema-2 fixture (`app/test/migration_safety_test.dart`), keeping the old entry's mood and tag untouched while adding the new table - the same TC-015/TC-100 pattern FEAT-010's step used. The failure-injection test (ADR-006 rule 2) was updated to still force a real failure: drift's `createTable` turned out to be `CREATE TABLE IF NOT EXISTS`, a silent no-op on an existing table, so only the earlier `addColumn` step reliably fails now; this is noted in the test file, not hidden. `image_picker` (1.2.3) added to `pubspec.yaml` for the camera/library pickers (its own Android manifest declares no permission beyond a `FileProvider`, checked directly against the plugin's package cache, not assumed). Not yet built: the encrypted-file layer for photo bytes, the repository layer, and any UI.

**Built 2026-09-23, continued**: the encrypted-file layer (`app/lib/data/media_files.dart`, `MediaFiles`) - one AES-256-GCM file per photo (`nonce | ciphertext | mac`, a fresh random nonce every write, no header needed since this file is never read outside the app's own current code, unlike the export envelope), and the repository layer (`EntryRepository.addPhoto`/`removePhoto`/`setPhotoCaption`/`photosFor`/`readPhotoBytes` in `app/lib/data/entry_repository.dart`). Deleting an entry now deletes its photos' rows and files too (FEAT-011 AC-4); a `media` row is only written after its file, and rolled back (the orphan file deleted) if the row insert fails, so a crash between the two never leaves a row pointing at nothing. Compression is not this layer's job: it happens where the photo is picked (`image_picker`'s own `maxWidth`/`imageQuality` parameters, still to be wired), so the repository only ever stores bytes it is handed, already at their final size. Proven in `app/test/media_test.dart` (10 tests: encryption round trip, wrong-key rejection, a fresh nonce each write, no plaintext on disk, and every repository method) - suite now 133. Not yet built: the editor UI (picker, thumbnails), the viewer screen, export/import.

**Built 2026-09-23, continued**: the editor UI (`app/lib/journal/photo_strip.dart`) and the S15 viewer (`app/lib/journal/photo_viewer_page.dart`), matching the owner-approved previews. `pickCompressedPhoto` wires `image_picker`'s own `maxWidth: 1600, imageQuality: 82` as the compression step decided above - no separate image-processing package. Three more Lucide icons registered (`camera`, `image`, `trash`/`trash-2`), code points verified the same way FEAT-010's mood icons were: `lucide-static@1.47.0`'s own `font/info.json` downloaded and read directly, never guessed. While wiring this, found and fixed a real gap: `app/lib/journal/journal_session.dart` built the app's real `EntryRepository` without a media directory or data key, so the running app could not have stored a photo at all despite the schema and repository layers being ready - it now passes `<app support directory>/media` and the already-loaded data key. `editor_page.dart` saves a still-unsaved entry silently on its first photo, the same way the existing draft mechanism already avoids losing text; adding a photo before any text exists is a no-op, matching Save's own rule. Proven in `app/test/photo_strip_widget_test.dart` (4 tests). A testing-infrastructure lesson worth keeping: `testWidgets` runs under a fake clock, so real file/AES-GCM work (photo encryption and decryption) never completes on its own inside one - `tester.runAsync` is required, both to call repository methods directly and, polling, to let a `FutureBuilder`'s real future resolve; this is noted in the test file itself. `flutter analyze` clean, suite now 137. Not yet built: export/import.

## Update 2026-09-20 (search)
Full-text search is built as decided: an FTS5 table (`unicode61` with accents removed, so `cafe` finds `Café`) lives inside the encrypted file, and three triggers keep it equal to the entries after every insert, edit and delete. Searching for a word matches from the start of a word (`riv` finds river; `iver` does not). Measured on an emulator with 20,000 entries: 0 to 24 ms (median) per query, and 0.7 s to insert the 20,000 entries with the index. Tests read the raw files after inserts and deletes and find no entry text (`app/test/search_test.dart`). Not verified on iOS.
