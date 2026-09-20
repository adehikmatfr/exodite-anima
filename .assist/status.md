# Status

Where the project stands. Update it in the postflight of every piece of work (`orchestration.md`). Last updated: 2026-09-20.

## Phase
All nine phases have work in them; none is finished.
- Planning and requirements (1), UX discovery (2), architecture (3): done as drafts. All nine feature specs are `in-progress` (built) and every question is answered.
- Security design (4): drafted and self-reviewed; open blockers are G1 (key-derivation settings: measured on a phone, 64 MiB / 3 passes / 2 lanes chosen and built; a second phone and an independent review are still needed), G10 (the CI check is written but has never run) and G11 (iOS, out of scope for the first release). No independent review yet.
- Test strategy (5): TP-001 has 102 cases; results from execution logs: 66 passed by automated test on the host and the Android emulator, 16 partial, 18 not executed, 1 passed by hand, 1 failed (TC-091, release signing). Nothing has been recorded on a physical phone per case.
- Visual design (6): tokens, components, all screens and states; logo A2 and the app icon; Lucide icons. The owner has not reviewed the `.pen` files in OpenPencil since the rebuild.
- Build (7): all nine v1 features are built for Android (Flutter). 98 unit tests on the host and screen tests on the emulator for every feature. The owner tried the release APK on a physical phone and reported that it ran smoothly (owner-reported, not per case). iOS is not built (no Mac; Android first).
- Verify and release (8): PRR-001 (`qa/report/PRR-001-v1-android.md`) says **No-Go for production**; the app is ready for an internal test on a physical phone. Not started: release signing key, first CI run, store material.
- Maintain (9): not started. See the phase table in `orchestration.md`.

## Features and gates
All nine specs are `in-progress`: built and tested to the level shown. Moving a spec to `released` needs the production readiness review (PRR-001) to reach Go.

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

RISK-001 scores 20 and is covered by the owner's written acceptance in ADR-001.

## Pending decisions (owner)
| Decision or action | Blocks |
|--------------------|--------|
| Numeric import limits (`ImportLimits`: file size, unpacked size, entries, entry size) | Final answer for TC-065 |
| Create the release signing key, kept outside the repository with a backup (TC-091) | Any store upload |
| Push to the private repository, switch on private vulnerability reporting, let CI run once | G10, the public release |
| Read the risk and legal notes and confirm they may be public; run a final scan before making the repository public | The first public push |
| Owner reads and signs off `product-manager/report/legal-self-assessment-v1.md` (not legal advice) | First store release in each region |
| Check that the name Exodite Anima is free on both stores | Store listing |
| Halt-trigger numbers for the staged release (plan decided; set after the internal test) | Release readiness |
| A physical phone for the performance targets (the owner chose a limited emulator, which cannot prove the frame-rate target) | Declaring the performance targets met |
| Independent review of the encryption and export design | RISK-005, the Security row of PRR-001 |
| Accessibility runs on a real screen reader and all screens at 200% text | The Compliance row of PRR-001 |
| Review of the Indonesian copy (all 180 strings, `app/lib/l10n/strings.dart`) and of the About text | Release of the Indonesian interface |
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
3. Push to the private repository, switch on private vulnerability reporting, and let CI run.
4. Independent review of the encryption and export design; accessibility runs; owner sign-offs (legal, privacy statement, Indonesian text).
5. Store material: data-safety answers, privacy statement page, listing text, name check.
6. Before making the repository public: the checklist in `publishing.md`, and a final scan.

## Recent changes
| Date | Change |
|------|--------|
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
