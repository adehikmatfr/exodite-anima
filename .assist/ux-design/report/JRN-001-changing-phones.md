# Journey Map: Changing phones without losing the journal

Optional section dropped for T1 (`_shared/standards/project-tiers.md`): backstage and service blueprint (the app has no staff or backend).

| Field | Value |
|-------|-------|
| Journey ID | `JRN-001` |
| Owner | ux-design |
| Scope | The user decides to get a new phone, until every entry is readable on it |
| Linked | FEAT-006, FEAT-007, FEAT-004, RISK-001, RISK-002 |
| Last updated | 2026-09-20 |

## 1. Persona or Segment and Evidence
| Item | Value |
|------|-------|
| Segment | Journal writer (hypothesis, `context.md`) |
| Goal | Keep the whole journal when changing phones |
| Context | Two phones during the move; may be different platforms; the file travels through something the user chooses (cable, messaging, cloud folder) |
| Evidence base | none |
| Evidence strength | hypothesis |

## 2. Journey Stages
Every cell is **assumed**: no research exists yet (RS-001 planned).

| | Stage 1: Prepare on the old phone | Stage 2: Move the file | Stage 3: Set up the new phone | Stage 4: Restore and check |
|---|---|---|---|---|
| Actions | Opens Settings, starts Export, chooses a password, saves the file | Sends the file to the new phone by a method they choose | Installs the app, sets a passcode, acknowledges the warning | Picks the file, enters the password, reads the result, opens the timeline |
| Touchpoints | Export screens (F5) | Outside the app: files, messaging, cloud folder | Onboarding (F1) | Import screens (F6), timeline |
| Thoughts | "Did it save? Where is the file?" (assumed) | "Is it safe to send this?" (assumed) | "Why a new passcode?" (assumed) | "Is everything there?" (assumed) |
| Emotions | 0 (assumed, unsure) | -1 (assumed, worry about privacy) | -1 (assumed, extra steps) | +2 if all entries appear, -2 if any is missing (assumed) |
| Pain points | Remembering the export password; finding the saved file | The file is readable if plaintext was chosen | Setup feels repeated | Entry count does not match what they remember |
| Opportunities | Show where the file was saved; tell them to keep the password | Warn that a plaintext file is readable by anyone | Explain that the passcode is new and can differ | Show counts and a way to spot-check |
| Evidence source per cell | assumed | assumed | assumed | assumed |

## 3. Moments of Truth
| Moment | Stage | Why it decides the outcome | Current performance | Target |
|--------|-------|----------------------------|---------------------|--------|
| Sees all entries on the new phone | 4 | Trust in the backup promise; failure means lost memories (RISK-001) | not measured | to be set from RS-001 |
| Remembers the export password | 1 to 4 | Without it the backup cannot be opened | not measured | to be set from RS-001 |

## 4. Metrics per Stage
| Stage | Metric | Current | Target | Source | Owner |
|-------|--------|---------|--------|--------|-------|
| 4 | Unaided completion of the restore task | not measured | to be set from RS-001 | RS-001 | ux-design |

## 6. Opportunities and Actions
| # | Opportunity | Stage | Expected impact | Evidence | Owner | Linked ID |
|---|-------------|-------|-----------------|----------|-------|-----------|
| 1 | Confirm where the exported file was saved | 1 | Fewer lost files | assumed | product-design | FEAT-006 |
| 2 | Remind users to keep the export password | 1 | Fewer unopenable backups | assumed | product-design | FEAT-006 |
| 3 | Explain why a new passcode is set on the new phone | 3 | Less confusion | assumed | product-design | FEAT-004 |
| 4 | Show added and skipped counts after import | 4 | Confidence in the result | assumed | product-design | FEAT-007 |

## 7. Open Questions and Validation Plan
Validate all assumed cells with RS-001 (task T5), including how people actually move the file between phones.
