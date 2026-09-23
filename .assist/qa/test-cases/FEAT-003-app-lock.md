# Test cases: FEAT-003 App lock and screen privacy

Plan: TP-001. Cases `TC-021` to `TC-031`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-021: Verify the lock screen appears with no entries visible

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-1) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The app was closed. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app is opened | synthetic | The lock screen appears with no entries visible |



Execution log: Automated, screen test `app/integration_test/feat003_004_ui_test.dart`: passed on the Android emulator, 2026-09-20 (a restarted app shows the lock screen with no entry text).

### TC-022: Verify the app is locked when the user returns

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-2) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** The app is unlocked. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app stays in the background longer than the timeout | synthetic | The app is locked when the user returns |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart`: passed on the emulator, 2026-09-20 with the background and return simulated through lifecycle events and a fake clock, for the default (lock immediately) and a one-minute timeout. Not run with a real app switch on a device. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Real app switch: locked on return.

### TC-023: Verify no entry content is visible in the preview

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-3) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | manual |
| Status | active |
| Owner | qa |

**Preconditions:** The app is unlocked. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user opens the app switcher | synthetic | No entry content is visible in the preview |



Execution log: Partial, 2026-09-20: the app covers its content as soon as it becomes inactive (screen test passed on the emulator). The Android recent-apps preview and the iOS app-switcher snapshot were not looked at; a release build sets the secure-window flag. Not passed. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Android recent-apps preview hides the content. The iOS snapshot is out of scope for version 1 (Android first).

Correction, 2026-09-23 (found while verifying FEAT-010 AC-9): the "Pass" above only checked what is painted, not what a screen reader can reach. A real gap existed the whole time: the privacy cover did not use `BlockSemantics`, so TalkBack/VoiceOver could still read the covered screen's content through the accessibility tree even while nothing was visible. Verified with a minimal reproduction against the real assembled semantics tree (not the widget tree, which gave a false negative at first), then fixed in `app/lib/main.dart`. No automated test covers this in the suite (a full-app widget test hung in this environment and was removed rather than left flaky); the next physical-phone or emulator run of this case should explicitly turn a screen reader on, not just look at the screen.

### TC-024: Verify the passcode field is offered

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-4) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | manual |
| Status | active |
| Owner | qa |

**Preconditions:** The lock screen. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: biometrics are cancelled or fail | synthetic | The passcode field is offered |



Execution log: Partial, 2026-09-20: with a fake biometric that fails, the passcode field is offered and unlocks (screen test on the emulator). The real system prompt was not exercised. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Real biometric prompt cancelled: the passcode field is offered.

### TC-025: Verify the app unlocks

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-5) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The lock screen. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the correct passcode is entered | synthetic | The app unlocks |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart` and `app/test/key_vault_test.dart`: passed on the emulator and the host, 2026-09-20.

### TC-026: Verify the wait before the next attempt grows

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-6) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** The lock screen. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: several wrong passcodes are entered | synthetic | The wait before the next attempt grows |



Execution log: Automated, unit and screen tests: passed, 2026-09-20 (six wrong tries lead to the wait; each further wrong try doubles it). Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Wrong passcodes: the wait appears and grows.

### TC-027: Verify no journal content is visible

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-7) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** Several wrong passcodes were entered. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the wait is running | synthetic | No journal content is visible |



Execution log: Automated, screen test: passed on the emulator, 2026-09-20 (during a wait the field and the Unlock button are disabled and no entry is shown). Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. No journal content during the wait.

### TC-028: Verify the app opens and all entries are intact

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-8) |
| Other links | ADR-001, THR-001, THR-004, THR-007, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | positive |
| Automation | manual |
| Status | active |
| Owner | qa |

**Preconditions:** Another fingerprint or face was added on the device. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user unlocks with the passcode | synthetic | The app opens and all entries are intact |



Execution log: Partial, 2026-09-20: the passcode unlocks when biometrics are turned on (tested with a fake biometric). Adding another fingerprint on a real or emulated device was not tried. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. After adding another fingerprint the passcode opens the app with all entries intact.

### TC-029: Verify the wait after wrong passcodes persists when the app is closed and reopened

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (AC-10) |
| Other links | THR-007 |
| Level | resilience |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** The lock screen with a wait running after several wrong passcodes. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Force-close the app and open it again | synthetic | The wait is still running and has not been reset |



Execution log: Automated, screen and unit tests: passed on the emulator, 2026-09-20; the wait and the count survive a new app instance over the same files. Not tried with a force-stop of the real process. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Force-stop during the wait: the wait continued.

### TC-030: Verify changing the phone clock does not shorten the wait after wrong passcodes

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-007 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | manual |
| Status | active |
| Owner | qa |

**Preconditions:** A wait running after several wrong passcodes. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Move the phone clock forward, then try the passcode | synthetic | The remaining wait is not shortened |



Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Clock moved forward: the wait was not shortened.

### TC-031: Verify unlock after a biometric success meets the latency target on the lowest-tier device

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-003 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | NFR-1 |
| Level | performance |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The lowest-tier device. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Unlock by biometrics 30 times and record the time to the timeline | synthetic | The 95th percentile is within the target |

Note: Measured on the low-end reference device once the owner chooses it; the numbers come from `nfr-targets-v1` and are provisional until measured: unlock to the timeline in at most 1 s (95th percentile).

Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Partial. Biometric unlock felt under one second. Partial: the 95th percentile over 30 tries was not measured, so the target is not confirmed.

