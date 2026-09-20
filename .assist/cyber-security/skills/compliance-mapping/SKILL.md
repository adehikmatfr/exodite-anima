---
name: compliance-mapping
description: Use when an audit, customer security questionnaire, certification effort, or regulatory question requires mapping the project's security controls to the compliance matrix and keeping an evidence log. Engineering guidance, not legal advice.
---
# Compliance Mapping

## Purpose
Show which framework obligations apply, which implemented controls satisfy them, and where the evidence lives, so audits are answered from a maintained log instead of scrambles. Implement each control once and map it to many frameworks.

## When to use
- Project setup or tier change: confirming applicable frameworks.
- Preparing for SOC 2, ISO 27001, PCI DSS, or customer due diligence.
- A regulator or contract names a control (`project-tiers.md` escalation).
- Quarterly evidence review.

## Principles
- This is not legal advice: counsel or compliance confirms applicability and current requirements. State this in every output.
- Map from the project's actual controls to obligations, not the reverse; never claim a control that lacks evidence.
- Evidence is a link or ID (ticket, `THR-` verified entry, `RB-`, log query, scan report), never pasted secrets or personal data.
- A gap is recorded as a gap with owner and date; do not hide it.
- Personal data, money, and regulated data escalate rows regardless of tier.

## Steps / Checklist
1. Read `_shared/compliance/compliance-matrix.md`; confirm each framework marked Applicable with a reason, and remove non-applicable rows.
2. List the controls actually in place: access control and MFA, encryption, audit logging, change management, incident response, backup and DR, retention and deletion, vendor risk.
3. For each applicable framework, map obligation to control (use the cross-framework table) and to the standard that defines it.
4. Attach evidence and record owner and last-reviewed date in the evidence log.
5. Flag gaps: control missing, evidence stale (older than review cycle), or ownership unclear; create `THR-` or `RISK-` entries.
6. Confirm notification duties and clocks with counsel; record them in `context.md` for incident use.
7. Review on schedule (`<quarterly>`) and on scope change.

Mapping example:
| Control | Frameworks | Evidence | Owner | Last reviewed | Gap |
|---------|-----------|----------|-------|---------------|-----|
| MFA for admins | ISO 27001, SOC 2, PCI DSS, UU PDP | IdP policy export ref `<link>` | security | `<date>` | none |
| Restore test | ISO 27001, SOC 2, OJK | `RB-NNN` drill record | devops | `<date>` | drill overdue |
| Breach notification process | UU PDP (target 3x24 h), GDPR (72 h) | `INC-NNN` tabletop | security | `<date>` | contacts unverified |

## Output format
Update the matrix Applicable column and the Evidence log table in `compliance-matrix.md`:
| Control | Evidence (link/ID) | Owner | Last reviewed |
|---------|--------------------|-------|---------------|
Plus a short gap list: `<control> | framework | THR-/RISK- ID | owner | due`.

## References
- `_shared/compliance/compliance-matrix.md` (matrix, cross-framework controls, evidence log)
- `_shared/standards/security-baseline.md`, `data-governance.md`, `severity-and-incident.md`, `project-tiers.md`
- `_shared/index.md` (THR, RISK, INC, RB)
- Related skills: `security-incident-response`, `security-requirements-review`
