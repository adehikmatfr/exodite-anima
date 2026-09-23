# Test cases: FEAT-010 Tags, mood, and On this day

Plan: TP-001. Cases `TC-103` to `TC-111`. Written from the acceptance criteria of the spec (one case per criterion). Expected results come from the spec. Updated 2026-09-23: every acceptance criterion (AC-1 to AC-9) is now built - the schema, the repository layer, the editor UI (mood picker, tag input), the timeline's display of mood and tags, export/import, and the screen-privacy fix - and proven at the unit/widget/format level. Nothing has been tested on an emulator or a device, and none of the real screens (`TimelinePage`, `EditorPage`, the export/import pages) has a widget test of its own; every case below stays Partial for that reason.

### TC-103: Verify the mood is saved with the entry and shown next to it in the timeline

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-1) |
| Other links | ADR-002, RISK-001 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The entry editor. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer picks a mood icon from the fixed set, then saves | synthetic | The mood is saved with the entry and shown next to it in the timeline |

Execution log: Partial. Automated, `app/test/entry_repository_test.dart` (repository level): passed, 2026-09-23 (a mood is saved with the entry and read back; `watchTimeline` carries it and updates when it changes). Automated, `app/test/mood_and_tags_widget_test.dart` (widget level): passed (tapping a mood icon selects it). `TimelinePage`'s display of the mood (`_EntryMeta`, matching the reviewed S6 design) is built but has no widget or emulator test of its own yet - it needs a `KeyVault`/`Biometrics`/`SettingsController` fixture this round did not build.

### TC-104: Verify a mood can be changed to a different one, or cleared

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-2) |
| Other links | RISK-001 |
| Level | e2e |
| Priority | P2 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A saved entry with a mood. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer opens it to edit, changes the mood to a different one, and saves | synthetic | The new mood is kept after saving |
| 2 | Perform: the writer opens it to edit, clears the mood, and saves | synthetic | No mood is shown for that entry |

Execution log: Partial. Automated, `app/test/entry_repository_test.dart`: passed, 2026-09-23 (mood changed to a different one; mood cleared by omitting it). Automated, `app/test/mood_and_tags_widget_test.dart`: passed (tapping the selected mood again clears it in the picker). Not done: no emulator or device run.

### TC-105: Verify tags from the preset list, free text, or both are saved and shown

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-3) |
| Other links | ADR-002, RISK-001 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The entry editor. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer adds a preset tag, a free-text tag, and both together, then saves | synthetic | Every tag is saved with the entry and shown next to it in the timeline |

Execution log: Partial. Automated, `app/test/entry_repository_test.dart`: passed, 2026-09-23 (preset, free text, and both together are saved and read back; the same tag name is stored once and shared, not duplicated; `watchTimeline` carries every tag, including one containing a comma, without splitting it wrongly, and updates when a tag changes). Automated, `app/test/mood_and_tags_widget_test.dart`: passed (tapping a preset chip adds it; typing through "Add a tag" adds a free-text one). `TimelinePage`'s display of tags (`_EntryMeta`, matching the reviewed S6 design) is built but has no widget or emulator test of its own yet.

### TC-106: Verify removing a tag stops it showing on the entry

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-4) |
| Other links | RISK-001 |
| Level | e2e |
| Priority | P2 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A saved entry with a tag. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer removes the tag and saves | synthetic | The tag no longer shows on that entry |

Execution log: Partial. Automated, `app/test/entry_repository_test.dart`: passed, 2026-09-23 (removing a tag on save stops it showing on that entry). Automated, `app/test/mood_and_tags_widget_test.dart`: passed (tapping a selected tag chip again removes it). Not done: no emulator or device run.

### TC-107: Verify the "On this day" card shows an entry from every matching previous year

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-5) |
| Other links | RISK-001 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** Entries exist for the same calendar day in more than one previous year. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer opens the timeline | synthetic | The "On this day" card shows an entry from every one of those years, each with its original date |

Execution log: Automated, `app/test/entry_repository_test.dart` (repository level, host): passed, 2026-09-23 (entries from two earlier years on the same month-day are both returned, most recent year first; an entry on the same day but a different month-day is excluded). Partial: the UI (`app/lib/journal/timeline_page.dart`, `_OnThisDayCard`) is built and wired to this query, but not yet exercised by a widget or emulator test, so the visible card, its tap-to-open behaviour, and its accessibility announcement are not yet proven end to end.

### TC-108: Verify no "On this day" card is shown when there is no match

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-6) |
| Other links | none |
| Level | e2e |
| Priority | P2 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** No entry exists for the same calendar day in any previous year. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer opens the timeline | synthetic | No "On this day" card is shown |

Execution log: Automated, `app/test/entry_repository_test.dart` (repository level, host): passed, 2026-09-23 (only an entry from today itself, same year: the query returns nothing). Partial, same limit as TC-107: the UI shows no card when the query is empty (`SizedBox.shrink()`), but this is not yet exercised by a widget or emulator test.

### TC-109: Verify an export includes an entry's mood and tags

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-7) |
| Other links | ADR-003, RISK-002 |
| Level | integration |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry with a mood and tags. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer exports the journal | synthetic | The export archive includes that entry's mood and tags |

Execution log: Automated, `app/test/backup_test.dart`: passed, 2026-09-23 (an entry's `mood` and `tags` are written into `entries.json`, present only when set; verified at the format level). No emulator or device run yet, so the real "writer exports the journal" action through the app UI is untested.

### TC-110: Verify mood and tags round-trip exactly through export and import

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-8) |
| Other links | ADR-003, RISK-002 |
| Level | integration |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An export archive that includes mood and tags. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer imports it | synthetic | Every entry's mood and tags match the exported values exactly |

Execution log: Automated, `app/test/backup_test.dart`: passed, 2026-09-23, at two levels: format only (mood and tags decode back exactly, including a tag containing a comma, and an archive with neither field imports with neither set), and through two separate real journal databases (export from one, import into the other, mood and tags match exactly). No emulator or device run yet.

### TC-111: Verify no mood or tag content is visible while locked or backgrounded

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-010 (AC-9) |
| Other links | FEAT-003, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The app is locked. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: a locked or backgrounded screen is shown | synthetic | No entry text, mood, or tag content from "On this day" or the timeline is visible, per FEAT-003 |

Execution log: Partial, 2026-09-23. Checking this surfaced a real gap in FEAT-003's privacy cover (`app/lib/main.dart`): it painted over the screen but did not remove it from the accessibility tree, so a screen reader could still reach entry text - and, by the same mechanism, mood and tags - while backgrounded. Verified against the real assembled semantics tree (not the widget tree, which gave a false negative) with a minimal reproduction, then fixed by wrapping the cover in `BlockSemantics`. See `cyber-security/report/threat-model-v1.md` (THR-004 update) and `qa/test-cases/FEAT-003-app-lock.md` (TC-023 correction) for the full account. No automated test in the suite covers the fix directly (a full-app widget test hung in this environment); visual hiding was already covered by TC-023's phone result, but the screen-reader half was not, for any screen, until now.
