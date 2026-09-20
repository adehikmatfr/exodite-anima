# TP-001: Version 1 release test plan

Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): schedule and resources, plan risks. Method: skills `risk-based-testing`, `test-plan`, `test-case-writing`, and `load-and-chaos-testing` for the failure and performance cases.

| Field | Value |
|-------|-------|
| ID | TP-001 |
| Status | draft |
| Owner (QA) | qa |
| Linked FEAT | FEAT-001, FEAT-002, FEAT-003, FEAT-004, FEAT-005, FEAT-006, FEAT-007, FEAT-008, FEAT-009 |
| Related | ADR-001, ADR-002, ADR-003, ADR-004, ADR-005, THR-001 to THR-015, RISK-001 to RISK-010 |
| Target release / build | Version 1, first store release; no build exists yet |
| Last updated | 2026-09-20 |

## 1. Scope
- **In scope:** the acceptance criteria of FEAT-001 to FEAT-009, the failure, boundary, and negative cases chosen by risk, the privacy and security properties in the threat model, accessibility, and compatibility.
- **Out of scope, with reason:**
  - iOS execution: iOS cannot be built or run on the current machine (no Mac). Every case is designed for both platforms, but only Android can be executed locally. This is accepted only if the owner confirms it, and is a residual risk (QR-13).
  - Real biometric hardware: the emulator has virtual biometrics only; cases that need real sensors are marked manual and need a physical device.
  - Store review, penetration testing, and localisation: not planned at T1; localisation waits for `platforms-and-languages`.
- **Assumptions and dependencies (updated 2026-09-20):** the app now exists for Android and most cases were run by automated tests on the host and the emulator (results in each case's execution log and in `../report/PRR-001-v1-android.md`); the case `Status` fields are still `draft`. Cases that need a number or a rule that is still an open question are `blocked` and name the decision. The dependency on the technical spike (encrypted storage, key handling, export envelope) is total for the integration cases.

## 2. Risk assessment
Impact and likelihood 1 to 5; score = impact x likelihood; depth from the score (15 to 25 deep, 8 to 14 standard, 4 to 7 light, 1 to 3 smoke).

| Risk ID | Area / behavior | Impact (1-5) | Likelihood (1-5) | Score | Test depth | Linked TC |
|---------|-----------------|--------------|------------------|-------|-----------|-----------|
| QR-1 | Saved entry lost or corrupted (crash, migration, interruption) (RISK-001, THR-010) | 5 | 4 | 20 | deep | TC-003, TC-004, TC-010, TC-015, TC-082, TC-092, TC-100, TC-101 |
| QR-2 | Encryption at rest missing or incomplete (RISK-005, THR-002) | 5 | 3 | 15 | deep | TC-009 |
| QR-3 | Passcode, key, or lock handling wrong: lockout or exposure (RISK-005, THR-001, THR-007, THR-011) | 5 | 3 | 15 | deep | TC-021, TC-026, TC-029, TC-038, TC-082, TC-093 |
| QR-4 | Export and import do not round trip, or old formats stop importing (RISK-002) | 5 | 4 | 20 | deep | TC-058, TC-061, TC-056, TC-066 |
| QR-5 | Malformed or hostile archive damages the journal (THR-008) | 4 | 2 | 8 | standard | TC-065 |
| QR-6 | Content leaks through backup, previews, logs, or clipboard (RISK-003, THR-003, THR-004, THR-005) | 4 | 3 | 12 | standard | TC-023, TC-085, TC-086 |
| QR-7 | Release build misconfigured (network permission, debug logging) (THR-015, THR-014) | 5 | 2 | 10 | standard | TC-084, TC-091, TC-083 |
| QR-8 | Search returns wrong, missing, or stale results, or is too slow (RISK-004) | 3 | 3 | 9 | standard | TC-040, TC-043, TC-046 |
| QR-9 | Accessibility below WCAG 2.2 AA (compliance matrix) | 3 | 3 | 9 | standard | TC-087, TC-088, TC-089 |
| QR-10 | Behaviour differs across OS versions and devices (NFR-16) | 4 | 3 | 12 | standard | TC-090 |
| QR-11 | Timeline, editor, and settings behave wrongly (FEAT-001, FEAT-002, FEAT-009) | 3 | 2 | 6 | light | TC-001, TC-016, TC-075 |
| QR-12 | Export reminder shows at the wrong time (FEAT-008) | 2 | 2 | 4 | light | TC-068, TC-074 |
| QR-13 | iOS behaviour cannot be executed locally (RISK-004) | 4 | 4 | 16 | deep | not testable locally, see section 1 |

**Not tested and why** (needs the owner's written acceptance):
| Item | Reason | Accepting owner |
|------|--------|-----------------|
| iOS execution | No Mac available; decide Mac or cloud CI | Project owner |
| Real fingerprint and face hardware | Emulator only | Project owner |
| Lowest-tier device performance | The device list is not decided | Project owner |
| Penetration test | Optional at T1; not planned | Project owner |

## 3. Strategy by level
| Level | Approach | Automated? | Owner |
|-------|----------|-----------|-------|
| Unit (guidance) | Pure rules: passcode rules, reminder timing, export format building and parsing. Run with `flutter test`. | Yes (planned) | frontend-mobile |
| Integration | Storage, encryption, key wrapping, export and import against real files on a device or emulator, including the fixture archives for every format version. | Yes (planned) | qa with frontend-mobile |
| Contract | The export format is the only contract; sample archives per `formatVersion` are its contract tests. No API exists. | Yes (planned) | qa |
| End-to-end | A few journeys on a device or emulator: setup, write, lock and unlock, search, export, import. Flutter's `integration_test` package where automatable. | Partly | qa |
| Performance / load | Timed runs on the lowest-tier device with a generated journal. Blocked until `nfr-targets-v1`. | Planned | qa |
| Resilience / chaos | Kill the process at every step of saving, changing the passcode, and importing; too little storage; interrupted export. | Planned | qa |
| Security-adjacent | Raw-file inspection, tampered archive, malformed archive, log inspection, traffic inspection, manifest check. Once code exists, use `tools/mutate.js` to prove that removing the lock, the encryption, or the backup exclusion makes the suite fail. | Yes (planned) | qa with cyber-security |
| Accessibility / compatibility | Screen reader, 200 percent font size, contrast and target size, OS versions. | Manual | qa with product-design |
| Exploratory (charters) | See section 8 | Manual | qa |

## 4. Environments and data
| Environment | Purpose | Parity gaps vs production | Data (synthetic/masked) |
|-------------|---------|---------------------------|-------------------------|
| Local Android emulator (`flutter_avd`, verified working) | Most functional and resilience cases | No real sensors; performance not representative | Synthetic entries and passcodes |
| Physical Android device | Biometrics, performance, real backup and restore | Device list not decided | Synthetic |
| iOS | All cases that need iOS | Not available locally (RISK-004) | Synthetic |
| CI | Automated checks (manifest, unit, integration) | Does not exist yet | Synthetic |

Test data rule: no real journal content or real passcodes, ever. Synthetic entries are generated by a script; fixture archives for each format version live with the app tests (path to be set when tests exist).

## 5. Entry criteria
- [ ] A build is installed on a test environment and a smoke journey passes
- [ ] The acceptance criteria of the feature are reviewed and testable (open questions closed)
- [ ] Test data and devices are ready

## 6. Exit criteria
- [ ] 100% of P0 cases executed and passed (50 P0 cases planned)
- [ ] At least 95% of all planned cases executed and passed
- [ ] No open S1 or S2 defects; S3 defects accepted in writing
- [ ] NFR targets met once confirmed (`nfr-analysis-v1.md`)
- [ ] Every FEAT acceptance criterion traced to at least one passing TC
- [ ] No quarantined P0 test

## 7. Traceability
76 acceptance criteria map to test cases. Blocked cases wait for a decision named in the case.

| FEAT acceptance criterion | TC IDs | Status |
|---------------------------|--------|--------|
| FEAT-001 AC-1: A new entry with that text and today's date appears in the timeline | TC-001 | not run |
| FEAT-001 AC-2: The entry shows the new text | TC-002 | not run |
| FEAT-001 AC-3: The saved text is unchanged | TC-003 | not run |
| FEAT-001 AC-4: The unsaved text is offered back at the next unlock | TC-004 | not run |
| FEAT-001 AC-5: The entry appears under the chosen date in the timeline | TC-005 | not run |
| FEAT-001 AC-6: The entry no longer appears in the timeline | TC-006 | not run |
| FEAT-001 AC-7: The entry is unchanged | TC-007 | not run |
| FEAT-001 AC-8: No entry is created | TC-008 | not run |
| FEAT-001 AC-9: A message says nothing was deleted and offers Try again and Import your journal | TC-092 | not run |
| FEAT-001 AC-10: The older version refuses to change it and asks the user to update the app | TC-101 | not run |
| FEAT-001 AC-11: The journal is restored to its state before the update and opens | TC-100 | not run |
| FEAT-002 AC-1: Entries are listed newest first, grouped by day | TC-016 | not run |
| FEAT-002 AC-2: An empty state with an action to write the first entry is shown | TC-017 | not run |
| FEAT-002 AC-3: The entry opens | TC-018 | not run |
| FEAT-002 AC-4: Scrolling stays smooth: at least 95% of frames render within 16.7 ms (`nfr-targets-v1`, a journal of 20,000 entries, provisional until measured) | TC-019 | not run |
| FEAT-002 AC-5: No entry text is visible | TC-020 | not run |
| FEAT-003 AC-1: The lock screen appears with no entries visible | TC-021 | not run |
| FEAT-003 AC-2: It is locked when the user returns | TC-022 | not run |
| FEAT-003 AC-3: No entry content is visible in the preview | TC-023 | not run |
| FEAT-003 AC-4: The passcode field is offered | TC-024 | not run |
| FEAT-003 AC-5: The app unlocks | TC-025 | not run |
| FEAT-003 AC-6: The wait before the next attempt grows | TC-026 | not run |
| FEAT-003 AC-7: No journal content is visible | TC-027 | not run |
| FEAT-003 AC-8: The app opens and all entries are intact | TC-028 | not run |
| FEAT-003 AC-9: The app waits 30 seconds before the next attempt, and the wait doubles with each further wrong attempt up to one hour | TC-093 | not run |
| FEAT-003 AC-10: The wait continues and the count of wrong attempts is kept | TC-029 | not run |
| FEAT-003 AC-11: The capture is blocked | TC-094 | not run |
| FEAT-004 AC-1: The timeline cannot be reached | TC-032 | not run |
| FEAT-004 AC-2: An error is shown and setup does not continue | TC-033 | not run |
| FEAT-004 AC-3: An error explains the rule and setup does not continue | TC-034 | not run |
| FEAT-004 AC-4: Setup cannot be completed | TC-035 | not run |
| FEAT-004 AC-5: The lock screen appears and the passcode opens the empty journal | TC-036 | not run |
| FEAT-004 AC-6: Every claim traces to a requirement and a test | TC-037 | not run |
| FEAT-004 AC-7: The passcode is refused with a reason and setup does not continue | TC-038 | not run |
| FEAT-005 AC-1: The matching entries are listed with the word highlighted | TC-040 | not run |
| FEAT-005 AC-2: A no-results message is shown | TC-041 | not run |
| FEAT-005 AC-3: The entry opens | TC-042 | not run |
| FEAT-005 AC-4: The entry is not listed | TC-043 | not run |
| FEAT-005 AC-5: Search works normally | TC-044 | not run |
| FEAT-005 AC-6: Results appear within 300 ms (`nfr-targets-v1`, provisional until measured) | TC-045 | not run |
| FEAT-005 AC-7: The entry is listed | TC-047 | not run |
| FEAT-005 AC-8: The first search lists the entry and the second does not | TC-095 | not run |
| FEAT-006 AC-1: The entries cannot be read | TC-048 | not run |
| FEAT-006 AC-2: No entries are revealed | TC-049 | not run |
| FEAT-006 AC-3: A warning is shown before anything is created | TC-050 | not run |
| FEAT-006 AC-4: The count equals the number of entries in the journal | TC-051 | not run |
| FEAT-006 AC-5: The deleted entry is not in the file | TC-052 | not run |
| FEAT-006 AC-6: The last export time is updated | TC-053 | not run |
| FEAT-006 AC-7: The last export time is not changed | TC-054 | not run |
| FEAT-006 AC-8: Progress is shown | TC-055 | not run |
| FEAT-006 AC-9: The password is refused with a reason and no file is created | TC-096 | not run |
| FEAT-007 AC-1: All N entries are present with the same text and dates | TC-058 | not run |
| FEAT-007 AC-2: The import is refused and nothing changes | TC-059 | not run |
| FEAT-007 AC-3: The import is refused and the journal is unchanged | TC-060 | not run |
| FEAT-007 AC-4: All its entries are restored | TC-061 | not run |
| FEAT-007 AC-5: A message asks the user to update the app and nothing changes | TC-062 | not run |
| FEAT-007 AC-6: No duplicates are created | TC-063 | not run |
| FEAT-007 AC-7: The journal is unchanged | TC-064 | not run |
| FEAT-007 AC-8: The entry already on the phone is kept unchanged and counted as skipped | TC-097 | not run |
| FEAT-007 AC-9: A passcode has already been set | TC-102 | not run |
| FEAT-008 AC-1: The reminder is shown | TC-068 | not run |
| FEAT-008 AC-2: No reminder is shown | TC-069 | not run |
| FEAT-008 AC-3: The reminder is shown | TC-070 | not run |
| FEAT-008 AC-4: It is hidden for 7 days | TC-071 | not run |
| FEAT-008 AC-5: The reminder disappears | TC-072 | not run |
| FEAT-008 AC-6: It contains no entry text | TC-073 | not run |
| FEAT-008 AC-7: No reminder is shown; one day later it is shown | TC-074 | not run |
| FEAT-009 AC-1: The app switches and keeps the choice after a restart | TC-075 | not run |
| FEAT-009 AC-2: The new passcode opens the app | TC-076 | not run |
| FEAT-009 AC-3: All entries are still readable | TC-077 | not run |
| FEAT-009 AC-4: The change is refused | TC-078 | not run |
| FEAT-009 AC-5: The app locks | TC-079 | not run |
| FEAT-009 AC-6: Only the passcode unlocks it | TC-080 | not run |
| FEAT-009 AC-7: Every claim traces to a requirement and a test | TC-081 | not run |
| FEAT-009 AC-8: All app text is in Indonesian and stays so after a restart | TC-098 | not run |
| FEAT-009 AC-9: The app is in English | TC-099 | not run |

### Coverage with no acceptance criterion yet (raised to product-manager)
QA does not invent expected results or acceptance criteria. These cases verify behaviour or properties that no criterion states. The product-manager should either add a criterion (proposed wording follows) or confirm that the case is verified as a non-functional requirement.

| TC | Case | FEAT | Priority |
|----|------|------|----------|
| TC-009 | Verify no entry text is readable in any stored file without the key |  | P0 |
| TC-010 | Verify a saved entry is complete or absent after a crash at every step of saving |  | P0 |
| TC-011 | Verify very long text is saved unchanged up to the technical bound and refused clearly beyond it |  | P1 |
| TC-012 | Verify Unicode text (emoji, combining marks, right-to-left) is saved and shown unchanged |  | P1 |
| TC-013 | Verify an entry keeps the date the user chose after the phone's time zone or clock changes |  | P2 |
| TC-014 | Verify saving an entry stays within the latency target on the lowest-tier device |  | P1 |
| TC-015 | Verify a database written by the previous schema version opens with all entries intact |  | P0 |
| TC-030 | Verify changing the phone clock does not shorten the wait after wrong passcodes |  | P1 |
| TC-031 | Verify unlock after a biometric success meets the latency target on the lowest-tier device |  | P1 |
| TC-039 | Verify closing the app before acknowledging the warning leaves nothing stored |  | P1 |
| TC-046 | Verify search handles special characters without an error or a wrong result |  | P1 |
| TC-056 | Verify any changed byte in an encrypted export makes import refuse it before anything is applied |  | P0 |
| TC-057 | Verify an export with too little storage fails cleanly without leaving a partial file |  | P1 |
| TC-065 | Verify malformed archives are refused and leave the journal unchanged |  | P0 |
| TC-066 | Verify importing the same file twice adds nothing the second time |  | P1 |
| TC-067 | Verify restoring a very large export meets the time target on the lowest-tier device |  | P2 |
| TC-082 | Verify closing the app during a passcode change leaves the journal openable |  | P0 |
| TC-083 | Verify a complete test run makes no network request carrying content |  | P0 |
| TC-084 | Verify the merged Android release manifest declares no network permission |  | P0 |
| TC-085 | Verify app data is excluded from cloud backup and is absent after a restore |  | P0 |
| TC-086 | Verify logs of a full run contain no entry text, passcode, or key |  | P0 |
| TC-087 | Verify every screen is usable with a screen reader in a logical order with labels |  | P1 |
| TC-088 | Verify all screens stay readable at 200 percent system font size in both themes |  | P1 |
| TC-089 | Verify text contrast and touch targets meet the design tokens in both themes |  | P1 |
| TC-090 | Verify launch, unlock, save, search, export, and import on the supported OS versions |  | P1 |
| TC-091 | Verify a release build has no debug logging and is signed with the release key |  | P0 |

Proposed criteria for the product-manager (those the owner's answers already covered were added to the specs on 2026-09-20: the wait that continues after closing the app, the passcode rules, the matching rules, and the reminder boundary):
- FEAT-001: "Given entries were saved, When the app's stored files are inspected without the key, Then no entry text can be found in any of them." (TC-009)
- FEAT-001: "Given the app stops at any moment while saving, When it is opened again, Then the entry is either fully saved or absent, and the journal opens." (TC-010)
- FEAT-006 and FEAT-007: "Given an encrypted export in which any byte was changed, When it is imported, Then the import is refused and the journal is unchanged." (TC-056)
- New cross-cutting criterion, if the owner approves adding it: "The app makes no network request, has no network permission in its Android release build, and excludes its data from cloud backup." (TC-083, TC-084, TC-085). This changes scope (a possible new FEAT), so it is the owner's decision.

## 8. Exploratory charters
1. **Setup and recovery wording:** explore the first-run flow as a person who has never used the app; note where the no-recovery rule is misunderstood (feeds RS-001).
2. **Interruptions:** explore calls, notifications, rotation, low battery, and killing the app at random moments during writing, exporting, and importing.
3. **Hostile files:** explore importing files of the wrong type, renamed files, and very large files.
4. **Side channels:** look for entry content anywhere except the screen: previews, notifications, clipboard, logs, and backups.

## 9. Defect handling
Severity and priority follow the `bug-report` skill and `_shared/standards/severity-and-incident.md`. No tracker is chosen yet; until one is, defects are recorded in a markdown file per defect under `qa/report/`. Triage is done by the owner as defects appear.

## 10. Test case index
All cases, in the format the registry check reads. Priority P0 blocks the release if it fails.

| TC | Title | FEAT and links | Level | Priority | Automation |
|----|-------|----------------|-------|----------|------------|
| TC-001 | Verify A new entry with that text and today's date appears in the timeline | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | e2e | P0 | planned |
| TC-002 | Verify the entry shows the new text | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | e2e | P1 | planned |
| TC-003 | Verify the saved text is unchanged | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | resilience | P0 | planned |
| TC-004 | Verify the unsaved text is offered back at the next unlock | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | resilience | P0 | planned |
| TC-005 | Verify the entry appears under the chosen date in the timeline | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | e2e | P1 | planned |
| TC-006 | Verify the entry no longer appears in the timeline | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | e2e | P0 | planned |
| TC-007 | Verify the entry is unchanged | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | e2e | P1 | planned |
| TC-008 | Verify no entry is created | FEAT-001, ADR-001, ADR-002, RISK-001, THR-010 | e2e | P1 | planned |
| TC-009 | Verify no entry text is readable in any stored file without the key | FEAT-001, THR-002, ADR-002 | integration | P0 | planned |
| TC-010 | Verify a saved entry is complete or absent after a crash at every step of saving | FEAT-001, THR-010, RISK-001 | resilience | P0 | planned |
| TC-011 | Verify very long text is saved unchanged up to the technical bound and refused clearly beyond it | FEAT-001 | integration | P1 | planned |
| TC-012 | Verify Unicode text (emoji, combining marks, right-to-left) is saved and shown unchanged | FEAT-001 | integration | P1 | planned |
| TC-013 | Verify an entry keeps the date the user chose after the phone's time zone or clock changes | FEAT-001 | integration | P2 | planned |
| TC-014 | Verify saving an entry stays within the latency target on the lowest-tier device | FEAT-001 | performance | P1 | planned |
| TC-015 | Verify a database written by the previous schema version opens with all entries intact | FEAT-001, THR-010 | integration | P0 | planned |
| TC-016 | Verify entries are listed newest first, grouped by day | FEAT-002, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-017 | Verify an empty state with an action to write the first entry is shown | FEAT-002, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-018 | Verify the entry opens | FEAT-002, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-019 | Verify scrolling stays within the responsiveness target of `nfr-targets-v1` (criterion incomplete until that decision is made) | FEAT-002, ADR-002, RISK-004 | performance | P1 | planned |
| TC-020 | Verify no entry text is visible | FEAT-002, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-021 | Verify the lock screen appears with no entries visible | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | planned |
| TC-022 | Verify the app is locked when the user returns | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | planned |
| TC-023 | Verify no entry content is visible in the preview | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | manual |
| TC-024 | Verify the passcode field is offered | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | manual |
| TC-025 | Verify the app unlocks | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | planned |
| TC-026 | Verify the wait before the next attempt grows | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | planned |
| TC-027 | Verify no journal content is visible | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | planned |
| TC-028 | Verify the app opens and all entries are intact | FEAT-003, ADR-001, THR-001, THR-004, THR-007, RISK-003 | e2e | P0 | manual |
| TC-029 | Verify the wait after wrong passcodes persists when the app is closed and reopened | FEAT-003, THR-007 | resilience | P0 | planned |
| TC-030 | Verify changing the phone clock does not shorten the wait after wrong passcodes | FEAT-003, THR-007 | e2e | P1 | manual |
| TC-031 | Verify unlock after a biometric success meets the latency target on the lowest-tier device | FEAT-003 | performance | P1 | planned |
| TC-032 | Verify the timeline cannot be reached | FEAT-004, ADR-001, RISK-001, THR-011 | e2e | P0 | planned |
| TC-033 | Verify an error is shown and setup does not continue | FEAT-004, ADR-001, RISK-001, THR-011 | e2e | P1 | planned |
| TC-034 | Verify an error explains the rule and setup does not continue | FEAT-004, ADR-001, RISK-001, THR-011 | e2e | P0 | planned |
| TC-035 | Verify setup cannot be completed | FEAT-004, ADR-001, RISK-001, THR-011 | e2e | P1 | planned |
| TC-036 | Verify the lock screen appears and the passcode opens the empty journal | FEAT-004, ADR-001, RISK-001, THR-011 | resilience | P0 | planned |
| TC-037 | Verify every claim traces to a requirement and a test | FEAT-004, ADR-001, RISK-001, THR-011 | exploratory | P1 | manual |
| TC-038 | Verify passcodes below, at, and above the minimum length and common passcodes are handled by the rules | FEAT-004, THR-007 | unit | P0 | planned |
| TC-039 | Verify closing the app before acknowledging the warning leaves nothing stored | FEAT-004, THR-011 | resilience | P1 | planned |
| TC-040 | Verify the matching entries are listed with the word highlighted | FEAT-005, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-041 | Verify A no-results message is shown | FEAT-005, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-042 | Verify the entry opens | FEAT-005, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-043 | Verify the entry is not listed | FEAT-005, ADR-002, RISK-004 | e2e | P0 | planned |
| TC-044 | Verify search works normally | FEAT-005, ADR-002, RISK-004 | e2e | P1 | planned |
| TC-045 | Verify results appear within the responsiveness target of `nfr-targets-v1` (criterion incomplete until that decision is made) | FEAT-005, ADR-002, RISK-004 | performance | P1 | planned |
| TC-046 | Verify search handles special characters without an error or a wrong result | FEAT-005 | integration | P1 | planned |
| TC-047 | Verify search ignores case and accents | FEAT-005 | integration | P1 | planned |
| TC-048 | Verify the entries cannot be read | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | integration | P0 | planned |
| TC-049 | Verify no entries are revealed | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | integration | P0 | planned |
| TC-050 | Verify A warning is shown before anything is created | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | e2e | P1 | planned |
| TC-051 | Verify the count equals the number of entries in the journal | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | integration | P0 | planned |
| TC-052 | Verify the deleted entry is not in the file | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | integration | P0 | planned |
| TC-053 | Verify the last export time is updated | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | e2e | P1 | planned |
| TC-054 | Verify the last export time is not changed | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | e2e | P1 | planned |
| TC-055 | Verify progress is shown | FEAT-006, ADR-001, ADR-003, RISK-001, RISK-002, THR-006 | performance | P2 | planned |
| TC-056 | Verify any changed byte in an encrypted export makes import refuse it before anything is applied | FEAT-006, THR-006 | integration | P0 | planned |
| TC-057 | Verify an export with too little storage fails cleanly without leaving a partial file | FEAT-006 | resilience | P1 | planned |
| TC-058 | Verify all N entries are present with the same text and dates | FEAT-007, ADR-001, ADR-002, ADR-003, RISK-002, THR-008 | e2e | P0 | planned |
| TC-059 | Verify the import is refused and nothing changes | FEAT-007, ADR-001, ADR-002, ADR-003, RISK-002, THR-008 | integration | P0 | planned |
| TC-060 | Verify the import is refused and the journal is unchanged | FEAT-007, ADR-001, ADR-002, ADR-003, RISK-002, THR-008 | integration | P0 | planned |
| TC-061 | Verify all its entries are restored | FEAT-007, ADR-001, ADR-002, ADR-003, RISK-002, THR-008 | integration | P0 | planned |
| TC-062 | Verify A message asks the user to update the app and nothing changes | FEAT-007, ADR-001, ADR-002, ADR-003, RISK-002, THR-008 | integration | P0 | planned |
| TC-063 | Verify no duplicates are created | FEAT-007, ADR-001, ADR-002, ADR-003, RISK-002, THR-008 | integration | P0 | planned |
| TC-064 | Verify the journal is unchanged | FEAT-007, ADR-001, ADR-002, ADR-003, RISK-002, THR-008 | resilience | P0 | planned |
| TC-065 | Verify malformed archives are refused and leave the journal unchanged | FEAT-007, THR-008 | integration | P0 | planned |
| TC-066 | Verify importing the same file twice adds nothing the second time | FEAT-007 | integration | P1 | planned |
| TC-067 | Verify restoring a very large export meets the time target on the lowest-tier device | FEAT-007 | performance | P2 | planned |
| TC-068 | Verify the reminder is shown | FEAT-008, RISK-001 | unit | P1 | planned |
| TC-069 | Verify no reminder is shown | FEAT-008, RISK-001 | unit | P1 | planned |
| TC-070 | Verify the reminder is shown | FEAT-008, RISK-001 | unit | P1 | planned |
| TC-071 | Verify the reminder is hidden for the snooze period | FEAT-008, RISK-001 | unit | P2 | planned |
| TC-072 | Verify the reminder disappears | FEAT-008, RISK-001 | unit | P1 | planned |
| TC-073 | Verify the reminder contains no entry text | FEAT-008, RISK-001 | e2e | P0 | planned |
| TC-074 | Verify the reminder is not shown at exactly 30 days and is shown a day later | FEAT-008 | unit | P2 | planned |
| TC-075 | Verify the app switches and keeps the choice after a restart | FEAT-009, ADR-001, RISK-001, RISK-005 | e2e | P1 | planned |
| TC-076 | Verify the new passcode opens the app | FEAT-009, ADR-001, RISK-001, RISK-005 | e2e | P0 | planned |
| TC-077 | Verify all entries are still readable | FEAT-009, ADR-001, RISK-001, RISK-005 | e2e | P0 | planned |
| TC-078 | Verify the change is refused | FEAT-009, ADR-001, RISK-001, RISK-005 | e2e | P0 | planned |
| TC-079 | Verify the app locks | FEAT-009, ADR-001, RISK-001, RISK-005 | e2e | P1 | planned |
| TC-080 | Verify only the passcode unlocks it | FEAT-009, ADR-001, RISK-001, RISK-005 | e2e | P1 | manual |
| TC-081 | Verify every claim traces to a requirement and a test | FEAT-009, ADR-001, RISK-001, RISK-005 | exploratory | P1 | manual |
| TC-082 | Verify closing the app during a passcode change leaves the journal openable | FEAT-009, RISK-001, ADR-001 | resilience | P0 | planned |
| TC-083 | Verify a complete test run makes no network request carrying content | FEAT-001, FEAT-003, FEAT-006, FEAT-007, THR-005, ADR-005 | e2e | P0 | planned |
| TC-084 | Verify the merged Android release manifest declares no network permission | FEAT-001, FEAT-006, FEAT-007, THR-015, ADR-005 | integration | P0 | planned |
| TC-085 | Verify app data is excluded from cloud backup and is absent after a restore | FEAT-001, FEAT-004, THR-003, ADR-001 | e2e | P0 | manual |
| TC-086 | Verify logs of a full run contain no entry text, passcode, or key | FEAT-001, FEAT-003, FEAT-004, THR-005 | integration | P0 | planned |
| TC-087 | Verify every screen is usable with a screen reader in a logical order with labels | FEAT-001, FEAT-003, FEAT-004 | e2e | P1 | manual |
| TC-088 | Verify all screens stay readable at 200 percent system font size in both themes | FEAT-001, FEAT-004, FEAT-009 | e2e | P1 | manual |
| TC-089 | Verify text contrast and touch targets meet the design tokens in both themes | FEAT-004, FEAT-009 | e2e | P1 | manual |
| TC-090 | Verify launch, unlock, save, search, export, and import on the supported OS versions | FEAT-001, FEAT-003, FEAT-006, FEAT-007 | e2e | P1 | planned |
| TC-091 | Verify a release build has no debug logging and is signed with the release key | FEAT-001, FEAT-003, THR-015, THR-014 | integration | P0 | manual |
| TC-092 | Verify a message says nothing was deleted and offers Try again and Import your journal | FEAT-001, ADR-006, RISK-001, THR-010 | e2e | P0 | planned |
| TC-093 | Verify the wait after five wrong passcodes is 30 seconds and doubles up to one hour | FEAT-003, THR-007 | integration | P0 | planned |
| TC-094 | Verify screenshots and screen recording are blocked on Android | FEAT-003, THR-004 | e2e | P1 | manual |
| TC-095 | Verify search matches from the start of a word only | FEAT-005 | integration | P1 | planned |
| TC-096 | Verify an export password shorter than 8 characters is refused | FEAT-006, THR-007 | unit | P1 | planned |
| TC-097 | Verify an entry already on the phone is kept unchanged and counted as skipped | FEAT-007, RISK-002 | integration | P0 | planned |
| TC-098 | Verify choosing Indonesian switches all app text and keeps the choice after a restart | FEAT-009 | e2e | P1 | planned |
| TC-099 | Verify a phone in another language starts the app in English | FEAT-009 | e2e | P1 | planned |
| TC-100 | Verify a failed data migration restores the journal to its state before the update | FEAT-001, ADR-006, RISK-001, THR-010 | resilience | P0 | planned |
| TC-101 | Verify an older app refuses to change a journal saved by a newer version | FEAT-001, ADR-006, THR-010 | integration | P0 | planned |
| TC-102 | Verify a passcode is set before a backup is imported on a fresh install | FEAT-007, ADR-001 | e2e | P0 | planned |

## 11. Results summary
Updated 2026-09-20 from the execution logs (details and the readiness decision in `../report/PRR-001-v1-android.md`). 102 cases planned: 50 P0, 13 manual, 2 blocked by open decisions.

| Result in the execution log | Cases | Of which P0 |
|-----------------------------|-------|-------------|
| Passed by automated test (host and Android emulator) | 66 | 34 |
| Passed by hand | 1 | 1 |
| Partial | 16 | 9 |
| Failed | 1 (TC-091: the release build is signed with the debug key) | 1 |
| Not executed | 18 | 5 |

No case is recorded on a physical phone; no case has been marked `passed` by qa in its status field. Open defects: TC-091 (release signing). Recommendation: **No-Go for production** (PRR-001); ready for an internal test on a physical phone.
