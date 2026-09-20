# Cyber Security Context: exodite-anima

Project identity, tier, and shared rules live in `../_shared/project.md`. This file holds only security-specific facts. Never record real secrets, keys, or personal data here.

## Assets and data classes
| Asset | Data class (`data-governance.md`) | Owner | Location | Related ID |
|-------|-----------------------------------|-------|----------|-----------|
| Journal entries and drafts | Restricted | The user (the developer never holds them) | Encrypted database on the user's phone | THR-001, THR-002 |
| Data key | Restricted | The user | OS key store, plus a passcode-wrapped copy in the app | THR-002, THR-007 |
| Passcode and export password | Restricted | The user | Never stored | THR-007 |
| Export archives | Restricted when plaintext | The user | Where the user saves them | THR-006 |
| Release signing keys and store accounts | Restricted | Project owner | Outside the repository | THR-014 |

## Trust boundaries
| Boundary | Between | Crossing controls | Threat model |
|----------|---------|-------------------|--------------|
| B1 | Device owner and app | Lock, biometrics, passcode | THR-001, THR-007, THR-011 |
| B2 | App and local storage | Encrypted database and files | THR-002, THR-010 |
| B3 | App and OS services | Key store, backup exclusion, hidden previews | THR-003, THR-004, THR-005 |
| B4 | App and export destination | Encrypted default, plaintext warning | THR-006 |
| B5 | Untrusted file and importer | Authentication, limits, atomic apply | THR-008, THR-009 |
| B6 | App and network | No network permission on Android release (proposed) | THR-005, THR-015 |
| B7 | Build, store, and user devices | Signing key custody, release checklist | THR-014, THR-015 |
| B8 | Dependencies and app | Dependency review | THR-012 |

Full model: `report/threat-model-v1.md`.

## Identity and access model
| Actor | Identity provider | Authentication | Authorisation model | Privileged access |
|-------|-------------------|----------------|---------------------|-------------------|
| End user (device owner) | none; no accounts | Passcode, optionally biometrics | Whoever unlocks the app sees everything; the OS sandbox isolates it from other apps | n/a |
| Developer / release owner | Store account provider | Strong authentication on store accounts (owner to confirm) | Publishes releases | Signing keys (`THR-014`) |
| Service account | none | none | none | none; no server |

## Security tooling
| Need | Tool | Where it runs | Owner |
|------|------|---------------|-------|
| Static analysis | `flutter analyze` with `flutter_lints` (in the Flutter toolchain) | Local, and CI (written, never run) | frontend-mobile |
| Dependency scanning | not chosen; the CI workflow has no vulnerability scan yet | not set up | cyber-security |
| Secret scanning | `tools/preflight.js` pattern scan, and a file-name and pattern scan in CI | Local, before a push; CI (written, never run) | cyber-security |
| Merged-manifest and release-build checks | `app/tool/check_release_manifest.sh` (allow-list of permissions, backup off, not debuggable), run by `.github/workflows/ci.yml` | Local (passes on the release APK); CI written, never run | frontend-mobile |
| SBOM generation | not chosen | Release process | cyber-security |
| Logging, SIEM, alerting | none by design | none | none |
| Finding tracker | `THR-` entries in the register | `report/threat-model-v1.md` | cyber-security |
| DAST | not applicable (no server) | none | none |

## Scan schedule
| Activity | Frequency | Trigger | Output location |
|----------|-----------|---------|-----------------|
| Static analysis | Each build | Local run | terminal |
| Publish-safety scan | Before each push | `tools/preflight.js` | terminal |
| Dependency review | Per dependency added | A change to `pubspec.yaml` | `report/dependency-review.md` |
| Threat register review | Each release and each boundary change | Change | `report/threat-model-v1.md` |
| Penetration test | Optional at T1; not planned; owner decides before the first release | Owner | `templates/pentest-scope.md` if planned |
| Access review | not applicable (no accounts) | none | none |

## Exception and waiver process
1. Requester names the control, the affected `THR-`, the compensating control, and an expiry date.
2. Security rates the residual risk; High or Critical needs the owner's written acceptance and a `RISK-` entry.
3. Waivers are reviewed at expiry, never renewed silently. The maximum waiver length is not set (open question for the owner).

| Waiver | Control waived | THR / RISK | Approver | Expiry |
|--------|----------------|------------|----------|--------|
| none | | | | |

Residual risks: the owner accepted the data-loss part of THR-011 (RISK-001) in ADR-001. The owner accepted THR-009 (RISK-009) and THR-013 (RISK-010) on 2026-09-20.

## Known gaps
- Open blockers in the security requirements review: G1 (key-derivation settings need a physical phone), G10 (the CI manifest check is written, never run), G11 (iOS backup, out of scope for the first release). G2, G3 and G9 are decided and built (`report/security-requirements-review-v1.md`).
- CI is written (`.github/workflows/ci.yml`, `app/tool/check_release_manifest.sh`) but has never run; dependency vulnerability scanning is not automated (D1).
- No release signing key and no key custody plan (THR-014).
- No independent review: every security artifact so far was written by the same assistant.
- Private vulnerability reporting must be switched on in the repository settings after the remote exists (`SECURITY.md` points to it).
- No security incident plan yet (a defect that exposes on-device content would be handled under `severity-and-incident.md`).

