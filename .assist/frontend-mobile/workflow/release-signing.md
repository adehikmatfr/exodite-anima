# Release signing and GitHub releases (Android)

As-built on 2026-09-20. Owner: project owner. Covers TC-091 (release signed with the release key) and how an APK reaches GitHub Releases.

## 1. Why the key matters
Android accepts an update only if it is signed with the same key as the installed app. An APK signed with the debug key cannot be updated by a release-key APK: the user must uninstall first, and uninstalling deletes the journal. The key must therefore exist before the first APK is shared, and it must never be lost or published.

## 2. One-time setup (by the owner)
1. Create a keystore **outside the repository** and choose the passwords yourself:
   `keytool -genkeypair -v -keystore exodite-anima-release.jks -alias exodite-anima -keyalg RSA -keysize 4096 -validity 10000`
   The certificate name fields are public inside every APK; enter only what you are happy to publish (the common name `Exodite Anima` is enough).
2. Back it up in two places you control (a password manager and an offline copy) with both passwords. If the key is lost, users can only install a differently signed app after uninstalling.
3. Copy `app/android/key.properties.example` to `app/android/key.properties` and fill in the path and passwords. Git ignores this file and `*.jks`; do not remove those rules.

## 3. How the build uses it
`app/android/app/build.gradle.kts` reads `key.properties`. With the file, `flutter build apk --release` signs with the release key. Without it, the build falls back to the debug key and prints a warning, so contributors and CI still build (CI artifacts are therefore never for distribution).

## 4. Publishing a GitHub release
1. Build: `cd app && flutter build apk --release --split-per-abi`, then `bash tool/check_release_manifest.sh build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.
2. Check the signature: `apksigner verify --print-certs <apk>` must show the release certificate, not "Android Debug".
3. Write SHA-256 sums: `sha256sum app-*-release.apk > SHA256SUMS.txt`.
4. Tag and publish (the owner decides when): `gh release create v0.1.0 --prerelease --title "..." --notes-file <notes> <apks> SHA256SUMS.txt`.
5. Mark it as a pre-release while `qa/report/PRR-001-v1-android.md` says No-Go. The notes must say: early version, Android only, not independently audited, a forgotten passcode cannot be recovered, export your journal regularly.

## 5. Decisions and gotchas
- Files to attach: the arm64-v8a APK for most phones; armeabi-v7a for older ones; the universal APK is large.
- A Play Store release later uses its own upload key and Play App Signing; a sideloaded GitHub APK and a Play install are then signed differently and cannot update each other.
- Do not attach debug or profile APKs.
