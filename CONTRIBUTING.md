# Contributing to exodite-anima

Thanks for helping. This app keeps a private journal on the device, so a few rules are stricter than usual.

## Before you start

- Open an issue first for anything bigger than a small fix, so we can agree on it before you spend time.
- Changes to behaviour start as a feature spec in `.assist/product-manager/features/` (see `.assist/README.md` and `.assist/orchestration.md` for how the project works). Small fixes and documentation do not need one.
- Security problems: do not open a public issue. Follow `SECURITY.md`.

## Rules that always apply

- **No network.** The release build must not declare a network permission, and no package that sends data is added (ADR-005). A pull request that adds one will be declined.
- **No real journal content.** Use made-up text and made-up passcodes in tests, screenshots, issues and fixtures.
- **No secrets or local paths** (keystores, `.env`, tokens, your username in a path).
- **Every visible string** is written in both English and Indonesian in `app/lib/l10n/strings.dart` (a test fails when one is missing).
- **Icons** come from `AppIcons` (`app/lib/theme/app_icons.dart`, Lucide); do not use `Icons.*`.
- **Design values** come from the tokens in `app/lib/theme/tokens.dart`; do not write raw colours or sizes in screens.
- Documents under `.assist/` and `docs/` are written in English, in plain sentences, without invented numbers.

## Working on the app

```
cd app
flutter pub get
dart run build_runner build      # after changing database tables
flutter analyze
flutter test test                # unit tests, no device needed
flutter test integration_test/<file>.dart -d <android device>   # screen tests
```

A change is ready when `flutter analyze` is clean, the unit tests pass, and the screen tests for the parts you touched pass on an Android device or emulator. Say in the pull request what you ran and what you could not run. iOS cannot be built by the maintainer yet, so please flag anything that may behave differently there.

Pull requests run CI (`.github/workflows/ci.yml`): analysis, unit tests, and a check that the release build declares no network permission (`app/tool/check_release_manifest.sh`).

If you touch `.assist/`, run these from the repository root and keep them passing:

```
node .assist/tools/check-registry.js
node .assist/tools/preflight.js
```

## Pull requests

- Keep them small and focused, with a short description of what changed and why.
- Add or update tests for behaviour you change.
- By contributing you agree that your contribution is licensed under the MIT licence of this repository (`LICENSE`).

The maintainer is one person, so replies can take time. Thank you for your patience.
