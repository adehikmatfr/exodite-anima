# Status

Where the project stands. Update it in the postflight of every piece of work (`orchestration.md`). Last updated: 2026-09-23.

## Phase
All nine phases have work in them; none is finished.
- Planning and requirements (1), UX discovery (2), architecture (3): done as drafts. All nine v1 feature specs are `in-progress` (built) and every question is answered. FEAT-010 (v1.1 candidate, tags/mood/On this day) is `ready`, not yet built.
- Security design (4): drafted and self-reviewed; open blockers are G1 (key-derivation settings: measured on a phone, 64 MiB / 3 passes / 2 lanes chosen and built; a second phone still needed), G10 (the CI manifest check passed on the first run; keep it for every release) and G11 (iOS, out of scope for the first release). An informal independent review by a friend of the owner found no issues (2026-09-23, `cyber-security/report/independent-review-scope-v1.md`); RISK-005 is lowered, not closed, since it was one informal read, not a formal audit, and did not cover the not-yet-built ADR-006 migration code.
- Test strategy (5): TP-001 has 102 cases; results from execution logs: 66 passed by automated test on the host and the Android emulator, 16 partial, 18 not executed, 1 passed by hand, 1 failed (TC-091, release signing). Nothing has been recorded on a physical phone per case.
- Visual design (6): tokens, components, all screens and states; logo A2 and the app icon; Lucide icons. The owner has not reviewed the `.pen` files in OpenPencil since the rebuild.
- Build (7): all nine v1 features are built for Android (Flutter). 98 unit tests on the host and screen tests on the emulator for every feature. The owner tried the release APK on a physical phone and reported that it ran smoothly (owner-reported, not per case). iOS is not built (no Mac; Android first).
- Verify and release (8): PRR-001 (`qa/report/PRR-001-v1-android.md`) says **No-Go for production**; the app is ready for an internal test on a physical phone. Release signing key and first CI run are done (2026-09-20). Store material (data-safety answers, listing text, privacy statement) drafted and owner-accepted 2026-09-23, not yet reconciled with the final build.
- Maintain (9): not started. See the phase table in `orchestration.md`.

## Features and gates
All nine v1 specs are `in-progress`: built and tested to the level shown. Moving a spec to `released` needs the production readiness review (PRR-001) to reach Go. FEAT-010 is `ready` for a v1.1 build; not started.

| FEAT | Title | Gate reached | What is still open |
|------|-------|--------------|--------------------|
| FEAT-001 | Entry management | in-progress | AC-1 to AC-10 tested on host and emulator; AC-11 (failed migration restore) has no code because no migration exists yet; process kill at each step not tried on a device |
| FEAT-002 | Timeline | in-progress | AC-1 to AC-3 tested; AC-4 (smooth scrolling at 20,000 entries) cannot be shown on an emulator (emulator graphics numbers proved unusable, TC-019); AC-5 tested with the lock |
| FEAT-003 | App lock and screen privacy | in-progress | Lock, waits, auto-lock, screen cover and Android secure window tested on the emulator and, reported by the owner, on a physical phone (real biometric prompt, app switch, screenshot and screen recording); the 95th-percentile unlock time is not measured; the wait uses the phone clock |
| FEAT-004 | Onboarding and passcode setup | in-progress | Setup and key vault tested; AC-6 (privacy claims traced to tests) partial; the common-passcode list is a short built-in floor |
| FEAT-005 | Search | in-progress | AC-1 to AC-5, AC-7, AC-8 tested; AC-6 measured on an emulator only (0 to 24 ms at 20,000 entries); works in airplane mode on a phone |
| FEAT-006 | Export | in-progress | AC-1 to AC-7, AC-9 tested; AC-8 progress bar is not determinate; the real Android share sheet was used in the owner's phone run (TC-054, TC-058) |
| FEAT-007 | Import | in-progress | AC-1 to AC-3, AC-6 to AC-9 tested; AC-4 needs a second format version; import limits are provisional |
| FEAT-008 | Export reminder | in-progress | AC-1 to AC-7 tested with a simulated clock; the card appeared on a phone after a simulated 31 days (TC-070); re-checked when the timeline opens, not while open across midnight |
| FEAT-009 | Settings | in-progress | AC-1 to AC-6, AC-8, AC-9 tested; AC-7 partial (`qa/report/privacy-claims-trace.md`); Indonesian text is a draft for the owner |
| FEAT-010 | Tags, mood, and On this day | ready | Spec complete: icon-based mood (5-point, Lucide), tags (preset list of 8 plus free text), bundled with photos in v1.1, "On this day" shows every past year. Software-architect read (ADR-002, ADR-003 updates: schema 1 -> 2, `formatVersion` unchanged) and effort read (frontend-mobile, size L, driven by ADR-006's migration rules) both done. Owner confirmed `ready` on 2026-09-23. Not started: build, qa test cases, ADR-006 implementation |

RISK-001 scores 20 and is covered by the owner's written acceptance in ADR-001.

## Pending decisions (owner)
| Decision or action | Blocks |
|--------------------|--------|
| Numeric import limits (`ImportLimits`: file size, unpacked size, entries, entry size) | Final answer for TC-065 |
| Back up the release key and both passwords in a second place (the key itself exists since 2026-09-20; TC-091) | Any store upload, and every update |
| (done) Private vulnerability reporting is on, and the push and first CI run are done | G10 closed by the CI run |
| Read the risk and legal notes and confirm they may be public; run a final scan before making the repository public | The first public push |
| (done 2026-09-23) Owner accepted `product-manager/report/legal-self-assessment-v1.md` as the basis for the first Android release (not legal advice) | First store release in each region |
| (informally checked 2026-09-23, `public-app-name.md`) Confirm at submission that the name Exodite Anima registers in Play Console / App Store Connect | Store listing |
| Halt-trigger numbers for the staged release (plan decided; set after the internal test) | Release readiness |
| A physical phone for the performance targets (the owner chose a limited emulator, which cannot prove the frame-rate target) | Declaring the performance targets met |
| (done 2026-09-23, informal) A friend of the owner read the encryption and export design/code; no issues found (`cyber-security/report/independent-review-scope-v1.md`). A more formal review is still open if the owner wants stronger assurance | RISK-005, the Security row of PRR-001 |
| (done) Accessibility: TC-087 screen reader (2026-09-20), TC-088 200% text both themes (2026-09-20), TC-089 contrast measured with a tool (2026-09-23), all owner-reported Pass | The Compliance row of PRR-001 |
| (done 2026-09-23) Owner reviewed and accepted the Indonesian copy (all 180 strings, `app/lib/l10n/strings.dart`); About text is part of it | Release of the Indonesian interface |
| iOS: decided to follow Android; needs a Mac or cloud CI later | Any iOS release |

Decided on 2026-09-20: v1 choices (`v1-choices-2026-09-20`: Android first, limited emulator, no high contrast, Lucide icons, pinned button, friends for RS-001), the legal approach and its written assessment, the staged rollout, the MIT licence, the public name (display name Exodite Anima) and a public repository, contributions welcome, platforms and languages, provisional performance targets, lock and passcode policy, the answers to all spec questions, ADR-005 (accepted), ADR-006 (new), RISK-009 and RISK-010 (accepted). The technical spike decided the export envelope (custom, on vetted primitives) and the storage engine on Android; ADR-001 R1 (device-bound key) was not evaluated.

## Artifacts by role
| Role | Done | Not yet |
|------|------|---------|
| product-manager | context, 9 specs (76 criteria, no open questions), 10 decisions, risk register, legal self-assessment, workflow | signed-off legal assessment; halt numbers; rollout after the internal test |
| ux-design | context, RS-001 plan, 7 flows, journey map, IA, design review, workflow | RS-001 fielding (friends, no payment); consent form |
| product-design | context, brief, tokens 0.2.0, component sheet and specs, 14 screens with every state (light and dark), screen specs with TC references, review record, asset register, logo A2 (SVG, icon, previews), Lucide icons, workflow | owner review of the `.pen` files; independent accessibility check on the built app |
| software-architect | context, ADR-001 to 006, NFR analysis, C4 diagrams, self-review, workflow docs (built and tested on Android), spike results in the frontend-mobile plan | independent review; the ADR-001 device-bound key question |
| cyber-security | context, threat model (THR-001 to 015), security requirements review, ADR security review, dependency review (including new packages and CI), workflow | independent review; a vulnerability scan of dependencies; incident plan; private reporting switched on |
| qa | context, TP-001, 102 test cases with execution logs, privacy claims trace, PRR-001 (No-Go), workflow | runs on a physical phone; iOS; a defect tracker |
| frontend-mobile | context, permission register, local data design, release plan, spike results (S1, S2, S6, S7, S8 done; S3, S4 partial; S5 not evaluated), effort read, workflow; the whole Android app; CI workflow and manifest check; icon generator | release signing key; first CI run; iOS (no Mac) |

## Risks to watch
RISK-001 (data loss, 20), RISK-002 (format compatibility, 15), RISK-003 (side-channel leaks, 12). RISK-009 and RISK-010 were accepted by the owner on 2026-09-20. RISK-004 (storage on the platforms) is reduced for Android (encrypted database, search and export tested there) and stays open for iOS. RISK-005 (cryptography mistakes) stays open until an independent review. The full register is in `product-manager/report/risk-register.md`.

## Next steps
1. The owner installs the release APK on a physical phone and runs the cases listed in PRR-001 ("What would turn this into a Go"); results go into the test cases.
2. Create the release signing key and keep it outside the repository, with a backup.
3. (done 2026-09-20) Private vulnerability reporting is on; the push and the first CI run are done.
4. (done 2026-09-23) Independent review (informal, one friend, no issues found), accessibility runs (TC-087, TC-088, TC-089 all owner-reported Pass), and owner sign-offs (legal, Indonesian text, privacy statement) are all complete. Still open if stronger assurance is wanted: a more formal independent review; TC-088's "both languages at 200% text" was not explicitly re-stated; touch-target sizes not re-measured with TC-089.
5. (drafted and accepted by the owner 2026-09-23) Store material: data-safety answers, listing text (`frontend-mobile/report/store-listing-and-data-safety-v1.md`), privacy statement page (`docs/privacy.md`), informal name check (`public-app-name.md`). Still needed: reconciliation with the final build, and the real console name check at submission.
6. Before making the repository public: the checklist in `publishing.md`, and a final scan.

## Recent changes
| Date | Change |
|------|--------|
| 2026-09-23 | FEAT-010 (Tags, mood, and On this day) drafted at the owner's request; registered as `draft`; roadmap in `product-manager/context.md` updated; four open questions await the owner and a software-architect read on the schema/export-version impact |
| 2026-09-23 | Owner answered FEAT-010's four open questions: icon-based mood, tags support preset and free text, ships bundled with photos in v1.1, "On this day" shows every past year with an entry; roadmap updated to place FEAT-010 with photos; two new open questions raised (exact icon set, exact preset tag list) |
| 2026-09-23 | Product-manager proposed the mood icon set (5-point, Lucide) and preset tag list (8 items) for FEAT-010, closing its remaining open questions. Software-architect read followed: schema step for FEAT-010 recorded as updates to ADR-002 (`journalSchemaVersion` 1 -> 2, `mood` column, normalized `tags` table) and ADR-003 (manifest `schemaVersion` 2, export `formatVersion` unchanged). Only blocker left before `ready` is an effort read from frontend-mobile; ADR-006's migration rules still need to be implemented before this ships |
| 2026-09-23 | Frontend-mobile gave an effort read for FEAT-010: size L (`frontend-mobile/report/effort-read-v1.md`), driven by ADR-006's migration safety rules being implemented for the first time, not by the mood/tag UI alone. Every `write-feature-spec` readiness-checklist item is now met; FEAT-010 awaits the owner's confirmation to move to `ready` |
| 2026-09-23 | Owner confirmed FEAT-010 as `ready`; registered in `_shared/index.md` as `active`, roadmap in `product-manager/context.md` updated. Hand-off recorded to FEAT-002, FEAT-003, FEAT-006, FEAT-007 for build, and to qa for `TC-` derivation from AC-1 to AC-9 once build starts. Not yet built; ADR-006's migration rules still need implementing first |
| 2026-09-23 | Cyber-security reviewed FEAT-010 (personal-data hand-off trigger): no new `THR-` or trust boundary needed; covered by existing THR-001, THR-002, THR-004, THR-006, THR-010 (migration), THR-013 (`cyber-security/report/threat-model-v1.md`, Update 2026-09-23). G2 (design ready) still needs ux-design's flow and product-design's screens before qa (G3) and build (G4) |
| 2026-09-23 | Worked four v1 production blockers at the owner's request: (1) independent-review scope prepared for a friend to read the code (`cyber-security/report/independent-review-scope-v1.md`), not yet run; (2) accessibility run pointed to the existing checklist (`qa/workflow/phone-test-checklist.md` Block E), not yet run; (3) owner read and accepted `legal-self-assessment-v1.md` as the basis for the first Android release; (4) store material drafted: `docs/privacy.md` (privacy statement, not yet owner-reviewed) and `frontend-mobile/report/store-listing-and-data-safety-v1.md` (data-safety answers, listing text); an informal web search found no conflicting app named "Exodite Anima" (`public-app-name.md`), pending the real console check at submission |
| 2026-09-23 | Reviewed all 180 Indonesian strings (`app/lib/l10n/strings.dart`) for linguistic quality: no errors found; two minor wording fixes applied (`warnCheck`, `importDoneBody`) and confirmed by the owner. `test/settings_test.dart` (20 cases, covers string completeness) still passes. Indonesian text sign-off is done; only the privacy statement page still needs the owner's review among the four blockers |
| 2026-09-23 | Owner closed the remaining three blockers: (1) a friend of the owner completed the informal independent review of the encryption/export design and code, no issues found (`cyber-security/report/independent-review-scope-v1.md`); RISK-005 lowered, not closed. (2) Owner accepted the store material drafts (`docs/privacy.md`, `frontend-mobile/report/store-listing-and-data-safety-v1.md`). (3) Accessibility: found while checking that TC-087 and TC-088 were already Pass since 2026-09-20 (a correction to what this session said earlier); TC-089 (contrast) newly measured with a tool on 2026-09-23 and upgraded to Pass. PRR-001 rows 6 and 12 updated accordingly; still No-Go for production overall (remaining gaps: second phone for G1, formal review if wanted, release-key backup, dependency scan, iOS, store submission checks) |
| 2026-09-23 | Closed finding D1 (dependency vulnerability scanning not automated): added `.github/workflows/osv-scanner.yml` (OSV-Scanner, `google/osv-scanner-action@v2.6.0`), scanning `app/pubspec.lock` on push, PR, and a weekly schedule, reporting to the repository's Security tab. Owner confirmed adding this CI workflow before it was created |
| 2026-09-23 | Committed and pushed the day's session (commit `bc3db60`: FEAT-010, ADR-002/003 updates, independent-review outcome, store material, Indonesian text fixes, `osv-scanner.yml`, and status updates). Both `ci.yml` and `osv-scanner.yml` ran on the push and passed (runs 35817757728, 35817758051); no dependency vulnerabilities found. D1 fully closed |
| 2026-09-23 | Wrote the two remaining planned end-user docs (`docs/README.md` had listed them as not started): `docs/export-format.md` (technical spec of the archive, for anyone writing an independent reader) and `docs/backup-and-new-phone.md` (plain-language guide). Linked from `docs/privacy.md`. PRR-001 row 13 updated; still missing a whole-app user guide and a changelog |
| 2026-09-20 | Foundation (`_shared`), product-manager, and ux-design stages completed as drafts |
| 2026-09-20 | `devops` role removed; `product-design` added |
| 2026-09-20 | `.assist/` is now tracked and pushed; README, orchestration, publishing, status, and preflight added |
| 2026-09-20 | Architecture stage: ADRs moved into the role and ADR-004, ADR-005 added; NFR analysis, C4 diagrams, review, and two workflow docs written |
| 2026-09-20 | Security stage: threat model migrated and revised, requirements review, ADR review, dependency baseline; RISK-009 and RISK-010 added |
| 2026-09-20 | QA stage: TP-001 and 91 test cases written (later 102); every acceptance criterion now cites a TC- |
| 2026-09-20 | FEAT-001 set to in-progress at the owner's request; spike S1, S2, S8 passed on Android; encrypted storage layer (12 tests) and FEAT-001 screens (6 device tests) written; a release build has no key source yet |
| 2026-09-20 | Stale documents refreshed across all roles (status, phases, contexts, test plan, threat model, dependency review); `preflight.js` now warns when `status.md` (2 hours) or a role's `context.md` (1 day) is older than the newest work it describes |
| 2026-09-20 | Owner tried the release APK on a physical phone and reported that it ran smoothly (owner-reported, not recorded per test case). Launcher name changed to Exodite Anima |
| 2026-09-20 | Logo designed with the owner: four ideas, then four refinements; A2 (ring with a core) chosen and applied to the app icon, the in-app mark, the SVG files and the design previews |
| 2026-09-20 | App icon added (ring on brand green, Android adaptive and themed, all iOS sizes) by `app/tool/make_icons.py`; launcher label set (later changed to Exodite Anima) |
| 2026-09-20 | Production readiness review PRR-001 written: No-Go for production (five blocker rows Partial), ready for an internal test on a physical phone |
| 2026-09-20 | Icons replaced with Lucide (icon font, ISC); GitHub Actions workflow and `check_release_manifest.sh` written (CI has not run yet: it needs the first push) |
| 2026-09-20 | FEAT-005 and FEAT-009 set to in-progress; all nine v1 features are now built to the level of their tests. All text exists in English and Indonesian (draft). The timeline scrolls as one area, so search and the reminder no longer hide entries at 200% text. Emulator scrolling numbers turned out to be unreliable (see TC-019) |
| 2026-09-20 | FEAT-008 set to in-progress: reminder rules (30 days, 7-day snooze) as a tested pure function, reminder card, last-export lines |
| 2026-09-20 | FEAT-006 and FEAT-007 set to in-progress: encrypted export, minimal ZIP reader, import screens, restore after passcode setup; spike S6 decided (custom envelope), S7 passed on host; entries now carry a stable uid |
| 2026-09-20 | FEAT-003 and FEAT-004 set to in-progress: key vault (Argon2id, AES-GCM), setup and lock screens, auto-lock, Android secure window; spike S3 partial, S4 provisional (32 MiB, 3 passes), S5 not evaluated; a release build now opens a journal |
| 2026-09-20 | FEAT-002 set to in-progress; lazy timeline over a light preview query; 20,000-entry measurement recorded in TC-019 |
| 2026-09-20 | Owner answered the open questions: languages, targets, lock and passcode policy, and all spec questions; ADR-005 accepted, ADR-006 added, risks accepted; 15 criteria and 11 test cases added; S9 gained language and timeout choices |
| 2026-09-20 | Frontend-mobile stage: context and four reports written; `android:allowBackup="false"` applied and verified in the release APK; evidence recorded in TC-084, TC-085, TC-091 |
| 2026-09-20 | Product-design stage: designs migrated into the role and rebuilt from a three-tier token file with all states; the old border token failed the 3:1 rule and was replaced |
| 2026-09-20 | Physical phone test checklist added (`qa/workflow/phone-test-checklist.md`), mapped to the cases in TP-001 that need a real phone |
| 2026-09-20 | Owner ran the phone checklist on a physical Android phone and reported all items passed; results recorded in 27 test-case logs (TC-014, TC-031, TC-089 and TC-090 recorded as Partial). PRR-001 stays No-Go |
| 2026-09-20 | Second physical phone (Android 11) connected to `adb`: release APK installed and driven through onboarding, save, lock and unlock; partial evidence for TC-083, TC-085, TC-086, TC-090 |
| 2026-09-20 | Key derivation measured on a physical phone: 2.95 s median to open with the passcode at the current setting (5.8 s for exports); parameters to be decided by the owner (G1) |
| 2026-09-20 | Owner chose Argon2id 64 MiB, 3 passes, 2 lanes for the passcode (decision `key-derivation-settings`); default changed in `key_vault.dart`, test added for older vaults, release APKs rebuilt and the manifest check passes |
| 2026-09-20 | Sharing images built (`product-design/design/social/`): four post slides, repository banner, logo pack; screens are real debug-build screenshots with made-up entries |
| 2026-09-20 | Release signing wired in Gradle (`key.properties`, falls back to the debug key without it) and documented (`frontend-mobile/workflow/release-signing.md`); waiting for the owner to create the key |
| 2026-09-20 | Release key created by the owner; release APKs signed with it and verified (`apksigner`, manifest check); TC-091 now Partial instead of failed |
| 2026-09-20 | First CI run passed (4 of 4 jobs); pre-release v1.0.0-beta.1 published on GitHub (arm64-v8a and armeabi-v7a APKs signed with the release key, SHA256SUMS, notes in `docs/releases/`) |
