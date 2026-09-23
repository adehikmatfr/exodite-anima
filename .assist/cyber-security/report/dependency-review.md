# Dependency and Supply Chain Review

Method: skill `dependency-and-supply-chain-review`. Status: baseline, 2026-09-20. Related: THR-012, THR-014, THR-015, ADR-004, ADR-005.

## Current dependencies
Read from `app/pubspec.yaml` on 2026-09-20, after the app was built. The first rows are the packages the team chose (reviewed below); `cupertino_icons` and the dev tools come from the Flutter template.

| Dependency | Version | Purpose | Licence | Advisories | Maintenance | Decision | Owner |
|-----------|---------|---------|---------|-----------|-------------|----------|-------|
| flutter (SDK) | 3.44.4 | Application framework | not checked | not checked | active (stable channel in use) | approved by ADR-004 | project owner |
| cupertino_icons | ^1.0.8 | iOS-style icons from the project template | not checked | not checked | not checked | **review**: not needed until icons are chosen; remove if unused | frontend-mobile |
| sqlite3 | 3.5.2 (exact) | Database engine bundled with the SQLite3MultipleCiphers build (ADR-002) | MIT; cipher library MIT per its project (confirm at release) | not checked against an advisory database | active; publisher simonbinder.eu, 3.6.0 released 2026-09-13 | approved for the spike and FEAT-001; the build hook downloads a prebuilt binary at build time and verifies sha256 (THR-012) | frontend-mobile |
| drift | 2.35.0 (exact) | Typed database access and migrations (ADR-002) | MIT | not checked against an advisory database | active; publisher simonbinder.eu | approved for FEAT-001 | frontend-mobile |
| path, path_provider | 1.9.1, 2.1.6 (exact) | File locations | BSD-3 | not checked | maintained by the Dart and Flutter teams | approved | frontend-mobile |
| integration_test (dev) | SDK | On-device tests | SDK | n/a | SDK | approved for development only | frontend-mobile |
| cryptography | 2.9.0 (exact) | Argon2id key derivation and AES-256-GCM to wrap the data key (ADR-001) | Apache-2.0 | not checked against an advisory database | publisher dint.dev, last release 2025-11-21; pure Dart, no native code, no permissions | approved for FEAT-003 and FEAT-004; its Argon2id is pure Dart (about 0.34 s at the chosen setting on the emulator) | frontend-mobile |
| flutter_secure_storage | 11.2.0 (exact) | The biometric copy of the data key in the Android Keystore or iOS Keychain (ADR-001) | BSD-3 | not checked | publisher steenbakker.dev, active (2026-09-16); adds no permission | approved; the copy is not gated by biometrics in hardware (see spike S5) | frontend-mobile |
| local_auth | 3.0.2 (exact) | The system face and fingerprint prompt | BSD-3 | not checked | publisher flutter.dev; adds `USE_BIOMETRIC` and `USE_FINGERPRINT`, no network | approved | frontend-mobile |
| androidx.appcompat:appcompat (Android) | 1.7.0 | Theme required by the biometric prompt | Apache-2.0 | not checked | Google (AndroidX) | approved | frontend-mobile |
| share_plus | 13.3.0 (exact) | Hands the export file to the Android share sheet and iOS share dialog | BSD-3 | not checked | publisher fluttercommunity.dev, active (2026-07-23); adds a `ShareFileProvider` (not exported) and a `queries` entry, no permission | approved for FEAT-006 | frontend-mobile |
| file_picker | 13.1.0 (exact) | The system file chooser for import | MIT | not checked | publisher victorcarreras.dev, active (2026-09-15); uses the system chooser, adds no permission | approved for FEAT-007 | frontend-mobile |
| flutter_lints (dev) | ^6.0.0 | Lint rules | not checked | not checked | not checked | approved for development only | frontend-mobile |
| flutter_test (dev) | SDK | Tests | SDK | n/a | SDK | approved for development only | frontend-mobile |

"Not checked" means this review did not look; it is not a finding. Licence and advisory checks happen when each dependency is confirmed.

## Rules for adding a dependency
1. Justify the need; prefer the Flutter SDK or the platform over a package.
2. Check maintenance (recent releases, more than one maintainer for critical components), advisories, transitive dependency count, and licence type (copyleft or unknown goes to the owner or counsel).
3. Confirm the official registry and publisher; watch for look-alike names.
4. Read the package's requested permissions and install-time scripts. **A package that adds a network permission to the release manifest is rejected** unless a superseding ADR allows it (ADR-005).
5. Pin the version and commit the lock file (`app/pubspec.lock` is committed).
6. Record the decision in the table above.

## Packages the technical spike needed to review (done 2026-09-20)
Reviewed and recorded in the table above: encrypted storage (sqlite3 with the SQLite3MultipleCiphers build, drift), ciphers and key derivation (cryptography), secure key storage and biometrics (flutter_secure_storage, local_auth, AndroidX appcompat), file sharing and picking (share_plus, file_picker), file locations (path, path_provider). Archive handling has no package: the app reads and writes ZIP itself (see the note at the end). Icons are a font asset, not a package (see Icons).

## Pinning and provenance
| Item | State |
|------|-------|
| Lock file committed | yes (`app/pubspec.lock`) |
| Versions pinned exactly | yes for every package the team added; `cupertino_icons` and `flutter_lints` still use ranges |
| SBOM per release | not generated; to be added to the release checklist |
| CI and automated scanning | `.github/workflows/ci.yml` written, never run; `.github/workflows/osv-scanner.yml` (OSV-Scanner, dependency vulnerability scan) added 2026-09-23, never run — both need the first push |
| Signing and provenance | release signing not set up (THR-014) |

## Findings
| ID | Finding | Threat | Owner |
|----|---------|--------|-------|
| D1 | ~~No CI exists~~ CI written 2026-09-20 (`.github/workflows/ci.yml`): analyze, unit tests, generated-code check, the merged-manifest check (ADR-005), registry and preflight, and a secrets and local-path scan. ~~Dependency vulnerability scanning is still not automated~~ Added 2026-09-23: `.github/workflows/osv-scanner.yml` (OSV-Scanner, `google/osv-scanner-action@v2.6.0`) scans `app/pubspec.lock` on every push, PR, and a weekly schedule, reporting to the repository's Security tab. **Closed 2026-09-23**: pushed (commit `bc3db60`), both `ci.yml` and `osv-scanner.yml` ran and passed; no vulnerabilities found in `app/pubspec.lock` (run 35817758051) | THR-012, THR-015 | frontend-mobile |
| D2 | Caret version ranges allow silent minor upgrades; pin before release. Update 2026-09-20: every package added since the spike is pinned exactly; `cupertino_icons` (template) and `flutter_lints` still use ranges, and `cupertino_icons` is unused. The CI workflow pins actions by major version tag, not by commit hash | THR-012 | frontend-mobile |
| D3 | No SBOM process (the lock file lists every package and version) | THR-012 | cyber-security |
| D4 | `flutter pub get` reports 22 packages with newer versions that the Flutter 3.44.4 constraints do not allow (2026-09-20); not reviewed | THR-012 | frontend-mobile |

Not used: the `archive` package. The export ZIP is written and read by `app/lib/backup/zip_lite.dart` (about 250 lines) so that name, count and size limits are enforced while unpacking, and anything unusual is refused. Reason and evidence: spike S7.


## Icons (2026-09-20)
The icons are a bundled font asset (`app/assets/fonts/Lucide.ttf`, ISC), taken from the official `lucide-static` 1.47.0 npm package, not a Dart package. The Flutter wrapper `lucide_icons_flutter` exists (MIT) but is published by an individual account, and a font asset adds no code and no dependency to trust. Flutter drops the unused glyphs from the release build. Recorded in `product-design/docs/asset-register.md`.
