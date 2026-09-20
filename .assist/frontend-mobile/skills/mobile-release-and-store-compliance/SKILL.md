---
name: mobile-release-and-store-compliance
description: Use when building, signing, submitting, rolling out, halting or hotfixing a mobile app release, or when a store rejection, privacy label or data-safety form question appears.
---
# Mobile Release and Store Compliance

## Purpose
Get a binary through the stores safely, expose it to users gradually, and be able to stop or fix it fast, given that a shipped binary cannot be recalled.

## When to use
- Preparing any store submission, including beta tracks and enterprise/MDM builds.
- A store rejection, policy warning, expiring certificate or target-SDK deadline.
- Crash or regression after release (halt, hotfix, force update).

## Principles
- Build once in CI, sign in CI, submit the same artifact tested in beta. No release from a laptop.
- Store review takes 24 h to 7 days; plan a buffer of 5 working days, and keep an expedited path only for security fixes.
- Server-side flags are the fast rollback; the binary is the slow one. Risky logic ships behind a flag.
- Store declarations (privacy labels, data safety) must match what the code and SDKs actually do.
- Every release names its rollback method and point of no return (`release-management.md`).

## Steps / Checklist
**Build and signing**
1. Version bump: semantic marketing version + monotonically increasing build number (Android versionCode, iOS CFBundleVersion).
2. Reproducible CI build; dependency and secret scan; symbols/mapping files uploaded to crash tool (fail build if missing).
3. Signing keys in secret manager; Play App Signing enabled; Apple certs and profiles expiry tracked (alert at 30 days).
4. Confirm target SDK meets the current store deadline; note next deadline in `context.md`.

**Store compliance (pre-submit)**
5. Permissions in manifest/Info.plist equal permissions used (`mobile-permissions-and-privacy`); each has a rationale string.
6. Privacy nutrition label (iOS) and Data safety form (Android) reconciled with SDK inventory; date and reviewer recorded.
7. Account deletion in-app if account creation exists; sign-in-with-Apple rule checked when other social logins exist; in-app purchase rules respected for digital goods.
8. Review notes: demo credentials, feature toggles needed, reviewer-only test data. No real user data.
9. Export compliance, content rating, age rating, regional restrictions updated.

**Rollout**
10. Beta soak: internal, then external beta >= 48 h with crash-free >= 99.5%.
11. Staged release: Play staged rollout 1% > 10% > 50% > 100%; iOS phased release (7-day automatic ramp) or manual hold.
12. Hold each step >= 24 h or until >= 1,000 sessions; proceed only if crash-free sessions >= 99.5% and ANR < 0.47% (Play bad-behaviour threshold), and no P1 defect (`severity-and-incident.md`).
13. Halt rule: crash-free < 99.0%, or new top crash affecting > 0.5% sessions, or P0/P1 open: pause rollout, flip flag off, open incident.

**Hotfix and force update**
14. Hotfix = smallest possible diff from the released tag; skip non-fix changes; request expedited review with justification.
15. Force update only for security, data-loss or contract-breaking issues, approved by the accountable owner; prefer soft prompt first (`app-version-compatibility`).

## Output format
Release record (attach to `FEAT-`/release ticket): version/build, commit, artifact hash, flags and defaults, rollout schedule, halt thresholds, rollback method, declarations reconciled (yes/date), sign-off names, post-release watch window (72 h) result.

Worked example: v4.12.0 (build 2210). Payments flag `FEAT-NNN` off by default; beta crash-free 99.7%; Play 1% > 10% > 50% held 24 h each; day 2 crash-free 98.8% on Android 9 -> halt, flag off, fix in 4.12.1.

## References
`../_shared/standards/release-management.md`, `severity-and-incident.md`, `production-readiness-review.md`, `security-baseline.md` (supply chain, secrets), `../_shared/compliance/compliance-matrix.md`. IDs: `FEAT-`, `RB-`, `SLO-`.

## Language notes
- iOS: Fastlane match or Xcode Cloud; upload dSYMs. Android: Gradle `bundleRelease`, upload R8 mapping.
- React Native/Flutter: also upload JS source maps / Dart symbols (`--split-debug-info`); OTA/code-push updates must not bypass store policy on changing app purpose.
