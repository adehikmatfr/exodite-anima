# Design Review Record: UI version 0.2

Optional section dropped for T1 (`_shared/standards/project-tiers.md`): evidence attachments beyond the previews.

| Field | Value |
|-------|-------|
| Artifact | `design/features/*/*.pen` (light and dark), `design/library/components-*.pen`, `design/library/tokens.json` |
| Version | 0.2, 2026-09-20 |
| Related | FEAT-001 to FEAT-009, `report/design-brief-v1.md`, `../ux-design/report/design-review-ui-s1-s7.md` |
| Review type | pre-hand-off review |
| Date | 2026-09-20 |

## 1. Participants
| Name | Role in session | Perspective |
|------|-----------------|-------------|
| product-design (the assistant) | designer and reviewer | design and accessibility |

**Self-review of work the same assistant drew: not independent.** The owner should review the previews and the `.pen` files before hand-off.

## 2. Criteria checked
| Criterion | Source | Checked |
|-----------|--------|---------|
| Meets success criteria and scope of the brief | `design-brief-v1.md` | [x] |
| WCAG 2.2 AA at design time (contrast, target size, focus order) | `context.md` | [x] contrast computed for 17 pairs, all pass; target sizes 48 or more by construction; focus order written in `screen-specs.md` (not verified in a build) |
| Design system used; deviations justified | `context.md` | [x] semantic tokens only; no local overrides |
| All states designed (empty, loading, error, offline) | brief section 7 | [x] for all screens and components; system UI (biometric prompt, share dialog, file picker) is drawn by the OS |
| Content, localisation and RTL considered | brief section 6 | [ ] partly: 200 percent text drawn for five screens; +40 percent expansion by wrapping; RTL not checked |
| Privacy and abuse risks reviewed | THR-001, THR-004, THR-005 | [x] app-switcher state drawn; reminder has no entry text |
| Buildable within constraints | frontend | [ ] not reviewed with frontend-mobile |

## 3. Findings
Status of the twelve findings of the earlier review (`ux-design/report/design-review-ui-s1-s7.md`) and new findings.

| # | Finding (observation, evidence, criterion) | Severity | Owner | Due | Status |
|---|--------------------------------------------|----------|-------|-----|--------|
| 1 | Restore order unresolved (earlier finding 1) | major | project owner | before build | fixed 2026-09-20: the owner decided passcode first, then import (FEAT-007 AC-9) |
| 2 | Vocabulary mixed (earlier 2) | major | ux-design, product-design | after RS-001 | partly fixed: Export and Import used consistently; final words wait for RS-001 |
| 3 | Placeholder-only labels (earlier 3) | major | product-design | now | fixed: every field has a visible label; search keeps a persistent "Search" prefix |
| 4 | Secure fields had no Show or Hide (earlier 4) | major | product-design | now | fixed: Show and Hide toggle drawn; paste allowed noted |
| 5 | Checkbox target 24 px (earlier 5) | major | product-design | now | fixed: whole row is the control, 56 high |
| 6 | Reminder actions 32 px (earlier 6) | major | product-design | now | fixed: actions 48 high |
| 7 | "Draft saved" next to "Save" confusing (earlier 7) | major | ux-design | RS-001 | open: wording changed to "Draft kept safely on this phone"; still tested in RS-001 |
| 8 | Disabled buttons unexplained (earlier 8) | minor | product-design | now | fixed: a sentence states what is needed |
| 9 | Missing states (earlier 9) | major | product-design | now | fixed for all screens and components |
| 10 | 200 percent and long content (earlier 10) | minor | product-design | before hand-off | partly fixed: five screens at 200 percent, two problems fixed while drawing (links and pills now wrap); long words and +40 percent not drawn |
| 11 | No focus order or accessible names (earlier 11) | major | product-design | now | fixed in `screen-specs.md`; verified only when built (TC-087) |
| 12 | Logo is a placeholder (earlier 12) | suggestion | product-design | after name decision | closed 2026-09-20: logo A2 chosen and applied to the app icon, the in-app mark and the design files (`.pen` regenerated, previews exported) |
| N1 | The old border token measured about 1.4:1, so input boundaries failed 3:1 | major | product-design | now | fixed: `color.border.strong` (3.66 light, 3.75 dark) |
| N2 | No high-contrast theme | minor | product-design, owner | before release | closed 2026-09-20: not in version 1 (owner); light and dark are enough |
| N3 | No icon set; glyphs used for the back arrow and tick | minor | product-design, frontend-mobile | before build | closed 2026-09-20: Lucide chosen and built (`app/lib/theme/app_icons.dart`, licence ISC, in the asset register) |
| N4 | At 200 percent text the primary action of S1 falls below the fold | minor | product-design, frontend-mobile | before build | closed 2026-09-20: the action stays pinned at the bottom (owner); built and tested |
| N5 | S14 (journal cannot be opened) has no criterion in any spec | major | product-manager | before `ready` | fixed 2026-09-20: FEAT-001 AC-9 to AC-11 |
| N6 | Export password rules unspecified | major | product-manager, cyber-security | before `ready` | fixed 2026-09-20: at least 8 characters (FEAT-006 AC-9), shown in the S11 helper text |
| N7 | Previews cannot show Lora or Inter weights faithfully | suggestion | product-design | none | accepted: `design-tokens.md` is the reference (owner decision) |

Severity: blocker = cannot hand off or ship; major = fix before release; minor = fix in normal flow; suggestion = optional.

## 4. Decision
- Outcome: approved with follow-ups for a first hand-off to frontend-mobile of tokens, components, and the screens that do not depend on open decisions; changes required for S1 large-text handling and for anything blocked by N5 and N6.
- Rationale: all blockers from the first review are fixed; remaining items depend on owner decisions or on a built app.
- Decider: project owner (to confirm).

## 5. Follow-ups
| Action | Owner | Due | Linked ID |
|--------|-------|-----|-----------|
| Owner reviews previews and `.pen` files in OpenPencil | project owner | before hand-off | FEAT-001 to FEAT-009 |
| Choose the icon set (N3); review the Indonesian copy | owner | before build | N3 |
| Independent accessibility check on a built screen | qa | at build | TC-087, TC-088, TC-089 |
| Re-review after RS-001 | ux-design, product-design | after RS-001 | RS-001 |
