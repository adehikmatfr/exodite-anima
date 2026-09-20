# Design Review Record: <artifact>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Artifact | <name, link> |
| Version | <file version / tag / date> |
| Related | `FEAT-NNN`, brief link |
| Review type | <critique / pre-hand-off review / design QA of built result> |
| Date | <YYYY-MM-DD> |

## 1. Participants

| Name | Role in session | Perspective |
|------|-----------------|-------------|
| <name> | <presenter / facilitator / scribe / reviewer / decider> | <design / product / engineering / qa / accessibility> |

## 2. Criteria Checked

| Criterion | Source | Checked |
|-----------|--------|---------|
| Meets success criteria and scope of the brief | brief section 4-5 | [ ] |
| WCAG 2.2 AA at design time (contrast, target size, focus order) | `context.md` | [ ] |
| Design system used; deviations justified | `context.md` | [ ] |
| All states designed (empty, loading, error, offline) | brief section 7 | [ ] |
| Content, localisation and RTL considered | brief section 6 | [ ] |
| Privacy and abuse risks reviewed | `THR-NNN` | [ ] |
| Buildable within constraints | frontend | [ ] |

## 3. Findings

| # | Finding (observation, evidence, criterion) | Severity | Owner | Due | Status |
|---|--------------------------------------------|----------|-------|-----|--------|
| 1 | <what was seen, where, which criterion it fails> | <blocker / major / minor / suggestion> | <name> | <date> | <open / fixed / wont-fix> |

Severity: blocker = cannot hand off or ship; major = fix before release; minor = fix in normal flow; suggestion = optional.

## 4. Decision

- Outcome: <approved / approved with follow-ups / changes required / rejected>.
- Rationale: <short>. Dissent recorded: <none / summary>.
- Decider: <name, role>.

## 5. Follow-ups

| Action | Owner | Due | Linked ID |
|--------|-------|-----|-----------|
| <action> | <name> | <date> | `FEAT-NNN` / `RISK-NNN` / `TC-NNN` |

## 6. Evidence (optional)

<Links to annotated screenshots (synthetic data only), test recordings, contrast reports.>

## 7. Re-review (optional)

<Version re-reviewed, date, outcome per finding.>
