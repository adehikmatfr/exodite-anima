# Test cases: FEAT-001 Entry management

Plan: TP-001. Cases `TC-001` to `TC-015`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-001: Verify A new entry with that text and today's date appears in the timeline

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-1) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The app is unlocked. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user writes text and saves | synthetic | A new entry with that text and today's date appears in the timeline |



Execution log: Automated, storage (`app/test/entry_repository_test.dart`, AC-1) and screens (`app/integration_test/feat001_ui_test.dart`): passed on the Windows host and on the Android emulator (API 34), 2026-09-20.

### TC-002: Verify the entry shows the new text

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-2) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An existing entry. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user changes its text and saves | synthetic | The entry shows the new text |



Execution log: Automated, storage and screens: passed on host and emulator, 2026-09-20.

### TC-003: Verify the saved text is unchanged

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-3) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | resilience |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** A saved entry. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app is closed and opened again | synthetic | The saved text is unchanged |



Execution log: Automated, storage: passed on host and emulator, 2026-09-20 (closing and reopening the encrypted file). Not run as a full app restart. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Force-stop, reopen, unlock: text unchanged.

### TC-004: Verify the unsaved text is offered back at the next unlock

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-4) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | resilience |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** The user is typing an unsaved entry. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app is force-closed | synthetic | The unsaved text is offered back at the next unlock |



Execution log: Automated: storage test and screen test (draft dialog and Continue writing) passed on host and emulator, 2026-09-20. The kill is stood in for by closing the database, not by force-stopping the process. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Unsaved text offered back after a real force-stop.

### TC-005: Verify the entry appears under the chosen date in the timeline

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-5) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An existing entry. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user changes its date and saves | synthetic | The entry appears under the chosen date in the timeline |



Execution log: Automated, storage: passed on host and emulator, 2026-09-20. The date picker screen path was not driven by a test.

### TC-006: Verify the entry no longer appears in the timeline

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-6) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An existing entry. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user deletes it and confirms | synthetic | The entry no longer appears in the timeline |



Execution log: Automated, storage and screens: passed on host and emulator, 2026-09-20; the deleted text is also absent from the raw file.

### TC-007: Verify the entry is unchanged

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-7) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An existing entry. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user starts to delete and then cancels | synthetic | The entry is unchanged |



Execution log: Automated, screens: passed on the emulator, 2026-09-20.

### TC-008: Verify no entry is created

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-8) |
| Other links | ADR-001, ADR-002, RISK-001, THR-010 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An empty editor. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user tries to save | synthetic | No entry is created |



Execution log: Automated, storage and screens (Save is disabled and says why): passed on host and emulator, 2026-09-20.

### TC-009: Verify no entry text is readable in any stored file without the key

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-002, ADR-002 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** Synthetic entries saved, then the app closed. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Copy every file the app created in its private storage (main database, journal, write-ahead, temporary, draft storage) | synthetic | All files copied |
| 2 | Search each file for the known synthetic words | synthetic | No word is found in any file |
| 3 | Try to open the database without the key | synthetic | The open is refused |

Note: NFR-9; the risk-review finding R4 requires the journal and write-ahead files to be included.

Execution log: Automated, `app/test/entry_repository_test.dart`, `app/test/search_test.dart` and `app/test/settings_test.dart`: passed on the host and the emulator, 2026-09-20 (entry text, draft text and search-index words are absent from every file of the database, including the write-ahead files, after inserts and deletes; a deleted word is not left behind).

### TC-010: Verify a saved entry is complete or absent after a crash at every step of saving

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-010, RISK-001 |
| Level | resilience |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** Test build with a hook that can stop the process at a chosen step. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Start saving a synthetic entry and stop the process before the write, during it, before the commit, and after the commit (four runs) | synthetic | The app is terminated each time |
| 2 | Reopen the app and unlock | synthetic | The entry is either fully present with the exact text or entirely absent; the database opens without error |

Note: NFR-6.

Execution log: Partial, 2026-09-20: every save, delete and import is one transaction (`app/test/entry_repository_test.dart`; an import cut off after two entries is rolled back). The process was not killed at each step of a save on a device.

### TC-011: Verify very long text is saved unchanged up to the technical bound and refused clearly beyond it

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | FEAT-001 question 1 |
| Level | integration |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** There is no artificial maximum entry length; the technical bound is set by the software-architect from the spike. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Save entries of empty, one character, and a very long text near the technical bound, and one above it | synthetic | Empty is not saved; the others are saved unchanged; the one above the bound is refused with a clear message and the text is kept |



Note: The technical bound comes from the spike (decision 2026-09-20: no artificial limit).

Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Very long text saved or refused clearly; the bound where it refused was not written down.

### TC-012: Verify Unicode text (emoji, combining marks, right-to-left) is saved and shown unchanged

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | none |
| Level | integration |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** Synthetic strings with emoji, combining marks, and right-to-left script. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Save each string, close and reopen the app, and open the entry | synthetic | The text is identical to what was typed |



Execution log: Partial, 2026-09-20: Japanese, emoji, quotes and control characters were saved, searched, exported and imported unchanged in tests; combining marks and right-to-left text were not tried. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Emoji, combining mark and right-to-left text shown and found unchanged.

### TC-013: Verify an entry keeps the date the user chose after the phone's time zone or clock changes

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | none |
| Level | integration |
| Priority | P2 |
| Type | boundary |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** An entry saved with a chosen date. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Change the phone's time zone and clock, then open the timeline | synthetic | The entry is still under the chosen date |



Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Entry date kept after a time-zone change.

### TC-014: Verify saving an entry stays within the latency target on the lowest-tier device

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | NFR-3 |
| Level | performance |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The lowest-tier device and the stress-size journal. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Save an entry 30 times and record the time until saved | synthetic | The 95th percentile is within the target |



Note: Measured on the low-end reference device once the owner chooses it; the numbers come from `nfr-targets-v1` and are provisional until measured: save acknowledged in at most 300 ms (95th percentile).

Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Partial. Saving felt instant; the latency was not timed, so the target is not measured.

### TC-015: Verify a database written by the previous schema version opens with all entries intact

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-010, NFR-20 |
| Level | integration |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A database created by the previous schema version. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Open it with the new version of the app and unlock | synthetic | Every entry is present and unchanged |

Note: With only one schema version the harness runs against the initial schema; real cases start when the schema changes.

Execution log: not executed (nothing is built yet).

