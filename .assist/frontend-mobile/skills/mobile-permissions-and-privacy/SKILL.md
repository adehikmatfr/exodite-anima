---
name: mobile-permissions-and-privacy
description: Use when adding, changing or reviewing an OS permission, tracking or analytics SDK, data collection, rationale string, or privacy label / data-safety declaration in a mobile app.
---
# Mobile Permissions and Privacy

## Purpose
Collect the least data and hold the fewest permissions needed, ask at the right moment, and keep code, store declarations and legal obligations in agreement.

## When to use
- A feature touches camera, microphone, location, contacts, photos, notifications, Bluetooth, health, biometrics, or files.
- Adding an SDK (analytics, ads, crash, payments, maps).
- Preparing a store submission or a privacy/DPIA review.

## Principles
- **Least privilege:** prefer the narrowest API (photo picker over full library, approximate over precise location, foreground over background location, one-time over always).
- **Just in time:** ask on the user action that needs it, never at launch. Pre-prompt (own screen) explains value; OS prompt follows only after user taps continue. iOS gives one system prompt; a denial cannot be re-asked, so protect it.
- **Degrade, don't block:** denial or later revocation leaves the app usable, with a path to Settings.
- **Minimise:** collect only fields with a named purpose; set retention; no unique cross-app identifiers without consent.
- **Truthful declarations:** SDK behaviour counts as your behaviour.

## Steps / Checklist
1. **Justify:** for each permission write purpose, feature (`FEAT-`), data class (`data-governance.md`), retention, and fallback. No justification, no permission.
2. **Narrowest API:** confirm no lighter alternative exists (e.g. `ACTION_OPEN_DOCUMENT`, `PHPicker`, `ACCESS_COARSE_LOCATION`, `POST_NOTIFICATIONS` requested after first value moment).
3. **Rationale strings:** specific and truthful, 1-2 sentences, localised (`i18n-and-localisation`). Bad: "Needed for app". Good: "Camera is used to scan the invoice barcode; images are not stored."
4. **Flow:** check state -> if not determined, pre-prompt -> OS prompt -> handle granted / denied / limited / restricted / revoked-in-background. Recheck on every foreground.
5. **Tracking consent:** ATT prompt only if you track across apps; consent for analytics/ads before SDK initialisation where GDPR/UU PDP applies; store consent with timestamp and version; provide in-app withdrawal.
6. **SDK audit:** list each SDK, data it collects, whether it is linked to identity, its purpose; remove unused ones; disable auto-collection until consent (e.g. advertising ID, Firebase analytics collection flag).
7. **Data handling:** location precision reduced or coarsened before upload; images stripped of EXIF; contacts hashed if matching; nothing sensitive in logs, clipboard, screenshots (secure flag / blur in task switcher) or backups (exclude from auto-backup).
8. **Declarations:** update iOS privacy manifest + nutrition label and Android data-safety form in the same PR that changes collection. Reviewer signs off.
9. **Compliance mapping:** map each collected data type to the rows of `compliance-matrix.md` (UU PDP: lawful basis, consent, deletion, breach 3x24 h; GDPR: DPIA, erasure; CCPA opt-out; PCI if card data) and log evidence in its Evidence log.
10. **Data-subject rights:** in-app account and data deletion; export where required; deletion propagates to backend and processors.
11. **Tests:** grant, deny, deny-forever, revoke while running, limited-photos, restricted (parental) modes; `TC-NNN` each.

## Output format
Permission register table: permission | feature `FEAT-NNN` | data class | API used | rationale string (key) | denial fallback | declaration updated (Y/N) | compliance row.

Worked example: "Nearby stores" needs location. Use `WhenInUse` coarse only; pre-prompt on tapping "Find near me"; on denial show manual city search. Data safety: approximate location, collected, not shared, purpose app functionality.

## References
`../_shared/standards/data-governance.md`, `security-baseline.md`, `../_shared/compliance/compliance-matrix.md`. IDs: `FEAT-`, `THR-`, `DS-`. Common skills: `frontend-security`, `client-error-handling-and-telemetry`.

## Language notes
- iOS: `Info.plist` usage keys, `PrivacyInfo.xcprivacy`, `ATTrackingManager`. Android: runtime permissions via `ActivityResultContracts.RequestPermission`, `shouldShowRequestPermissionRationale`, `android:allowBackup="false"` or data-extraction rules.
- RN: `react-native-permissions`; Flutter: `permission_handler`; both still need native manifest entries.
