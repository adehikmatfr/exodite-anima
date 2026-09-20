# Physical phone test checklist (Android, version 1)

Written 2026-09-20 by qa. It turns the "not executed" and "partial" cases of `TP-001` that need a real phone into one manual run, in the order that saves the most time. It is a guide, not a new plan: the cases and their expected results stay in `../test-cases/`.

## Rules for the run
- **Use a fresh install with synthetic text only** (for example "test entry one"). Never put real journal text, real passcodes, or account names in a test entry or in a result note. If the phone already holds a real journal, export it first, or use a second phone: uninstalling deletes the journal.
- Install the release APK for the phone's architecture (`app-arm64-v8a-release.apk` for most phones). It is signed with the debug key, so TC-091 stays failed until the release key exists.
- Record each result in the **execution log of the case** in `../test-cases/`, with the date, the words Pass, Fail, or Partial, and one line of what was seen. Name the phone only by class (for example "mid-range phone, Android 13"); never a serial number, IMEI, or account. A case may be set to `active` only when its log says Pass on a phone.
- Any Fail: stop that block, write down the exact steps, and hand it to the assistant as a defect.
- Do not tick a case you did not do. "Not tried" is a valid result.

## Block A: first run (about 10 minutes)
| Case | Do | Expect |
|------|----|--------|
| TC-090 | Install, open, finish onboarding with biometrics on, write one entry, search for a word in it | Every step works on this Android version |
| TC-003 | Force-stop the app (Settings, Apps, Force stop), open it, unlock | The entry text is unchanged |
| TC-014 | Save an entry a few times | Saving feels instant; note anything over about one second |

## Block B: lock and screen privacy (about 20 minutes)
| Case | Do | Expect |
|------|----|--------|
| TC-022 | Press Home, wait past the lock timeout (default: immediately), return | The lock screen is shown, no entry visible |
| TC-023, TC-020 | Open the recent-apps screen while an entry is open | The preview is blank or hides the content |
| TC-094 | Take a screenshot; start the system screen recorder while the app shows an entry | Screenshot is blocked or blank; the recording shows black for the app |
| TC-024 | On the lock screen cancel the fingerprint or face prompt | The passcode field is offered and unlocks |
| TC-028 | In system settings add another fingerprint, return, unlock with the passcode | The app opens and all entries are intact |
| TC-026, TC-027 | Enter a wrong passcode six times | A wait appears and grows; nothing of the journal is visible |
| TC-029 | During the wait, force-stop and reopen | The wait is still running |
| TC-030 | During the wait, turn off automatic time and move the clock forward one day, then try the passcode | The wait is not shortened. Turn automatic time back on afterwards |
| TC-031 | Unlock by biometrics ten times | Time to the timeline feels under one second; record the slowest. A 95th-percentile figure over 30 tries needs a stopwatch and is optional |

## Block C: data (about 15 minutes)
| Case | Do | Expect |
|------|----|--------|
| TC-004 | Type text without saving, force-stop, reopen and unlock | The unsaved text is offered back |
| TC-012 | Save an entry with an emoji, a combining mark (for example "e" followed by U+0301), and Arabic or Hebrew text; find it by search | Shown and found unchanged |
| TC-013 | Save an entry, change the time zone in system settings, look at its date | The date is the one you chose. Restore the time zone afterwards |
| TC-011 | Paste a very long text (many pages) and save | Saved unchanged, or refused with a clear message; write down where it refused |
| TC-044 | Turn on airplane mode, search | Search works normally |

## Block D: export and import (about 20 minutes)
| Case | Do | Expect |
|------|----|--------|
| TC-054 | Export and close the system share sheet without choosing a target | The timeline still says "Not exported yet" |
| TC-058 | Export encrypted, save it somewhere you can reach, delete two entries, import the file, enter the export password | All entries are back with the same text and dates |
| TC-065 | Try to import a file that is not an export (for example a photo) | A clear refusal and the journal unchanged |
| FEAT-008 (TC-068 to TC-070) | After an export, move the clock forward 31 days, add an entry, open the timeline. Restore the clock | The export reminder card appears; it holds no entry text |

## Block E: settings and accessibility (about 25 minutes)
| Case | Do | Expect |
|------|----|--------|
| FEAT-009 | Switch language, theme, and the lock timeout; change the passcode; lock and unlock with the new one | Each change applies at once; entries still readable (TC-077) |
| TC-088 | Set the system font size and display size to the largest, open every screen in light and dark themes | Nothing is cut off or overlapping |
| TC-089 | Look at every screen in both themes | Text is readable; buttons are easy to hit |
| TC-087 | Turn on TalkBack and go through: unlock, write, save, search, export, settings | Every control has a label and the order is logical |

## Not in this checklist (needs the assistant, a tool, or a decision)
- TC-083, TC-086 (network and logs) and TC-085 (cloud backup): need a phone visible to `adb`; the phone used earlier was not.
- TC-019, TC-045 (speed at 20,000 entries): need a build seeded with test data.
- TC-015, TC-100, TC-061: need a second schema or format version, which does not exist yet.
- TC-091: needs the release signing key.
- TC-010, TC-082: need the process killed at exact steps.

## After the run
Send the assistant the list of Pass, Fail, and Partial results. It updates the logs, the counts in `PRR-001`, and `../../status.md`, and reports what is still open.
