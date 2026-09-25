# Mobile Context: exodite-anima

Project identity, tier and rules live in `../_shared/project.md`; do not repeat them here. This file holds mobile facts a mobile engineer needs before touching code. Rows that do not apply are marked with the reason. Facts below were checked on 2026-09-20 unless a decision is named.

## 1. Platforms and framework

| Item | Value |
|------|-------|
| Platforms | iOS and Android phones. Tablet, watch, and TV: not designed for version 1 |
| Minimum OS | Decided 2026-09-20 (`../product-manager/decisions/platforms-and-languages.md`): the Flutter 3.44.4 defaults, Android API 24 (Android 7.0) and iOS 13.0 |
| Target / compile SDK | Android compileSdk 36 and targetSdk 36 (Flutter defaults; the store's target deadline must be checked at submission and recorded here). iOS SDK: cannot be built locally |
| Approach | Flutter, one codebase (ADR-004) |
| Language and version | Dart 3.12.2; Flutter 3.44.4 (stable) |
| UI toolkit | Flutter, with the project's own design system (`../product-design/`), not stock Material styling |
| Repo layout | One app in `app/` (Android and iOS projects inside it); no entrypoints map |
| Build system | Gradle 9.1.0, Android Gradle Plugin 9.0.1, Kotlin 2.3.20, Java 17 target for Android; Xcode for iOS (not available here); no CI |

## 2. Common frontend items (inherited topics)

| Item | Value |
|------|-------|
| Design system / component library | Tokens, components, and screens in `../product-design/` (`design/library/tokens.json`, `docs/component-specs.md`, `docs/screen-specs.md`); the Flutter theme must match the token file; no code library yet |
| State management | No package: plain `StatefulWidget` and drift streams; the lock, language and theme changes are handled in `_ShellState` and `SettingsController` (`app/lib/main.dart`, `app/lib/settings/`) |
| API client and base URL per env | None: there is no API and no network use (ADR-005) |
| API contracts | None. The export archive format is the only contract (ADR-003) |
| i18n | English and Indonesian, switchable in Settings, default follows the phone (decided 2026-09-20); no RTL; all strings externalised in both languages; Indonesian text reviewed by the owner |
| Accessibility target | WCAG 2.2 AA; VoiceOver and TalkBack; 200 percent text (TC-087 to TC-089) |
| Local storage | Encrypted SQLite through drift with SQLite3MultipleCiphers (ADR-002, **unverified until the spike**) |
| Secure storage | OS Keychain and Keystore for the data key (ADR-001, unverified until the spike) |

## 3. Device matrix

Not defined. The skill builds a matrix from usage data; the app has no users and no analytics, so none exists. It also depends on the pending decision `platforms-and-languages`.

| Tier | Devices | OS versions | Rationale |
|------|---------|-------------|-----------|
| Primary (real devices) | none identified | Android 7.0 and later, iOS 13 and later (decided minimums) | needs devices and public platform share data |
| Secondary | none | none | |
| Low-end reference (performance budgets) | none identified | not decided | needs a device before `nfr-targets-v1` can be measured |
| Emulator only | `flutter_avd`: Android 14 (API 34), x86_64 | 14 | the only environment available; verified working |

Device farm: none. iOS: no device and no Mac. Matrix owner: project owner; review at each major OS release once it exists.

## 4. Distribution

| Channel | Value |
|---------|-------|
| Public stores | Apple App Store and Google Play; regions to be decided with `legal-applicability-confirmation` |
| Beta | Google Play testing tracks and TestFlight, planned; not set up |
| Enterprise / MDM | Not applicable |
| Release cadence | Not set; store review buffer of 5 working days per the skill |
| Rollout policy | **Pending** (`v1-rollout-plan`); candidates in `report/release-plan-v1.md`. There is no kill switch: the only levers are halting a staged rollout and shipping a fix |
| Store listing owner | Project owner |

## 5. Signing and provisioning

| Item | Value |
|------|-------|
| Owner (primary / backup) | Project owner / none. Single point of failure (THR-014) |
| Apple team ID, certificates, profiles | Not set up; account status not confirmed |
| Android signing | Play App Signing recommended; upload key not created. **The template signs release builds with the debug key** (verified: the release APK's signer is "Android Debug"); that build must never be shipped (TC-091) |
| Where secrets live | Outside the repository; `.gitignore` blocks key file names; no secret manager exists |
| Rotation and loss procedure | See `report/release-plan-v1.md` (no runbook role exists) |

## 6. Push, deep links, integrations

| Item | Value |
|------|-------|
| Push provider | None. In-app reminders only (FEAT-008) |
| Notification categories and channels | None in version 1 |
| Deep links | None |
| Third-party SDKs | None. Packages for storage, keys, biometrics, archives, and file picking are chosen in the spike, each with a data-safety entry (`report/permission-and-privacy-register.md`) |

## 7. Observability

| Item | Value |
|------|-------|
| Crash reporting | None in the app (ADR-005); crash and stability data from the store consoles only |
| Analytics | None by product policy |
| Performance monitoring | None; budgets are measured in tests on a device (`../software-architect/report/nfr-analysis-v1.md`) |
| Remote config / flags | None: no network. Behaviour cannot be changed after release without a new build |

## 8. Version support policy

| Item | Value |
|------|-------|
| Minimum supported app version | Not applicable: no server to enforce it |
| API support window | Not applicable. Data window instead: every app version imports exports from every older `formatVersion` (ADR-003) |
| Force-update rule | Not available (no server). A newer export is refused by an older app with a message to update; updates come only through the stores |
| Current version distribution | Not available (no telemetry); store consoles once released |

## 9. Compliance pointers

Applicable frameworks: see `../_shared/compliance/compliance-matrix.md` (store rules and WCAG apply; UU PDP, PP 71/2019 and GDPR: no obligation on this reading, `../product-manager/report/legal-self-assessment-v1.md`, owner sign-off pending). Privacy label and data-safety form owner: project owner, prepared by frontend-mobile; last reconciled with code: never (`report/permission-and-privacy-register.md`).

## 10. Known gaps
- Release builds are signed with the debug key; no release key yet (TC-091). CI is written (`.github/workflows/ci.yml`) but has never run.
- iOS cannot be built or verified (no Mac; Android first). iOS backup exclusion and privacy manifest are not built.
- No physical-phone results recorded per case; the owner reported that the release APK ran smoothly on their phone. Real biometric prompt, share sheet, file picker and screen capture are untested by cases (`../qa/report/PRR-001-v1-android.md`).
- The low-end reference device is an emulator with limited resources (owner's choice), which cannot prove the frame-rate target; the size budget of the universal APK (58.9 MB) has no decided target.
- Spike: S5 (device-bound key wrapping) not evaluated; S3 and S4 partial (fake biometrics, emulator timings); S9 (iOS privacy manifest) open.
- Indonesian text is a draft for the owner's review. Import limits and Argon2id settings are provisional.
- ADR-006's copy-before-migrate and restore-on-failure mechanics are built and tested (`app/lib/data/journal_database.dart`, `app/test/migration_safety_test.dart`, 2026-09-23), proven against a real migration failure since no `onUpgrade` step exists yet (the schema is still version 1). FEAT-010 (tags, mood, and On this day) will be the first feature to add a real schema step (`journalSchemaVersion` 1 -> 2) and exercise this against a real second schema; effort read given 2026-09-23 (`report/effort-read-v1.md`), size L (now somewhat lower risk, since the generic safety net already exists).
- FEAT-010's "On this day" slice (AC-5, AC-6) is built (2026-09-23): `EntryRepository.watchOnThisDay` and the `_OnThisDayCard` widget in `app/lib/journal/timeline_page.dart`, needing no schema change since it reads the existing `day` column. Proven at the repository level (`app/test/entry_repository_test.dart`); no widget or emulator test yet.
- FEAT-010's mood and tags slice (AC-1 to AC-4) is also built (2026-09-23): `journalSchemaVersion` moved 1 -> 2 with a real `onUpgrade` (`app/lib/data/journal_database.dart`), proven against a genuine hand-built schema-1 fixture (`app/test/migration_safety_test.dart`); `EntryRepository.create`/`update` take `mood` and `tags`; the editor UI (`MoodPicker`, `TagInput`, `app/lib/journal/mood_and_tags.dart`) is wired into `editor_page.dart`, matching the design reviewed by the owner beforehand this time. The timeline now shows them too (`EntryRepository.watchTimeline`'s `GROUP_CONCAT` join, `TimelinePage`'s `_EntryMeta`), matching a second reviewed design (S6 "With mood and tags"). Repository level proven (3 new tests for the timeline, including that a comma inside a free-text tag survives and that the stream updates when a tag changes; full suite 122 tests by the end of the day). Known gap: neither `TimelinePage` nor `EditorPage` has a widget or emulator test of its own - only their pieces (`MoodPicker`, `TagInput`) do, plus the repository underneath both. Export/import (AC-7, AC-8) now carry `mood` and `tags` too (`app/lib/backup/backup_service.dart`, `docs/export-format.md` updated), proven at the format level and through two real journal databases (`app/test/backup_test.dart`); the real export/import screens are not tested by a widget or emulator run. AC-9 is built too: checking it found that FEAT-003's privacy cover (`app/lib/main.dart`) hid content visually but never blocked it from the accessibility tree - a real, pre-existing gap, now fixed with `BlockSemantics`. Every FEAT-010 acceptance criterion is now built; none is proven by a widget or emulator test of the real screens.
- FEAT-011 (Photos) schema, file, repository, and UI layers are built (2026-09-23): `journalSchemaVersion` 2 -> 3, a `media` table, a real `onUpgrade`, proven against a genuine hand-built schema-2 fixture (`app/test/migration_safety_test.dart`). `MediaFiles` (`app/lib/data/media_files.dart`) encrypts one file per photo (AES-256-GCM, fresh nonce each write); `EntryRepository` gained `addPhoto`/`removePhoto`/`setPhotoCaption`/`photosFor`/`readPhotoBytes`, and entry deletion now takes photos with it. The editor (`app/lib/journal/photo_strip.dart`) wires `image_picker` (1.2.3) with camera/library choice and its own `maxWidth`/`imageQuality` as the compression step; a new photo viewer screen (`app/lib/journal/photo_viewer_page.dart`, S15) shows a photo full-size with Remove and its confirmation. Fixed a real gap found while wiring this: `journal_session.dart` never gave the app's real `EntryRepository` a media directory or data key, so no photo could have been stored on a device even with everything else built - it does now. Proven in `app/test/media_test.dart` (10 tests) and `app/test/photo_strip_widget_test.dart` (4 tests; needed `tester.runAsync` throughout, since real file/AES-GCM work never completes under `testWidgets`'s fake clock - a testing-infrastructure lesson, not a product one). Export/import are built too: `entries.json` gains a `media` field per entry, each photo's plaintext bytes travel under the archive's `media/<id>.<ext>`, a photo that fails to decrypt is left out of the export rather than failing it (AC-8), and an imported photo keeps its original `uid`. Proven at the format level and through a full round trip between two real encrypted journals (`app/test/backup_test.dart`); suite now 144. FEAT-011 is built end to end at the repository/unit/widget level; not yet verified on a real device.
- FEAT-011, real-device findings 2026-09-23 (the owner's first physical-phone try): adding a photo silently failed on any unguarded picker exception (fixed, `../workflow/mobile-build-and-release.md`); a brand-new blank entry could not open the picker at all (fixed: `S.photoNeedsTextFirst` shown instead of nothing); and a picked photo vanished after the app relocked mid-pick, since opening the camera or library backgrounds the app and FEAT-003 locks immediately by default (fixed with `AutoLockGuard`, `app/lib/lock/auto_lock_guard.dart` - full mechanism and its bounded residual risk, RISK-014, in `../software-architect/adr/ADR-002-local-database.md`'s 2026-09-23 update). `CAMERA` added to `AndroidManifest.xml` (image_picker's own code requests it at runtime, confirmed by reading the plugin source); no photo-library permission was added, since nothing in image_picker's Android code needs one. Suite now 150 tests (`app/test/auto_lock_guard_test.dart` new). Still not verified on a real device - that is what surfaced these in the first place, and remains the next step.
- Editor fixes 2026-09-25 (owner report: text not visible while writing): the editor body now scrolls as one area (mood, tags, photos, text, Delete), so the text field can no longer be squeezed to zero height by the keyboard; a photo's silent first save no longer leaves a draft that restores as a duplicate entry; `MoodPicker` no longer overflows a 360 dp phone. `EditorPage` now has its first widget test (`app/test/editor_page_widget_test.dart`, 2 cases); suite 152. Tried on the emulator for the text and the camera path; library pick, photo viewer and a photo on an existing entry are not, and none of this is verified on a real phone. Detail in `workflow/mobile-build-and-release.md`.
- Several packages in `pubspec.yaml` are pinned exactly; 22 packages have newer versions that the Flutter 3.44.4 constraints do not allow (not reviewed); `cupertino_icons` is unused.

## Verified build baseline (2026-09-20)
| Check | Result |
|-------|--------|
| `flutter analyze` | No issues found |
| `flutter test` | The template's sample test passes (it tests the demo counter that will be replaced) |
| Debug build on the emulator | Runs; first Gradle build took about 104 s |
| Release build (`flutter build apk --release`) | Builds in about 130 s; 41.4 MB universal APK |
| Release APK network permission | None. Only an AndroidX-internal receiver permission is present; the debug build adds `INTERNET` for tooling |
| Release APK backup | `allowBackup` is `false` (set in the main manifest on 2026-09-20) |
| Release APK target and minimum SDK | target 36, minimum 24 |
| Release APK signature | **Android Debug certificate** (not shippable) |
- FEAT-001 in progress: encrypted storage in `app/lib/data/`, screens in `app/lib/journal/`, theme from the design tokens in `app/lib/theme/`, strings in `app/lib/l10n/strings.dart` (English only until FEAT-009). The only key source is a public debug key that exists in debug builds only; a release build shows a placeholder until FEAT-003 and FEAT-004 are built. Spike results are in `report/technical-spike-plan.md`.
- FEAT-003 and FEAT-004 in progress: `app/lib/security/` (vault, passcode rules, biometrics, secret store), `app/lib/lock/`, `app/lib/onboarding/`. The debug key is gone; `main.dart` now runs onboarding, the lock, auto-lock, and a privacy cover. Android release builds set the secure-window flag. Known limits: the wait after wrong tries uses the phone clock; the biometric copy of the key is not hardware-gated (spike S5).
- FEAT-006 and FEAT-007 in progress: `app/lib/backup/` (format, envelope, minimal ZIP, export and import screens, share and file-picker gateway), a minimal Settings screen in `app/lib/settings/`. The real share sheet and file picker are not exercised by the tests (they use `FakeBackupFiles`).
- FEAT-005 and FEAT-009 in progress: search (`app/lib/journal/search_page.dart`, index in `journal_database.dart`), settings (`app/lib/settings/`: controller, settings, change passcode, about), and two languages (`app/lib/l10n/strings.dart`, English and Indonesian). All nine v1 features now exist in the app. Open: real-device checks (biometric prompt, share sheet, file picker, screen capture), iOS, the reference device for performance, the owner's review of the Indonesian text.
