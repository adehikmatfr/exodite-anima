# FEAT-010: Tags, mood, and On this day

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature), rollout detail (follows the existing staged-rollout pattern, decision `v1-rollout-plan`).

| Field | Value |
|-------|-------|
| ID | FEAT-010 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-23 |
| Priority score | Not scored (relative sizing only, T1). Owner decided it ships bundled with photos in the "Next" roadmap horizon (v1.1), `context.md` |
| Related capability | none (new) |
| Related IDs | ADR-002, ADR-003, ADR-006, RISK-001, RISK-002, FEAT-001, FEAT-002, FEAT-003, FEAT-006, FEAT-007 |

## Problem
Today an entry is plain text with a date; there is no way to mark how the writer felt or what an entry was about, and no way to be shown what was written on the same calendar day in a previous year. Journal writers who keep writing over years lose an easy way to notice emotional patterns or rediscover old entries without scrolling the whole timeline.

Evidence: none yet; this is a hypothesis carried in the roadmap ("Later: tags, mood, favourites...", `context.md`), not a measured user request. The product has no users and collects no usage data.

## Users
| Segment | Need | How they meet this feature |
|---------|------|----------------------------|
| Journal writer (primary, hypothesis) | Notice patterns over time and reconnect with past entries, without any of it leaving the device | Tags and mood on each entry; an "On this day" view in the timeline |

## Goals
- A journal writer can mark an entry's mood using an icon, and add tags (from a preset list or free text), at write time or later.
- A journal writer is shown every entry written on the same calendar day in any previous year, if any exist.
- Mood and tags survive an export/import round trip exactly (product principle 2: the user owns the data).

## Non-goals
- Filtering or searching entries by mood or tag (a possible later `FEAT-`; FEAT-005 Search is unchanged by this spec).
- Any aggregated statistics, charts, or mood trends.
- Any automatic mood or tag suggestion (on-device ML/NLP or otherwise).
- Any server-side or cross-device sync of tags or mood; export/import remains the only way to move them (product principle 1).

## Proposed behaviour
1. In the entry editor, the writer can optionally pick one mood icon from a fixed, small set, and add zero or more tags, each either chosen from a preset list or typed as free text.
2. The timeline shows the mood icon and tags next to each entry that has them; entries without either show as today.
3. The writer can change or clear an entry's mood, and add or remove its tags, at any time after saving, the same way they edit entry text.
4. When the timeline is opened, if one or more entries exist for the same calendar day in any previous year, an "On this day" card appears showing all of them, each with its original date; tapping one opens it.
5. If no entry exists for the same calendar day in any previous year, no "On this day" card appears (no empty-state card).
6. Mood and tags are entry content: covered by the same lock, screen-privacy (FEAT-003), and no-logging/no-clipboard rules as entry text.
7. Export and import (FEAT-006, FEAT-007) carry mood and tags for every entry; an import restores them exactly.

## User stories
- As a journal writer, I want to tag an entry with my mood, so that I can look back and notice patterns over time.
- As a journal writer, I want to be shown entries from this day in past years, so that I can reconnect with what I was writing about before.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases assigned by qa on 2026-09-23 (`TP-001`, `qa/test-cases/FEAT-010-tags-mood-and-on-this-day.md`). Updated 2026-09-23: every criterion (AC-1 to AC-9) is now built and holds at the repository/unit/widget/format level (all nine `TC-`s Partial in `TP-001`); none is proven by a widget or emulator test of the real screens yet.

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | The entry editor | The writer picks a mood icon from the fixed set | The mood is saved with the entry and shown next to it in the timeline | TC-103 |
| AC-2 | A saved entry with a mood | The writer opens it to edit | They can change the mood to a different one, or clear it, and the change is kept after saving | TC-104 |
| AC-3 | The entry editor | The writer adds one or more tags, from the preset list, typed as free text, or both | The tags are saved with the entry and shown next to it in the timeline | TC-105 |
| AC-4 | A saved entry with a tag | The writer removes the tag and saves | The tag no longer shows on that entry | TC-106 |
| AC-5 | Entries exist for the same calendar day in more than one previous year | The writer opens the timeline | The "On this day" card shows an entry from every one of those years, each with its original date | TC-107 |
| AC-6 | No entry exists for the same calendar day in any previous year | The writer opens the timeline | No "On this day" card is shown | TC-108 |
| AC-7 | An entry with a mood and tags | The writer exports the journal | The export archive includes that entry's mood and tags | TC-109 |
| AC-8 | An export archive that includes mood and tags | The writer imports it | Every entry's mood and tags match the exported values exactly | TC-110 |
| AC-9 | The app is locked | A locked or backgrounded screen is shown | No entry text, mood, or tag content from "On this day" or the timeline is visible, per FEAT-003 | TC-111 |

## NFR and compliance impact
| Area | Requirement | Source |
|------|-------------|--------|
| Security / privacy | Mood and tag text is journal content: Restricted data, same classification and handling as entry text (no logs, no clipboard, no notifications, encrypted at rest) | `project.md` principle 1, ADR-001, ADR-002, FEAT-003 |
| Data integrity | Adding mood and tags is a database schema change; must follow the migration safety rules before it ships | ADR-006, RISK-001 |
| Compatibility | The export archive's `schemaVersion` must be bumped and a migration/round-trip path defined so older exports without mood and tags still import | ADR-003, RISK-002 |
| Accessibility (optional) | Mood indicators need a text alternative (not colour or icon alone), meeting WCAG 2.2 AA | `compliance-matrix.md` (WCAG row) |
| Compliance | No new trigger beyond existing entry content handling (`compliance-matrix.md`); mood and tags are Restricted data under the same rules as entry text | `compliance-matrix.md` |
| Security review | Reviewed by cyber-security 2026-09-23: no new `THR-` or trust boundary; covered by THR-001, THR-002, THR-004, THR-006, THR-013; THR-010 (migration) is the one this feature actually exercises for the first time | `cyber-security/report/threat-model-v1.md` (Update 2026-09-23) |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|--------|-----------|----------|--------|-----------|--------------------|
| Tag/mood round-trip integrity | Entries whose mood or tags differ after export then import, found by test | none (feature does not exist yet) | 0 | must not regress the existing export round-trip guardrail in `context.md` | Automated tests before each release, owned by qa |

## Rollout
Ships bundled with photos in v1.1 (owner decision, 2026-09-23; see Decisions), not with v1. Staging detail is not yet planned; follows the existing staged-rollout pattern (decision `v1-rollout-plan`) once the v1.1 rollout is defined. Rollback means halting the rollout and shipping a build without the new schema fields active.

## Risks
| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|-----------|--------|-----------|-------|
| RISK-001 | User loses data if the schema migration adding mood/tags is mishandled | L | H | Follow ADR-006 (copy before migrate, restore on failure) before this ships | software-architect |
| RISK-002 | An export made after this ships cannot be read by an older app version, or an old export cannot be told apart from a new one | M | M | Bump the export `schemaVersion`; define and test the migration path per `project.md` ("every persisted format is versioned") | software-architect |

## Dependencies
- FEAT-001 (entry management): this spec extends the entry data model.
- FEAT-002 (timeline): displays mood, tags, and the "On this day" card.
- FEAT-003 (app lock and screen privacy): the privacy rules extend to the new content.
- FEAT-006, FEAT-007 (export, import): must carry the new fields and round-trip them.
- software-architect read received (2026-09-23): `journalSchemaVersion` moves 1 -> 2 (nullable `mood` column; a normalized `tags` table plus join table, not a delimited string); manifest `schemaVersion` moves to 2; export `formatVersion` stays 1 (additive fields, ignored by older readers per ADR-003 rule 2). Recorded as updates to ADR-002 and ADR-003, not a new ADR. This is the first schema step to actually exercise ADR-006's migration safety rules, which frontend-mobile has not yet implemented.
- Effort read from frontend-mobile received (2026-09-23, `frontend-mobile/report/effort-read-v1.md`): size L, relative, low confidence (no spike run for the ADR-006 implementation yet). The size is driven mainly by ADR-006's safety rules being implemented for the first time, not by the mood/tag UI on its own, which would be M alone.

## Decisions
- Mood is shown as an icon, not a text label alone (owner, 2026-09-23).
- Tags support both a preset list and free text, not one or the other (owner, 2026-09-23).
- This feature ships bundled with photos in v1.1, not on its own (owner, 2026-09-23); roadmap in `context.md` updated to place FEAT-010 in the "Next" horizon with photos.
- "On this day" shows an entry from every previous year that has one for that calendar day, not only the nearest (owner, 2026-09-23).
- Mood icon set (owner asked product-manager to pick the best option, 2026-09-23): a 5-point scale, the convention used by established mood-journaling apps, each with a mandatory text label for accessibility (per the NFR row above) and drawn from Lucide (the icon set already decided for this project, `project.md`). This is a product proposal, not a measured fact; product-design confirms it renders correctly when FEAT-010 reaches design (`figma`/`.pen` workflow) and the owner can still change it before `ready`.

  | Mood | Lucide icon | Text label |
  |------|------------|------------|
  | Great | `laugh` | "Great" |
  | Good | `smile` | "Good" |
  | Okay | `meh` | "Okay" |
  | Bad | `frown` | "Bad" |
  | Awful | `angry` | "Awful" |

- Preset tag list (owner asked product-manager to pick the best option, 2026-09-23): eight broad, non-overlapping topics common to personal journals, short enough to fit on one row and leave the rest to free text: Work, Family, Relationships, Health, Travel, Gratitude, Goals, Reflection. Same status as the icon set: a proposal, confirmed at design time, changeable before `ready`.

## Open questions
None. Questions 1 to 6 were all closed by the owner on 2026-09-23; see Decisions. The mood icon set and preset tag list were product-manager proposals; product-design confirmed both render correctly when it drew S6 and S7 (`docs/screen-specs.md`, 2026-09-23), and the owner approved those previews before the matching code was built.

## Estimate and hand-off (optional)
- Effort read from engineering: size L, relative, low confidence (frontend-mobile, 2026-09-23; see Dependencies).
- Hand-off date: 2026-09-23, on the owner's confirmation (see Status log). Built by frontend-mobile since: the schema step, the repository layer, the editor UI, the timeline display, and export/import (AC-1 to AC-9, all Partial in `TP-001`). Not yet done: any widget or emulator test of the real screens.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-23 | draft | Created at the owner's request, as a candidate feature for the roadmap's "Later" horizon (tags, mood); not yet prioritised or sized |
| 2026-09-23 | draft | Owner answered open questions 1 to 4: mood is icon-based, tags support both preset and free text, ships bundled with photos in v1.1, "On this day" shows every past year with an entry. Two new open questions raised (exact icon set, exact preset tag list); still blocked on a software-architect read and an effort read before `ready` |
| 2026-09-23 | draft | Owner asked product-manager to pick the best option for the two remaining open questions. Proposed a 5-point mood scale (Great/Good/Okay/Bad/Awful, Lucide icons) and an 8-item preset tag list (Work, Family, Relationships, Health, Travel, Gratitude, Goals, Reflection); both are proposals to be confirmed by product-design, not measured facts. No open questions remain; still blocked on a software-architect read (schema/export version) and an effort read before `ready` |
| 2026-09-23 | draft | Software-architect read received: schema step (`journalSchemaVersion` 1 -> 2, nullable `mood`, normalized `tags` table), manifest `schemaVersion` 2, export `formatVersion` unchanged at 1; recorded as updates to ADR-002 and ADR-003. This is the first migration to exercise ADR-006's safety rules, which are not yet implemented. Only blocker left before `ready`: an effort read from frontend-mobile |
| 2026-09-23 | draft | Effort read received from frontend-mobile: size L (`frontend-mobile/report/effort-read-v1.md`), driven by ADR-006's migration safety rules being implemented for the first time, not by the mood/tag UI alone. Every `write-feature-spec` readiness-checklist item is now satisfied; this spec is ready to move to `ready` on the owner's confirmation |
| 2026-09-23 | ready | Owner confirmed. Hand-off: FEAT-006, FEAT-007 (export/import fields), FEAT-002 (timeline display), FEAT-003 (screen privacy) for build alongside frontend-mobile's ADR-006 implementation; qa to derive `TC-` from AC-1 to AC-9 (`TP-001`) once build starts |
| 2026-09-23 | ready | Cyber-security review completed (personal-data hand-off trigger): no new `THR-` or trust boundary; covered by THR-001, THR-002, THR-004, THR-006, THR-013, and THR-010 for the migration (`cyber-security/report/threat-model-v1.md`, Update 2026-09-23). Remaining work before build is unchanged: ux-design flow and product-design screens (G2), then qa test cases (G3), then frontend-mobile build with ADR-006 implemented (G4) |
| 2026-09-23 | ready | ADR-006's generic migration-safety mechanism is now implemented and tested (see FEAT-001 status log), lowering FEAT-010's build risk. UX flow F8 added (`ux-design/report/user-flows.md`), covering mood/tag editing and the "On this day" card, with an accessibility note that the mood icon's text label must reach screen readers. Product-design added FEAT-010 rows and states to the existing S6 Timeline and S7 Editor specs rather than new screens (`product-design/docs/screen-specs.md`); the `.pen` design files themselves are not yet regenerated. QA assigned TC-103 to TC-111 for AC-1 to AC-9 (`qa/test-cases/FEAT-010-tags-mood-and-on-this-day.md`, `TP-001`), none executed since the feature is not built. Remaining before build (G4): the actual schema `onUpgrade` step, editor/timeline UI, and export/import fields |
| 2026-09-23 | ready | Built AC-5 and AC-6 ("On this day"), the one slice of FEAT-010 that needs no schema change: `EntryRepository.watchOnThisDay` (`app/lib/data/entry_repository.dart`) and the `_OnThisDayCard` widget in the timeline (`app/lib/journal/timeline_page.dart`), following S6's updated spec and flow F8's ordering proposal (most recent year first). Proven at the repository level by 3 new tests in `app/test/entry_repository_test.dart` (TC-107, TC-108 now Partial, from not run); `flutter analyze` clean, full suite 107 tests passing. Not yet proven end to end (no widget or emulator test), and AC-1 to AC-4 and AC-7 to AC-9 (mood, tags, export/import) still need the schema step, which was not started this round |
| 2026-09-23 | ready | Correction, caught by the owner: the row above skipped gate G2 in practice - `screen-specs.md` was edited with text describing the "On this day" card, but the actual `.pen` design file was left un-regenerated while the code was already built, so there was nothing visual for the owner to review before the build happened. Fixed out of order: `product-design/tools/gen_screens.py` now draws "S6 Timeline / With On this day" and it was self-checked by rendering both themes to PNG. The owner has not yet looked at that preview; G2 for this slice is not truly closed until they do, even though the code already matches it |
| 2026-09-23 | ready | Owner reviewed the "S6 Timeline / With On this day" preview (both themes, shown inline in the session) and approved it. G2 for AC-5, AC-6 is now genuinely closed, in the right order this time. Still open for the rest of FEAT-010: S7's mood picker and tag input have no design yet, and the schema step, editor UI, and export/import are not built |
| 2026-09-23 | ready | Drew S7 "Mood and tags" (`product-design/tools/gen_screens.py`, changelog 0.4) for AC-1 to AC-4, this time before any code: mood as a circle with its mandatory text label (real Lucide icon codepoints for laugh/smile/meh/frown/angry verified against `lucide-static@1.47.0`'s own `font/info.json`, not yet used in code) and tag chips (preset plus one free-text example) wrapping across rows. Self-checked by rendering both themes to PNG. Awaiting the owner's review of this preview before G2 for AC-1 to AC-4 closes and the schema/editor build can start |
| 2026-09-23 | ready | Owner reviewed the "S7 Mood and tags" preview (both themes) and moved on ("next"), taken as approval. G2 for AC-1 to AC-4 is closed. The schema step (`journalSchemaVersion` 1 -> 2, `mood` column, `tags`/`entry_tags` tables, a real `onUpgrade`) and the editor UI are next, in that order, since the UI needs somewhere to save to |
| 2026-09-23 | ready | Built the schema step (ADR-002 update), the repository layer (`EntryRepository.create/update` take `mood` and `tags`; `Tags`/`EntryTags` tables), and the editor UI (`MoodPicker`, `TagInput` in `app/lib/journal/mood_and_tags.dart`, wired into `editor_page.dart`), matching the reviewed design. A genuine schema-1 fixture (hand-built, no schema-snapshot tooling exists here) proves the real migration keeps old data and adds no mood or tags to it. `flutter analyze` clean; suite now 116 tests (unit and widget level). AC-1 to AC-4 are Partial (TC-103 to TC-106): saving, changing, and clearing mood and tags all work, but the timeline does not show them on an entry yet, and nothing has run on an emulator or a device. Real Lucide icon code points (laugh, smile, meh, frown, angry) verified against the bundled font's own metadata, added to `app_icons.dart` and the asset register. AC-7 to AC-9 (export/import, screen privacy) remain unbuilt |
| 2026-09-23 | ready | Design-first again, before any timeline code: drew S6 "With mood and tags" (`product-design/tools/gen_screens.py`, changelog 0.5) for the "shown next to it in the timeline" half of AC-1 and AC-3 - a mood dot plus its text label, and read-only tag chips, on one entry, with a second entry showing neither. Self-checked by rendering both themes to PNG. Awaiting the owner's review of this preview before the timeline UI is built |
| 2026-09-23 | ready | Owner moved on ("next"), taken as approval of the preview. Built the timeline display: `EntryRepository.watchTimeline` now reads each entry's `mood` and its tags (via a `GROUP_CONCAT` subquery, joined on `entry_tags`/`tags`, with a control-character separator so a comma inside a free-text tag is never split wrongly), and `TimelinePage`'s `_EntryMeta` widget shows the mood dot-plus-label and read-only tag chips next to an entry, matching the reviewed design. Proven at the repository level, including that the stream updates when a tag changes and not just when the text does (`app/test/entry_repository_test.dart`, 3 new tests; suite now 119). AC-1 and AC-3 are now fully built in code, but still Partial in `TP-001`: there is no widget or emulator test of `TimelinePage` itself yet (it needs a `KeyVault`/`Biometrics`/`SettingsController` fixture this session did not build) |
| 2026-09-23 | ready | Built export/import (AC-7, AC-8): `entries.json` now carries `mood` (the enum's name, e.g. `"good"`, not its numeric index, so an independent reader stays self-describing) and `tags` (a string array), both present only when set, per the ADR-003 update. An unrecognised mood name is dropped, not refused, on import. `EntryRepository.readAllForExport`/`importEntries` carry the fields into and out of a real database. Proven with 3 new tests in `app/test/backup_test.dart` (format-level round trip including a comma inside a tag and a no-meta archive; a full round trip through two separate real journals) - suite now 122, `flutter analyze` clean. `docs/export-format.md` updated with the concrete field shapes. AC-9 (screen privacy hides mood and tags too) and any widget or emulator test remain not done |
| 2026-09-23 | ready | Checking AC-9 found a real, pre-existing gap in FEAT-003's privacy cover, not created by FEAT-010: it hid content visually but never removed it from the accessibility tree, so a screen reader could still reach the covered screen while it was backgrounded. Verified against the real assembled semantics tree (a first check with the wrong finder gave a false negative), then fixed in `app/lib/main.dart` with `BlockSemantics`. `flutter analyze` clean, full suite (122 tests) unaffected. No automated test guards the fix - a full-app widget test hung in this environment (likely a platform-channel call blocking with no device or mock) and was removed rather than left flaky. Recorded in `cyber-security/report/threat-model-v1.md` (THR-004), `qa/test-cases/FEAT-003-app-lock.md` (TC-023 correction), and `qa/report/PRR-001-v1-android.md` (row 6), since this reaches back into an already-`Pass`ed v1 case, not just FEAT-010. AC-9 itself is now Partial, the same as the rest of FEAT-010: every acceptance criterion is built, none proven by a widget or emulator test |
