# Security Finding: THR-NNN <short title>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

ID scheme: threats and findings share the `THR-` prefix (`_shared/index.md`). A finding from testing or review is a `THR-` entry with `source` set to how it was found. IDs are never reused.

| Field | Value |
|-------|-------|
| ID | THR-NNN |
| Source | design review / code review / SAST / DAST / SCA / pentest / bug report / incident `INC-NNN` |
| Reported by / date | `cyber-security` / `<date>` |
| Severity | Critical / High / Medium / Low / Informational |
| CVSS-like vector and score | `<e.g. network, low complexity, no privileges, no user interaction, high confidentiality impact>` = `<0.0-10.0>` |
| Affected component and version | `<service, endpoint, file, commit or build>` |
| Category | `<OWASP Top 10 / API Top 10 / CWE id>` |
| Status | new / triaged / in-fix / fixed-unverified / verified-closed / accepted / false-positive |
| Owner | `<role or team>` |
| Due date | `<report date + fix target>` |

## Rating guide
| Severity | Typical characteristics | Fix target (`security-baseline.md`) |
|----------|------------------------|-------------------------------------|
| Critical | Exploited in the wild or remote code execution, mass data exposure | 24-72 h |
| High | Authz bypass, injection, credential exposure, no special access needed | 7 days |
| Medium | Needs user interaction or special conditions, limited data | 30 days |
| Low | Hardening gap, minimal impact | 90 days |
Adjust the base score for exposure (internet-facing raises), data class (Restricted raises), and compensating controls (record them). State the reason for any adjustment.

## Description
`<what is wrong, in defensive terms>`

## Evidence
Redacted output, log excerpts, scanner ID, screenshots. No real secrets or personal data.
```
<redacted evidence>
```

## Reproduction
1. `<environment, account role, build>`
2. `<step>`
3. `<observed result vs expected>`

## Impact
`<what an attacker gains, which data class, which users, which THR-/FEAT- affected>`

## Remediation
- Fix: `<specific change>`
- Interim mitigation (optional): `<WAF rule, feature flag, access restriction>`
- Regression test or control to add: `<TC-NNN or check>`

## Business context (optional)
`<exposure, exploitability evidence, affected customers, contractual or regulatory trigger>`

## Timeline
| Date | Event |
|------|-------|
| `<date>` | reported, triaged, fix merged, retested, closed |

## Closure evidence
Retest result, build or commit, verifier. Required before `verified-closed`. If accepted instead: `RISK-NNN`, approver, expiry.
