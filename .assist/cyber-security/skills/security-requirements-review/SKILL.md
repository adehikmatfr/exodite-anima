---
name: security-requirements-review
description: Use when a FEAT- or design needs its security requirements checked before build, covering authentication, authorisation, session, cryptography, secrets, input validation, and logging, with an OWASP ASVS level chosen by project tier.
---
# Security Requirements Review

## Purpose
Ensure a feature states a testable security bar before code is written, so review and testing have something to verify. Output is a checklist result plus gaps raised to the requirement owner.

## When to use
- New or changed `FEAT-` that handles identity, data, money, or external input.
- Before `threat-modeling` on a new feature, and before test planning.
- Preparing for an ASVS-based customer or audit request.

## Principles
- Requirements must be testable: "sessions expire after 15 minutes idle", not "sessions are secure".
- ASVS level follows tier and escalations (`project-tiers.md`): T1 L1; T2 L2; T3 L2, with L3 for high-value functions (money movement, key management, admin plane). Personal or payment data at T1 raises to L2.
- Do not invent requirements; raise gaps to the `FEAT-` owner with a proposed wording.
- Reference the baseline instead of restating it (`security-baseline.md`).

## Steps / Checklist
1. Read the `FEAT-`, its data classes, and the tier; pick the ASVS level and record why.
2. Walk the checklist; mark each item met, gap, or not applicable (with reason).
   - Authentication: [ ] MFA for humans and privileged access [ ] credential storage with a modern adaptive hash [ ] rate limiting and lockout [ ] safe recovery flow, no user enumeration
     - Machine clients (tools holding an API key, no human typing a password): MFA does not apply, so state that and require custody rules instead (one key per client, expiry, rotation, never shared or committed). A high-entropy random key (256-bit) may be stored as a fast hash such as SHA-256; a slow adaptive hash is for human-chosen secrets. Throttle failed attempts, but do not lock out a valid key (lockout would become a denial-of-service lever).
   - Authorisation: [ ] server-side, deny by default [ ] per-object checks (BOLA) [ ] admin functions separated [ ] tenant isolation
   - Session and tokens: [ ] short-lived, rotated, revocable [ ] secure cookie attributes [ ] logout invalidates server-side [ ] CSRF protection where cookies are used
   - Cryptography: [ ] TLS 1.2+ [ ] encryption at rest with managed keys [ ] rotation plan [ ] no custom algorithms
   - Secrets: [ ] secret manager only [ ] none in repo, image, CI logs [ ] rotation on exposure
   - Input and output: [ ] validation at every boundary [ ] parameterised queries [ ] output encoding [ ] upload and size limits [ ] SSRF controls on outbound calls
   - Logging and audit: [ ] auth and privilege events logged [ ] immutable audit log for security-relevant and financial actions [ ] no secrets or unnecessary PII in logs [ ] alerts on anomalies
   - Privacy: [ ] data minimised, retention defined (`data-governance.md`)
3. For each gap, propose a requirement sentence and severity if left unmet (Blocker, Should, Could).
4. Feed gaps into `threat-modeling` and test conditions (`TC-`).
5. Record the result on the `FEAT-` review; unresolved Blockers stop the `Security` row of the PRR.

Worked mini-example: FEAT-NNN adds password reset by email. Gap: token lifetime and single use unspecified. Proposed: "Reset token expires in 15 minutes, single use, invalidated on password change; response identical for unknown emails." Severity Blocker.

## Output format
| Area | Requirement | ASVS level | Result | Gap and proposed wording | Severity |
|------|-------------|-----------|--------|--------------------------|----------|
| Session | Idle timeout defined | L2 | gap | "Idle timeout 15 min" | Should |
Header states FEAT ID, tier, ASVS level, reviewer, date.

## References
- `_shared/standards/security-baseline.md`, `project-tiers.md`, `data-governance.md`
- `_shared/index.md` (FEAT, THR, TC)
- Related skills: `threat-modeling`, `secure-code-review`
