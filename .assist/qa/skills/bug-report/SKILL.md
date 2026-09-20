---
name: bug-report
description: Use when a defect is found, a failure needs triage, or an existing bug report is vague, duplicated, or missing severity and reproduction steps; also to classify severity and priority consistently.
---
# Bug Report

## Purpose
Produce a defect report that lets someone reproduce, prioritize, fix, and verify the issue without asking follow-up questions.

## When to use
- A test fails or unexpected behavior is observed.
- Triage: classifying, deduplicating, or reviewing reports.
- Verifying a fix or closing a defect.

## Principles
- One defect per report; symptom, not suspected cause, in the title.
- Reproducible or clearly flagged as intermittent with frequency and conditions.
- Severity (impact) and priority (urgency) are separate decisions; QA proposes severity, product/engineering decides priority.
- Evidence over prose: logs, correlation IDs, screenshots, request/response with secrets and PII redacted.
- Report facts; avoid blame and speculation. Label hypotheses as such.
- Security-sensitive defects go through the security channel, not the open tracker (`security-baseline.md`).

## Steps / Checklist
1. Reproduce at least twice; find the minimal reproduction.
2. Search for duplicates; link instead of re-filing.
3. Record environment: build/version, environment, config/flags, browser/OS/device, data set, time (UTC).
4. Write numbered steps, expected result, actual result.
5. Attach redacted evidence and correlation/trace ID.
6. Link `TC-`, `FEAT-`, and affected `API-`/`SLO-`.
7. Assign severity from the matrix; propose priority.
8. On fix: verify on the fix build, run related regression, add or update the `TC-` that would have caught it, then close.
9. For escapes to production: note the detection gap and feed into `risk-based-testing`.

### Severity (aligned with `severity-and-incident.md`)
| Sev | Definition | Example |
|-----|-----------|---------|
| S1 (P0) | Data loss/corruption, security breach, outage, no workaround | Payment charged twice |
| S2 (P1) | Core function broken or severe degradation, hard workaround | Login fails for a user segment |
| S3 (P2) | Partial loss, workaround exists | Filter ignores one field |
| S4 (P3) | Cosmetic, minor | Typo, misalignment |

### Priority
| Priority | Meaning |
|----------|---------|
| Urgent | Fix now; may trigger incident process |
| High | This release; blocks sign-off if S1/S2 |
| Medium | Scheduled next cycle |
| Low | Backlog |

### Default resolution targets (tune per project)
S1 mitigation within 4 h; S2 within 2 business days; S3 within the next release; S4 backlog.

## Output format
```
Title: <component>: <symptom>
ID / links: BUG-<n> | TC-<n> | FEAT-<n>
Severity / Priority:
Environment: <build, env, flags, client, data>
Steps to reproduce: 1... 2...
Expected:
Actual:
Frequency: always / n of m / intermittent
Evidence: <redacted logs, trace ID, screenshot>
Workaround:
Suspected area (optional, labelled hypothesis):
```

## References
- `_shared/standards/severity-and-incident.md`, `security-baseline.md`, `data-governance.md`
- `_shared/index.md`

## Language notes
Tracker field names and workflow states live in `.assist/qa/context.md`.
