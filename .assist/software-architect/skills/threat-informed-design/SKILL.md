---
name: threat-informed-design
description: Use when designing or changing a system that adds a trust boundary, exposes an interface, handles sensitive data or money, integrates a third party, or uses LLM/agent features, so that threats shape the architecture before build.
---
# Threat-Informed Design

## Purpose
Bring security into architecture decisions early: identify assets, trust boundaries, and threats, then choose structural mitigations. This produces design input and a hand-off to the cyber-security role, which owns `THR-` entries.

## When to use
- New service, public API, or integration; new data classification handled.
- Change to authentication, tenancy, network topology, or secret handling.
- Adopting a third-party component (see `build-vs-buy`).
- Before `architecture-review` of anything internet-facing.

## Principles
- Threat model the design, not the code: cheap now, expensive later.
- Structure beats patching: prefer designs that remove a threat class (isolation, least privilege, no long-lived credentials) over controls that detect it.
- Every trust boundary crossing needs authentication, authorisation, validation, and logging.
- Fail closed, secure defaults, defence in depth (`security-baseline.md`).
- Rank by risk (likelihood x impact) and act on the top, not on everything.
- Residual risk is accepted explicitly by a named owner via `RISK-`.

## Steps / Checklist
1. Identify assets: data (classified per `data-governance.md`), credentials, money movement, availability, reputation.
2. Draw a data-flow view (use `c4-diagramming` container level) and mark trust boundaries: internet/internal, tenant/tenant, service/service, prod/non-prod, vendor.
3. Identify actors: anonymous, authenticated user, admin, service account, insider, compromised dependency.
4. For each boundary crossing and data store, apply STRIDE:
   - Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege.
5. Add domain checks: OWASP Top 10 and API Top 10; OWASP LLM Top 10 for LLM features (prompt injection, excessive agency, data leakage).
6. Score each threat: likelihood 1-3 x impact 1-3 = 1-9. Address >= 6 before build; 3-5 with owner and date; <= 2 accept.
7. Choose mitigations at design level: network segmentation, per-tenant keys, token scoping, idempotency and rate limits, signed artifacts, audit log, egress allow-lists.
8. Verify testability: each mitigation has a test or control evidence.
9. Log each threat as `THR-NNN` (hand off to cyber-security), decisions as `ADR-`, leftovers as `RISK-`.

Quality gate:
- [ ] Every boundary has authn, authz, validation, logging noted
- [ ] Top-scored threats have a mitigation or an accepted `RISK-`
- [ ] Secrets, supply chain, and audit trail covered

## Output format
| THR | Boundary / asset | STRIDE | Threat | L | I | Score | Design mitigation | Residual | Owner |
|-----|------------------|--------|--------|---|---|-------|-------------------|----------|-------|
| THR-021 | Public API / orders | E | Caller reads another tenant's order (BOLA) | 3 | 3 | 9 | Server-side per-object authz; tenant ID from token, never from request | Low | backend |
| THR-022 | Webhook receiver | S, T | Forged provider callback | 2 | 3 | 6 | Signature verification, replay window 5 min, idempotency key | Low | backend |

## References
- `_shared/standards/security-baseline.md`
- `_shared/standards/data-governance.md`
- `_shared/compliance/compliance-matrix.md`
- `_shared/index.md` (THR, RISK, ADR)
