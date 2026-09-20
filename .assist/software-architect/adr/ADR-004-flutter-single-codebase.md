# ADR-004: Build the app with Flutter, one codebase for iOS and Android

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-09-20 |
| Deciders | Project owner |
| Consulted | none (solo project); software-architect role recorded the analysis |
| Reversibility | one-way door in effort (rewrite of UI and platform integration); user data survives a change because the export format is portable (ADR-003) |
| Related | FEAT-001 to FEAT-009, RISK-004, ADR-001, ADR-002 |
| Review date | After the technical spike (ADR-001 and ADR-002 validation), and if a needed platform capability turns out to be unavailable in Flutter |

## Context
The app targets iOS and Android, is built and maintained by one person, and has no backend. It needs secure key storage (Keychain and Keystore), biometrics, an encrypted local database with text search, file export and import through the system share and file dialogs, screen-reader accessibility, and full offline operation.

The owner chose Flutter on 2026-09-20. **No reason was recorded at the time.** The reasons below are the software-architect role's analysis, added when recording the decision, and are marked as such.

### Quantified requirements (drivers)
| NFR | Target | Measured by | Source |
|-----|--------|-------------|--------|
| Codebases the owner must maintain | 1 for two platforms | Repository layout | Solo developer |
| Required capabilities present with maintained packages | 100% of the list in Context, on both platforms | Technical spike | ADR-001, ADR-002, ADR-003 |
| Accessibility | WCAG 2.2 AA behaviours reachable (labels, font scaling, focus order) | Accessibility audit of the built app | Compliance matrix |
| Local iOS build possible | Not possible on the current Windows machine (no Mac) | `flutter doctor` result | `_shared/project.md` |

## Options considered

### Option A: Flutter (chosen)
- Summary: one Dart codebase drawing its own UI on both platforms.
- Pros: one codebase; the same rendering on both platforms, so the design tokens map directly to the theme; hot reload speeds a solo developer up; the toolchain already runs on the owner's machine (Android emulator verified).
- Cons: platform capabilities such as secure key storage, biometrics, and the encrypted database depend on packages that must be checked for maintenance and platform support (spike); the Flutter engine is included in the app, so size is larger (not measured); iOS builds still need a Mac or cloud CI.
- Cost / effort: lowest for two platforms.
- Risks: a required capability is missing or unmaintained (RISK-004).

### Option B: React Native
- Summary: one JavaScript or TypeScript codebase using native UI components.
- Pros: one codebase; native look on each platform.
- Cons: more dependence on third-party native modules for the same capabilities; different toolchain the owner has not set up.
- Cost / effort: similar to A, plus toolchain setup.
- Risks: the same capability-availability risk.

### Option C: Native apps (Swift for iOS, Kotlin for Android)
- Summary: two separate codebases.
- Pros: direct access to the platform's security and accessibility APIs; no framework risk.
- Cons: two codebases and two skill sets for one person; roughly double the work.
- Cost / effort: highest.
- Risks: delivery risk for a solo developer (RISK-006).

### Option D: Kotlin Multiplatform with native UI
- Summary: shared logic in Kotlin, native UI per platform.
- Pros: shared logic, native UI.
- Cons: still two UIs; more setup.
- Cost / effort: high.
- Risks: as C, less so.

### Option E: do nothing (baseline)
- Consequence of not deciding: no codebase, no build.

## Decision
We will use **Flutter** with a single Dart codebase, as decided by the owner, because one codebase is the only way a single person can realistically ship and maintain two platforms, and the toolchain is already verified on the owner's machine.

## Consequences
- Positive: one codebase; direct mapping from design tokens to the theme.
- Negative / trade-offs accepted: security and storage capabilities come through packages, not directly from the platform; the app is larger; iOS cannot be built or verified on the current machine.
- Follow-up work: technical spike proving the required capabilities on Android and, when possible, iOS; choose and pin packages after checking their maintenance and licences; decide how iOS will be built (Mac, cloud CI) before the first iOS release.
- New risks: RISK-004 covers capability failure and iOS verification.
- Assumptions to validate: every capability in Context is available in maintained Flutter packages on both platforms (ASSUMPTION; owner: software-architect; validate in the spike).
- Exit strategy: the export archive (ADR-003) is an open, versioned format, so users' data can be carried into a rewrite. The rewrite itself would cost the whole UI and platform layer.

## Validation
The spike shows every required capability working on Android with maintained packages, and the iOS status is recorded. Revisit if any capability is missing or a needed package becomes unmaintained.
