# Privacy statement: what backs each claim

Status: draft, 2026-09-20. Related: FEAT-009 (S13, AC-7), TC-081, `product-design/docs/screen-specs.md` (S13). The statement in the app (screen S13) has four points. A claim with no control behind it is removed.

| # | Claim in the app | Requirement or decision | What makes it true in the build | Test | State |
|---|------------------|-------------------------|---------------------------------|------|-------|
| 1 | Nothing you write is uploaded or shared by the app. | ADR-005, THR-002, `project.md` principle 1 | The release build declares no network permission (checked on the merged manifest); no package that sends data is used (`dependency-review.md`); the only way content leaves is the share sheet after an export. | TC-084 (manifest), TC-083 (no request carries content) | Manifest checked by hand on 2026-09-20 (Android, release APK). TC-083 not run. Partial. |
| 2 | There is no account, no ads, and no tracking. | `decisions/free-private-positioning-policy.md` | The app has no sign-in screen, no ad or analytics package, and no network permission. | TC-084, dependency review | Same as above. Partial. |
| 3 | The only way your writing leaves this phone is an export you choose to make. | FEAT-006, ADR-003 | Export needs a choice and, for a readable file, a confirmed warning; the file goes to the phone's share sheet; cloud backup is off (`allowBackup=false`); exported files are removed from the cache. | TC-050, TC-085, FEAT-006 tests | Export tests pass on the emulator. TC-085 (restore test) not run; the iOS backup exclusion is not built. Partial. |
| 4 | If you forget your passcode, your journal cannot be recovered. | ADR-001, FEAT-004 | The data key is random and wrapped by the passcode only; there is no recovery path, and setup makes the user acknowledge it. | TC-035 (acknowledgement), key vault tests | Passes on host and emulator. |

## Not claimed, because nothing backs it yet
- "Your data is encrypted with strong encryption" is not stated in the app; the storage tests support it but the key-store side and the iOS build are not verified.
- Anything about iOS.

## Follow-ups
| Action | Owner |
|--------|-------|
| Run TC-083 and TC-086 on a release build | qa |
| Confirm the Indonesian wording of the four points | project owner |
| Re-check this table when the iOS build exists | qa, cyber-security |
