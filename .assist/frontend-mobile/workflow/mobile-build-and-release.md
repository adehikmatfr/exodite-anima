# Mobile build and release in exodite-anima

As-built description of how the app is built, checked, and released today. Written after the process was set up on 2026-09-20; update it when the process changes.

## 1. Overview
The app is a Flutter project in `app/`. It is built locally on a Windows machine; there is no CI and no Mac. Android builds and runs on an emulator; iOS cannot be built here. Nothing has been released. Store steps and rollout are planned in `../report/release-plan-v1.md`.

## 2. Trigger / entry points
- A feature or fix in `app/`.
- A release candidate.
- A change to permissions, packages, or declarations.

## 3. Step-by-step flow (what works today)
1. Read `../../_shared/project.md`, this role's `prompts/role.md` and `context.md`, the `FEAT-`, and `../../product-design/docs/screen-specs.md` for the screens.
2. Before adding a package, review it (`../../cyber-security/report/dependency-review.md`); pin the version; reject any package that adds a network permission.
3. Run the checks from `app/`: `flutter analyze` and `flutter test`.
4. Run on the emulator: start `flutter_avd` (`flutter emulators --launch flutter_avd`), then `flutter run -d emulator-5554`.
5. Build a release: `flutter build apk --release`. Inspect the result with the Android build tools: `aapt2 dump permissions <apk>`, `aapt2 dump xmltree --file AndroidManifest.xml <apk>`, and `apksigner verify --print-certs <apk>`.
6. Record evidence in the affected test-case execution log and update `../context.md` if a fact changed.
7. Update the permission and privacy register when permissions, packages, or declarations change.

## 4. Statuses and data model
Not applicable: there is no release pipeline yet. A release record (version, build, commit, hash, declarations, schedule, thresholds, sign-off, 72-hour result) is kept per release once releases exist (`../report/release-plan-v1.md`).

## 5. External calls and events
The store consoles (Apple App Store Connect and Google Play Console) are the only external systems, used for submission and for crash and stability data. Neither is set up. The app itself makes no external calls (ADR-005).

## 6. Decisions and gotchas
- **The template signs release builds with the debug key.** A release built today is not shippable; the upload key and Play App Signing come first.
- **Debug and profile builds carry a network permission** (for tooling); release builds do not. Every network-related check must use a release build.
- `android:allowBackup="false"` is set in the main manifest (2026-09-20, ADR-001 decision 5). The iOS equivalent (exclude stored files from backup) is not built.
- Flutter's defaults for `minSdk`, `targetSdk`, and `compileSdk` come from the Flutter SDK, not from literals in the project; a Flutter upgrade can change them.
- The store's target-SDK deadline changes yearly; check it at every submission.
- Nothing may be built for release from a laptop once CI exists (skill rule); until then the release record must say the build was local.
- Spike code goes in its own folder, never in `app/lib/` (`../report/technical-spike-plan.md`).

## Building a feature (FEAT-001 storage, 2026-09-20)
- Packages: `sqlite3` 3.5.2, `drift` 2.35.0, `path`, `path_provider`; dev: `drift_dev`, `build_runner` 2.15.1, `integration_test`. Versions are exact. Newer sqlite3 (3.6.0) and build_runner (2.16.1) cannot be resolved with Flutter 3.44.4's pinned SDK packages.
- The pubspec `hooks: user_defines: sqlite3: source: sqlite3mc` selects the encrypted build. Without it the database silently stays unencrypted, so tests check for plaintext in the raw file.
- Generated drift code (`*.g.dart`) is produced by `dart run build_runner build` from `app/`. Regenerate after changing tables.
- Storage code is in `app/lib/data/` (database, repository). It takes the data key as a parameter; the key comes from `KeyVault` (`app/lib/security/`), released by the passcode or, after the system prompt, the biometric copy.
- Tests: `flutter test test/entry_repository_test.dart` on the host; `flutter test integration_test/feat001_storage_test.dart -d <emulator>` on a device. Both run the same file.
- The plain-Dart spike lives in `app/spike/` and is throwaway.
- Screens: `app/lib/journal/` (timeline host, editor, S14). Colours, spacing and type are in `app/lib/theme/tokens.dart`, copied by hand from the product-design tokens; change the token file there first. Every visible string is in `app/lib/l10n/strings.dart`.
- Fonts: Inter and Lora are bundled from `app/assets/fonts/` with their licence texts; no font is fetched at run time (ADR-005).
- Screen tests: `flutter test integration_test/feat001_ui_test.dart -d <emulator>`. They use a made-up key and a temporary folder, and prepare files with a helper that closes the database before the app opens it.
- Keys: the data key comes only from `KeyVault` (created at setup, released by the passcode or, after the system prompt, the biometric copy). There is no fixed key. `JournalApp(testKeySource: ...)` is the only bypass and exists for tests.
- Timeline (FEAT-002): the list reads a light query (`watchTimeline`: id, day, time, first 240 characters) and builds rows lazily; the full text is read only when a row is opened. Do not use `watchAll` for the list.
- Measuring scrolling: `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/feat002_timeline_perf_test.dart -d <device> --profile`. `flutter test` cannot run a profile build, and debug numbers are pessimistic. Results on an emulator are indicative only.
- Lock: `_ShellState` in `app/lib/main.dart` watches the app lifecycle. On `inactive` it covers the content; on `paused` it locks immediately (default) or after the timeout on return, closes the database, wipes its copy of the key, and pops every screen. The editor writes its draft when the app goes inactive, before the journal is closed.
- Android: `MainActivity` extends `FlutterFragmentActivity` (biometric prompt) and sets `FLAG_SECURE` in non-debuggable builds; the activity themes derive from `Theme.AppCompat` (`.NoActionBar`), and the app declares `androidx.appcompat` 1.7.0. Debug builds allow screenshots on purpose.
- Testing the lock: `integration_test/feat003_004_ui_test.dart` uses `waitFor` (real time), `background()` and `foreground()` helpers that send lifecycle events in the order the platform does. No frames run while paused, so do not `pump` between them.
- Gotcha found by tests: a text field that is disabled while a request runs loses focus and closes the keyboard. Use `readOnly` and keep the focus node.
- Backup: `createBackup` and `readBackup` in `app/lib/backup/backup_service.dart` are pure functions over bytes and run in isolates; the screens only call them and the repository (`readAllForExport`, `importEntries`, `recordExport`). Format changes: bump `currentFormatVersion`, keep a reader for every older version, and add a fixture archive for each.
- Sharing and picking go through `BackupFiles` (`SystemBackupFiles` uses share_plus and file_picker; `FakeBackupFiles` is for tests). Export files are written to the cache and removed two minutes after sharing and at every start. Do not log file names or content.
- Tests: `flutter test test/backup_test.dart` (host, 28 tests) and `integration_test/feat006_007_ui_test.dart` (emulator, 6 tests). `envelopeDefaults` is lowered in the screen tests to keep key derivation fast.
- Reminder (FEAT-008): the rules are the pure function `reminderFor` in `app/lib/backup/reminder.dart` (calendar days, not hours: more than 30 days, snooze 7 days); the repository supplies counts and times only (`reminderInputs`), never text. The timeline re-checks when it opens, when the entry list changes, and after returning from the editor, Settings or the export screen. Tests: `test/reminder_test.dart`, `integration_test/feat008_reminder_ui_test.dart` (the clock is passed in as `now`).
- Gotcha found by tests: anything a screen does after coming back from another screen can run after the app locked and closed the journal. Wrap such calls in try and catch (as `_refreshReminder` does).

- Search: FTS5 inside the encrypted database; queries are built by `searchQueryFor` from words only (punctuation is dropped, so user input cannot change the query). A schema change that touches `entries` must keep the three triggers; the first real migration follows ADR-006 and must rebuild the index.
- Language: every visible string is a getter on `S` in `app/lib/l10n/strings.dart` with an English and an Indonesian text, generated pairs are checked by `test/settings_test.dart`. A new string needs both texts. Changing the language redraws every open screen (`_ShellState._onSettings` marks all elements dirty). Never write `const Text(S.x)`: the value changes with the language.
- Settings storage: theme and language in plain `prefs.json` (needed before unlock); lock timeout inside the encrypted journal; face and fingerprint on means the key store holds the biometric copy. Changing the passcode re-wraps the same data key and swaps the vault file atomically.
- Screens that scroll: the timeline is one `CustomScrollView` (search field, reminder and list) so large text cannot push entries off the screen. Tests reach rows with `ensureVisible`.
- Emulator performance numbers are not stable between sessions (TC-019). Compare only inside one session, and judge targets on the reference device.
- CI (`.github/workflows/ci.yml`, written 2026-09-20, not yet run): analyze and unit tests, a check that the generated database code is up to date, a release APK build followed by `app/tool/check_release_manifest.sh` (fails on any permission outside its allow-list, cloud backup on, or a debuggable build), the registry and preflight checks, and a scan for secrets and local paths. The screen tests are not in CI (they need an emulator). If a new permission is truly needed, it needs an ADR first, then a line in the allow-list of the script.
- Icons: use `AppIcons` (`app/lib/theme/app_icons.dart`), never `Icons.*`. To add one, look up its code point in the Lucide `info.json` (lucide-static), add it there, and list it in the asset register.
- App icon: run `python tool/make_icons.py` from `app/` to regenerate every Android and iOS icon from the two brand colours (no packages needed). To use different artwork, replace the generated files instead and note it in the asset register. The launcher name is `android:label` in `AndroidManifest.xml`.
- Real-device bug found 2026-09-23 (FEAT-011): `EditorPage._addPhoto` (`app/lib/journal/editor_page.dart`) only wrapped `repository.addPhoto` in try/catch; the `pickCompressedPhoto` call that drives `image_picker`'s real platform channel (camera or library) ran outside it. Any exception there (permission denial, camera error, and similar) was unhandled, so adding a photo appeared to silently do nothing, in both create and update, with no `_photoAddFailed` banner and no test catching it - `photo_strip_widget_test.dart` never exercises the real picker (see its own file comment). Fixed by moving the picker call inside the same try block. This path still has no automated test: `pickCompressedPhoto` calls `ImagePicker()` directly with no seam to inject a fake, and `EditorPage` itself has no widget test at all (a known gap already recorded in `../context.md`). Verifying this on a real device is still open.
