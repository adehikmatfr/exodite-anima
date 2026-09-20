# Test cases: FEAT-002 Timeline

Plan: TP-001. Cases `TC-016` to `TC-020`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-016: Verify entries are listed newest first, grouped by day

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-002 (AC-1) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** Entries on different dates. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the timeline opens | synthetic | Entries are listed newest first, grouped by day |



Execution log: Automated: storage test for order and grouping (`app/test/entry_repository_test.dart`) and screen test for headings and vertical order (`app/integration_test/feat001_ui_test.dart`); passed on the Windows host and the Android emulator, 2026-09-20.

### TC-017: Verify an empty state with an action to write the first entry is shown

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-002 (AC-2) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** No entries. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the timeline opens | synthetic | An empty state with an action to write the first entry is shown |



Execution log: Automated, screen test (empty state and its action): passed on the emulator, 2026-09-20.

### TC-018: Verify the entry opens

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-002 (AC-3) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry in the list. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user taps it | synthetic | The entry opens |



Execution log: Automated, screen tests (tapping a row opens the editor with the full text): passed on the emulator, 2026-09-20.

### TC-019: Verify scrolling stays within the responsiveness target of `nfr-targets-v1` (criterion incomplete until that decision is made)

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-002 (AC-4) |
| Other links | ADR-002, RISK-004 |
| Level | performance |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A very large journal. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user scrolls quickly | synthetic | Scrolling stays within the responsiveness target of `nfr-targets-v1` (criterion incomplete until that decision is made) |



Note: Measured on the low-end reference device once the owner chooses it; the numbers come from `nfr-targets-v1` and are provisional until measured: at least 95% of frames within 16.7 ms with 20,000 entries.

Execution log: Partial, 2026-09-20, Android emulator (x86, API 34), 20,000 synthetic entries (`app/integration_test/feat002_timeline_perf_test.dart`, profile build). First run: list visible 276 ms after start; build within 16.7 ms in 100% of frames; raster within 16.7 ms in 80.3%. Later the same test on the same code gave raster 7% to 14%, and a plain `ListView` of text with no app code gave 0% (checked with a throw-away test), so the emulator's graphics speed changed between sessions. Emulator raster numbers are therefore not usable for AC-4. Build times stayed at 100% (worst 12 to 29 ms). Not passed: needs the reference device, which is not chosen.

### TC-020: Verify no entry text is visible

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-002 (AC-5) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** The app is locked. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the timeline would be shown | synthetic | No entry text is visible |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart`: passed on the emulator, 2026-09-20 (after the app locks, no entry text is in the screen tree). Real app-switcher behaviour not checked. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Recent-apps view shows no entry text.

