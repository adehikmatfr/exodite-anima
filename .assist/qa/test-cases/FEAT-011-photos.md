# Test cases: FEAT-011 Photos

Plan: TP-001. Cases `TC-112` to `TC-120`. Written from the acceptance criteria of the spec (one case per criterion), after every criterion was built and proven at the unit/widget/format level on 2026-09-23 (schema, encrypted-file layer, repository layer, editor UI, S15 viewer, export/import). Unlike FEAT-010's UI, FEAT-011's own screens (`PhotoStrip`, `PhotoViewerPage`) do have widget tests of their own (`app/test/photo_strip_widget_test.dart`), so several cases below are Partial for a narrower reason: no emulator or device run yet, not "the UI has no test at all."

### TC-112: Verify a photo added from the camera or the library is saved with the entry and shown as a thumbnail

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-1) |
| Other links | ADR-002, RISK-011, RISK-012 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The entry editor. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes; a synthetic image, never a real photo.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer adds a photo from the camera | synthetic image | The photo is saved with the entry and shown as a thumbnail |
| 2 | Perform: the writer adds a photo from the phone's photo library | synthetic image | The photo is saved with the entry and shown as a thumbnail |

Execution log: Partial. Automated, `app/test/media_test.dart` (repository level): passed, 2026-09-23 (`EntryRepository.addPhoto` saves a photo with the entry; `photosFor`/`readPhotoBytes` read it back exactly). Automated, `app/test/photo_strip_widget_test.dart` (widget level): passed (a real photo, added through the repository, renders as a decrypted thumbnail and can be tapped open). `image_picker`'s own camera/library channel is never exercised by these tests (`pickCompressedPhoto` is the untested seam, by design - it needs a real device). Not done: no emulator or device run of the actual camera/library pickers.

### TC-113: Verify tapping a photo's thumbnail opens it full-size

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-2) |
| Other links | none |
| Level | e2e |
| Priority | P2 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry with a photo. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer taps its thumbnail | synthetic | The photo opens full-size (S15 Photo viewer), with its caption if it has one |

Execution log: Automated, `app/test/photo_strip_widget_test.dart`: passed, 2026-09-23 (tapping a thumbnail navigates to `PhotoViewerPage`, which shows the decrypted photo full-size and its caption). Not done: no emulator or device run.

### TC-114: Verify removing a photo stops it showing on the entry, and its file is gone

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-3) |
| Other links | RISK-011 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry with a photo. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer removes the photo (S15's Remove, then confirms) and saves | synthetic | The photo no longer shows on that entry, and its encrypted file is deleted from disk |

Execution log: Partial. Automated, `app/test/media_test.dart`: passed (removing a photo deletes both its row and its file). Automated, `app/test/photo_strip_widget_test.dart`: passed (the Remove confirmation sheet; cancelling it keeps the photo; confirming it removes the row, its file, and returns to the editor). Not done: no emulator or device run.

### TC-115: Verify deleting an entry deletes its photos for good, the same as its text

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-4) |
| Other links | RISK-011 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry with one or more photos. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer deletes the entry and confirms | synthetic | The entry's photos (rows and files) are deleted for good, the same permanence rule its text already has |

Execution log: Automated, `app/test/media_test.dart`: passed, 2026-09-23 (deleting an entry with two photos deletes both photos' rows and both their files). No emulator or device run yet, so the real delete-confirmation sheet's photo behaviour is untested end to end (the sheet itself, without photos, was already covered by FEAT-001's TC-006/TC-007).

### TC-116: Verify an export includes an entry's photos

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-5) |
| Other links | ADR-003, RISK-002 |
| Level | integration |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry with a photo. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer exports the journal | synthetic | The export archive includes that photo, under `media/`, referenced from the entry's `media` field in `entries.json` |

Execution log: Automated, `app/test/backup_test.dart`: passed, 2026-09-23 (a photo with a caption, and one without, both round-trip into `entries.json`'s `media` field and a real file under `media/` in the archive; verified at the format level). No emulator or device run yet, so the real "writer exports the journal" action through the app UI is untested (same standing gap FEAT-006/FEAT-010 have).

### TC-117: Verify every entry's photos match the exported ones exactly after import

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-6) |
| Other links | ADR-003, RISK-002 |
| Level | integration |
| Priority | P0 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An export archive that includes photos. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer imports it | synthetic | Every entry's photos (bytes, caption, and identity) match the exported ones exactly |

Execution log: Automated, `app/test/backup_test.dart`: passed, 2026-09-23, at two levels: format only (a photo's `id`, `caption`, and `path` decode back exactly; a photo missing from the archive is skipped, not a failure), and through two separate real encrypted journal databases (export a photo from one, import into the other, its bytes decrypt to exactly what was exported, under the same original `uid`). No emulator or device run yet.

### TC-118: Verify no photo thumbnail or full-size photo is visible while locked or backgrounded

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-7) |
| Other links | FEAT-003, RISK-003 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The app is locked, on an entry with a photo. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: a locked or backgrounded screen is shown | synthetic | No photo thumbnail or full-size photo from any entry is visible, visually or to a screen reader |

Execution log: Not executed. FEAT-003's privacy cover (`BlockSemantics`, fixed 2026-09-23 for TC-111/THR-004) already hides every widget behind it, including `PhotoStrip` and `PhotoViewerPage` - no photo-specific code path bypasses it, so the same mechanism applies here without a photo-specific change. No dedicated test exists for this case specifically (the underlying fix's own test coverage is recorded against TC-111, not repeated here); a full-app widget test to prove it directly was attempted for TC-111 and hung in this environment (see that case's log), so this remains an emulator/device case, same as TC-111.

### TC-119: Verify a photo that cannot be read, decrypted, or written names itself, and does not affect the entry's text or other photos

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-8) |
| Other links | RISK-011 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A photo file cannot be read, decrypted, or written (damaged file, wrong key, disk full). Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer tries to view a damaged or undecryptable photo | synthetic | The app names which photo failed (its caption or a generic label); the entry's text and every other photo are unaffected |
| 2 | Perform: the writer tries to add a photo when writing fails (e.g. disk full) | synthetic | The app shows an inline error naming the failure; the entry's text and every other photo are unaffected |
| 3 | Perform: an export or import encounters a photo it cannot decrypt or that is missing from the archive | synthetic | That one photo is left out; the entry's text, mood, tags, and every other photo import or export normally |

Execution log: Partial. Automated, `app/test/media_test.dart`: passed (a wrong key is rejected without touching anything else). Automated, `app/test/backup_test.dart`: passed (a photo missing from the export's `photoBytes` map is left out of the archive entirely, not a failed export; a malformed or missing photo reference at import time is skipped, not an import failure). Automated, `app/test/photo_strip_widget_test.dart` and `app/lib/journal/photo_viewer_page.dart`'s `_OpenFailed` state exist for the on-screen failure message, but are not exercised by an automated test with a genuinely damaged file (only the happy path is tested at the widget level) - the on-screen wording is built (`S.photoOpenFailedTitle`/`S.photoAddFailedTitle`) but its trigger path is unverified end to end. No emulator or device run.

### TC-120: Verify a photo's caption is saved and shown, and a photo without one still has an accessible name

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-011 (AC-9) |
| Other links | none |
| Level | e2e |
| Priority | P2 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The entry editor, a photo already added. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the writer adds a caption and saves | synthetic | The caption is saved with the photo and shown with it (thumbnail and S15 viewer) |
| 2 | Perform: the writer clears the caption and saves | synthetic | The photo has no caption, but its thumbnail and viewer still expose a generic accessible name ("Photo"), never blank |

Execution log: Automated, `app/test/media_test.dart`: passed (a caption is saved with the photo, and can be cleared). Automated, `app/test/photo_strip_widget_test.dart`: passed (a photo with a caption shows it in the viewer). The "never blank" accessible-name rule for a captionless photo is built (`S.photoGenericLabel`, used in both `_Thumbnail` and `PhotoViewerPage`) but not directly asserted by a semantics-tree test the way TC-111's fix was - a gap worth closing with the same `find.semantics.byLabel` technique, not yet done. No emulator or device run.
