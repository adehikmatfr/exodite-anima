# ADR-003: Export as a versioned ZIP of JSON (and Markdown), wrapped in an encrypted envelope by default

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-09-20 |
| Deciders | Project owner |
| Consulted | none (solo project); software-architect and cyber-security roles applied |
| Reversibility | one-way door once users hold archives (cost to undo: old archives must stay importable forever) |
| Related | FEAT-006, FEAT-007, ADR-001, ADR-002, RISK-002 |
| Review date | Before adding media (v1.1), and before the first store release |

## Context

Export is the only backup and the only way to move to a new device (charter). The format must:

- restore the whole journal in the app (FEAT-007), including archives made by older app versions;
- not lock the user in: a person must be able to read their entries without this app;
- be protected by default, since a leaked file would expose the journal (ADR-001);
- leave room for photos and audio in v1.1 and v1.2 without breaking old archives.

The owner decided that the plaintext export produces **both JSON and Markdown**.

### Quantified requirements (drivers)

| NFR | Target | Measured by | Source |
|-----|--------|-------------|--------|
| Round trip | Export then import restores 100% of entries, text and dates identical | Round-trip test | FEAT-007 |
| Backward compatibility | Every past `formatVersion` remains importable | Fixture archives per version in CI | RISK-002 |
| Encrypted archive readable without the password | 0 bytes of entry text | Raw-file test | ADR-001 |
| Export or import of 5,000 entries | Completes with progress shown, app stays responsive | Benchmark | requirements |

## Options considered

### Option A: ZIP of JSON and Markdown, with an encrypted envelope
- Summary: The archive is a ZIP holding `manifest.json`, `entries.json`, and human-readable Markdown files. The plaintext export is that ZIP as is. The encrypted export wraps the same ZIP in an authenticated-encryption envelope with a small header.
- Pros: Open, documented, readable by anyone. One structure for both modes, so one importer. Easy to extend with a `media/` folder later.
- Cons: A custom envelope needs care (mitigated by vetted primitives and tests). ZIP input must be handled defensively.
- Cost / effort: Medium.
- Risks: Cryptography or parsing mistakes (RISK-005).

### Option B: Copy of the encrypted database file
- Summary: Export the SQLite file (ADR-002) with its existing encryption.
- Pros: Trivial to produce.
- Cons: Ties the format to one database engine and schema, unreadable without this app, no plaintext option, hard to migrate across schema versions. Violates "the user owns the data".
- Cost / effort: Low.
- Risks: Lock-in, brittle across versions.

### Option C: A single JSON file
- Summary: One JSON document for everything.
- Pros: Simple.
- Cons: Poor fit for media later, no built-in place for Markdown, large single file.
- Cost / effort: Low.
- Risks: Format must change when media arrives.

### Option D: Use an existing standard encrypted container for the envelope (for example the `age` format)
- Summary: Same ZIP as Option A, but encrypted with an established, specified file-encryption format rather than our own header.
- Pros: Less of our own crypto design.
- Cons: Availability and maintenance of a suitable Dart implementation is not verified.
- Cost / effort: Depends on library support.
- Risks: No maintained Dart library.

### Option E: do nothing (baseline)
- Consequence of not deciding: FEAT-006 and FEAT-007 cannot be built, and the "move to a new device" promise fails.

## Decision

We will use **Option A**, with Option D evaluated during the spike as a replacement for the custom envelope header, because the ZIP of open formats keeps the user's data readable and portable, handles both encrypted and plaintext modes with one importer, and can grow to include media without breaking old archives.

### Archive structure (formatVersion 1)

```
manifest.json          format, formatVersion, schemaVersion, appVersion, createdAt, entryCount, sha256 of entries.json
entries.json           canonical machine-readable entries (the only file the importer reads for content)
entries/YYYY/YYYY-MM-DD-<id>.md    one Markdown file per entry, for human reading (plaintext mode only)
media/                 reserved for v1.1 and later
```

- **Entry fields** in `entries.json`: stable `id` (random, never reused), `entryDate` (local calendar date `YYYY-MM-DD`), `createdAt` and `updatedAt` (ISO 8601, UTC), `text` (UTF-8).
- **Two version numbers:** `formatVersion` (the archive layout) and `schemaVersion` (the data model). Both are in the manifest.
- **Markdown files are for reading only.** Import uses `entries.json`, so the JSON is the source of truth and no Markdown parsing is needed.

### Encrypted envelope

- File extension for encrypted export (proposal): `.anima`. Plaintext export is a normal `.zip`.
- A small unencrypted header states the magic bytes, `formatVersion`, KDF algorithm and parameters, salt, and nonce. The header is authenticated as associated data.
- The payload (the ZIP) is encrypted with a vetted authenticated cipher. The key is derived from the export password with a memory-hard KDF (for example Argon2id), with parameters stored in the header so they can be raised later.
- For v1 (text only, small size) one authenticated encryption of the whole payload is acceptable. A chunked scheme will be introduced through a new `formatVersion` when media arrives.

### Rules for compatibility and safety

1. The importer supports **every past `formatVersion`** and migrates data to the current `schemaVersion`. A newer, unsupported version is rejected with a message to update the app.
2. Unknown fields inside a known version are ignored, so additive changes do not break older readers.
3. **Import treats the archive as untrusted input:** it reads only `manifest.json` and `entries.json` by exact name, ignores any other path (no path traversal), and enforces limits on file count, decompressed size, and entry size before parsing.
4. Wrong password, tampered data, or truncation all fail authentication before any data is applied. Import remains atomic (FEAT-007).
5. The plaintext export always shows the leak warning (FEAT-006).

## Consequences

- Positive: Data stays portable and readable. One importer serves both modes. Media can be added under `media/` with a new `formatVersion`.
- Negative / trade-offs accepted: Every `formatVersion` must be supported forever, with fixtures in CI. A custom envelope carries crypto-design risk until Option D is evaluated. Plaintext ZIPs contain the same text twice (JSON and Markdown), which enlarges the file slightly.
- Follow-up work:
  - Spike: decide between the custom envelope and an existing standard (Option D), based on Dart library maintenance.
  - Publish a short format specification in `docs/` once the layout is final.
  - Create fixture archives for each `formatVersion` and run them in CI.
  - Define the merge rule for import (FEAT-007 open question).
- New risks: RISK-002 (import fails across versions) and RISK-005 (crypto mistakes) stay open and are mitigated by the fixtures, vetted libraries, and tests above.
- Assumptions to validate: a memory-hard KDF runs within acceptable time on a low-end phone (owner, at spike); ZIP handling in Dart can enforce the size limits safely (owner, at spike).
- Exit strategy: introduce a new `formatVersion` and keep the old reader. Users can always export in plaintext to leave the app.

## Validation

- Round-trip test (export then import equals original) in both modes.
- Fixture archives for every `formatVersion` import successfully in CI.
- The raw encrypted file contains no plaintext entry text; a wrong password or a modified byte fails before any data is applied.
- Malformed archives (path traversal names, oversized entries, zip bombs) are rejected without changing the journal.
- Revisit before media is added, or if a standard envelope proves clearly better.

## Review record (2026-09-20)
Added when the ADR was moved into the software-architect role and checked against `adr-writing`. The decision is unchanged and remains accepted; nothing above was rewritten.

- **Quality gate:** decision in one sentence: yes. Two or more real options: yes (Option D is deliberately left open). Numbers in the drivers: partly. Negative consequences named: yes. Owner and review trigger: yes.
- **Unconfirmed number:** "5,000 entries" in the drivers was proposed by the assistant; treat as `ASSUMPTION` until `nfr-targets-v1` is decided.
- **Open by design:** the envelope (custom header versus an existing standard such as `age`) is decided in the spike; if the standard is chosen, that is a superseding ADR for the envelope part only.
- **Not yet done:** fixture archives for `formatVersion` 1 and the round-trip test do not exist; qa owns them (test plan stage). RISK-002 stays open until they do.
- **Consulted:** none. The cyber-security role reviews the envelope and import limits (THR-006, THR-007, THR-008).

## Update 2026-09-23 (FEAT-010: mood and tags)
FEAT-010 adds `mood` (one of the 5 fixed values, or absent) and `tags` (a list of tag names, possibly empty) to each entry in `entries.json`. Per rule 2 above ("unknown fields inside a known version are ignored"), this is additive: **`formatVersion` stays 1.** The manifest's `schemaVersion` moves to 2 (matching the ADR-002 update), so an archive can be told apart from one made before FEAT-010 without a new archive layout.

An older app version importing a FEAT-010 archive sees `entries.json` with fields it does not know; rule 2 says it ignores them, so entries import without mood or tags rather than failing. An import of a pre-FEAT-010 archive into a FEAT-010 app simply finds no `mood`/`tags` fields and leaves those entries unset — no special-case code needed. A fixture archive at `schemaVersion` 2 is follow-up work for qa (mirrors the existing rule that every past version stays importable, RISK-002), and is a smaller addition than a new `formatVersion` fixture would be.

**Built 2026-09-23**: `mood` (the enum's name, e.g. `"good"`, not its numeric index, so the exported file stays self-describing) and `tags` (a plain string array) are written and read in `app/lib/backup/backup_service.dart`, present only when set. An unrecognised `mood` string (an older name, or one from a future version) is dropped rather than refusing the import, per rule 2. Proven at the format level and through a full round trip between two real, separate journal databases (`app/test/backup_test.dart`), including a tag containing a comma and an archive with neither field at all. `docs/export-format.md` updated with the concrete field shapes. No fixture archive at `schemaVersion` 2 exists yet (still open, as noted above).

## Update 2026-09-23 (FEAT-011: photos)
FEAT-011 (Photos) makes the `media/` folder this document already reserved (`docs/export-format.md`: "Reserved for photos and audio, planned for a later version. Empty today.") real. Bumps the manifest's `schemaVersion` 2 -> 3 (matching the ADR-002 update); **`formatVersion` stays 1**, the same additive treatment FEAT-010's fields got, per rule 2.

- `entries.json` gains a `media` field per entry (owner decisions 2026-09-23 behind this shape): an array of objects, each with the photo's `id` (the same stable `uid` as the `media` table row), `caption` (present only when set), and the archive path where the photo's own bytes live. Absent, not an empty array, on an entry with no photos.
- Each photo's bytes are written under `media/` in the archive, at their plaintext (decrypted, compressed) content — the same treatment `entries.json` gives entry text: decrypted from the device data key first, then the whole archive is optionally wrapped once by the export's own password-derived envelope. A photo is never double-encrypted (device key, then export key); only ever the export key, if any.
- **Rule 3 needs real code, not just a rule**: this ADR's rule 3 says the importer "reads only `manifest.json` and `entries.json` by exact name, ignores any other path." That is a safety default for *unrecognised* paths, correct as written, but it also means today's importer (`app/lib/backup/backup_service.dart`) does not yet know to look for `media/` files at all — it must be extended to read them by the exact paths `entries.json`'s `media` field names, still under the same size and count limits (`ImportLimits`) rule 3 already requires, and still refusing any path outside `media/` (no path traversal, unchanged).
- An older app version importing a FEAT-011 archive sees `entries.json` with a `media` field it does not know, and a `media/` folder it never looks at; rule 2 and rule 3 together mean it imports the entry's text (and FEAT-010's mood/tags, if present) and simply never sees the photos — not a crash, not a partial failure, just content it does not understand yet. A FEAT-011 app importing a pre-FEAT-011 archive finds no `media` field and adds no photos, the same "no special-case code needed" pattern FEAT-010 established.
- A fixture archive at `schemaVersion` 3 is follow-up work for qa, the same as the `schemaVersion` 2 fixture FEAT-010 still owes (RISK-002).

**Built 2026-09-23**: exactly as decided above, and now the last of FEAT-011's slices. Each photo's archive filename is `media/<id>.<ext>`, its extension derived from the photo's own `mimeType` (`jpg`/`png`/`heic`/`webp`, or `bin` for anything else) rather than a bare id, so the file is recognisable outside the app too; `entries.json`'s `media[].path` names this exact string, which the importer both reads from and validates against (the `id` inside a `path` must match that photo's own `id` field, or the reference is dropped). Rule 3's real code: `readBackup` now runs the ZIP reader twice - once for `manifest.json`/`entries.json` as before, then a second exact-name pass for only the `media/` paths `entries.json` itself named and passed validation, so nothing about which files exist in the ZIP's own directory is ever trusted before that point (no path traversal, unchanged; a made-up `path` like `../../evil.jpg` is rejected by the path pattern itself, never reaching the second pass). A malformed photo reference (bad id, an id that does not match its own path, a caption of the wrong type) is dropped silently, the same "ignore what is not understood" rule mood and tags already follow, extended to a single bad reference rather than the whole entry or import. A photo an entry claims but whose bytes are not in the archive - an older/truncated archive, or one AC-8 excluded at export because it could not be decrypted - is simply not added, not an import failure. Export-side, `EntryRepository.readAllForExport` now returns each entry's photo metadata (`StoredMediaRef`: `uid`, `mimeType`, `caption`); `ExportPage` decrypts each photo's bytes itself (it alone holds the device data key) and drops any that fail (AC-8) before handing them to `createBackup`. Import-side, `EntryRepository.importEntries` gained a `mediaBytes` parameter and re-uses `addPhoto`'s machinery with the archive's own `uid` (not a freshly minted one), so an imported photo's identity survives a round trip the same way an entry's does. Proven at the format level (round trip with and without a caption, a missing-bytes exclusion, an older-app-shaped archive with no `media` field at all, and every malformed-reference case above) and through a full round trip between two real, separate encrypted journals with a real encrypted photo file on each side (`app/test/backup_test.dart`). `flutter analyze` clean, suite now 144 tests. `docs/export-format.md` updated to describe the real (not "not built yet") shape.

## Update 2026-09-20 (spike S6 and S7)
- The custom envelope was kept and option D (`age`) was not adopted: no maintained Dart implementation was found (see the spike plan). The envelope is specified in `app/lib/backup/envelope.dart`.
- The importer uses its own minimal ZIP reader, not a general package, so size limits hold while unpacking. Supporting decision 3 above is implemented that way.
- The journal database gained a stable random `uid` per entry (needed for `id` in `entries.json` and for skipping entries already present) and a small `app_values` table (last export time). This is still schema version 1 because no version has been released.
- Numeric import limits are provisional until the owner decides (TC-065).
- Unchanged: the decision itself remains accepted.
