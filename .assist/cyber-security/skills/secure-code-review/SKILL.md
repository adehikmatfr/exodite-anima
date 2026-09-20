---
name: secure-code-review
description: Use when a pull request or module touches authentication, authorisation, cryptography, input handling, file or network access, money, or personal data, or when a security review of existing code is requested.
---
# Secure Code Review

## Purpose
Find and verify security defects in code and configuration by reading it against the threat model, with findings that carry evidence and a fix. Complements automated SAST; it targets logic flaws scanners miss.

## When to use
- Change to login, session, token, permission, or tenant logic.
- New endpoint, parser, file upload, deserialisation, outbound request, or query builder.
- Crypto, key handling, or secret loading changes.
- T2: risky change review; T3: mandatory on auth, crypto, and money paths.

## Principles
- Review by data flow: trace untrusted input from source to sink, and privilege from identity to resource.
- Review against `THR-` rows first, then the OWASP Top 10 list.
- Prove it: no finding without a code location and a plausible path; mark unverified items as questions.
- Fix at the root (central validator, authz middleware), not per call site.
- Read configuration and infrastructure-as-code too; misconfiguration is a top-ten category.

## Steps / Checklist
1. Read the linked `FEAT-`, `ADR-`, and relevant `THR-`; list entry points changed.
2. Run tooling (SAST, secret scan, dependency scan) and read results as leads, not verdicts.
3. Walk each area:
   - [ ] Authz enforced server-side, per object, on every path (guard IDOR/BOLA); tenant ID from token, not request
   - [ ] Authentication: no bypass on error paths; rate limiting; token expiry and revocation
   - [ ] Input: validated at the boundary; parameterised queries only; output encoding; safe file paths and upload types
   - [ ] Outbound requests: allow-listed hosts (SSRF), timeouts, no credential forwarding
   - [ ] Crypto: vetted libraries, no custom schemes, modern algorithms, random from a secure source, keys from the secret manager
   - [ ] Secrets and PII: not in code, config, logs, error messages, or URLs
   - [ ] Errors: fail closed, no stack traces to clients
   - [ ] Concurrency and money: race conditions, double spend, idempotency keys, audit log written
   - [ ] Deserialisation and templating on untrusted data avoided or constrained
   - [ ] Error messages, especially from configuration parsing and startup, never echo the offending value (a secret pasted in the wrong place must not reach the logs)
   - [ ] Lockout and throttling cannot be turned into a denial of service against legitimate users (shared addresses behind a proxy, attacker-chosen identifiers); a valid credential of sufficient entropy is not locked out
   - [ ] In-memory state keyed by attacker-controlled values (addresses, ids, tokens) is bounded
   - [ ] Responses carrying personal data are not cacheable (`Cache-Control: no-store`) and cannot be content-sniffed (`X-Content-Type-Options: nosniff`)
   - [ ] Servers set explicit header and request timeouts and body size limits
   - [ ] Files that hold identifiers or secrets (logs, exports, key files) are created owner-only
   - [ ] Anything placed into SQL as an identifier (schema, table, column) is validated against a strict pattern; values are parameterised
4. Record findings per `templates/security-finding.md` with severity from `vulnerability-triage`.
5. Re-review the fix; confirm a regression test exists **and that it fails when the control is removed** (a mutation check: disable the fix, run the test, expect red). A security test that stays green without its control proves nothing.

Worked mini-example: handler loads `orders/{id}` by ID and checks only "is logged in". Finding: missing object-level authz (BOLA), High. Fix: query scoped by tenant and owner from the token; test that user B receives 404 for user A's order.

## Output format
| Finding | Location (file:line) | Category | Severity | Evidence | Fix | Owner | Due |
|---------|----------------------|----------|----------|----------|-----|-------|-----|
| THR-NNN | `<path>:<line>` | Broken access control | High | Query lacks owner filter | Scope by owner | backend | +7 d |
End with a verdict: approve, approve with conditions, or block, with the reason and residual risk.

## References
- `_shared/standards/security-baseline.md` (fix-target table, OWASP checklist)
- `_shared/standards/project-tiers.md`
- `_shared/index.md` (THR, ADR, TC)
- Related skills: `vulnerability-triage`, `security-requirements-review`

## Language notes
Optional: memory-unsafe languages add bounds and lifetime review; dynamic languages add unsafe eval, dynamic imports, and prototype or mass-assignment issues; typed ORMs still need review of raw query escape hatches.
