# Design Review Record: UI screens S1 to S7

Optional section dropped for T1 (`_shared/standards/project-tiers.md`): re-review.

| Field | Value |
|-------|-------|
| Artifact | the version 0.1 drafts of S1 to S7, now archived in `../../product-design/design/archive/2026-09-20-v0.1-superseded/`; superseded by version 0.2 (see `../../product-design/report/design-review-ui-v0.2.md`, which records the status of each finding below) |
| Version | files as of 2026-09-20 |
| Related | FEAT-001 to FEAT-005, FEAT-008 |
| Review type | critique (retroactive: the screens were drawn before flows and research) |
| Date | 2026-09-20 |

## 1. Participants
| Name | Role in session | Perspective |
|------|-----------------|-------------|
| The assistant, acting as ux-design | reviewer | design and accessibility |

**This is a self-review of work the same assistant drew, so it is not independent.** It should be repeated by the owner or in RS-001.

## 2. Criteria Checked
| Criterion | Source | Checked |
|-----------|--------|---------|
| Meets success criteria and scope of the brief | no brief exists yet (`product-design` writes it) | [ ] not possible |
| WCAG 2.2 AA at design time (contrast, target size, focus order) | `context.md` | [x] contrast checked in `tokens.md`; target size and focus order below |
| Design system used; deviations justified | `context.md` | [x] tokens used; no system governance yet |
| All states designed (empty, loading, error, offline) | design-brief rule | [ ] **fails**: only default states, plus timeline empty and delete confirmation |
| Content, localisation and RTL considered | design-brief rule | [ ] not done: English only, no RTL check, no +40% text check |
| Privacy and abuse risks reviewed | THR-001 to THR-013 | [x] partial: app-switcher state not drawn |
| Buildable within constraints | frontend | [ ] not reviewed with frontend-mobile |

## 3. Findings
| # | Finding (observation, evidence, criterion) | Severity | Owner | Due | Status |
|---|--------------------------------------------|----------|-------|-----|--------|
| 1 | S1 "Restore from a backup" leads nowhere defined: the order of passcode setup and import is unresolved (F6). Flow criterion: every path ends in a defined state. | major | product-design with product-manager | before implementation | open |
| 2 | Vocabulary mixes "backup" and "export/import" across screens. Labels must use one vocabulary consistent with the glossary. | major | product-design with ux-design | after RS-001 | open |
| 3 | S2 "Repeat the passcode" and S6 "Search your entries" rely on placeholder text as the only label; the visible label disappears once typing starts. Criterion: visible labels, not placeholder-only. | major | product-design | before hand-off | open |
| 4 | Passcode fields (S2, S5) show dots with no show/hide control and no note that pasting is allowed. Criterion: accessible authentication (WCAG 2.2 SC 3.3.8). | major | product-design | before hand-off | open |
| 5 | S4 checkbox is drawn 24 px and the row target is not defined. Touch targets should be at least 44 pt (iOS) and 48 dp (Android). | major | product-design | before hand-off | open |
| 6 | S6 reminder actions "Export now" and "Later" are text only, about 32 px tall. Same target-size criterion. | major | product-design | before hand-off | open |
| 7 | S7 shows "Draft saved" and a "Save" link together; it is unclear whether Save is still needed. Risk of user confusion about whether text is safe (RISK-001). | major | ux-design and product-design | test in RS-001 | open |
| 8 | S4 and S2 disabled buttons are shown with reduced contrast and no stated reason next to the button. Criterion: say what is needed to continue. | minor | product-design | before hand-off | open |
| 9 | No screen is drawn for the app-switcher state, error states (mismatched passcode, wrong passcode, wait after failures), long entries, or a large text size. Criterion: every state designed. | major | product-design | before hand-off | open |
| 10 | Text sizes not checked at 200% system font size; long words and 40% longer translations not tested. | minor | product-design | before hand-off | open |
| 11 | No focus order or screen-reader labels documented for any screen. | major | product-design | before hand-off | open |
| 12 | The logo is a placeholder. | suggestion | product-design | after the name decision | open |

Severity: blocker = cannot hand off or ship; major = fix before release; minor = fix in normal flow; suggestion = optional.

## 4. Decision
- Outcome: changes required before hand-off to frontend-mobile.
- Rationale: the screens are useful hypotheses for RS-001, but findings 1, 3 to 7, 9 and 11 must be fixed first.
- Decider: project owner (to confirm).

## 5. Follow-ups
| Action | Owner | Due | Linked ID |
|--------|-------|-----|-----------|
| Decide the restore and passcode order | project owner | before implementation | FEAT-004, FEAT-007 |
| Choose the vocabulary after RS-001 | ux-design, product-design | after RS-001 | RS-001 |
| Add missing states, labels, targets, and accessibility notes to every screen | product-design | before hand-off | FEAT-001 to FEAT-009 |
| Repeat this review with the owner as second reviewer | ux-design | after fixes | RS-001 |
