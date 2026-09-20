---
name: security-incident-response
description: Use when there is suspected or confirmed compromise, a leaked secret, unauthorised access, or exposure of personal or restricted data, to contain, preserve evidence, start notification clocks, and hand off to the devops incident process with an INC- record.
---
# Security Incident Response

## Purpose
Provide the security side of an incident: stop the damage, keep evidence usable, decide notifications in time, and hand a clean record to the devops process. The commander and lifecycle are defined in `severity-and-incident.md`; this skill adds security-specific actions.

## When to use
- Alert or report of unauthorised access, malware, data exposure, or abuse.
- A secret found in a repo, log, image, or public place.
- Vulnerability under active exploitation.
- Lost or stolen device with access to the system.

## Principles
- Contain first, investigate second; but do not destroy evidence while containing.
- Preserve before you change: snapshot, export logs, record hashes and times (UTC).
- Assume a leaked credential is compromised; rotate it.
- Notification clocks start at awareness, not at confirmation; involve legal and the data-protection contact early.
- Facts only in records: timeline, observed data, actions; no speculation, no real personal data in the write-up.
- Blameless review; actions tracked to closure.

## Steps / Checklist
1. Declare: page the security lead; devops opens the incident; classify severity (breach or data loss is P0/P1). Assign commander, scribe, comms.
2. Preserve: copy relevant logs, snapshot affected hosts or volumes, capture cloud audit trails, record who did what and when. Restrict access to evidence.
3. Contain (choose least disruptive effective step): revoke tokens and sessions, rotate credentials and keys, isolate host or network segment, disable account, block indicators at the edge.
4. Assess scope: which assets and data classes (`data-governance.md`), how many subjects, time window, attacker access path.
5. Start clocks: check `compliance-matrix.md` and list applicable duties with deadlines (see below); counsel confirms.
6. Eradicate and recover: remove access paths, patch, rebuild from known-good, restore, monitor for recurrence.
7. Hand off: register `INC-NNN`; devops runs the postmortem for P0/P1 (review within 5 business days). Security adds root cause, control gaps, and new or updated `THR-` and `RISK-` entries.
8. Verify: retest fix, confirm rotation complete, close actions with owners and dates.

Notification clocks (starting points from the matrix; confirm with counsel):
| Regime | Trigger | Target |
|--------|---------|--------|
| UU PDP | Personal data breach | 3x24 h |
| GDPR / UK GDPR | Personal data breach, EU/UK residents | 72 h to authority |
| PCI DSS, HIPAA, OJK/BI | Card data, health data, regulated financial service | Per framework and contract; check the matrix row |

Worked mini-example: an API key is found in a public repo. Preserve commit and access logs; revoke and rotate the key; review provider audit log for use since the commit time; no use seen, no data exposed, so no notification duty but `INC-NNN` P2 recorded; add secret scanning gate to CI (`THR-NNN`).

## Output format
Security section of the incident record:
| Time (UTC) | Event or action | Evidence ref | Actor |
|------------|-----------------|--------------|-------|
Plus: scope (assets, data classes, subject count), notification decisions with times and approver, root cause, follow-up `THR-` IDs.

## References
- `_shared/standards/severity-and-incident.md`
- `_shared/compliance/compliance-matrix.md`, `_shared/standards/data-governance.md`, `security-baseline.md`
- `_shared/index.md` (INC, THR, RISK, RB)
- Related skills: `vulnerability-triage`, `compliance-mapping`
