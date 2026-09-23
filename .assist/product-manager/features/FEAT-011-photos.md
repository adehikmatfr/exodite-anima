# FEAT-011: Photos

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): current behaviour (new feature).

| Field | Value |
|-------|-------|
| ID | FEAT-011 |
| Type | new feature |
| Status | in-progress |
| Owner | Project owner |
| Date | 2026-09-23 |
| Priority score | Not scored (relative sizing only, T1). Bundled with FEAT-010 in the "Next" roadmap horizon (v1.1), owner decision 2026-09-23 (`FEAT-010` Decisions, `context.md`) |
| Related capability | none (new) |
| Related IDs | ADR-001, ADR-002, ADR-003, ADR-006, FEAT-001, FEAT-006, FEAT-007, FEAT-010 |

## Problem
Today an entry is text only. A journal writer who wants to keep a photo alongside what they wrote (a place, a face, a page from a notebook) has no way to do that inside the app; they would have to keep photos somewhere else, disconnected from the entry they belong to.

Evidence: none yet; this is a hypothesis carried in the roadmap ("Later: photos and audio", `v1-scope-and-non-goals.md`), not a measured user request. The product has no users and collects no usage data. Photos was deliberately deferred out of v1 by the owner on effort and risk grounds (larger export files, more storage work, a larger data-loss and privacy surface) — see `v1-scope-and-non-goals.md`.

## Users
| Segment | Need | How they meet this feature |
|---------|------|----------------------------|
| Journal writer (primary, hypothesis) | Keep a photo with the entry it belongs to, without any of it leaving the device | Attach one or more photos to an entry; view them later |

## Goals
- A journal writer can attach one or more photos to an entry, from the phone's camera or its existing photo library.
- A photo attached to an entry is exactly as private as entry text: encrypted at rest, never uploaded, covered by the same lock and screen-privacy rules (FEAT-003).
- A photo survives an export/import round trip exactly, the same guarantee FEAT-010 makes for mood and tags (product principle 2: the user owns the data).
- A journal writer can add a short caption to a photo, if they want to; it is optional.

## Non-goals
- Audio attachments (a separate, later roadmap item, `v1-scope-and-non-goals.md`; not part of this spec).
- Editing photos in the app (crop, rotate, filters, drawing).
- Automatic tagging, face recognition, or any on-device ML analysis of photo content.
- Cloud backup, sync, or CDN delivery of photos; export/import remains the only way to move them (product principle 1).
- Filtering or searching entries by photo content (mirrors FEAT-010's non-goal for mood/tag search).

## Proposed behaviour
1. In the entry editor, the writer can add one or more photos, taken with the camera or chosen from the phone's photo library (owner decision 2026-09-23: both sources, not one or the other).
2. A photo is resized/compressed on the way in to save space (owner decision 2026-09-23); the exact target is a technical bound set by frontend-mobile, not an artificial limit the writer has to think about.
3. The writer can optionally add a short caption to a photo (owner decision 2026-09-23); a photo with no caption still has an accessible name (a generic label, not blank).
4. Each photo shows as a thumbnail in the editor and in the timeline, next to the entry it belongs to.
5. Tapping a photo opens it full-size, with its caption if it has one; the writer can remove a photo from an entry at any time, the same way they edit entry text.
6. Deleting an entry deletes its photos for good, the same way deleting an entry deletes its text (FEAT-001 AC-6).
7. Photos are stored encrypted, as separate files outside the database (ADR-002's existing media decision), never as plain files on the phone.
8. No cap on the number of photos per entry or on total photo storage for now (owner decision 2026-09-23, same as entry text has no artificial maximum length); revisited if it becomes a real problem.
9. Photo files keep their embedded metadata (for example EXIF GPS location) as-is (owner decision 2026-09-23); nothing is stripped or asked about today. This is a real residual privacy consideration, not a closed one — see RISK-013.
10. Export and import (FEAT-006, FEAT-007) carry every entry's photos and captions; an import restores them exactly, byte for byte.
11. Failure path: if a photo cannot be read, decrypted, or written (damaged file, out of space), the entry's text is never put at risk; the app says which photo failed and leaves everything else untouched.

## User stories
- As a journal writer, I want to attach a photo to an entry, so that a memory has more than just words.
- As a journal writer, I want my photos to be exactly as private as my writing, so that adding a photo never means giving up my privacy.

## Acceptance criteria
Each criterion is verifiable and traceable to a `TC-`. Test cases assigned 2026-09-23 (`qa/test-cases/FEAT-011-photos.md`).

| # | Given | When | Then | TC |
|---|---|---|---|---|
| AC-1 | The entry editor | The writer adds a photo from the camera or the photo library | The photo is saved with the entry and shown as a thumbnail | TC-112 |
| AC-2 | An entry with a photo | The writer taps its thumbnail | The photo opens full-size | TC-113 |
| AC-3 | An entry with a photo | The writer removes the photo and saves | The photo no longer shows on that entry, and its file is gone | TC-114 |
| AC-4 | An entry with one or more photos | The writer deletes the entry and confirms | The entry's photos are deleted for good, the same as its text | TC-115 |
| AC-5 | An entry with a photo | The writer exports the journal | The export archive includes that photo | TC-116 |
| AC-6 | An export archive that includes photos | The writer imports it | Every entry's photos match the exported ones exactly | TC-117 |
| AC-7 | The app is locked | A locked or backgrounded screen is shown | No photo thumbnail or full-size photo from any entry is visible | TC-118 |
| AC-8 | A photo file cannot be read, decrypted, or written | The writer tries to view, add, or import it | The app names which photo failed; the entry's text and every other photo are unaffected | TC-119 |
| AC-9 | The entry editor, a photo already added | The writer adds a caption and saves | The caption is saved with the photo and shown with it; a photo with no caption still has an accessible name | TC-120 |

## NFR and compliance impact
| Area | Requirement | Source |
|------|-------------|--------|
| Security / privacy | A photo is journal content: Restricted data, same classification and handling as entry text (no logs, no clipboard, no notifications, encrypted at rest, never transmitted) | `project.md` principle 1, ADR-001, ADR-002, FEAT-003 |
| Data integrity | Photo files and their database references must not fall out of sync (ADR-002 already names this risk for media in general); adding photo storage is additive to the schema, so it must follow ADR-006's migration safety rules | ADR-002, ADR-006 |
| Compatibility | The export archive must carry photo files as well as `entries.json`; `docs/export-format.md` already reserves a `media/` folder for this, empty today | ADR-003 |
| Storage | No cap on photo count or total storage (owner decision 2026-09-23, same as entry text); resized/compressed on the way in to a technical bound set by frontend-mobile, not an owner-set number | `local-data-design.md` |
| Accessibility | A photo needs a text alternative for a screen reader: its caption if it has one, otherwise a generic accessible name, never blank; WCAG 2.2 AA | `compliance-matrix.md` (WCAG row) |
| Compliance | Photo files keep their embedded metadata (for example EXIF GPS location) as-is (owner decision 2026-09-23); no dedicated compliance review of this exists yet, and it is a real residual privacy consideration for cyber-security to review once this spec is further along, not a closed question (RISK-013) | `compliance-matrix.md`, RISK-013 |

## Success metrics
| Metric | Definition | Baseline | Target | Guardrail | Measured by / when |
|--------|-----------|----------|--------|-----------|--------------------|
| Photo round-trip integrity | Entries whose photos differ, or are missing, after export then import, found by test | none (feature does not exist yet) | 0 | must not regress the existing export round-trip guardrail in `context.md` | Automated tests before each release, owned by qa |

## Rollout
Ships bundled with FEAT-010 in v1.1 (owner decision, 2026-09-23, recorded in FEAT-010's Decisions), not with v1. Staging detail is not yet planned; follows the existing staged-rollout pattern (decision `v1-rollout-plan`) once the v1.1 rollout is defined.

## Risks
| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|-----------|--------|-----------|-------|
| RISK-011 | A photo file and its database reference fall out of sync (crash mid-write, partial import), leaving an orphaned file or a broken reference | M | M | Atomic write and orphan-file cleanup on a failed insert are built and tested (`app/test/media_test.dart`); no periodic consistency scan exists yet for a crash between the write and the insert itself | software-architect |
| RISK-012 | Photo storage grows without bound and fills the phone, or the writer has no way to know how much space their photos use | M | M | Owner decided 2026-09-23: no cap, same as entry text; accepted, not mitigated. Compression on the way in reduces the rate of growth but does not bound it. Revisit if store reviews or support reports report the phone filling up | Project owner |
| RISK-013 | A photo carries metadata (for example EXIF GPS location) that reveals more than the writer intended, especially on export | L | M | Owner decided 2026-09-23: keep metadata as-is, not stripped, not asked about. Accepted, not mitigated: exporting or sharing a photo can reveal more than the entry text around it would. No code exists yet; cyber-security should still review this before FEAT-011 ships, since "the user owns the data" is not the same claim as "the app protects the user from their own photo" | cyber-security |

## Dependencies
- FEAT-001 (entry management): this spec extends the entry data model, the same way FEAT-010 did.
- FEAT-006, FEAT-007 (export, import): must carry photo files, not just `entries.json`; `docs/export-format.md`'s reserved `media/` folder is the starting point.
- FEAT-010 (tags, mood, and On this day): the two features are bundled for v1.1 by owner decision, not technically dependent on each other's code.
- Software-architect read received (2026-09-23): a `media` table (`id`, `uid`, `entry_id`, `caption`, `mime_type`, `byte_size`, `sha256`, `created_at_ms`), `journalSchemaVersion` moves 2 -> 3; photo files encrypted with AES-256-GCM (the same primitive already used elsewhere in the app), one file per photo, temp-file-then-move for atomic writes. Export: `entries.json` gains a `media` field per entry, photo bytes go under the archive's already-reserved `media/` folder at their plaintext content; manifest `schemaVersion` moves to 3, export `formatVersion` stays 1. Recorded as updates to ADR-002 and ADR-003, not a new ADR. The importer's current hard-coded two-file read set (rule 3) needs real code to recognise `media/` paths, not just ignore them.
- No effort read yet from frontend-mobile; the owner's decisions and the architecture read above unblock it, but it has not been given.

## Decisions
- No cap on the number of photos per entry, or on total photo storage, for now (owner, 2026-09-23); the same approach FEAT-001 took for entry text length. Accepted as a risk, not mitigated (RISK-012).
- Photos come from both the camera and the phone's existing photo library, not one or the other (owner, 2026-09-23).
- Photos are resized/compressed on the way in to save space (owner, 2026-09-23); the exact target is a technical bound for frontend-mobile to set, not an owner-decided number.
- Embedded photo metadata (for example EXIF GPS location) is kept as-is: not stripped, not asked about (owner, 2026-09-23). Accepted as a residual privacy risk, not mitigated (RISK-013); cyber-security should still review it before this ships.
- A photo can optionally have a caption (owner, 2026-09-23); a photo without one still needs an accessible name for a screen reader.

## Open questions
None. All five were closed by the owner on 2026-09-23; see Decisions.

## Estimate and hand-off (optional)
- Effort read from engineering: size L, relative, low confidence (frontend-mobile, 2026-09-23, `report/effort-read-v1.md`). Driven by real device integration this project has not needed before (camera/library pickers, image decoding and compression) and a new encrypted-file-per-photo store, not just the schema step alone.
- Hand-off date and assigned team: 2026-09-23, on the owner's confirmation (see Status log). Hand-off: FEAT-002 (timeline thumbnails), FEAT-006, FEAT-007 (export/import media handling), FEAT-003 (screen privacy extends to photos) for build; qa to derive `TC-` from AC-1 to AC-9 (`TP-001`) once build starts.

## Status log
| Date | Status | Note |
|------|--------|------|
| 2026-09-23 | draft | Created at the owner's request to unblock v1.1 planning: FEAT-010 is bundled with Photos in the roadmap, but Photos had never been specified. Drafted from existing decisions already on record (ADR-002's media design, `local-data-design.md`'s open item on a size cap, `v1-scope-and-non-goals.md`'s reason for deferring photos out of v1). Five open questions raised for the owner; none answered yet |
| 2026-09-23 | draft | Owner closed all five open questions: no cap on photo count/storage (accepted risk, RISK-012); photos from both camera and library; resized/compressed on the way in (target left to frontend-mobile); embedded metadata (e.g. EXIF location) kept as-is (accepted risk, RISK-013); captions are optional. Proposed behaviour, AC (added AC-9 for captions), NFR, Risks, and Decisions updated. Still needed before `ready`: a software-architect read and an effort read from frontend-mobile |
| 2026-09-23 | ready | Software-architect read received: a `media` table (`id`, `uid`, `entry_id`, `caption`, `mime_type`, `byte_size`, `sha256`, `created_at_ms`); `journalSchemaVersion` moves 2 -> 3; one AES-256-GCM-encrypted file per photo; export gains a `media` field per entry and real files under the archive's already-reserved `media/` folder, manifest `schemaVersion` 3, `formatVersion` unchanged at 1. Recorded as updates to ADR-002 and ADR-003. Effort read received from frontend-mobile: size L, driven by camera/library pickers and image compression this project has never needed before, not just the schema step. Every `write-feature-spec` readiness-checklist item is now satisfied; moved to `ready` |
| 2026-09-23 | ready | ux-design added flow F9 (add/view/remove a photo, including the failure path and the "never blank" accessible-name rule for captions, `ux-design/report/user-flows.md`). Product-design drew S7 "With photos" (thumbnail row plus "Add photo") and a new screen S15 "Photo viewer" (full-size photo, caption, Remove, and its confirmation) before any code, following the corrected gate order from FEAT-010 - self-checked by rendering both themes to PNG (`product-design/tools/gen_screens.py` changelog 0.6). Awaiting the owner's review of this preview before the schema step or any code is built |
| 2026-09-23 | ready | Owner reviewed the S7 "With photos" and S15 "Photo viewer" previews (both themes shown inline) and approved them. G2 is closed, in the right order this time. The schema step and the code are next |
| 2026-09-23 | ready | Built the schema step: `journalSchemaVersion` 2 -> 3, a `media` table exactly as the software-architect read described, a real `onUpgrade` step. Proven against a genuine hand-built schema-2 fixture, keeping an existing entry's mood and tag untouched while adding the table (`app/test/migration_safety_test.dart`). Fixed the failure-injection test for ADR-006 rule 2 to keep forcing a real failure, since drift's `createTable` turned out to be a silent no-op on an existing table (only `addColumn` reliably fails) - noted in the test, not hidden. Added `image_picker` (1.2.3) to `pubspec.yaml`; checked its own Android manifest directly (declares no permission beyond a `FileProvider`), not assumed. `flutter analyze` clean, suite now 123 tests. Not yet built: the encrypted-file layer for photo bytes, the repository layer, the editor UI, the viewer, export/import |
| 2026-09-23 | in-progress | Built the encrypted-file layer (`app/lib/data/media_files.dart`, one AES-256-GCM file per photo, fresh nonce every write) and the repository layer (`EntryRepository.addPhoto`/`removePhoto`/`setPhotoCaption`/`photosFor`/`readPhotoBytes`). Deleting an entry now deletes its photos' rows and files too (AC-4); an orphan file is cleaned up if its row insert fails. Compression is not this layer's job - it happens where the photo is picked (`image_picker`'s own parameters), still to be wired. Proven in `app/test/media_test.dart` (10 tests: round trip, wrong-key rejection, fresh nonce per write, no plaintext on disk, every repository method including AC-1, AC-3, AC-4, AC-9) - suite now 133, `flutter analyze` clean. Not yet built: the editor UI, the viewer screen, export/import |
| 2026-09-23 | in-progress | Built the editor UI and the S15 viewer, matching the approved previews exactly. `app/lib/journal/photo_strip.dart`: the thumbnail row and "Add photo" button (S7 "With photos"), a bottom sheet choosing camera or library, and `pickCompressedPhoto` wiring `image_picker`'s own `maxWidth`/`imageQuality` (1600px, 82) as the compression step (owner decision, no separate image-processing package). `app/lib/journal/photo_viewer_page.dart`: S15 full-size view, caption, Remove and its confirmation sheet (same pattern as the delete-entry sheet); AC-8's "name which photo failed, leave everything else untouched" reuses the existing inline-error pattern rather than a new drawn state, since screen-specs already noted none is drawn for it yet. `editor_page.dart` now creates the entry silently on the first photo (mirroring the existing draft mechanism) when there is already text to save; adding a photo before any text is typed is a no-op, the same rule Save already has. Also fixed a real gap found while wiring this up: `journal_session.dart` never passed a media directory or data key to `EntryRepository`, so the app's own running instance could not have stored a photo at all - it does now (`<app support dir>/media`, the session's already-loaded data key). 6 new Lucide icons registered were actually 3 (`camera`, `image`, `trash`/`trash-2`), verified the same way as FEAT-010's mood icons: downloaded and read `lucide-static@1.47.0`'s own `font/info.json` directly, never guessed. New widget tests in `app/test/photo_strip_widget_test.dart` (4 tests) needed `tester.runAsync` throughout: real file and AES-GCM work never completes under `testWidgets`'s fake clock, a genuine testing-infrastructure lesson worth keeping, not a product bug - documented in the test file itself. `flutter analyze` clean, suite now 137. Not yet built: export/import |
| 2026-09-23 | in-progress | Built export/import, the last slice: `entries.json` gains a `media` field per entry (`id`, optional `caption`, `path`), each photo's plaintext bytes written under the archive's `media/<id>.<ext>` (extension from its `mimeType`, so the file is recognisable outside the app, not a bare id). `ExportPage` decrypts each photo itself (only the repository holds the device key) and drops any that fail to decrypt (AC-8) before the archive is built, rather than failing the whole export. Import re-uses `addPhoto`'s machinery with the archive's own `uid`, so a photo's identity survives a round trip the same way an entry's already did; a photo an entry references but whose bytes are missing from the archive is skipped, not an import failure. Rule 3 (ADR-003) now has real code, not just a stated rule: the importer reads `manifest.json`/`entries.json` first, validates every `media` reference (id, and that the id inside its own `path` matches), and only then opens the exact `media/` paths that passed validation - nothing about the ZIP's own directory listing is ever trusted before that. Proven at the format level (round trip with and without a caption, a missing-bytes exclusion, an older-app-shaped archive, every malformed-reference case) and through a full round trip between two real encrypted journals with a real encrypted photo file on each side (`app/test/backup_test.dart`). `flutter analyze` clean, suite now 144. FEAT-011 is now built end to end; production-readiness review, real-device verification, and moving to `released` are next |
