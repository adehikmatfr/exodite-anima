# Threat Model: exodite-anima v1

Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): abuse cases beyond the attacker paths below. Method: skill `threat-modeling`. Migrated from the earlier draft and revised on 2026-09-20.

| Field | Value |
|-------|-------|
| Threat model ID | THR-001..015 (one ID per threat row; this header groups them) |
| Scope | The whole app: FEAT-001 to FEAT-009, ADR-001 to ADR-005 |
| Tier | T1 with escalations: journal content is highly sensitive personal data (`_shared/project.md`) |
| Author / reviewer | cyber-security / **not independently reviewed** (the same assistant wrote the earlier draft) |
| Date / next review | 2026-09-20 / after the technical spike, before the first store release, and at every trust-boundary change |
| Related | ADR-001 to ADR-005, RISK-001, RISK-003, RISK-005, RISK-009, RISK-010, `../../software-architect/report/c4-diagrams.md` |

## 1. Assets
| Asset | Data class | Why it matters (confidentiality / integrity / availability) |
|-------|-----------|-------------------------------------------------------------|
| Journal entries (text, dates) | Restricted (`data-governance.md`) | Confidentiality is the product; integrity and availability matter because there is no cloud copy |
| Data key (ADR-001) | Restricted | Exposes every entry if leaked; losing it loses every entry |
| App passcode | Restricted | Guards the passcode-wrapped copy of the data key |
| Export archives (ADR-003) | Restricted when plaintext; protected when encrypted | Leave the app's protection once created |
| Export password | Restricted | Protects encrypted archives |
| Release signing keys and store accounts | Restricted | Whoever holds them can publish an update to every user |

## 2. Trust boundaries and data flows
| Boundary | From -> to | Data crossing | Controls at crossing |
|----------|-----------|---------------|----------------------|
| B1 Device owner to app | Person -> app UI | Passcode, biometrics, entry text | Lock screen, auto-lock, biometric with passcode fallback (FEAT-003) |
| B2 App to local storage | App -> database and files | Entries (encrypted) | Whole-file database encryption (ADR-002), key in the OS key store (ADR-001) |
| B3 App to OS services | App -> key store, biometrics, clipboard, notifications, backup | Key material, prompts | Hardware-backed storage where available, no content in notifications, backup exclusion |
| B4 App to user-chosen destination | App -> share or save dialog | Export archive | Encrypted by default; plaintext only after a warning (FEAT-006) |
| B5 Untrusted file to app | Archive -> importer | Archive bytes | Authenticated decryption, exact-name reads, size limits, atomic apply (ADR-003, FEAT-007) |
| B6 App to network | none | none | No network permission on Android release builds, checked in CI (ADR-005); review and traffic test on iOS |
| B7 Build and release to store | Build machine -> store -> user devices | The signed app | Signing key custody, store account protection, release checklist |
| B8 Third-party code to app | Dependencies -> app | Code that runs with the app's rights | Dependency review, pinned versions (`dependency-review.md`) |

## 3. Actors and assumptions
- **Nearby person**: brief physical access to a locked or unlocked phone (partner, friend, colleague). The primary realistic attacker.
- **Thief or finder** of a locked phone who may copy app files and try the passcode offline.
- **Someone who obtains an export file** (shared drive, email, cloud folder).
- **Malicious or malformed archive** offered for import.
- **Compromised or abandoned dependency**, and a **compromised build or signing key**.
- Assumptions that would invalidate this model if false: the OS key store works as documented; the vetted crypto libraries are correct; the OS itself is not compromised (THR-013).
- Out of scope: shoulder surfing while the user writes, and malware on a rooted or jailbroken phone.

## 4. Threats (STRIDE)
Likelihood 1-3 x Impact 1-3 = Score 1-9. Score 6-9: mitigate before release. 3-5: owner and date. 1-2: accept. Status is `verified` only with evidence. Evidence exists for many controls (tests on the host and the Android emulator, see the update below the table), but none has been checked on a physical phone or independently, so every status stays `open` except the two accepted risks. "TC-: QA will assign" until the test plan exists.

| ID | Boundary | STRIDE | Threat | L | I | Score | Mitigation (control and where it lives) | Verification | Owner | Status |
|----|----------|--------|--------|---|---|-------|------------------------------------------|--------------|-------|--------|
| THR-001 | B1 | I | A nearby person opens the app on an unlocked phone and reads entries | 3 | 3 | 9 | Lock at cold start and after the timeout (FEAT-003) | Lock tests: cold start, background timeout | cyber-security | open |
| THR-002 | B2, B3 | I | A thief copies the app's files and reads entries | 2 | 3 | 6 | Encrypted database and media; data key in the OS key store, never stored readable (ADR-001, ADR-002) | Raw-file test of the database, its journal and write-ahead files, and media, without the key | cyber-security | open |
| THR-003 | B3 | I | Entries leak through automatic OS cloud backup | 2 | 3 | 6 | Exclude app data from cloud backup on both platforms (ADR-001 #5). Android configured 2026-09-20 (`allowBackup` is false in the release APK); iOS not built (architecture finding F2) | Inspect merged manifest and file attributes; restore test from a real backup | frontend-mobile | open |
| THR-004 | B1, B3 | I | Content shown in the app-switcher preview, screenshots, or screen recording | 3 | 2 | 6 | Obscure the preview when backgrounded (`BlockSemantics` added 2026-09-23 so this also removes the content from the accessibility tree, not just the paint layer, see the update below); Android screenshots and recording blocked by the secure-window flag in release builds (decided and built; iOS not built) | Manual check on both platforms, including with a screen reader on | product-design, frontend-mobile | open |
| THR-005 | B3, B6 | I | Content leaks through logs, crash reports, notifications, the clipboard, or the network | 2 | 3 | 6 | No content in logs or notifications, telemetry off, no network permission on Android release (ADR-005) | Log and traffic inspection; merged-manifest check in CI | cyber-security | open |
| THR-006 | B4 | I | A plaintext or weakly protected export file is leaked (for example saved to a synced folder) | 2 | 3 | 6 | Encrypted by default; plaintext needs a warning; the app never uploads (FEAT-006) | Export tests for the default and the warning | cyber-security | open |
| THR-007 | B1, B2 | I | Offline brute force of the passcode-wrapped key or of an export password | 2 | 3 | 6 | Memory-hard key derivation with stored parameters (ADR-001, ADR-003); passcode rules (FEAT-004, built) and wait after wrong tries (FEAT-003, built); recommended: also bind the wrapped key to the device (`adr-security-review-v1.md`, R1) | Review of parameters on the lowest-tier device; lock-screen tests | cyber-security | open |
| THR-008 | B5 | T, D | A crafted archive uses path traversal, oversized entries, or a decompression bomb | 2 | 2 | 4 | Read only exact file names; limits on file count and size; atomic import (ADR-003, FEAT-007). Numeric limits are provisional pending the owner | Malformed-archive fixtures | cyber-security | open |
| THR-009 | B5 | T | A plaintext archive is modified before import | 1 | 2 | 2 | Encrypted archives are authenticated; plaintext checksum only against accidents | none possible for plaintext | project owner | accepted by the owner 2026-09-20 (RISK-009) |
| THR-010 | B2 | T, D | A crash mid-write or a faulty migration corrupts or loses entries | 2 | 3 | 6 | Transactional writes, autosaved drafts, migration tests for every schema step (ADR-002, ADR-003) | Crash-injection and migration tests | frontend-mobile, qa | open |
| THR-011 | B1 | D | The user forgets the passcode and loses the journal | 3 | 3 | 9 | Setup warning the user must acknowledge (FEAT-004); export reminders (FEAT-008); accepted by design in ADR-001 | Acknowledgment test; wording review | product-manager | open (residual accepted, RISK-001) |
| THR-012 | B8 | T, E | A compromised or abandoned dependency exposes data or breaks encryption | 1 | 3 | 3 | Few dependencies, pinned versions, review before adding (`dependency-review.md`) | Dependency review at each addition; scan when tooling exists | cyber-security | open |
| THR-013 | B2, B3 | I | Malware or a compromised OS reads app memory or the unlocked data | 1 | 3 | 3 | Cannot be fully defended; hardware-backed key storage where available; key cleared from memory on lock | none possible beyond design review | project owner | accepted by the owner 2026-09-20 (RISK-010) |
| THR-014 | B7 | S, T, D | Release signing key or store account is stolen or lost, so a malicious update is published, or updates become impossible | 1 | 3 | 3 | Keep keys out of the repository; use store-managed signing where offered; strong authentication on store accounts; offline copy of any key that cannot be recreated | Release checklist before each submission | project owner | open |
| THR-015 | B6, B7 | T, I | A release build ships misconfigured: network permission present, debug logging on, or debug signing | 2 | 3 | 6 | CI check of the merged release manifest (written, not yet run); release build flags checked by the release checklist (ADR-005); the release is still signed with the debug key | CI check; inspection of the release artifact | frontend-mobile | open |

## 5. Attacker paths and chained threats
| # | Path | Threats chained | Combined effect | Control that breaks the chain |
|---|------|-----------------|-----------------|-------------------------------|
| AP-1 | Nearby person holds the phone, tries passcode guesses on the lock screen | THR-001, THR-007 | Reads entries if guesses are cheap | Wait that grows after wrong tries; passcode rules |
| AP-2 | Thief copies the app files, then attacks the wrapped key offline | THR-002, THR-007 | Decrypts everything if the passcode is weak | Strong key derivation; minimum passcode rules; device-bound wrapping (R1) |
| AP-3 | The phone's cloud backup contains the database and the wrapped key, and is attacked offline | THR-003, THR-007 | Same as AP-2 without touching the phone | Backup exclusion; same as AP-2 |
| AP-4 | User saves a plaintext export to a synced folder, the cloud account is compromised | THR-006 | Full journal read | Encrypted default; plaintext warning |
| AP-5 | A dependency quietly adds a network call and the release keeps the permission | THR-012, THR-015 | Journal exfiltration | Merged-manifest CI check; dependency review |

Chained score: AP-2 and AP-3 combine two threats that score 6 individually; both stay below 9 only if the passcode rules and key derivation are strong, which is why THR-007 must be closed before release.

## 6. Data handling decisions
| Data | Class | Stored where | Encrypted at rest / in transit | Retention and deletion | Logged? |
|------|-------|--------------|-------------------------------|------------------------|---------|
| Entries and drafts | Restricted | Encrypted local database | Yes / not transmitted | Until the user deletes them; deletion is permanent | Never |
| Data key | Restricted | OS key store, plus a passcode-wrapped copy | Yes / not transmitted | Lives with the journal | Never |
| Passcode | Restricted | Never stored; only derives a wrapping key | n/a | n/a | Never |
| Export archive | Restricted | Where the user saves it | Encrypted by default | User's responsibility after export | Never |
| Media (v1.1 and later) | Restricted | Encrypted separate files | Yes / not transmitted | Deleted with its entry | Never |
| Release signing keys | Restricted | Outside the repository | Yes | Kept for the app's life | Never |

## 7. Compliance and residual risk
- Frameworks touched (`compliance-matrix.md`): store rules and WCAG apply; UU PDP, PP 71/2019, and GDPR are Confirm (RISK-008).
- Residual risk: the owner accepted THR-009 (RISK-009) and THR-013 (RISK-010) on 2026-09-20, and the data-loss part of THR-011 (RISK-001) in ADR-001. Review date for these: 2026-12-20, with the risk register.

## 8. Verification plan
| THR | How verified | Evidence | Date |
|-----|--------------|----------|------|
| THR-001 | Lock tests: cold start, background timeout | pending | |
| THR-002 | Raw-file test including journal and write-ahead files | pending | |
| THR-003 | Manifest and attribute inspection; restore test | pending | |
| THR-004 | Manual check on both platforms | pending | |
| THR-005 | Log and traffic inspection; CI check | pending | |
| THR-006 | Export default and warning tests | pending | |
| THR-007 | Key-derivation parameter review on the lowest-tier device; lock-screen tests | pending | |
| THR-008 | Malformed-archive fixtures | pending | |
| THR-010 | Crash-injection and migration tests | pending | |
| THR-011 | Acknowledgment test and wording review | pending | |
| THR-012 | Dependency review at each addition | pending | |
| THR-014 | Release checklist | pending | |
| THR-015 | CI check and artifact inspection | pending | |

## Update 2026-09-20 (controls built)
Built and tested on the host and the Android emulator (evidence in the test cases and `qa/report/PRR-001-v1-android.md`): THR-001 lock at start, in the background and after the timeout; THR-002 encrypted database (raw files hold no text); THR-003 Android cloud backup off; THR-004 content cover and secure window; THR-006 encrypted export by default, warning for the plaintext one; THR-007 Argon2id, passcode rules and the wait; THR-008 own ZIP reader with limits, hostile-file tests; THR-010 transactions, drafts, atomic import and passcode change; migration safety (ADR-006) built and proven against a real schema-1 fixture 2026-09-23, still for FEAT-010/v1.1 only, nothing released yet; THR-011 setup warning and export reminder; THR-012 pinned packages. Not built or not verified: iOS parts of THR-003 and THR-004, the device-bound key (THR-007 R1), release signing (THR-014), the CI check (THR-015), no content in logs and requests (TC-083, TC-086).

## Update 2026-09-23 (FEAT-010 review, `security-requirements-review`)
FEAT-010 (tags, mood, and On this day) was reviewed against the register at the product-manager/software-architect hand-off trigger ("personal data" in the FEAT-010 spec). Conclusion: **no new `THR-` and no new trust boundary.**

- Mood and tags are the same Restricted data class as entry text (`context.md` asset table, "Journal entries and drafts"), stored in the same encrypted database (B2) and carried by the same encrypted export envelope (B4). They add fields, not a new asset or a new boundary.
- They are covered by the existing controls and threats: THR-001 (lock), THR-002 (encrypted database, raw-file test must now also cover the `tags`/`entry_tags` tables and the `mood` column), THR-004 (screen privacy: the "On this day" card and mood/tag chips must be covered by the same preview-cover and secure-window checks as entry text), THR-006 (export), THR-013 (memory).
- **THR-010 is the one to watch.** Its mitigation already names ADR-002 and ADR-003 but was written when "no migration yet" existed (see the update above). FEAT-010's schema step (ADR-002 update, ADR-003 update, both 2026-09-23) is the first migration THR-010 will actually be tested against. Mitigation reference for THR-010 should be read as also covering ADR-006 (the migration safety rules) once frontend-mobile implements them; this note stands in for editing that row until this ADR is next revisited.
- No new residual risk beyond RISK-001 and RISK-002, already registered against FEAT-010 in `product-manager/features/FEAT-010-tags-mood-and-on-this-day.md`.

Nothing here blocks FEAT-010 from being built; qa should extend the THR-002 and THR-010 verification steps (raw-file test, migration test) to include the new tables/column when TC-s are written.

## Update 2026-09-23 (real finding while verifying FEAT-010 AC-9, affects THR-004 on every screen, not just FEAT-010)
While checking that the privacy cover (`_Shell`'s `builder` in `app/lib/main.dart`, FEAT-003) also hides mood and tags, found that it never fully worked: the cover painted an opaque box over the current screen when the app was backgrounded, but did not remove that screen from the accessibility tree. A screen reader (TalkBack, VoiceOver) could still reach the covered screen's content - entry text, and now mood and tags - through touch exploration or linear navigation, even though nothing was visible on screen. This gap existed since FEAT-003 shipped; FEAT-010 did not create it, but exercising AC-9 is what surfaced it.

- Verified directly, not assumed: a minimal reproduction (`Stack` with a `ColoredBox` cover over a `Text`) showed the label was still reachable via the real assembled `SemanticsNode` tree (`find.semantics.byLabel`, the finder that reflects what an actual screen reader receives - a first attempt using `find.bySemanticsLabel` gave a false positive, because that finder reads each `RenderObject`'s local, unmerged semantics data and does not respect tree-pruning). Adding `BlockSemantics` around the cover removed the leak in the same reproduction.
- **Fixed** in `app/lib/main.dart`: the privacy cover is now wrapped in `BlockSemantics`, which drops the semantics of everything painted before it in the same container. `flutter analyze` clean, full suite (122 tests) still passes.
- Not covered by a permanent automated test: a full-app widget test (`JournalApp` with a real entry, backgrounded, checking the real semantics tree) was attempted but hung indefinitely in this environment, most likely a platform-channel call (e.g. `path_provider`) blocking forever with no device or plugin mock available; it was removed rather than left flaky. TC-023 ("no entry content visible in the preview") is `manual`, and should now explicitly include a screen-reader check, not just a visual one, the next time it is run by hand or as an emulator/device integration test.
- This is a correction to THR-004's mitigation, not a new threat: "obscure the preview" always meant "so nothing is exposed," and now it actually does that for assistive technology too.

## Update 2026-09-23 (real finding on a physical device, FEAT-011 photos: a deliberate, bounded weakening of THR-001's mitigation)
The owner's first physical-phone test of FEAT-011 found that adding a photo from an existing entry appeared to work, but the photo was then gone and the app was back on the timeline, asking for the passcode again. Cause: opening the camera or the photo library backgrounds the app the same way switching to any other app does, and THR-001's mitigation ("lock at cold start and after the timeout") is built as *immediate* by default (`lockTimeout: Duration.zero` in `app/lib/main.dart`) - it closed the database and wiped the key before `image_picker`'s result, delivered only once the app resumes, could ever reach `EntryRepository.addPhoto`.

- **Fixed** with `AutoLockGuard` (`app/lib/lock/auto_lock_guard.dart`, ADR-002 update 2026-09-23 has the full mechanism): `EditorPage._addPhoto` holds a counter while its whole picker-and-save operation is in flight; `_ShellState._lock()` defers instead of running while any hold is active, and applies the deferred lock the instant the last hold ends. The passcode is still required again after using the camera or the library - THR-001's mitigation is not removed, only delayed until the photo has somewhere safe to land.
- **Residual risk, not closed by this fix:** for as long as a hold is active - bounded to the time the user is actually inside the camera or library app, normally seconds - someone who takes the unlocked phone during exactly that window and backs out into the app (not the camera/library app itself) would reach a still-unlocked `EditorPage` without a passcode prompt. THR-004's mitigation (the privacy cover, `FLAG_SECURE`) is unaffected and still applies throughout, so nothing is exposed in the recents/app-switcher snapshot during the hold; the exposure is limited to whichever screen is live, for that one bounded window. This is a deliberate trade-off made to fix a real, owner-reported data-loss bug, not yet independently reviewed. Recorded here as an open item for the next independent or formal review (RISK-005), rather than folded into THR-001's mitigation text as if it were already settled.
- **A testing-infrastructure correction to the note two updates above:** that note said a full-`JournalApp` widget test "hung indefinitely... most likely a platform-channel call (e.g. `path_provider`)". The actual cause was narrower and now confirmed: `_ShellState._boot` calls `SystemBackupFiles.clearLeftovers()` unconditionally, which calls `path_provider`'s `getTemporaryDirectory()` - a real platform channel with no handler under `flutter test`, so the call never returns. Passing `JournalApp(files: FakeBackupFiles())` avoids it entirely. `app/test/auto_lock_guard_test.dart` now pumps the real `JournalApp` shell successfully (with `tester.runAsync` for the real database open, the same pattern `photo_strip_widget_test.dart` already uses) and proves the lock-deferral behaviour above end to end, including the baseline (no hold: still locks immediately) for contrast. The screen-reader gap from the update above still has no permanent automated test; that specific limit (semantics tree assertions, not the platform channel) stands.
