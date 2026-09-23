# Independent review scope: encryption and export design (v1)

Status: prepared 2026-09-23, review not yet done. This is a scope note for whoever the owner asks to read the code and design (a friend, not a paid audit or an authorised penetration test; `templates/pentest-scope.md` does not apply here since nothing is being actively tested). Purpose: close RISK-005 ("cryptography mistake weakens the privacy claim") and the "no independent review" gaps named in ADR-001, ADR-002, ADR-003, and `PRR-001` (rows 2 and 6).

## What to give the reviewer
- This file.
- `../adr/ADR-001-encryption-and-key-recovery.md`, `ADR-002-local-database.md`, `ADR-003-export-archive-format.md`, `ADR-006-migration-safety-rules.md`.
- Read access to `app/lib/security/`, `app/lib/data/` (`journal_database.dart`), `app/lib/backup/` (envelope, minimal ZIP reader, export/import).
- No real journal content, passcodes, or export passwords: use a fresh install with synthetic entries only (same rule as `qa/workflow/phone-test-checklist.md`).

## Questions the review should answer
1. **Key handling (ADR-001):** Is the data key generated with a sound random source? Is it held only in the OS Keychain/Keystore and the passcode-wrapped copy, never written elsewhere (files, logs, backups)? Does the passcode-derived key actually use the parameters recorded in `local-data-design.md` (Argon2id, 64 MiB, 3 passes, 2 lanes)?
2. **Database encryption (ADR-002):** Does the raw database file (and its journal/write-ahead files) contain zero readable entry text without the key? Are the `mood` and `tags` fields (FEAT-010, once built) encrypted the same way as entry text, not stored separately in the clear?
3. **Export envelope (ADR-003):** Is the encryption authenticated (tampering or a wrong password fails before any data is read)? Are the KDF parameters and salt/nonce handling correct? Is there any place the plaintext ZIP or a decrypted buffer could be written to disk unintentionally (temp files, crash dumps)?
4. **Import safety (ADR-003, THR-008):** Does the importer enforce its stated limits (file count, decompressed size, entry size) before parsing, and reject path traversal, without ever touching the current journal until the import fully succeeds?
5. **Migration safety (ADR-006, once implemented for FEAT-010):** Does the copy-before-migrate step actually protect against an interrupted migration? Is the pre-migration copy itself encrypted with the same key, not left in the clear?
6. **General:** Any hand-rolled cryptographic primitive (forbidden by `_shared/project.md`); any secret or key value that could end up in a log, crash report, or the app-switcher preview.

## What "done" looks like
- A short written note (informal is fine) naming: what was checked, what was found (if anything), and a severity if something is wrong. No fix is required from the reviewer; findings come back to the owner to record as `THR-` (cyber-security) if new, or against existing `THR-002`, `THR-007`, `THR-008`, `THR-010`.
- The owner reports the outcome back; this session (or a future one) records it in `PRR-001` rows 2 and 6, `RISK-005`, and this file's Outcome section below.

## Outcome
Done, 2026-09-23. A reviewer outside the assistant/owner pair (a friend of the owner) read the ADRs and the code named above. Reported result: no issues found across the six question areas (key handling, database encryption, export envelope, import safety, migration safety, general hygiene). No `THR-` findings raised.

This is the owner's report of the outcome, not something this session observed directly; the review itself happened outside this conversation. RISK-005 is downgraded on this basis, not eliminated: a single informal read by one person is lighter assurance than a paid audit or a second reviewer, and it did not (and could not, since FEAT-010's migration code does not exist yet) cover ADR-006's implementation. Revisit before the first store submission and again once ADR-006 ships.
