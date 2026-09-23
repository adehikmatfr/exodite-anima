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

**Migration:** this schema step must ship with ADR-006 Option A fully implemented (copy-before-migrate, restore-on-failure, refuse-newer-schema, transactional/resumable), because it is additive but still a real migration for any phone that already has entries under schema 1. Follow-up work for frontend-mobile: fixture database at schema 1, migration test to schema 2, and the failure-injection test named in ADR-006 (TC-015, TC-100, TC-101) — none of that exists yet for a real migration step.

**Export impact:** see the ADR-003 update below; `schemaVersion` in the manifest moves to 2, `formatVersion` does not change.

No new risk beyond what RISK-001 and ADR-006 already cover. This is an application of accepted decisions, not a new trade-off, so it is recorded here rather than as a new ADR.

## Update 2026-09-20 (search)
Full-text search is built as decided: an FTS5 table (`unicode61` with accents removed, so `cafe` finds `Café`) lives inside the encrypted file, and three triggers keep it equal to the entries after every insert, edit and delete. Searching for a word matches from the start of a word (`riv` finds river; `iver` does not). Measured on an emulator with 20,000 entries: 0 to 24 ms (median) per query, and 0.7 s to insert the 20,000 entries with the index. Tests read the raw files after inserts and deletes and find no entry text (`app/test/search_test.dart`). Not verified on iOS.
