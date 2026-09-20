# ADR-005: Enforce "no network" through the build, not by convention

| Field | Value |
|-------|-------|
| Status | accepted |
| Date | 2026-09-20 |
| Deciders | Project owner (accepted 2026-09-20); proposed by the software-architect role |
| Consulted | cyber-security perspective applied (THR-005, THR-012, THR-013) |
| Reversibility | Technically two-way (a permission can be added); in trust terms one-way, because it reverses a public promise |
| Related | THR-005, THR-012, THR-013, RISK-003, RISK-007, FEAT-001 to FEAT-009, product decision `free-private-positioning-policy` |
| Review date | Before the first store release, and whenever a dependency is added |

## Context
The product promise is that journal content never leaves the device (`_shared/project.md`, principle 1). A promise kept only by developer discipline is weak: any dependency could open a connection. The stronger form is a property the platform enforces and a test can check.

Facts verified on 2026-09-20 in the Flutter project:
- The **Android main manifest declares no INTERNET permission**. The debug and profile manifests add it, for development tooling only. An Android app without the INTERNET permission cannot open network connections.
- **iOS has no equivalent permission**, so network access cannot be removed at the OS level. No App Transport Security exception is set in `Info.plist`.

### Quantified requirements (drivers)
| NFR | Target | Measured by | Source |
|-----|--------|-------------|--------|
| Network requests that carry user content | 0 | Traffic inspection during the full test run, and code review | `project.md` principle 1 |
| Network permissions in the merged Android release manifest | 0 | Automated check of the merged manifest in CI | THR-005 |
| Dependencies that add a network permission or capability | 0 without an ADR | Dependency review at each addition | THR-012 |

## Options considered

### Option A: Convention and code review only
- Summary: developers promise not to add network code.
- Pros: no extra work.
- Cons: nothing stops a dependency, or a mistake, from opening a connection; the claim is unverifiable.
- Cost / effort: lowest.
- Risks: silent violation of the core promise.

### Option B: Build-enforced (chosen)
- Summary: keep the Android release manifest free of network permissions and fail CI if the merged manifest gains one; review every dependency for network capability; on iOS, rely on dependency review and a traffic-inspection test; state the property in the store privacy declarations.
- Pros: on Android the OS itself blocks the network; the check is automatic; the claim can be shown to anyone who reads the repository.
- Cons: no online feature can exist (crash reporters, analytics, remote configuration, cloud sync) without a new ADR; iOS relies on review and testing, not on the OS.
- Cost / effort: low (one CI check and a review rule).
- Risks: a package that quietly needs the permission fails the check and must be rejected or replaced.

### Option C: Allow network with an allow-list
- Summary: permit connections to named hosts only.
- Pros: room for future online features.
- Cons: breaks the "nothing leaves the device" promise as stated; adds a large trust surface.
- Cost / effort: medium.
- Risks: the promise becomes conditional.

### Option D: do nothing (baseline)
- Consequence of not deciding: Option A by default.

## Decision
We will use **Option B**, because the privacy promise is the product, and a promise the platform enforces and a build check verifies is worth far more than one that depends on discipline.

## Consequences
- Positive: strong, checkable privacy claim; simple store data-safety answers ("no data collected or shared"), which must still be verified before each submission.
- Negative / trade-offs accepted: no crash reporting or analytics inside the app (store consoles only); no cloud features; debug builds legitimately carry the permission, so the claim applies to release builds only.
- Follow-up work: add the CI check for the merged Android release manifest; add a traffic-inspection test for both platforms; add the dependency-review rule to `definition-of-done` use; record the property in the store listings.
- New risks: none new. Residual: iOS is enforced by review and test, not by the OS (THR-005, THR-013).
- Assumptions to validate: the merged-manifest check works with the plugins' own manifests (ASSUMPTION; owner: frontend-mobile; validate when CI is set up).
- Exit strategy: to add any network capability, write a superseding ADR that states what leaves the device, update the threat model, the compliance matrix (the Confirm rows become binding), the store declarations, and the onboarding wording.

## Validation
CI fails on a network permission in the merged release manifest; a full test run produces no outbound requests. Revisit if a feature genuinely needs a connection.

## Review record (2026-09-20)
Accepted by the project owner on 2026-09-20, after the release APK check: the release build of the template app declares no network permission (the debug build adds one for tooling), and the merged manifest check is now a required CI check (TC-084) once CI exists.
