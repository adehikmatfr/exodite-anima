# Security Requirements Review: version 1

Method: skill `security-requirements-review`.

| Field | Value |
|-------|-------|
| Scope | FEAT-001 to FEAT-009 (all version 1 features share one security bar) |
| Tier | T1, escalated for sensitive personal data |
| ASVS level | L2. The skill says T1 uses L1, but personal data raises it to L2 (`project-tiers.md` escalation). |
| Reviewer | cyber-security role (**self-review, not independent**) |
| Date | 2026-09-20 |

Limits of the checklist: the OWASP ASVS is written for web applications. Items about servers, sessions, cookies, CSRF, tenants, and outbound server calls are marked N/A because the app has no server. The OWASP Mobile Application Security Verification Standard (MASVS) is the mobile counterpart; it is not part of the project's standards and is only mentioned here as an option for the owner to adopt.

## Review
| Area | Requirement | ASVS level | Result | Gap and proposed wording | Severity |
|------|-------------|-----------|--------|--------------------------|----------|
| Authentication | Credential storage uses a modern adaptive hash | L2 | partly met | The passcode is never stored; it derives a wrapping key with a memory-hard function (ADR-001). **Gap G1:** the function's parameters are not set. Proposed: "The key derivation parameters are chosen from vetted guidance and checked on the lowest-tier device, and are stored with the wrapped key so they can be raised." | Blocker |
| Authentication | Rate limiting and lockout | L2 | partly met | FEAT-003 says waits grow after wrong tries, but the numbers are open. **Gap G2:** proposed: "After a fixed number of wrong passcodes the wait doubles on each further attempt, and no content is visible during the wait; the numbers are set by the owner." | Blocker |
| Authentication | MFA | L2 | not applicable | There is no account or remote access. Biometrics plus passcode is the local factor pair. | n/a |
| Authentication | Safe recovery flow, no user enumeration | L2 | not applicable by design | No recovery exists (ADR-001); no accounts to enumerate. | n/a |
| Authentication | Passcode strength | L2 | gap | **Gap G3:** rules are an open question on FEAT-004. Proposed: "A minimum length and a check against very common passcodes; the owner sets the length." | Blocker |
| Authorisation | Server-side checks, per-object checks, tenants | L2 | not applicable | No server or tenants. Access is limited by the OS sandbox and the lock. | n/a |
| Session | Idle timeout and logout | L2 | partly met | Auto-lock is the session analogue (FEAT-003). **Gap G4:** timeout choices are open. Proposed: "The data key is cleared from memory whenever the app locks." | Should |
| Session | CSRF, cookie attributes | L2 | not applicable | No web session. | n/a |
| Cryptography | TLS 1.2 or later | L2 | not applicable | No network use (ADR-005). | n/a |
| Cryptography | Encryption at rest with managed keys | L2 | met by design, unverified | ADR-001 and ADR-002. Verification waits for the spike. | n/a |
| Cryptography | No custom algorithms | L2 | met by rule | `project.md` rule; verify at code review. | n/a |
| Cryptography | Rotation plan | L2 | gap | Changing the passcode re-wraps the key. **Gap G5:** there is no way to replace the data key itself. Proposed: "A future version may re-encrypt the journal under a new data key; not required for version 1." | Could |
| Secrets | Secrets never in the repository | L2 | partly met | `.gitignore` blocks secret file names and preflight scans for keys. **Gap G6:** custody of release signing keys and store accounts is undefined. Proposed: "Signing keys stay outside the repository, store accounts use strong authentication, and any key that cannot be recreated has an offline copy." | Should |
| Secrets | No secrets in logs | L2 | met by rule | Verify with the log test. | n/a |
| Input and output | Validation at every boundary, size limits | L2 | partly met | Import is designed to validate (ADR-003). **Gap G7:** numeric limits (file count, unpacked size, entry size) are not set. Proposed: "The importer refuses archives above limits set by the software-architect before implementation." | Should |
| Input and output | Passcode and export-password fields | L2 | gap | **Gap G8:** proposed: "Passcode and password fields are marked secure: no suggestions, no keyboard learning, no copy out of the field; pasting in is allowed so password managers work." | Should |
| Input and output | SSRF and outbound calls | L2 | not applicable | No outbound calls. | n/a |
| Logging and audit | No secrets or personal data in logs | L2 | met by rule | Verify: release builds emit no content in logs. | n/a |
| Logging and audit | Audit and anomaly alerting | L2 | not applicable | No server or central log. | n/a |
| Privacy | Data minimised, retention defined | L2 | met | Journal text stays on the device, deleted only by the user (`data-governance.md`). | n/a |
| Privacy | Screens and previews | L2 | gap | **Gap G9:** Android screenshot blocking is an open question (FEAT-003). Proposed: "The app hides content in the app switcher on both platforms; blocking screenshots on Android is decided by the owner." | Should |
| Build and release | Release build hygiene | L2 | gap | **Gap G10 (update 2026-09-20: CI check written, not yet run):** proposed: "A release build has no network permission, no debug logging, and is signed with the release key; a checklist and a CI check confirm this before each submission" (THR-015, ADR-005). | Blocker |
| Backup | Cloud backup exclusion | L2 | gap | **Gap G11:** ADR-001 requires it and the project does not configure it yet (architecture finding F2). Proposed: "App data is excluded from cloud backup on both platforms and this is tested." **Update 2026-09-20: Android configured** (`android:allowBackup="false"`, seen in the release APK); iOS not built; restore test not run. | Blocker (Android part done) |

## Result
Update 2026-09-20: G2 and G3 are decided (wait rule, passcode rules) and built; G1 has a provisional setting (32 MiB, 3 passes, 1 lane). Measured on a physical phone 2026-09-20: median 2.95 s to open with the passcode (worst 3.34 s), and 5.8 s for the 64 MiB export setting; two lanes at 64 MiB took 1.28 s. The owner chose 64 MiB, 3 passes, 2 lanes (`product-manager/decisions/key-derivation-settings.md`) and it is built; G1 stays open until a second phone is measured and the design is independently reviewed. Blockers open: G1, G10, G11 (iOS part). Under the rule "unresolved Blockers stop the Security row of the readiness review", version 1 cannot pass that row yet. G1 to G3 map to open questions already on FEAT-003 and FEAT-004; G10 and G11 are build work for frontend-mobile.

## Hand-offs
| To | What | By ID |
|----|------|-------|
| product-manager | Proposed wording for G2, G3, G8, G9 into the specs, keeping the numbers as owner questions | FEAT-003, FEAT-004, FEAT-009 |
| software-architect | Numeric import limits (G7), key derivation parameters (G1), and the device-bound wrapping recommendation | ADR-001, ADR-003 |
| frontend-mobile | Backup exclusion (G11), release build checks (G10), secure fields (G8) | THR-003, THR-015 |
| qa | Each gap becomes a test condition when the test plan is written | `TC-`: QA will assign |
