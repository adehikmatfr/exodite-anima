# Test cases: FEAT-006 Export

Plan: TP-001. Cases `TC-048` to `TC-057`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-048: Verify the entries cannot be read

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-1) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An encrypted export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the file is opened without the password | synthetic | The entries cannot be read |



Execution log: Automated, `app/test/backup_test.dart`: passed on the host, 2026-09-20 (an encrypted export holds no entry text and no file names). The screen test `app/integration_test/feat006_007_ui_test.dart` also checks the shared bytes on the emulator.

### TC-049: Verify no entries are revealed

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-2) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An encrypted export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: A wrong password is used | synthetic | No entries are revealed |



Execution log: Automated, `app/test/backup_test.dart` and `app/integration_test/feat006_007_ui_test.dart`: passed, 2026-09-20 (no password and a wrong password reveal nothing).

### TC-050: Verify A warning is shown before anything is created

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-3) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The plaintext option. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user selects it | synthetic | A warning is shown before anything is created |



Execution log: Automated, `app/integration_test/feat006_007_ui_test.dart`: passed on the emulator, 2026-09-20 (the warning shows first; going back creates nothing; the file is made only after confirming).

### TC-051: Verify the count equals the number of entries in the journal

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-4) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | integration |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A finished export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: its entry count is read | synthetic | The count equals the number of entries in the journal |



Execution log: Automated, `app/test/backup_test.dart`: passed on the host, 2026-09-20 (the manifest count equals the entries).

### TC-052: Verify the deleted entry is not in the file

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-5) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry that was deleted. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: an export is made | synthetic | The deleted entry is not in the file |



Execution log: Automated, `app/test/backup_test.dart`: passed on the host, 2026-09-20 (a deleted entry is not in the export).

### TC-053: Verify the last export time is updated

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-6) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A successful export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the export completes | synthetic | The last export time is updated |



Execution log: Automated, `app/integration_test/feat006_007_ui_test.dart`: passed on the emulator, 2026-09-20 (Settings shows the last export as today).

### TC-054: Verify the last export time is not changed

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-7) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** A failed export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the export ends with an error | synthetic | The last export time is not changed |



Execution log: Automated, `app/integration_test/feat006_007_ui_test.dart`: passed on the emulator, 2026-09-20 (a failing share and a share dialog closed by the user both leave it at 'Not exported yet'). Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Closing the share sheet leaves 'Not exported yet'.

### TC-055: Verify progress is shown

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-8) |
| Other links | ADR-001, ADR-003, RISK-001, RISK-002, THR-006 |
| Level | performance |
| Priority | P2 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A very large journal. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: an export runs | synthetic | Progress is shown |



Execution log: Partial, 2026-09-20: a progress bar and the entry count are shown, but the bar is not determinate. Not measured with a large journal in the screens.

### TC-056: Verify any changed byte in an encrypted export makes import refuse it before anything is applied

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-006, NFR-10 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An encrypted export of synthetic entries and a fresh journal. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Change one byte at the start, middle, and end of the file (three runs) and import each | synthetic | Each import is refused and the journal is unchanged |



Execution log: Automated, `app/test/backup_test.dart`: passed on the host, 2026-09-20 (a changed byte at the header, the body and the tag is refused; also cut-off files and a header asking for an absurd key derivation).

### TC-057: Verify an export with too little storage fails cleanly without leaving a partial file

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | none |
| Level | resilience |
| Priority | P1 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A test device with almost no free space. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Start an export | synthetic | An error is shown, no partial file remains, and the last export time is unchanged |



Execution log: Not executed: a full-storage failure was not simulated. A failing share is covered by TC-054.

