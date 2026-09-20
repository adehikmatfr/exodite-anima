---
name: threat-modeling
description: Use when a component, trust boundary, data class, integration, or LLM feature is added or changed, or when refreshing the threat register, to produce scored, owned THR- entries that go deeper than the architect's design-level pass.
---
# Threat Modeling

## Purpose
Turn the architect's design-level hand-off (`threat-informed-design`) into a verified, owned threat register: enumerate threats systematically, score them, assign mitigations with evidence, and keep the model current. The architect shapes the design; security owns `THR-` and verifies.

## When to use
- Architect hands off a new design or boundary change.
- New personal, payment, or health data class; new third party; new tenant model.
- Incident or pentest reveals a threat class not in the register.
- Scheduled review (T2: per major feature; T3: per trust-boundary change).

## Principles
- Model what you will build or have built, using the real data-flow, not a wish diagram.
- Start from the architect's `THR-` rows; do not redo, extend: attacker paths, abuse cases, chained threats.
- One threat per row, phrased as attacker action and outcome; no vague "security issues".
- Mitigation must name a control and where it lives; unverifiable mitigation is status `open`.
- Depth scales by tier (`project-tiers.md`): T1 short STRIDE table, T2 per feature, T3 reviewed per boundary change.

## Steps / Checklist
1. Collect inputs: `FEAT-`, `ADR-`, architect's `THR-` rows, data classes (`data-governance.md`), `context.md` boundaries.
2. Confirm the data-flow and mark boundaries: internet, tenant, service, environment, vendor, admin plane.
3. For each crossing and datastore apply STRIDE; add OWASP Top 10, API Top 10, and LLM Top 10 items where relevant.
4. Add attacker paths: entry, pivot, objective; note chained low-score threats that combine to high.
5. Score with the matrix below; record reasoning for any adjustment.
6. Decide per threat: mitigate, transfer, avoid, or accept (accept needs `RISK-` and named owner).
7. Attach a verification method per mitigation: test, review, scan, or pentest item.
8. Register `THR-` entries in `_shared/index.md`; link `RISK-` and `ADR-`.

Scoring (Likelihood x Impact):
| | Impact 1 (minor) | Impact 2 (significant) | Impact 3 (severe: Restricted data, money, outage) |
|--|------|------|------|
| Likelihood 3 (easy, exposed) | 3 | 6 | 9 |
| Likelihood 2 (needs skill or access) | 2 | 4 | 6 |
| Likelihood 1 (unlikely) | 1 | 2 | 3 |
Score 6-9 mitigate before release; 3-5 owner and date; 1-2 accept.

Worked mini-example: webhook receiver, threat "forged callback marks an unpaid order as paid" (S, T). L2 x I3 = 6. Mitigation: signature check plus 5 min replay window plus idempotency key. Verification: negative test with bad signature (`TC-NNN`). Status moves to `verified` after the test passes in CI.

Quality gate:
- [ ] Every boundary crossing has at least one row
- [ ] All scores of 6+ have mitigation or `RISK-NNN`
- [ ] Every mitigation has a verification method

## Output format
Fill `templates/threat-model.md`. Summary table:
| THR | Boundary | STRIDE | Threat | L | I | Score | Mitigation | Verification | Status |
|-----|----------|--------|--------|---|---|-------|-----------|--------------|--------|
| THR-NNN | Webhook | S,T | Forged callback | 2 | 3 | 6 | Signature, replay window | TC-NNN | open |

## References
- `_shared/standards/security-baseline.md`, `project-tiers.md`, `data-governance.md`
- `_shared/index.md` (THR, RISK, ADR, TC)
- Architect counterpart: `threat-informed-design` skill
- Related skills: `security-requirements-review`, `pentest-scoping`

## Language notes
Optional: for LLM features add prompt injection, excessive agent permissions, and data leakage through tool output as explicit rows.
