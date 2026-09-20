# Severity and Incident Management

## Severity levels
| Level | Definition | Response | Update cadence |
|-------|-----------|----------|----------------|
| P0 / SEV1 | Full outage, data loss or breach, safety or legal exposure | Page immediately, all hands, incident commander | 15 min |
| P1 / SEV2 | Major feature down or severe degradation for many users | Page on-call | 30 min |
| P2 / SEV3 | Partial degradation, workaround exists | Business hours | daily |
| P3 / SEV4 | Minor defect, cosmetic | Backlog | n/a |

## Roles
- **Incident Commander**: coordinates, decides, owns the timeline.
- **Ops lead**: hands-on mitigation.
- **Comms lead**: status page and stakeholder updates.
- **Scribe**: records timeline.

## Lifecycle
Detect, Triage (assign severity), Mitigate (stop the bleeding first), Resolve, Postmortem.

## Postmortem (blameless), required for P0/P1
Registered as `INC-<n>`. Sections: summary, impact (users, duration, money), timeline, root cause(s), what went well or badly, where we got lucky, action items (owner + due date + `FEAT-` or ticket), detection and prevention gaps. Review within 5 business days; track actions to closure.

## Security incidents
Preserve evidence, isolate, notify the security lead immediately; legal and regulatory notification clocks apply (see `compliance-matrix.md`).
