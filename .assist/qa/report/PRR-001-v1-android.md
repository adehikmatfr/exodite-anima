# PRR-001: Version 1 (Android) production readiness review

Status: draft, 2026-09-20. Standard: `_shared/standards/production-readiness-review.md`. Tier: T1, escalated (journal text is sensitive personal data), so the Security, Data and Compliance rows are blockers (`_shared/project.md`). Scope: the first production release of the Android app. iOS is out of scope (decided: Android first, `v1-choices-2026-09-20`).

**Written by the assistant from the evidence in this repository. It is a self-review, not an independent one.** Where a row needs a real phone or a real environment, the "Verified in" column says `local` (a developer machine or the Android emulator) and the row cannot reach Pass on that alone.

## Decision
**No-Go for a production release.** Five blocker rows are Partial. The app is complete enough for the next step: an internal test on a physical Android phone, which most of the open rows need. No waiver is requested.

## Evidence in numbers (2026-09-20)
- Nine features, 76 acceptance criteria, all citing a test case (`check-registry` passes: 145 IDs, no unregistered references).
- 102 test cases in TP-001: 66 passed by automated test, 18 not executed, 16 partial, 1 passed by hand, 1 failed. Of the P0 cases: 34 passed by automated test, 9 partial, 5 not executed, 1 passed by hand, 1 failed. "Passed by automated test" means a test passed on the Windows host and/or the Android emulator; no case has been run on a physical phone, and none has been marked `passed` by qa in its status field.
- Automated tests on record: 98 unit tests (host) and screen tests on the emulator for every feature (8 + 11 + 5 + 6 + 6 + 9, plus the timeline and search performance runs).
- Release APK (58.9 MB, universal): no network permission; cloud backup off; signed with the **debug** key.

## Update: physical phone run (2026-09-20)
The owner ran `qa/workflow/phone-test-checklist.md` on a physical Android phone and reported that every item passed; there are no per-case notes and the assistant did not observe the run. 27 test-case logs now record it: 23 Pass (22 set to `active`; TC-065 stays `blocked` until the owner decides the import limits) and 4 Partial: TC-014 (save latency not timed), TC-031 (95th percentile not measured), TC-089 (contrast not measured on the phone), TC-090 (one phone and one Android version). The counts under "Evidence in numbers" were written before this run and are not recomputed. The decision is unchanged: No-Go, because these are still open: TC-091 (debug signing), TC-083, TC-085, TC-086 (need `adb`), TC-019 and TC-045 (20,000 entries on a phone), key-derivation timing (G1), first CI run, independent review, owner sign-offs and store material. From the run, "What would turn this into a Go" item 1 is done except TC-083, TC-085, TC-086, TC-019, TC-045 and the timing figures, and item 5 is done except the measured contrast and both languages on every screen.

A second physical phone (Android 11) was then connected to `adb`: the release APK installed and ran onboarding, save, lock and unlock. TC-083, TC-085, TC-086 and TC-090 gained partial evidence from it (no network permission, no backup flag, no marker word or passcode in the device log). Key derivation was then measured on that phone (`technical-spike-plan.md`, S4): opening with the passcode takes a median 2.95 s (worst 3.34 s) with the current setting, and the export setting takes 5.8 s; two lanes at 64 MiB took 1.28 s. The owner chose 64 MiB, 3 passes, 2 lanes and it is built (the in-app time after the change was not measured). G1 stays open until a second phone is measured and the design is reviewed; the Security row stays Partial.

**Signing, 2026-09-20:** the owner created the release key and the build signs with it (TC-091: the debug-key failure is resolved; the case is Partial because debug logging was not reviewed beyond TC-086). The row 10 condition about the release key is met; the key backup is the owner's to confirm. The counts above were written before this and are not recomputed.

**First CI run, 2026-09-20:** the workflow ran on the first push (commit 8a423f9) and all four jobs succeeded: analyze and unit tests, release build with no network permission (the manifest check, G10, TC-084), project record checks, and the secrets and local-path scan. "What would turn this into a Go" item 3 is done; a run on the release-signing commit was still in progress when this was written.

## Release, 2026-09-20
The pre-release v1.0.0-beta.1 was published on GitHub by the owner's instruction (two APKs signed with the release key, checksums, notes in `docs/releases/`). It is a pre-release for testers; the decision above is unchanged: No-Go for a production release.

## Review table (T1 column)
| # | Area | Check | T1 | Status | Verified in | Evidence | Unblocked by |
|---|------|-------|----|--------|-------------|----------|--------------|
| 1 | Requirements | Linked `FEAT-` with acceptance criteria and a named owner; each criterion cites a real test | B | **Pass** | local | FEAT-001..009 (owner: project owner), `check-registry` result above | none |
| 2 | Architecture | `ADR-` for significant decisions; NFRs quantified | R | Partial | docs, local | ADR-001..006 accepted; `nfr-analysis-v1.md` numbers are provisional (`nfr-targets-v1`); no independent review of ADR-001 or ADR-003 (RISK-005) | qa or an outside reviewer; a physical phone to confirm the numbers |
| 3 | Testing | Test plan executed; critical cases pass; no open S1 or S2 bugs | B | **Partial** | local | TP-001; counts above. Not run: TC-083, TC-086 (no content in requests and logs), TC-100 (migration restore), the biometric, share-sheet and screen-capture cases on a real phone. TC-091 **fails** (debug signing). No defect tracker; bugs found by tests were fixed the same day and none is known open | qa: run the cases on a physical phone; project owner: release key |
| 4 | Performance | Smoke test at expected peak (T1) | R | Partial | local (emulator) | Open 276 to 401 ms and search 0 to 24 ms at 20,000 entries, but emulator graphics numbers proved unusable (TC-019); the owner chose an emulator as the reference | project owner: a physical phone (`v1-choices-2026-09-20`) |
| 5 | Reliability | Failure paths verified | R | Partial | local | Saves, imports and passcode changes are atomic and tested; drafts survive a lock; process kills at every step were not tried; no network so no timeouts | qa |
| 6 | Security | Threat model reviewed; scans clean; authn tested | B | **Partial** | docs, local, informal independent review 2026-09-23 | THR-001..015 (self-reviewed); wrong-passcode wait, passcode change, wrapped key, encrypted export, hostile-file tests pass; open blockers in `security-requirements-review-v1.md`: G1 (key-derivation settings need a phone), G10 (CI manifest check written, not yet run), G11 (iOS backup, out of scope); no dependency vulnerability scan; device-bound key wrapping not evaluated (spike S5). Informal independent review by a friend of the owner found no issues in key handling, database encryption, export envelope, and import safety (`cyber-security/report/independent-review-scope-v1.md`); a single informal read is lighter assurance than a paid audit, so this row stays Partial, not Pass. **Real finding, 2026-09-23**: the privacy cover (FEAT-003) hid content visually but not from a screen reader (THR-004); fixed with `BlockSemantics` in `app/lib/main.dart`, no automated test, TC-023's earlier phone "Pass" only ever covered the visual check | first CI run; a physical phone (this time with a screen reader on, per the finding above); a second or more formal reviewer, if the owner wants stronger assurance (RISK-005) |
| 7 | Data | Backup and restore tested; PII handling reviewed | B* | **Partial** | local | Export then import round trip tested on host and emulator (TC-058); restore after passcode setup tested (TC-102); privacy claims traced (`qa/report/privacy-claims-trace.md`, two of four partial); Android cloud-backup restore not run (TC-085); no RPO or RTO applies (backup is the user's export) | qa: TC-085 and TC-086 on a phone |
| 8 | Observability | Logs, health check | R | Partial (by design) | docs | The app has no telemetry, crash reporting or logs of content, by policy. Crash-free rate will come from the store consoles after release; TC-086 (no content in logs) not run | after the first release |
| 9 | Operations | Runbook; owner named | R | Partial | docs | Owner is the project owner. Rollback path is written (`v1-rollout-plan`, `release-plan-v1.md`); no runbook for a lost-journal report or a bad release | project owner |
| 10 | Release | Repeatable release; rollback written; migration reversible | R | Partial | docs, local | Staged rollout with a halt rule decided; CI workflow written and now run (both `ci.yml` and `osv-scanner.yml` passed on push); **no release signing key** (TC-091); ADR-006's migration safety rules are built and tested against real schema-1 and schema-2 fixtures (`app/test/migration_safety_test.dart`), for FEAT-010 and FEAT-011 (both v1.1), not yet released with v1 | project owner: release key and Play account |
| 11 | Capacity | | - | N/A | | no server | |
| 12 | Compliance | Applicable rows of `compliance-matrix.md` satisfied | B** | **Partial** | docs, local, physical phone | WCAG 2.2 AA (adopted): TC-087 (screen reader) Pass, TC-088 (200% text, both themes) Pass, TC-089 (contrast) Pass as of 2026-09-23 (measured with a tool; touch-target sizes not re-measured this run) — all owner-reported on a physical phone, no per-case notes kept. Both languages on every screen at 200% was not explicitly re-stated. Store rules: honest answer is "no data collected"; data-safety answers and listing text drafted, and the privacy statement page drafted and accepted by the owner 2026-09-23 (`docs/privacy.md`, `frontend-mobile/report/store-listing-and-data-safety-v1.md`), still to be reconciled with the final build before submission. Legal: self-assessment accepted by the owner 2026-09-23 (`legal-self-assessment-v1.md`). Indonesian text (180 strings) reviewed and accepted by the owner 2026-09-23, two minor wording fixes applied (`app/lib/l10n/strings.dart`) | Reconcile store material with the final build before submission; the owner-reported runs above have no independent observation |
| 13 | Docs | User docs, changelog, support hand-off | R | Partial | docs | README, CONTRIBUTING, SECURITY, LICENSE exist. Added 2026-09-23: `docs/privacy.md` (owner-accepted), `docs/export-format.md`, `docs/backup-and-new-phone.md`; store listing text drafted (`frontend-mobile/report/store-listing-and-data-safety-v1.md`). Still missing: a user guide covering the whole app, and a changelog | product-manager |
| 14 | Dependencies | Licences, failure modes understood | R | Partial | docs, CI | All reviewed packages have permissive licences (`dependency-review.md`); versions pinned except two; automated vulnerability scan added and run 2026-09-23 (`.github/workflows/osv-scanner.yml`, OSV-Scanner, commit `bc3db60`), no vulnerabilities found; the SQLite build hook downloads a prebuilt binary at build time and checks its hash | keep the scan running on every push and weekly |

\* B when the data cannot be recreated from elsewhere: the journal can be recreated from an export only if the user made one, so it is treated as B. \*\* B because WCAG and the store rules are marked applicable.

## What would turn this into a Go (in order)
1. **Run on a physical Android phone** and record the results in the test cases: real biometric prompt (TC-024, TC-028), screen capture and recent-apps preview **with a screen reader turned on** (TC-023, TC-094 - added 2026-09-23 after finding the privacy cover did not block the accessibility tree, now fixed), share sheet and file picker (TC-058 on a real export), backup and restore (TC-085), logs and network (TC-083, TC-086), key-derivation time and the performance targets (G1, TC-014, TC-019, TC-045).
2. **Create the release signing key** and keep it outside the repository; sign the release build with it (TC-091). Losing the key blocks updates, so back it up.
3. **Push the repository and let CI run**; the manifest job must pass (G10, TC-084).
4. **Independent review** of the encryption and export design (ADR-001, ADR-003, RISK-005), even a friend who reads code. Scope prepared 2026-09-23: `cyber-security/report/independent-review-scope-v1.md`; the owner still needs to find a reviewer and run it.
5. **Accessibility runs**: TalkBack (TC-087, done 2026-09-20), 200% text (TC-088, done 2026-09-20), contrast measured with a tool (TC-089, done 2026-09-23). Still open: both languages explicitly checked at 200% text, and touch-target sizes re-measured on a device.
6. **Owner sign-offs**: the legal self-assessment (done 2026-09-23), the Indonesian text (done 2026-09-23), the privacy statement (drafted, owner review still pending).
7. **Store material**: data-safety answers, privacy statement page, listing text drafted and accepted by the owner 2026-09-23 (`frontend-mobile/report/store-listing-and-data-safety-v1.md`, `docs/privacy.md`); name check done informally (`public-app-name.md`). Still open: reconciliation with the final build, and the real console name check at submission.

## Conditions
| Row | Condition | Verified when | Owner | Met (date, evidence) |
|-----|-----------|---------------|-------|----------------------|
| 10 | The release build is signed with the release key | Before submission | project owner | met 2026-09-20: `apksigner` shows the release certificate on all three APKs (TC-091 log) |
| 10 | The staged-rollout halt numbers are set from the first internal-test baseline | After the internal test | project owner | not met |

## Sign-off
| Role | Name | Date | Decision |
|------|------|------|----------|
| Engineering | assistant (self-review) | 2026-09-20 | No-Go for production; ready for internal testing |
| QA | pending | | |
| Security | pending | | |
| Operations | not applicable (no service) | | |
| Product | pending: project owner | | |

## Waivers
None requested.
