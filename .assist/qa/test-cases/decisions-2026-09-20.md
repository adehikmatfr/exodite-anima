# Test cases added after the owner's decisions

Plan: TP-001. Cases `TC-092` to `TC-102`. Written on 2026-09-20 for the acceptance criteria added when the owner answered the open questions (passcode and wait rules, screenshot blocking, matching, export password, import merge, languages, migration safety, and the journal-cannot-be-opened state). Nothing is executed yet.

### TC-092: Verify a message says nothing was deleted and offers Try again and Import your journal

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-9) |
| Other links | ADR-006, RISK-001, THR-010 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A test build with a deliberately damaged database file. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Start the app and unlock | synthetic | A message says nothing was deleted and offers Try again and Import your journal |
| 2 | Choose Try again | synthetic | The app tries to open the journal again and shows the same message while the file is damaged |



Execution log: Automated, `app/integration_test/feat001_ui_test.dart` (emulator) and the storage tests: passed, 2026-09-20 (a key that does not match shows screen S14: 'nothing has been deleted', Try again and Import your journal; the file is unchanged). A damaged file is refused and kept at storage level.

### TC-093: Verify the wait after five wrong passcodes is 30 seconds and doubles up to one hour

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-9) |
| Other links | THR-007 |
| Level | integration |
| Priority | P0 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The lock screen with a controllable clock. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Enter five wrong passcodes, one after the other | synthetic | Each is refused and the next attempt is allowed at once |
| 2 | Enter a sixth wrong passcode | synthetic | The next attempt is blocked for 30 seconds |
| 3 | After each wait, enter another wrong passcode until the wait stops growing | synthetic | The waits are 30 s, 60 s, 120 s, and so on, and never exceed one hour |



Execution log: Automated, unit and screen tests: passed, 2026-09-20 (five free tries, then 30 s, doubling to one hour). Limit: the wait uses the phone clock, so changing the clock shortens it.

### TC-094: Verify screenshots and screen recording are blocked on Android

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-11) |
| Other links | THR-004 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | manual |
| Status | active |
| Owner | qa |

**Preconditions:** An Android device or emulator with the journal open. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Take a screenshot and start a screen recording | synthetic | The capture is blocked, blank, or refused by the system |



Execution log: Partial, 2026-09-20: on a release build installed on the emulator, `adb shell screencap` returned an empty image (blocked); a debug build allows capture on purpose. Screen recording and other capture tools were not tried. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Screenshot blocked and the system screen recorder showed black.

### TC-095: Verify search matches from the start of a word only

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-8) |
| Other links |  |
| Level | integration |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry that contains the word river. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Search for riv | synthetic | The entry is listed |
| 2 | Search for iver | synthetic | The entry is not listed |



Execution log: Automated, `app/test/search_test.dart` and `app/integration_test/feat005_search_ui_test.dart`: passed, 2026-09-20 (riv finds river; iver, ver and driver do not).

### TC-096: Verify an export password shorter than 8 characters is refused

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-006 (AC-9) |
| Other links | THR-007 |
| Level | unit |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The export password step. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Enter a 7-character password and continue | synthetic | It is refused with a reason and no file is created |
| 2 | Enter an 8-character password and continue | synthetic | It is accepted |



Execution log: Automated, `app/integration_test/feat006_007_ui_test.dart`: passed on the emulator, 2026-09-20 (Export stays disabled for a short password and no file is created).

### TC-097: Verify an entry already on the phone is kept unchanged and counted as skipped

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-8) |
| Other links | RISK-002 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry with the same id but different text exists on the phone and in the export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Import the export | synthetic | The entry on the phone is unchanged, and the result counts it as skipped |



Execution log: Automated, `app/test/backup_test.dart` and `app/integration_test/feat006_007_ui_test.dart`: passed, 2026-09-20 (the entry already on the phone is kept and counted as skipped).

### TC-098: Verify choosing Indonesian switches all app text and keeps the choice after a restart

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-8) |
| Other links |  |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The settings screen with the language on English. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Choose Indonesian | synthetic | All app text is in Indonesian at once |
| 2 | Close and reopen the app | synthetic | The app is still in Indonesian |



Execution log: Automated, `app/test/settings_test.dart` and `app/integration_test/feat009_settings_ui_test.dart`: passed, 2026-09-20 (Settings, the timeline and the lock screen switch at once and after a restart). Not checked: every screen in Indonesian by eye, and the wording (owner review).

### TC-099: Verify a phone in another language starts the app in English

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009 (AC-9) |
| Other links |  |
| Level | e2e |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A phone set to a language that is neither English nor Indonesian, and a fresh install. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Open the app for the first time | synthetic | The app is in English |



Execution log: Automated, `app/test/settings_test.dart` and `app/integration_test/feat009_settings_ui_test.dart`: passed, 2026-09-20 (a phone in French or Japanese starts in English; Indonesian and English are followed).

### TC-100: Verify a failed data migration restores the journal to its state before the update

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-11) |
| Other links | ADR-006, RISK-001, THR-010 |
| Level | resilience |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A fixture database from the previous schema and a hook that forces the migration to fail. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Start the new version so that it migrates and the migration fails | synthetic | The journal is restored from the copy made before the migration |
| 2 | Unlock | synthetic | The journal opens and every entry is intact |



Execution log: not executed (nothing is built yet).

### TC-101: Verify an older app refuses to change a journal saved by a newer version

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001 (AC-10) |
| Other links | ADR-006, THR-010 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A fixture database written by a newer schema than the app knows. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Open it with the older version | synthetic | The app refuses to change it and asks the user to update |
| 2 | Inspect the file | synthetic | The file is unchanged |



Execution log: Partial, `app/test/entry_repository_test.dart`: a journal from a newer schema is not opened and not changed (host and emulator, 2026-09-20). The 'Please update the app' screen exists but was not driven in a screen test.

### TC-102: Verify a passcode is set before a backup is imported on a fresh install

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-007 (AC-9) |
| Other links | ADR-001 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A fresh install. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Choose Import your journal on the welcome screen | synthetic | Passcode setup starts first |
| 2 | Finish setup and choose the file | synthetic | The import starts only after the passcode exists |



Execution log: Automated, `app/integration_test/feat006_007_ui_test.dart`: passed on the emulator, 2026-09-20 (Import your journal on the welcome screen leads to the passcode first, then the import screen).

