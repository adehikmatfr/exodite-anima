# Permission and privacy register (version 1)

Method: skill `mobile-permissions-and-privacy`. Status: draft, 2026-09-20. Related: FEAT-003, FEAT-004, FEAT-006, FEAT-007, ADR-001, ADR-005, THR-003, THR-004, THR-005, RISK-007, `../../_shared/compliance/compliance-matrix.md`.

The app has no account, no server, no analytics, and no third-party SDK. The rule "no justification, no permission" therefore leaves one permission.

## Permission register
| Permission | Feature | Data class | API used | Rationale string | Denial fallback | Declaration updated | Compliance row |
|------------|---------|-----------|----------|------------------|-----------------|---------------------|----------------|
| Biometrics (Android `USE_BIOMETRIC`; iOS `NSFaceIDUsageDescription`) | FEAT-003, FEAT-004, FEAT-009 | none: the phone checks the face or fingerprint and the app never receives it | The platform biometric prompt, gating access to the key held in the OS key store (ADR-001) | iOS: "Face ID unlocks your journal on this phone. Your face data stays with iOS and is never seen by the app." (draft; must be localised) | The passcode always works (FEAT-003 AC-4, test case TC-024; changed biometrics: TC-028) | no: not yet declared | app store rules |

Read from the merged release manifest on 2026-09-20 (Android): `USE_BIOMETRIC` and `USE_FINGERPRINT` (both from `local_auth`; the second is the older name of the same right), and the app's own non-exported receiver permission added by AndroidX. There is no `INTERNET` permission. Since export and import were added (2026-09-20) the merged manifest also holds a `ShareFileProvider` (from `share_plus`, for handing the export file to the share sheet) and a `queries` element; neither adds a permission.

## Not requested in version 1, with reason
| Capability | Why not |
|------------|---------|
| Camera, microphone, photo library | Photos (v1.1) and audio (v1.2) are out of scope; when added, use the narrowest picker and a just-in-time prompt with its own explanation screen |
| Notifications | In-app reminders only in v1 (FEAT-008); a later daily reminder would request permission after the first value moment |
| Location, contacts, Bluetooth, health | Not needed |
| Storage or file access | Export and import use the system save, share, and file-picker dialogs, which need no storage permission |
| Network | None: content never leaves the device (ADR-005); no network permission on Android release builds |
| Tracking (iOS App Tracking Transparency) | No tracking across apps, so no prompt |

## SDK and dependency audit
| Item | Data collected | Linked to identity | Purpose | Decision |
|------|----------------|--------------------|---------|----------|
| Flutter framework and engine | none by the app | no | framework | approved (ADR-004) |
| sqlite3, drift, cryptography, flutter_secure_storage, local_auth, path, path_provider | none sent anywhere; no network permission | no | storage, keys, biometrics | reviewed 2026-09-20 in `../../cyber-security/report/dependency-review.md`; archives and file picking not chosen yet |
| Crash reporting, analytics, remote config, ads | not used | not applicable | none | rejected by product policy (`../../product-manager/decisions/free-private-positioning-policy.md`) |

## Data handling
| Concern | Rule | State |
|---------|------|-------|
| Logs | No entry text, passcode, or key in any log, release builds emit no content | not verified (TC-086) |
| Clipboard | The app never writes entry text to the clipboard; secure fields block copy | built: the app writes nothing to the clipboard and passcode fields are obscured (Flutter blocks copying from an obscured field); not tested on a device |
| Screenshots and task switcher | Content hidden in the app-switcher preview on both platforms; Android screenshots and screen recording blocked (decided 2026-09-20) | **Android**: secure-window flag set in release builds (`adb screencap` returned an empty image on the emulator); the app also covers its content when inactive. iOS not built; preview not looked at (TC-023, TC-094) |
| Backups | Excluded from OS cloud and device backup | **Android done 2026-09-20**: `android:allowBackup="false"` set in the main manifest; iOS exclusion attribute on stored files not built |
| Media metadata | Photos are not in version 1; when added, strip location and camera data unless the owner decides otherwise | not applicable yet |

## Store declarations plan
| Declaration | Intended answer | Condition | Owner | Reconciled with code |
|-------------|-----------------|-----------|-------|----------------------|
| Apple privacy nutrition label | Data Not Collected | Only true if ADR-005 is accepted and no SDK collects data | project owner (frontend-mobile prepares) | never |
| Apple privacy manifest (`PrivacyInfo.xcprivacy`) | Tracking false, no collected data types; required-reason API entries as the app and its packages use them | Determined at the first iOS build | frontend-mobile | never |
| Google Play Data safety form | No data collected or shared | Same condition | project owner | never |
| Apple export compliance (encryption question) | The app uses encryption (data at rest and encrypted exports); the exact answer needs the owner or counsel | Not legal advice; tracked as RISK-007 and decision `legal-applicability-confirmation` | project owner | never |
| Content and age ratings | To be answered at submission; journal content is private and not shared | none | project owner | never |

Declarations are updated in the same change that alters collection, permissions, or dependencies, and reconciled before each submission.

## Compliance mapping
Nothing is collected by the developer, so UU PDP and GDPR rows stay "Confirm" (`../../_shared/compliance/compliance-matrix.md`, RISK-008). Store rules apply now. If any data ever leaves the device, the Confirm rows become binding and this register must be redone.

## Tests
Biometrics granted, denied, and changed on the device (TC-024, TC-028); no network request (TC-083); no network permission in the release manifest (TC-084); backup excluded (TC-085); no content in logs (TC-086); denied or revoked biometrics while running (to be added when biometrics exist).
