# Technical spike plan

Purpose: prove, on real builds, the assumptions that ADR-001, ADR-002, ADR-003, and ADR-005 rest on, before feature work depends on them. RISK-004 stays open until this is done. Status: mostly done (2026-09-20): S1, S2, S6, S7 and S8 passed or decided; S3 and S4 partial; S5 not evaluated; S9 open. Android only. Owner: frontend-mobile with software-architect. Not scheduled: the project has no dates.

## Ground rules
- Spike code lives in its own folder (`app/spike/`, created when the spike starts), never in `app/lib/`, and is deleted or rewritten before feature work.
- Every package is reviewed before it is added (`../../cyber-security/report/dependency-review.md`): maintenance, licence, requested permissions, install-time scripts, and whether it adds a network permission (rejected unless ADR-005 is superseded). Versions are taken from the package registry on the day and pinned.
- Only synthetic data and made-up passcodes. Nothing from the spike is committed with keys or real content.
- Device evidence: the Android emulator `flutter_avd` (Android 14, API 34, x86_64) is available; iOS cannot be run locally, so iOS results stay open and are recorded as such. Emulator timings are not representative of a low-end phone.

## Questions and pass criteria
| # | Question | Evidence needed | Decides | Related cases |
|---|----------|-----------------|---------|---------------|
| S1 | Can an encrypted database be created, written, closed, reopened with the right key, and refused with a wrong key, with the packages ADR-002 names? | A short test program and its output | ADR-002 stays or is reopened | TC-009 |
| S2 | Does full-text search work inside the encrypted file, and is no plaintext index or cache created elsewhere? | Search query result; raw-file inspection of the main file, journal, write-ahead file, and temporary files | ADR-002 | TC-009, TC-040 |
| S3 | Can a random data key be created, stored in the OS key store, released by biometrics, and also recovered from a passcode-wrapped copy? | Working flow on the emulator with virtual biometrics; the passcode path independent of biometrics | ADR-001 | TC-024, TC-028 |
| S4 | Which key-derivation parameters give a slow-enough guess and an acceptable unlock time, and how long do they take on the emulator? | Measured times for a few parameter sets (not representative of low-end phones) | Security requirement G1; NFR-1 | TC-014 (blocked) |
| S5 | Does the device-bound wrapping recommended in the security review (R1) work, and what does it cost in complexity? (The owner asked for this evaluation.) | Prototype and a note; a recommendation to accept or reject R1 | Whether to supersede ADR-001 | none yet |
| S6 | Custom envelope or an existing standard (for example `age`) for encrypted exports; is there a maintained Dart library for the standard? | Library check and a working round trip of both options | ADR-003 envelope | TC-056, TC-058 |
| S7 | Can the importer enforce the file-count, unpacked-size, and entry-size limits safely, and reject the fixture files (traversal names, oversized entries, decompression bomb)? | Fixture archives and results | Security gap G7 | TC-065 |
| S8 | Does the merged Android release manifest stay free of network permissions with the chosen packages, and does backup stay excluded? | Read of the merged release manifest | ADR-005 | TC-084, TC-085 |
| S9 | What do the packages add to the iOS privacy manifest and to the Data safety answer? | Package review; iOS part open without a Mac | Declarations | `permission-and-privacy-register.md` |

## Sequence
1. Confirm the toolchain and record versions (done: Flutter 3.44.4, Dart 3.12.2, Android SDK 36, emulator API 34).
2. S1 and S2 (storage), then S3 and S4 (keys), then S6 and S7 (export and import), then S8 and S9 (release checks). S5 is included: the owner asked on 2026-09-20 that the device-bound wrapping (R1) be evaluated in the spike and decided with evidence.
3. After each step, record the result in this file and update the affected ADR review record.

## Exit criteria
The spike ends when: S1, S2, S3, S6, S7, and S8 each have a pass or a documented fail on Android; S4 has parameters and timings; S9 lists what remains for iOS; every failed item has an ADR follow-up. RISK-004 is re-scored with the evidence. If S1 fails, ADR-002 is reopened and superseded before any feature code is written.

## Results

### Versions and packages (2026-09-20)
| Package | Version | Publisher | Licence | Note |
|---------|---------|-----------|---------|------|
| sqlite3 | 3.5.2 | simonbinder.eu | MIT | 3.6.0 is not resolvable with Flutter 3.44.4 (Flutter pins `meta` 1.18.0; sqlite3 3.6.0 needs `record_use`, which needs `meta` ^1.19). The spike started on 3.6.0 in plain Dart and was re-run on 3.5.2 with the same result. |
| drift | 2.35.0 | simonbinder.eu | MIT | Added to the app; not used yet by the spike tests |
| path, path_provider | 1.9.1, 2.1.6 | dart.dev, flutter.dev | BSD-3 | Added to the app for file locations |
| SQLite3MultipleCiphers | bundled by the `sqlite3` build hook (`source: sqlite3mc`) | utelle | MIT (as stated by the project; confirm at release) | Default cipher: chacha20. The hook downloads a prebuilt binary from the package's GitHub release at build time and checks its sha256 against the published package; there is no network use at run time. |

### S1: encrypted database round trip: PASS (Android emulator, API 34; also Windows host)
Created with a 256-bit raw key, written, closed, reopened with the right key and read back; a wrong key and no key were both refused with an error. Evidence: `app/integration_test/spike_s1_s2_test.dart` (4 tests passed on `emulator-5554`). The cipher was confirmed as the multiple-ciphers build (`PRAGMA cipher` returns `chacha20`; SQLite 3.53.4). Not verified: iOS (no Mac).

### S2: full-text search and no plaintext on disk: PASS (Android emulator; also Windows host)
FTS5 works in the encrypted file. While the database was open in WAL mode, the main file, `-wal`, and `-shm` files contained neither marker string; the control test with an unencrypted database did contain the marker, so the inspection method can find plaintext. Not measured: search time at 20,000 entries (TC-045), and temporary files under memory pressure.

### S8: release manifest: PASS for the current packages (Android)
The release APK built with sqlite3, drift, path and path_provider has no `INTERNET` permission and `allowBackup=false`. The only permission entry is the app's own `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, added by AndroidX. The universal release APK is 47.7 MB (it carries the cipher library for every processor type); no size target is set. The check is not automated yet (no CI).


### S3: key created, wrapped by the passcode, biometric copy in the key store: PARTIAL (Android emulator, host)
Built and tested (`app/lib/security/key_vault.dart`, 11 unit tests on the host, 11 screen tests on the emulator): a random 256-bit data key is wrapped with AES-256-GCM under an Argon2id-derived key; a wrong passcode fails the authentication tag; the passcode and the key are not readable in the stored files; the passcode path works whether or not biometrics are on. The biometric copy sits in `flutter_secure_storage` and is released after the system prompt succeeds. Not verified: the real biometric prompt (tests use a fake), the real Android Keystore and iOS Keychain behaviour, and behaviour after a fingerprint is added.

### S4: key-derivation parameters: DONE for a provisional choice (emulator, profile build)
Measured with `cryptography` 2.9.0 (pure Dart), one lane unless noted: 19 MiB and 2 passes 210 ms; 32 MiB and 3 passes 339 ms; 64 MiB and 3 passes 566 ms; 64 MiB, 3 passes and 2 lanes 441 ms. **Chosen provisionally: 32 MiB, 3 passes, 1 lane**, stored next to the wrapped key so it can be raised. The emulator runs on a fast desktop processor; a low-end phone may be several times slower, and the passcode path is the slow path (biometric unlock skips it). To be re-measured on the reference device, which is not chosen yet (closes security gap G1 only then).

**Physical phone, 2026-09-20 (Infinix X689B, Android 11, arm64, profile build, five runs each, `app/integration_test/spike_s4_kdf_test.dart`):** 19 MiB, 2 passes, 1 lane: median 1,256 ms; **32 MiB, 3 passes, 1 lane (the current setting): median 2,953 ms, worst 3,339 ms**; 64 MiB, 3 passes, 1 lane (used for exports): median 5,776 ms, worst 7,413 ms; 64 MiB, 3 passes, 2 lanes: median 1,283 ms, worst 1,376 ms. The phone is about ten times slower than the emulator, and two lanes ran about four and a half times faster than one at the same memory and passes. This applies to unlocking with the passcode; unlocking with the biometric copy does not run the function. One phone only, and the run was a profile build. The owner then chose 64 MiB, 3 passes, 2 lanes (`product-manager/decisions/key-derivation-settings.md`); it is the default in `key_vault.dart` from 2026-09-20, and existing vaults keep their stored settings.

### S5: device-bound wrapping (R1): NOT EVALUATED
The biometric copy in the key store is protected by the operating system's storage but is not released by a hardware-enforced biometric check: the app asks for the prompt and then reads the key. A key that is bound to the biometric in hardware would need a native key-store integration that the chosen packages do not give. This stays open; ADR-001 is not changed.


### S6: envelope for encrypted exports: DECIDED (custom envelope on vetted primitives)
Two small Dart implementations of the `age` format exist on pub.dev (`dage`, last release 2024-02-04; `dartage`, 0.3.0, 2026-09-09); neither was verified as maintained or reviewed, so ADR-003's option D was **not adopted**. The envelope in `app/lib/backup/envelope.dart` uses AES-256-GCM and Argon2id from the already-reviewed `cryptography` package, and authenticates its whole header as associated data. Argon2id for exports is 64 MiB, 3 passes, 1 lane (about 0.57 s on the emulator), stored in the header; an importer refuses headers asking for more than 256 MiB, 10 passes, 4 lanes. Tests (`app/test/backup_test.dart`): round trip, no text or file names in the encrypted file, wrong password, a changed byte anywhere (header, body, tag), cut-off files, absurd key-derivation settings. Not done: an independent review of the envelope design (RISK-005 stays open).

### S7: safe import of untrusted archives: PASS for the cases tested (host)
Findings: the common ZIP packages unpack whole files, so a header that lies about its size cannot be stopped in time; the importer therefore has its own minimal ZIP reader (`zip_lite.dart`) that opens only `manifest.json` and `entries.json` by exact name, refuses encryption, ZIP64, split archives and unknown methods, and stops inflating the moment output passes the cap. Tested: path-trick names, missing files, an 8 MiB decompression bomb with a header claiming 100 bytes, a header claiming 500 MiB, too many entries, an oversized entry, a file over the size limit, and 60 random corruptions (never a crash, never different entries). The numeric limits are provisional (64 MiB file, 256 MiB unpacked, 100,000 entries, 1 MiB per entry, 65,534 files because classic ZIP has no more) and need the owner's decision (TC-065). A plaintext export is limited to 65,000 entries for the same ZIP reason.

### Not yet done
S9 (iOS privacy manifest and Data safety answer), and the speed of a large export and import on the reference device (5,000 entries target). ADR-002 spike gate: passed on Android; still open on iOS.

