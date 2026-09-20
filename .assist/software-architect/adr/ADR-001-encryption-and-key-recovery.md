# ADR-001: Encrypt data in the app, unlock with biometrics and passcode, no key recovery

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-09-20 |
| Deciders | Project owner |
| Consulted | none (solo project); cyber-security and software-architect roles applied |
| Reversibility | one-way door (cost to undo: migrating every user's stored data and export archives; realistic only via a versioned migration) |
| Related | FEAT-003, FEAT-004, FEAT-006, FEAT-009, RISK-001, RISK-003, RISK-005, THR-001 to THR-013 |
| Review date | Before the first store release, or when a recovery/sync feature is requested |

## Context

exodite-anima is a fully private journaling app for iOS and Android with no backend and no accounts. All data lives on the device. The main promise is privacy, so the claim must hold against the realistic threats:

- Someone holding an unlocked phone (partner, friend, borrowed phone).
- Device backups (iCloud, Google) and copies of app files.
- Export files that end up somewhere the user did not intend.
- Loss or replacement of the device.

There is no server, so there is nothing to hold a recovery secret. Whatever recovery model is chosen is entirely the user's responsibility.

### Quantified requirements (drivers)

| NFR | Target | Measured by | Source |
|-----|--------|-------------|--------|
| Entries unreadable from a copy of the app's files without the key | 100% | Test that stored database and media contain no plaintext entry text | Product principle "private by construction" |
| Unlock latency after biometric success | Under 1 s to first entry list on a mid-range device | Manual timing on a low-end test device | Usability |
| No entry content in logs, crash reports, screenshots in app switcher | 0 occurrences | Test and mutation check | project.md working rules |
| Restore from export on a new device | Full data restored, verified by round-trip test | Round-trip test | Product principle "user owns the data" |

## Options considered

### Option A: Application-level encryption, biometric + passcode unlock, no recovery
- Summary: The app generates a random data key at setup and encrypts the database and media files with it. The data key is protected by the OS Keychain/Keystore (unlocked by biometrics) and by a second copy wrapped with a key derived from an app passcode. There is no recovery mechanism: if both the biometric path and the passcode are lost, the data is unrecoverable. Export is the safety net.
- Pros: Content is unreadable without the key even if files or backups leak. Realistic protection against people with access to an unlocked phone. Simple and honest story: "we cannot recover it, because we never have it".
- Cons: Forgotten passcode plus no export means permanent loss. Cryptographic code adds risk if done wrong. Encrypted data complicates search.
- Cost / effort: Medium. Requires vetted libraries, key handling, and tests.
- Risks: User data loss (see New risks).

### Option B: Application-level encryption with a one-time recovery key
- Summary: Same as A, plus a long recovery code shown once at setup for the user to store.
- Pros: Lower chance of permanent loss.
- Cons: Users tend to store the code badly (screenshot, notes app), which weakens privacy. More UI and more states to test. Extra secret to explain.
- Cost / effort: Medium-high.
- Risks: Weak storage of the recovery code by users.

### Option C: No application-level encryption (OS sandbox and app lock only)
- Summary: Rely on OS sandboxing and full-device encryption, with an optional app lock screen.
- Pros: Simplest, no key management, no lockout data loss.
- Cons: The app lock only guards the UI. Files, backups, and exports remain readable. The privacy claim would be weaker than the product's positioning.
- Cost / effort: Low.
- Risks: Privacy claim not defensible.

### Option D: do nothing (baseline)
- Consequence of not deciding: Storage and export formats would be built without a key model, and adding encryption later would force a data migration for every user.

## Decision

We will use **Option A**: application-level encryption with a random data key, unlocked by biometrics with an app passcode as fallback, and **no key recovery**, because the privacy claim is the core of the product, the realistic threat is people near the user rather than remote attackers, and a recovery secret would either require a server (contradicting the product) or rely on the user storing it safely (weakening privacy).

Supporting decisions:

1. **Data key**: a random 256-bit key generated on the device at setup. Entries and media are encrypted with an authenticated cipher (for example AES-256-GCM or XChaCha20-Poly1305) using a vetted library. No custom cryptography.
2. **Key protection**: the data key is stored in the iOS Keychain / Android Keystore with access gated by biometrics, and a second copy is wrapped with a key derived from the app passcode using a memory-hard KDF (for example Argon2id). Either path unlocks the app.
3. **Setup warning**: setup states plainly that a forgotten passcode cannot be recovered, and the user must acknowledge it.
4. **Export**: archives are encrypted by default with a separate export password (Argon2id-derived key). A plaintext export (JSON/Markdown) is available as an explicit opt-in with a warning. The export password is independent of the app passcode.
5. **Backup exclusion**: app data is excluded from OS cloud backup, so the encrypted store is not silently copied elsewhere. The safety net is export, backed by reminders.
6. **Auto-lock and screen privacy**: the app locks after a short timeout, and hides content in the app switcher.

## Consequences

- Positive: Privacy claim is technically defensible. Leaked files or backups reveal no entries. Clear, simple user story.
- Negative / trade-offs accepted: Forgotten passcode means permanent loss unless an export exists. Full-text search over encrypted data needs a design decision (search after unlock, in-memory index, or encrypted index). Extra unlock friction on each session.
- Follow-up work:
  - ADR for the local database engine (encrypted storage, migrations, search).
  - ADR for the export/import archive format and `schemaVersion` strategy.
  - Threat model (THR) covering the threats listed in Context.
  - UX for setup warning, export reminders ("last export" indicator), and lockout states.
  - Choose and validate concrete Flutter libraries for secure key storage, biometrics, encryption, and KDF; confirm they support both platforms and are maintained.
- New risks: permanent data loss from forgotten passcode or lost device without export; biometric enrollment changes invalidating the Keystore-bound key (mitigated by passcode fallback); cryptographic implementation mistakes (mitigated by vetted libraries and tests).
- Assumptions to validate: users accept the no-recovery trade-off when clearly told (owner, before release); chosen libraries expose the required Keychain/Keystore access controls on both platforms (owner, before implementation).
- Exit strategy: change the key model through a versioned migration that decrypts with the old scheme and re-encrypts with the new one on unlock. Requires the archive and database formats to carry a version, which is already a project rule.

## Validation

- A test opens the stored database and media files without the key and asserts no plaintext entry text is present.
- Round-trip test: export, wipe, import on a clean install, verify all entries and media.
- Test that wrong passcode and cancelled biometrics never expose data, and that the passcode path works after biometric enrollment changes.
- Revisit this decision if a meaningful share of test users lose data from forgotten passcodes, or if an optional sync or recovery feature is proposed.

## Review record (2026-09-20)
Added when the ADR was moved into the software-architect role and checked against `adr-writing`. The decision is unchanged and remains accepted; nothing above was rewritten.

- **Quality gate:** decision fits one sentence: yes. Two or more real options: yes. Numbers in the drivers: partly. Negative consequences named: yes. Owner and review trigger: yes.
- **Unconfirmed number:** the driver "unlock in under 1 s after biometric success" was proposed by the assistant and is not confirmed by the owner. Treat it as `ASSUMPTION` (owner: project owner; validate on the lowest-tier device in the spike) until the pending decision `nfr-targets-v1` is made.
- **Not yet true in the code (verified 2026-09-20):** supporting decision 5 (exclude app data from OS cloud backup) is not implemented. The Android main manifest sets no `allowBackup` attribute, so cloud backup stays on by default. Follow-up for frontend-mobile: disable backup for the app's data on Android and set the exclude-from-backup attribute on stored files on iOS.
  - **Update 2026-09-20:** the Android part is done: `android:allowBackup="false"` is set in the main manifest and appears in the release APK. The iOS part is still open.
- **Consulted:** none. The cyber-security role reviews this ADR when the threat model is migrated.
- **Validation status (2026-09-20):** the key vault, wrong-passcode wait, passcode change, biometric copy and encrypted export are built and tested on the host and the Android emulator (`app/test/key_vault_test.dart`, `settings_test.dart`, `backup_test.dart`; screen tests). Not validated: the real biometric prompt and Keystore on a phone, iOS, and the device-bound key (R1). No independent review (RISK-005).
