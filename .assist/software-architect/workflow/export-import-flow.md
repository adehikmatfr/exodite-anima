# Export and import flow

Status: **built and tested on Android (2026-09-20); not verified on iOS or on a physical phone per case.** Written after ADR-003 was accepted; update it when the spike or the implementation changes anything. Source decisions: ADR-003 (format), ADR-001 (keys), ADR-002 (storage). Diagrams: `../report/c4-diagrams.md`.

## 1. Overview
Export is the only backup and the only way to move to a new phone. It produces one file: a ZIP holding a manifest, a machine-readable entries file, and (in the plaintext option) one readable Markdown file per entry. The encrypted option wraps the same ZIP in an authenticated-encryption envelope keyed from a separate export password. Import reads only the manifest and the entries file, validates them, upgrades older versions, and applies the result all-or-nothing.

## 2. Trigger / entry points
- Export: Settings, or "Export now" on the backup reminder (FEAT-006, FEAT-008).
- Import: Settings on an existing install, or "Restore from a backup" on a fresh install (FEAT-007; order relative to passcode setup is an open question).

## 3. Step-by-step flow
**Export**
1. The user chooses encrypted (default) or plaintext. Plaintext needs an explicit warning and confirmation.
2. Encrypted: the user sets an export password twice; a memory-hard function turns it into a key (parameters stored in the file header).
3. The app reads all entries and builds `manifest.json` (format version, schema version, app version, time, entry count, checksum of the entries file) and `entries.json`. Plaintext also writes `entries/YYYY/YYYY-MM-DD-<id>.md`.
4. Encrypted: the ZIP is encrypted with an authenticated cipher; the header is authenticated too.
5. The file goes to the share or save dialog; the user chooses the place. The app never uploads it.
6. Only on success is the "last export" time recorded.

**Import**
1. The user picks a file; an encrypted file asks for the export password.
2. Authentication is checked first. A wrong password, a modified byte, or truncation fails here, before anything is applied.
3. The importer reads only `manifest.json` and `entries.json` by exact name, and enforces limits on file count, unpacked size, and entry size.
4. A newer format version than the app supports is refused with a message to update. An older version is upgraded to the current schema.
5. Entries are matched by their stable id; those already present are kept, missing ones are added. Merge rule for conflicting text is an open question on FEAT-007.
6. Everything is applied in one transaction. Any failure or interruption leaves the journal unchanged.
7. The result shows how many entries were added and skipped.

## 4. Statuses and data model
- Entry fields in the file: stable id, entry date, created and updated times (UTC), text.
- Two version numbers: `formatVersion` (file layout) and `schemaVersion` (data model). Both are in the manifest; every past `formatVersion` must stay importable.
- Unknown fields inside a known version are ignored.
- `media/` is reserved for photos and audio in later versions.

## 5. External calls and events
- The share or save dialog and the file picker, both provided by the OS (failure modes below).
- No network calls.

## 6. Decisions and gotchas
- **Failure modes to design and test** (open finding F8): the file lives in a cloud folder that has not downloaded; low storage during export; the app is killed during export or import; the user picks a file that is not a backup.
- The envelope (a custom header or an existing standard such as `age`) is decided in the spike; a standard choice would supersede that part of ADR-003.
- Fixture archives per `formatVersion` and the round-trip test do not exist yet; qa owns them (finding F4, RISK-002).
- Plaintext archives cannot be authenticated; that risk is accepted (THR-009).
- The export password is separate from the passcode by design; users may mix them up (see `ux-design` findings).
