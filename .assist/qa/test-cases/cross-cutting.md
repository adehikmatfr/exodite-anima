# Test cases: cross-cutting (privacy, security, accessibility, compatibility)

Plan: TP-001. Cases `TC-083` to `TC-091`. These verify properties that belong to no single feature: no network, backup exclusion, no content in logs, release build hygiene, accessibility, and OS compatibility. No acceptance criterion covers them yet; they are raised to the product-manager in TP-001 section 7. Nothing is executed yet.

### TC-083: Verify a complete test run makes no network request carrying content

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001, FEAT-003, FEAT-006, FEAT-007 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-005, NFR-12, ADR-005 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A release build on a test device with traffic inspection. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Run every journey (setup, write, search, lock, export, import, settings) while capturing network traffic | synthetic | No outbound request is captured |

Note: iOS has no permission to remove, so this is the main iOS control.

Execution log: Second physical phone (Infinix X689B, Android 11, arm64), release APK installed with `adb`, driven by `uiautomator` taps, 2026-09-20: Partial. A run of onboarding, saving an entry, locking by Home and unlocking made no request that could carry content because the app cannot open a network connection: the installed package requests no INTERNET permission and its process is not in the network group (no gid 3003). No traffic was captured, and export, import and search were not part of this run.

### TC-084: Verify the merged Android release manifest declares no network permission

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001, FEAT-006, FEAT-007 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-015, NFR-13, ADR-005 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A release build with all plugins merged. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Read the merged manifest of the release build | synthetic | No network permission is present |
| 2 | Add a test dependency that requests one | synthetic | The check fails |

Note: Automated in CI when CI exists.

Execution log:

| Date | Build | Environment | Result | Evidence | Defect |
|------|-------|-------------|--------|----------|--------|
| 2026-09-20 | 1.0.0+1 release APK built from the Flutter template (no app code) | Local Windows machine, Android build tools 36.0.0 | Pass, informal (template app only) | `aapt2 dump permissions` on the release APK lists no network permission (only an AndroidX-internal receiver permission); the debug APK lists `android.permission.INTERNET`. Meaningless for feature code until packages are added; needs the CI check. | none |
| 2026-09-20 | 1.0.0+1 release APK of the full app, 58.8 MB | Local Windows machine, Android build tools 36.0.0 | Pass locally; not yet in CI | `aapt2 dump permissions` lists only USE_BIOMETRIC, USE_FINGERPRINT and the app's own non-exported receiver permission. `app/tool/check_release_manifest.sh` passes on it and fails on a debug APK (INTERNET, debuggable). The CI job that runs it is written (`.github/workflows/ci.yml`) but has not run yet. | none |

### TC-085: Verify app data is excluded from cloud backup and is absent after a restore

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001, FEAT-004 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-003, ADR-001 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | manual |
| Status | draft |
| Owner | qa |

**Preconditions:** A test device with backup enabled. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Create a journal, run a backup, then restore to a clean device or reinstall | synthetic | The app opens as a fresh install with no journal data |

Note: Gap G11: not configured in the project yet.

Execution log: Second physical phone (Infinix X689B, Android 11, arm64), release APK installed with `adb`, driven by `uiautomator` taps, 2026-09-20: Partial. The installed package's flags on the device are HAS_CODE and ALLOW_CLEAR_USER_DATA only (no ALLOW_BACKUP, not debuggable), so system backup does not include app data. A real backup and restore was not run.

| Date | Build | Environment | Result | Evidence | Defect |
|------|-------|-------------|--------|----------|--------|
| 2026-09-20 | 1.0.0+1 release APK built from the Flutter template (no app code) | Local Windows machine, Android build tools 36.0.0 | Partial | `allowBackup` is `false` in the release APK manifest (Android). The restore-from-backup part was not run, and iOS is not built. | none |
| 2026-09-20 | 1.0.0+1 release APK of the full app | Local Windows machine | Partial | `android:allowBackup=false` is in the merged manifest and checked by `check_release_manifest.sh`. A backup and restore on a device was not run. iOS exclusion is not built. | none |

### TC-086: Verify logs of a full run contain no entry text, passcode, or key

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001, FEAT-003, FEAT-004 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-005 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A release build with device logs captured. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Run every journey with known synthetic words and a known passcode | synthetic | None of them appears in the logs |



Execution log: Second physical phone (Infinix X689B, Android 11, arm64), release APK installed with `adb`, driven by `uiautomator` taps, 2026-09-20: Partial. The full device log of one run (about 17,700 lines: launch, passcode setup, saving an entry containing a marker word, Home, return, unlock with the passcode) was searched for the marker word and for the passcode: no match. Other flows (search, export, import, settings) were not in the run.

### TC-087: Verify every screen is usable with a screen reader in a logical order with labels

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004, FEAT-001, FEAT-003 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | NFR-17 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | manual |
| Status | active |
| Owner | qa |

**Preconditions:** A test device with the screen reader on. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Move through every screen with the screen reader | synthetic | Each control has a label, the order is logical, and every action can be completed |



Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. TalkBack through unlock, write, save, search, export and settings.

### TC-088: Verify all screens stay readable at 200 percent system font size in both themes

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-004, FEAT-001, FEAT-009 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | NFR-17 |
| Level | e2e |
| Priority | P1 |
| Type | boundary |
| Automation | manual |
| Status | active |
| Owner | qa |

**Preconditions:** The system font size at the largest setting. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Open every screen in the light and the dark theme | synthetic | No text is clipped or overlapping and every control can be reached |



Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Largest system font and display size in light and dark themes. Both languages on every screen were not stated.

### TC-089: Verify text contrast and touch targets meet the design tokens in both themes

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-009, FEAT-004 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | NFR-17 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | manual |
| Status | draft |
| Owner | qa |

**Preconditions:** Both themes. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Measure contrast of every text and control pair, and the size of every tappable element | synthetic | Text contrast is at least 4.5 to 1 and targets at least 44 pt (iOS) or 48 dp (Android) |



Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Partial. Both themes looked at by eye; contrast was not measured on the phone.

### TC-090: Verify launch, unlock, save, search, export, and import on the supported OS versions

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001, FEAT-003, FEAT-006, FEAT-007 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | NFR-16 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The supported OS versions are decided. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Run the smoke journey on the current and the previous major version of each platform | synthetic | Every step works |



Note: The OS minimums are decided (Android 7.0 / API 24, iOS 13). The device list and the low-end reference device are not, and iOS cannot be run locally.

Execution log: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Partial. One phone and one Android version only, so 'supported OS versions' is not covered. Then: Second physical phone (Infinix X689B, Android 11, arm64), release APK installed with `adb`, driven by `uiautomator` taps, 2026-09-20: onboarding, saving, lock and unlock work on Android 11 (API 30). With the owner's earlier phone that makes at least two devices; the supported version range is still not covered.

### TC-091: Verify a release build has no debug logging and is signed with the release key

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-001, FEAT-003 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | THR-015, THR-014 |
| Level | integration |
| Priority | P0 |
| Type | negative |
| Automation | manual |
| Status | draft |
| Owner | qa |

**Preconditions:** A release build. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Inspect the built artifact and its signature | synthetic | Debug flags are off and the signing key is the release key |

Note: Depends on the release process.

Execution log: Then, 2026-09-20: release key created by the owner (outside the repository); `flutter build apk --release --split-per-abi` now signs with it. `apksigner verify --print-certs` shows the same certificate (SHA-256 1eb278fb...07892e4) on the arm64-v8a, armeabi-v7a and x86_64 APKs, not the debug certificate, and `app/tool/check_release_manifest.sh` passes (not debuggable). Partial overall: the check for debug logging in a release build was not done beyond TC-086's device-log search. The earlier failure (debug key) is resolved.

| Date | Build | Environment | Result | Evidence | Defect |
|------|-------|-------------|--------|----------|--------|
| 2026-09-20 | 1.0.0+1 release APK built from the Flutter template (no app code) | Local Windows machine, Android build tools 36.0.0 | **Fail** | `apksigner verify --print-certs` shows the release APK is signed by `CN=Android Debug`. The manifest is not debuggable. Debug logging was not inspected. | none |
| 2026-09-20 | 1.0.0+1 release APK of the full app | Local Windows machine | **Fail** | The release build is still signed with the debug certificate (`app/android/app/build.gradle.kts` uses the debug signing config); a store upload needs a release key kept outside the repository. Debug logging was not checked. | open: release signing not set up |

