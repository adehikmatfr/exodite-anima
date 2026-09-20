---
name: compliance-and-legal-check
description: Use when a FEAT- collects, uses, shares, retains, or deletes personal data, moves money, targets a regulated sector, or changes consent or terms. Identifies triggered compliance-matrix rows from the product side. Not legal advice.
---
# Compliance and Legal Check (product side)

## Purpose
Find early which compliance obligations a feature triggers and turn them into spec requirements, so counsel, security, and engineering are engaged before build rather than at release. This is engineering guidance, not legal advice; counsel or compliance confirms applicability.

## When to use
- A spec adds or changes personal data, tracking, profiling, messaging, or third-party sharing.
- A feature moves or records money, or targets a regulated user group or sector.
- Terms, consent wording, retention, or data location changes.

## Principles
- Ask before build: obligations found at release cost weeks.
- Only rows marked applicable in `_shared/compliance/compliance-matrix.md` are binding; if none are marked, flag it to the owner rather than assuming none apply.
- Collect the minimum: each data field needs a stated purpose.
- Personal data, money, and public authenticated exposure escalate regardless of tier (`project-tiers.md`).
- Product decides what is collected and why; security decides how it is protected; counsel decides what the law requires.

## Checklist
1. Data inventory for the feature: fields, data class, source, purpose, recipients, storage location.
2. Lawful basis and consent: is consent needed, where and how captured, wording owner, how withdrawn, proof kept.
3. Retention and deletion: retention period per field and its reason; deletion or anonymisation trigger; backup handling (`data-governance.md`). If deletion is automated: dry run as the default, a batch limit, evidence of every run (counts and ids only), the external erasure record, and a runbook (`RB-`); the first cycle is a dry run reviewed by the data owner.
4. Data-subject rights: how a person can access, correct, export, and delete their data; response time; who handles requests. Each right needs a named role that may perform it (export of a person's data is privileged) and an audit trail.
5. Sharing and transfer: vendors, cross-border transfer, contract or safeguard needed.
6. Children, health, financial, or other sensitive data: escalate the tier; get counsel review.
7. Breach impact: what would be exposed, who must be notified, and the notification window in the matrix.
8. Sector rules: money movement, lending, payments, cards, public-facing accessibility (matrix rows for financial regulators, PCI DSS, WCAG).
9. Audit evidence: what proof is needed, where stored, owner (evidence log in the matrix).
10. Third-party and licence risk for any new dependency (`production-readiness-review.md` row 14).

## Mapping example
| Feature element | Trigger | Matrix row | Spec requirement |
|-----------------|---------|-----------|------------------|
| Email address collected for notifications | Personal data | Personal-data protection law of the user's country | Consent captured with timestamp; unsubscribe in every message; deletion within the stated window |
| Card payment entry | Card data | PCI DSS | Use a tokenising provider; no card data stored; PM confirms scope with security |
| Export of user history | Data-subject access | Personal-data law, GDPR if EU users | Self-service export within the statutory period |

## Output format
"NFR and compliance impact" section in `FEAT-NNN` listing triggered rows, the requirement added, the evidence owner, and open questions for counsel. Raise `RISK-NNN` for anything unresolved; request `THR-` from cyber-security when personal data or money is involved.

## References
- `_shared/compliance/compliance-matrix.md`, `_shared/standards/data-governance.md`, `security-baseline.md`, `project-tiers.md`, `production-readiness-review.md` (rows 6, 7, 12)
- IDs: `FEAT-`, `RISK-`, `THR-`, `ADR-`; skills: `write-feature-spec`, `risk-register`
