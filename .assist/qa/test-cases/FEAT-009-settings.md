# Test cases: FEAT-009 Settings

Plan: TP-001. Cases `TC-075` to `TC-082`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-075: Verify the app switches and keeps the choice after a restart

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-1) |
| Other links | ADR-001, RISK-001, RISK-005 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The settings screen. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user picks a theme | synthetic | The app switches and keeps the choice after a restart |



Execution log: Automated, `app/test/settings_test.dart` and `app/integration_test/feat009_settings_ui_test.dart`: passed, 2026-09-20 (dark, light and follow-the-phone; kept after a restart, including on the lock screen).

### TC-076: Verify the new passcode opens the app

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-2) |
| Other links | ADR-001, RISK-001, RISK-005 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The user knows the current passcode. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: they change it | synthetic | The new passcode opens the app |



Execution log: Automated, `app/test/settings_test.dart` and `app/integration_test/feat009_settings_ui_test.dart`: passed, 2026-09-20.

### TC-077: Verify all entries are still readable

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-3) |
| Other links | ADR-001, RISK-001, RISK-005 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** The user knows the current passcode. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: they change it | synthetic | All entries are still readable |



Execution log: Automated, `app/test/settings_test.dart` and `app/integration_test/feat009_settings_ui_test.dart`: passed, 2026-09-20 (an entry written before the change reads after it; the key does not change). Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Entries readable after the passcode change.

### TC-078: Verify the change is refused

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-4) |
| Other links | ADR-001, RISK-001, RISK-005 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A wrong current passcode. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user tries to change it | synthetic | The change is refused |



Execution log: Automated, `app/test/settings_test.dart` and `app/integration_test/feat009_settings_ui_test.dart`: passed, 2026-09-20 (a wrong current passcode is refused, nothing changes, and it counts as a wrong try with the same wait).

### TC-079: Verify the app locks

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-5) |
| Other links | ADR-001, RISK-001, RISK-005 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A new lock timeout is chosen. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app stays in the background that long | synthetic | The app locks |



Execution log: Automated, `app/integration_test/feat009_settings_ui_test.dart`: passed on the emulator, 2026-09-20 (1 minute: still open after 30 s, locked after 2 min; kept after a restart). Background and return are simulated with lifecycle events and a fake clock.

### TC-080: Verify only the passcode unlocks it

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-6) |
| Other links | ADR-001, RISK-001, RISK-005 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | manual |
| Status | draft |
| Owner | qa |

**Preconditions:** Biometrics are turned off. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app is locked | synthetic | Only the passcode unlocks it |



Execution log: Automated, `app/integration_test/feat009_settings_ui_test.dart`: passed on the emulator, 2026-09-20 (with it off the lock screen offers no shortcut). Uses a fake biometric.

### TC-081: Verify every claim traces to a requirement and a test

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-7) |
| Other links | ADR-001, RISK-001, RISK-005 |
| Level | exploratory |
| Priority | P1 |
| Type | positive |
| Automation | manual |
| Status | draft |
| Owner | qa |

**Preconditions:** The privacy statement. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the privacy statement is reviewed | synthetic | Every claim traces to a requirement and a test |



Execution log: Partial, 2026-09-20: the four claims and what backs each are in `../report/privacy-claims-trace.md`; two of the four rest on manual or partial checks (TC-084 on a release build, no content in logs TC-086). Not passed.

### TC-082: Verify closing the app during a passcode change leaves the journal openable

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | RISK-001, ADR-001 |
| Level | resilience |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A journal and a change of passcode in progress. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Stop the process at each step of the change, then reopen | synthetic | Either the old or the new passcode opens the journal, never neither; all entries are intact |



Execution log: Partial, `app/test/settings_test.dart`: passed on the host, 2026-09-20. The change writes a new file and moves it over the old one, so a leftover half-written file does not stop the old passcode. No real process kill in the middle of the move was tried.

