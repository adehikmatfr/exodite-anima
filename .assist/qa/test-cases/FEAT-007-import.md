# Test cases: FEAT-007 Import

Plan: TP-001. Cases `TC-058` to `TC-067`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-058: Verify all N entries are present with the same text and dates

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-1) |
| Other links | ADR-001, ADR-002, ADR-003, RISK-002, THR-008 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** An export of N entries and a fresh install. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the file is imported | synthetic | All N entries are present with the same text and dates |



Execution log: Automated, `app/test/backup_test.dart` (two journals, host) and `app/integration_test/feat006_007_ui_test.dart` (emulator): passed, 2026-09-20; text, dates and ids are identical. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Encrypted export through the real share sheet, two entries deleted, import restored all entries with the same text and dates.

### TC-059: Verify the import is refused and nothing changes

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-2) |
| Other links | ADR-001, ADR-002, ADR-003, RISK-002, THR-008 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An encrypted file. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: A wrong password is entered | synthetic | The import is refused and nothing changes |



Execution log: Automated, `app/test/backup_test.dart` and `app/integration_test/feat006_007_ui_test.dart`: passed, 2026-09-20 (wrong password is refused, nothing changes; the right one then works).

### TC-060: Verify the import is refused and the journal is unchanged

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-3) |
| Other links | ADR-001, ADR-002, ADR-003, RISK-002, THR-008 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A damaged or cut-off file. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the file is imported | synthetic | The import is refused and the journal is unchanged |



Execution log: Automated, `app/test/backup_test.dart` (60 random damages, cut-offs) and `app/integration_test/feat006_007_ui_test.dart` (a cut-off file): passed, 2026-09-20; the journal is unchanged.

### TC-061: Verify all its entries are restored

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-4) |
| Other links | ADR-001, ADR-002, ADR-003, RISK-002, THR-008 |
| Level | integration |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A file made by an older app version. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the file is imported | synthetic | All its entries are restored |



Execution log: Not executed: only formatVersion 1 exists, so there is no older version to import. The importer has the place to add a reader per version; add a fixture with each new version.

### TC-062: Verify A message asks the user to update the app and nothing changes

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-5) |
| Other links | ADR-001, ADR-002, ADR-003, RISK-002, THR-008 |
| Level | integration |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A file made by a newer unsupported version. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the file is imported | synthetic | A message asks the user to update the app and nothing changes |



Execution log: Partial, `app/test/backup_test.dart`: a newer formatVersion and a newer envelope are refused with 'too new' (host). The 'update the app' screen was not driven in a screen test.

### TC-063: Verify no duplicates are created

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-6) |
| Other links | ADR-001, ADR-002, ADR-003, RISK-002, THR-008 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A journal that already has some of the file's entries. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the file is imported | synthetic | No duplicates are created |



Execution log: Automated, `app/test/backup_test.dart`: passed on the host, 2026-09-20 (importing twice adds nothing the second time).

### TC-064: Verify the journal is unchanged

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-7) |
| Other links | ADR-001, ADR-002, ADR-003, RISK-002, THR-008 |
| Level | resilience |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An import that is interrupted midway. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app is opened again | synthetic | The journal is unchanged |



Execution log: Automated, `app/test/backup_test.dart`: passed on the host, 2026-09-20 (a failure after two entries were added rolls both back). No real process kill was tried.

### TC-065: Verify malformed archives are refused and leave the journal unchanged

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-008 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | blocked |
| Owner | qa |

**Preconditions:** Fixture archives: path-traversal names, oversized entries, a decompression bomb, duplicate names, and an extra unexpected file. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Import each fixture | synthetic | Each is refused with a clear message and the journal is unchanged |

Note: Blocked until numeric import limits are set (review gap G7).

Execution log: Partial, 2026-09-20: malformed archives (path names, missing files, wrong sizes, a decompression bomb whose header lies, too many entries, an oversized entry, a file over the size limit) are refused in `app/test/backup_test.dart`. Still blocked for the final numbers: the limits in `ImportLimits` (64 MiB file, 256 MiB unpacked, 100,000 entries, 1 MiB per entry) are provisional and need the owner's decision. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. A file that is not an export was refused and the journal was unchanged.

### TC-066: Verify importing the same file twice adds nothing the second time

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | none |
| Level | integration |
| Priority | P1 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A journal restored once from an export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Import the same file again | synthetic | Zero entries are added and all are reported as skipped |



Execution log: Automated, `app/test/backup_test.dart`: passed on the host, 2026-09-20 (same as TC-063).

### TC-067: Verify restoring a very large export meets the time target on the lowest-tier device

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | NFR-8 |
| Level | performance |
| Priority | P2 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The lowest-tier device and a stress-size export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Import the export and record the time | synthetic | It is within the target and progress is shown |



Note: Measured on the low-end reference device once the owner chooses it; the numbers come from `nfr-targets-v1` and are provisional until measured: restore of a 20,000-entry export in at most 60 s, with progress shown.

Execution log: Not executed: needs the reference device.

