# Test cases: FEAT-008 Export reminder

Plan: TP-001. Cases `TC-068` to `TC-074`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-068: Verify the reminder is shown

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-008 (AC-1) |
| Other links | RISK-001 |
| Level | unit |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** No export was ever made and the journal has entries. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the timeline opens | synthetic | The reminder is shown |



Execution log: Automated, `app/test/reminder_test.dart` (rule) and `app/integration_test/feat008_reminder_ui_test.dart` (emulator): passed, 2026-09-20.

### TC-069: Verify no reminder is shown

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-008 (AC-2) |
| Other links | RISK-001 |
| Level | unit |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A recent export and no new entries since. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the timeline opens | synthetic | No reminder is shown |



Execution log: Automated, `app/test/reminder_test.dart` and `app/integration_test/feat008_reminder_ui_test.dart`: passed, 2026-09-20 (a recent export with nothing new since shows nothing).

### TC-070: Verify the reminder is shown

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-008 (AC-3) |
| Other links | RISK-001 |
| Level | unit |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** The last export is too old and new entries exist. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the timeline opens | synthetic | The reminder is shown |



Execution log: Automated, `app/test/reminder_test.dart` and `app/integration_test/feat008_reminder_ui_test.dart`: passed, 2026-09-20 (45 days after the export, with a new entry). Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Clock moved 31 days after an export and a new entry: the reminder card appeared and held no entry text. The other reminder cases (TC-068, TC-069) were not in the phone run.

### TC-071: Verify the reminder is hidden for the snooze period

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-008 (AC-4) |
| Other links | RISK-001 |
| Level | unit |
| Priority | P2 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The reminder is shown. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user dismisses it | synthetic | The reminder is hidden for the snooze period |



Execution log: Automated, `app/test/reminder_test.dart` and `app/integration_test/feat008_reminder_ui_test.dart`: passed, 2026-09-20 (hidden after Later, still hidden six days later, back on the seventh day after). The clock is faked; the check runs when the timeline opens.

### TC-072: Verify the reminder disappears

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-008 (AC-5) |
| Other links | RISK-001 |
| Level | unit |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A successful export. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the export completes | synthetic | The reminder disappears |



Execution log: Automated, `app/integration_test/feat008_reminder_ui_test.dart`: passed on the emulator, 2026-09-20 (after an export started from the reminder, it is gone).

### TC-073: Verify the reminder contains no entry text

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-008 (AC-6) |
| Other links | RISK-001 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The reminder. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the reminder is shown | synthetic | The reminder contains no entry text |



Execution log: Automated, `app/integration_test/feat008_reminder_ui_test.dart`: passed on the emulator, 2026-09-20 (the card holds exactly its title, body and two buttons; the entry text is not in it).

### TC-074: Verify the reminder is not shown at exactly 30 days and is shown a day later

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-008 (AC-7) |
| Other links | FEAT-008 question 1 |
| Level | unit |
| Priority | P2 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The thresholds are decided: more than 30 days, dismissed for 7 days. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Set the last export exactly 30 days ago with new entries, and open the timeline | synthetic | No reminder is shown |
| 2 | Move the clock forward one day and open the timeline | synthetic | The reminder is shown |
| 3 | Dismiss it and move the clock forward 6 days, then 7 days | synthetic | Hidden after 6 days; shown again after 7 days |



Note: Includes a clock or time-zone change.

Execution log: Automated, `app/test/reminder_test.dart`: passed on the host, 2026-09-20 (exactly 30 calendar days: not shown; one day later: shown; time of day does not move the boundary).

