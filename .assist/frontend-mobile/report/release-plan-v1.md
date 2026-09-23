# Release plan (version 1)

Method: skill `mobile-release-and-store-compliance`. Status: draft, 2026-09-20. This plan is the frontend-mobile input to the pending product decision `v1-rollout-plan`; the stage gates and halt numbers below are candidates from the skill, not decisions. Related: FEAT-001 to FEAT-009, RISK-007, THR-014, THR-015, ADR-005, `../../_shared/standards/release-management.md`, `../../_shared/standards/production-readiness-review.md`.

## What is different for this app
- **A shipped binary cannot be recalled, and there is no kill switch.** The skill's fast rollback is a server-side flag; this app has no server and no network (ADR-005). The only levers are halting a staged rollout and shipping a fixed build. So the first release must be small in blast radius and its data handling (migrations, export) must be right before it ships.
- **There is no minimum-version enforcement or force update** (no server). Old versions live on. Compatibility is carried by data: every app version must import exports from older format versions, and refuses (with a message) an export from a newer one.
- **Crash and stability data come only from the store consoles**, not from the app (no crash SDK, no analytics).
- **Users are few at first.** The skill's gate "at least 1,000 sessions per step" may never be reached in the early stages; the owner decides how to gate.

## Build and signing
| Step | Current state | Needed |
|------|---------------|--------|
| Version | `1.1.0+3` in `app/pubspec.yaml` (v1.0.0+1 was v1.0.0-beta.1's pre-release, 2026-09-20; bumped to 1.1.0+2 for v1.1.0-beta.1, 2026-09-23, bundling FEAT-010 and FEAT-011; bumped to 1.1.0+3 for v1.1.0-beta.2, 2026-09-23, a photo-add bug fix only, no feature change) | Marketing version plus a build number that only increases (Android versionCode, iOS build number) |
| Reproducible CI build | No CI | Build once in CI, sign in CI, submit the tested artifact (skill rule); until CI exists, builds are local and the release record says so |
| Android signing | **The template signs release builds with the debug key** (`android/app/build.gradle.kts`, Flutter's own TODO) | Create an upload key, keep it and its passwords outside the repository (THR-014), use Play App Signing, keep an offline copy of anything that cannot be recreated. Test case TC-091 |
| Apple signing | Not set up; no Mac | Certificates, profiles, and a build machine (Mac or cloud CI) |
| Dependency and secret scan | `tools/preflight.js` scans for a few secret patterns only | Dependency scan in CI when it exists (`../../cyber-security/report/dependency-review.md`) |
| Symbols | Not applicable yet | Flutter symbol files if a store crash view needs them (`--split-debug-info`) |
| Target SDK | Flutter 3.44.4 defaults: compile 36, target 36, min 24 (Android 7.0); iOS deployment target 13.0 | The store's current target deadline is checked at submission and recorded here. Minimum OS versions are decided (Android 7.0 and iOS 13, `platforms-and-languages`) |

Loss procedure for the signing key: if the upload key is lost, the store account owner requests a reset through the store (Play App Signing makes this possible); if the Apple account or certificates are lost, they are re-issued through the Apple developer account. Both depend on the owner's account access, which is a single point of failure (THR-014). No runbook role exists; this paragraph is the procedure.

## Pre-submission checklist
| Item | State |
|------|-------|
| Manifest and `Info.plist` permissions equal permissions used | biometrics only; see `permission-and-privacy-register.md` |
| Rationale strings written and localised | Face ID string drafted |
| Privacy label, privacy manifest, and Data safety reconciled with the packages actually included | draft answers written 2026-09-23 (`store-listing-and-data-safety-v1.md`); not reconciled with the final package list |
| No network permission in the merged release manifest (ADR-005) | checked once on the template app; needs a CI check (TC-084) |
| Backup excluded on both platforms | Android done; iOS not built |
| Release build has no debug logging and the release key (TC-091) | no |
| Account deletion, sign-in rules, in-app purchase rules | not applicable: no accounts, no purchases |
| Review notes | The reviewer must create a passcode on first launch; there are no accounts or demo credentials; explain that the app is offline by design |
| Export compliance (encryption), content rating, age rating, regions | to be answered by the owner at submission (RISK-007) |
| Public app name and store listing | name decided, store availability informally checked 2026-09-23, listing text drafted (`public-app-name`, `store-listing-and-data-safety-v1.md`); submission-time console check still needed |
| Legal applicability | accepted by the owner 2026-09-23 (`legal-applicability-confirmation`, `legal-self-assessment-v1.md`) |
| Readiness review (`production-readiness-review.md`) | Operations row is N/A (no server); other rows open |

## Rollout candidates (for the owner's decision `v1-rollout-plan`)
These come from the skill's defaults and are not decided.
| Stage | Candidate | Note |
|-------|-----------|------|
| Internal testing | Play internal testing track and TestFlight internal group | Uses the exact artifact planned for release |
| Beta soak | External beta of at least 48 hours with crash-free sessions of at least 99.5% (skill default) | Needs enough testers for the number to mean anything |
| Staged release | Play staged rollout 1%, 10%, 50%, 100%; iOS phased release | Hold each step at least 24 hours (skill default) |
| Halt rule | Pause when crash-free sessions fall below 99.0% or a new top crash affects more than 0.5% of sessions, or a P0 or P1 is open (skill default) | The only rollback: halt, then ship a fix |
| Post-release watch | 72 hours in the store consoles | Result recorded in the release record |

Point of no return: once a user's journal has been migrated by a release, an older binary cannot be used on it (rule 3 in `local-data-design.md`). This is why migrations need fixtures and a pre-migration copy.

## Hotfix
Smallest possible change from the released tag; nothing else in the same build; expedited review only for security or data-loss fixes; announce in the store notes.

## Release record (fill for every release)
Version and build, commit, artifact hash, permissions and declarations reconciled (yes, date), rollout schedule, halt thresholds, rollback method (halt and hotfix), sign-off names (owner), 72-hour watch result.

## Owner decisions (2026-09-20)
- Staged release with a halt rule accepted (`v1-rollout-plan`); the halt numbers follow the internal test.
- **Android first**: version 1 is released on Google Play only; iOS follows when a Mac or cloud CI exists (`v1-choices-2026-09-20`).
