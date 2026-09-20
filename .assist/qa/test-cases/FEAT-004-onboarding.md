# Test cases: FEAT-004 Onboarding and passcode setup

Plan: TP-001. Cases `TC-032` to `TC-039`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-032: Verify the timeline cannot be reached

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (AC-1) |
| Other links | ADR-001, RISK-001, THR-011 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** First launch. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: no passcode has been set | synthetic | The timeline cannot be reached |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart`: passed on the emulator, 2026-09-20.

### TC-033: Verify an error is shown and setup does not continue

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (AC-2) |
| Other links | ADR-001, RISK-001, THR-011 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The passcode step. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the confirmation does not match | synthetic | An error is shown and setup does not continue |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart`: passed on the emulator, 2026-09-20.

### TC-034: Verify an error explains the rule and setup does not continue

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (AC-3) |
| Other links | ADR-001, RISK-001, THR-011 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The passcode step. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the passcode does not meet the passcode rules | synthetic | An error explains the rule and setup does not continue |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart`: passed on the emulator, 2026-09-20.

### TC-035: Verify setup cannot be completed

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (AC-4) |
| Other links | ADR-001, RISK-001, THR-011 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The warning step. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user has not acknowledged it | synthetic | Setup cannot be completed |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart`: passed on the emulator, 2026-09-20; also checked that no vault file exists before the user starts.

### TC-036: Verify the lock screen appears and the passcode opens the empty journal

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (AC-5) |
| Other links | ADR-001, RISK-001, THR-011 |
| Level | resilience |
| Priority | P0 |
| Type | recovery |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** Setup is completed. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the app is closed and opened again | synthetic | The lock screen appears and the passcode opens the empty journal |



Execution log: Automated, `app/integration_test/feat003_004_ui_test.dart`: passed on the emulator, 2026-09-20 (after setup, a restarted app locks and the passcode opens the empty journal).

### TC-037: Verify every claim traces to a requirement and a test

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (AC-6) |
| Other links | ADR-001, RISK-001, THR-011 |
| Level | exploratory |
| Priority | P1 |
| Type | positive |
| Automation | manual |
| Status | draft |
| Owner | qa |

**Preconditions:** The onboarding text. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the onboarding text is reviewed against the privacy statements | synthetic | Every claim traces to a requirement and a test |



Execution log: not executed (nothing is built yet).

### TC-038: Verify passcodes below, at, and above the minimum length and common passcodes are handled by the rules

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (AC-7) |
| Other links | THR-007 |
| Level | unit |
| Priority | P0 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The passcode rules are decided: at least 8 characters and a refusal list of very common passcodes. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Enter a 7-character passcode, an 8-character passcode, a very common passcode, one containing spaces, and one with non-Latin characters | synthetic | The 7-character and the common passcode are refused with a reason; the 8-character, the one with spaces, and the non-Latin one (8 or more characters) are accepted |



Note: The refusal list contents are chosen at implementation; the test uses entries from that list.

Execution log: Automated, unit and screen tests: passed, 2026-09-20. The list of very common passcodes is a short built-in floor, to be replaced by a vetted list.

### TC-039: Verify closing the app before acknowledging the warning leaves nothing stored

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-011 |
| Level | resilience |
| Priority | P1 |
| Type | recovery |
| Automation | planned |
| Status | blocked |
| Owner | qa |

**Preconditions:** First launch, at the no-recovery warning step. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Force-close the app, then open it again | synthetic | Setup starts again from the welcome screen and no passcode or journal exists |

Note: Depends on the proposal in the flow review (F1); blocked until confirmed.

Execution log: not executed (nothing is built yet).

