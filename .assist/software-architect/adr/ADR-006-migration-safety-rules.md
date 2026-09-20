# ADR-006: Protect the journal during data migrations

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-09-20 |
| Deciders | Project owner |
| Consulted | none (solo project); software-architect and frontend-mobile roles applied |
| Reversibility | two-way door as a rule, but a mistake in it can lose user data; treat as high-care |
| Related | ADR-002, ADR-003, FEAT-001, RISK-001, RISK-002, THR-010, `../../frontend-mobile/report/local-data-design.md` |
| Review date | Before the first schema change after release |

## Context
The journal lives only on the phone. The usual safety net for a failed local migration is to rebuild the cache from a server, and this app has no server. A migration that fails or is interrupted can therefore destroy the only copy (RISK-001, THR-010). Shipped binaries cannot be recalled, and old versions stay in use, so a newer database can meet an older app after a downgrade or reinstall.

### Quantified requirements (drivers)
| NFR | Target | Measured by | Source |
|-----|--------|-------------|--------|
| Entries lost or altered by a migration | 0 | Migration tests from every supported previous schema, and a failure-injection test | NFR-6, TC-015, TC-100 |
| A newer database is never written by an older app | 0 writes | Test that opens a newer-schema fixture with an older version | TC-101 |

## Options considered

### Option A: Four safety rules (chosen)
- Summary: (1) before a migration, keep an encrypted copy of the database file and delete it only after the next successful launch on the new schema; (2) if a migration fails, restore the copy and show the "journal cannot be opened" screen with an offer to import an export, never leaving a half-migrated file; (3) a database written by a newer schema than the app knows is never opened for writing, and the app asks the user to update; (4) large migrations run in one transaction where possible, otherwise resumably in the background with progress.
- Pros: a failed migration does not lose data; downgrades cannot corrupt data; matches what the platform-side skill requires.
- Cons: temporary extra storage during a migration; more code and tests.
- Cost / effort: medium.
- Risks: the copy itself must be as protected as the database (it is encrypted with the same key).

### Option B: In-place migration in a single transaction only
- Summary: rely on the database transaction.
- Pros: simplest.
- Cons: does not cover a crash of the file system, a bug that succeeds wrongly, or a downgrade.
- Cost / effort: low.
- Risks: silent data loss.

### Option C: Require an export before every migration
- Summary: block the update until the user exports.
- Pros: an independent copy.
- Cons: friction, users skip or forget the password, and it fails for users who cannot export.
- Cost / effort: medium.
- Risks: blocks updates.

### Option D: do nothing (baseline)
- Consequence of not deciding: Option B by default.

## Decision
We will use **Option A**, because the journal has no other copy and the cost of extra storage and tests is small compared with losing a user's writing.

## Consequences
- Positive: migrations become recoverable; downgrade is safe.
- Negative / trade-offs accepted: temporary double storage during a migration; a migration test suite that must keep growing with every schema change.
- Follow-up work: a fixture database for every schema version; test cases TC-015, TC-100, and TC-101; the "journal cannot be opened" screen (S14) and criterion (FEAT-001 AC-9).
- New risks: none new; RISK-001 and THR-010 are mitigated further.
- Assumptions to validate: the encrypted database can be copied and restored safely while the app is closed (ASSUMPTION; owner: frontend-mobile; validate in the spike).
- Exit strategy: supersede this ADR with a new set of rules; the export archive is the independent copy of last resort.

## Validation
The migration tests pass from every supported schema; the failure-injection test restores the previous state; the newer-schema test is refused. Revisit if a migration ever needs more storage than the phone can give.
