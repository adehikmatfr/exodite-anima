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

## Update 2026-09-20 (spike S6 and S7)
- The custom envelope was kept and option D (`age`) was not adopted: no maintained Dart implementation was found (see the spike plan). The envelope is specified in `app/lib/backup/envelope.dart`.
- The importer uses its own minimal ZIP reader, not a general package, so size limits hold while unpacking. Supporting decision 3 above is implemented that way.
- The journal database gained a stable random `uid` per entry (needed for `id` in `entries.json` and for skipping entries already present) and a small `app_values` table (last export time). This is still schema version 1 because no version has been released.
- Numeric import limits are provisional until the owner decides (TC-065).
- Unchanged: the decision itself remains accepted.
