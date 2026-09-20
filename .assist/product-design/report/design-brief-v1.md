# Design Brief: Version 1 interface

Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): options and decisions beyond those listed. Written after the first drafts, which is out of order; the ux-design flows and review came first, and this brief now frames the second draft.

| Field | Value |
|-------|-------|
| Feature | FEAT-001 to FEAT-009 |
| Designer | product-design |
| Status | draft |
| Design link | `design/features/` (three areas) and `design/library/` |
| Last updated | 2026-09-20 |

## 1. Problem
People who want a private journal need to write, find, back up, and restore entries on their phone with confidence that nobody else can read them and that nothing is lost. Nothing exists yet, and no user evidence exists (`ux-design/context.md`): the audience is a hypothesis. The cost of getting the interface wrong is misunderstanding the no-recovery rule, losing data, or abandoning setup.

## 2. Users
| User / segment | Context of use | Key needs | Accessibility or inclusion needs |
|----------------|----------------|-----------|----------------------------------|
| Journal writer (hypothesis) | Phone, often private moments, sometimes one-handed, sometimes at night | Calm, quick capture; reassurance of privacy; a backup they trust | Screen reader, large text, low vision, motor limits; unknown until RS-001 |

## 3. Constraints
- Technical: Flutter on iOS and Android (ADR-004); compact phone layouts only; no network features (ADR-005); no analytics; fonts must be free to bundle.
- Business and legal: WCAG 2.2 AA target (`_shared/compliance/compliance-matrix.md`); accurate privacy statements only.
- Design system: none existed; tokens and components are created here (`design-tokens.md`, `component-specs.md`).
- Timeline and team: one person, no deadline.

## 4. Success criteria
| Criterion | Metric | Baseline | Target | How measured | Owner |
|-----------|--------|----------|--------|--------------|-------|
| Users finish setup and understand the no-recovery rule | Unaided completion and correct explanation | none | to be set from RS-001 | RS-001 tasks T1 and Q1 | ux-design |
| Users can restore on a new phone unaided | Unaided completion of the restore task | none | to be set from RS-001 | RS-001 task T5 | ux-design |
| Every screen meets the accessibility bar | Contrast, target size, labels, 200 percent text | not measured | all pass | TC-087, TC-088, TC-089 | qa |

## 5. Scope and non-goals
- In scope: the screens and states in `screen-specs.md` (S1 to S14) for phones, light and dark themes, the token set, and the component set.
- Non-goals: tablets and landscape, RTL layouts (not needed for English and Indonesian), high-contrast theme (open question), a real logo and app icon (waits for the app name), animation design beyond fades and slides, marketing and store artwork.

## 6. Accessibility and privacy considerations
- Accessibility: WCAG 2.2 AA (`inclusive-and-accessible-design` checklist run on all screens; see the review record). Passcode entry is the hardest point: secure fields with a Show toggle, paste allowed, no cognitive test.
- Privacy: no entry text appears outside the unlocked screens (previews, reminder, notifications). The app-switcher state is drawn. No participant data is used in designs; all content is made up. Threats: THR-001, THR-004, THR-005.
- Content and localisation: English and Indonesian, switchable in Settings (decided 2026-09-20); all strings externalised; +40 percent expansion tolerated by wrapping; no RTL needed.

## 7. States to cover
| Screen / component | Default | Loading | Empty | Error | Offline | Permission denied | Long / extreme content |
|--------------------|---------|---------|-------|-------|---------|-------------------|------------------------|
| S1 to S5 (setup and lock) | [x] | n/a | n/a | [x] | n/a (offline by design) | n/a | [x] 200% text |
| S6 Timeline | [x] | [x] | [x] | see S14 | n/a | n/a | [x] 200% text |
| S7 Editor | [x] | n/a | [x] new | [x] save error | n/a | n/a | [x] long entry, 200% |
| S8 Search | [x] | n/a | [x] | [x] no results | n/a | n/a | not drawn |
| S9 to S13 (settings, export, import) | [x] | [x] progress | n/a | [x] | n/a | n/a | not drawn |
| S14 Journal cannot be opened | [x] | n/a | n/a | [x] | n/a | n/a | n/a |
| Components | [x] | [x] | [x] | [x] | n/a | n/a | not drawn |

Offline is the normal condition, so no offline state exists. Permission denied applies to biometrics only, which is covered by "Not available" (S3).

## 8. Deliverables
| Deliverable | Format | Due | Consumer |
|-------------|--------|-----|----------|
| Tokens | `design/library/tokens.json` and `docs/design-tokens.md` | done (draft) | frontend-mobile |
| Component sheet and specs | `.pen` and `docs/component-specs.md` | done (draft) | frontend-mobile |
| Screens with all states | `.pen` files and previews | done (draft) | frontend-mobile, qa |
| Screen specs | `docs/screen-specs.md` | done (draft) | frontend-mobile, qa |
| Hand-off note | this brief and the review record | after owner review | frontend-mobile |

## 9. Options and decisions
| Option | Pros | Cons | Chosen |
|--------|------|------|--------|
| Separate light and dark `.pen` files | Both themes render and check with the CLI | Two files to keep in step (generated from one token file) | yes |
| One file with theme variables | One file | The CLI ignores per-frame themes, so dark cannot be checked here | no |
| Vocabulary Export and Import (glossary) | Matches specs | May not read as "backup" to users | yes for now; decided after RS-001 |
| Restore after passcode setup | Fits the key model | More steps on a new phone | yes: the owner decided on 2026-09-20 |

## 10. Review and approval
| Reviewer | Role | Scope | Date | Decision |
|----------|------|-------|------|----------|
| product-design | designer | self-review | 2026-09-20 | changes required (see the review record) |
| project owner | owner | whole brief | pending | pending |

Review record: `report/design-review-ui-v0.2.md`. Not independent: the same assistant drew the designs.

## 11. Risks
| ID | Risk | Likelihood | Impact | Mitigation | Owner |
|----|------|-----------|--------|------------|-------|
| RISK-001 | Users misunderstand the no-recovery rule and lose their journal | M | H | Warning screen with acknowledgment (S4), export reminder, RS-001 wording test | product-design |
| RISK-007 | Store review finds statements on About and privacy inaccurate | L | M | Every claim traced to a control and a test (TC-081) | product-design |

## 12. Open questions
- High-contrast theme in version 1? (owner)
- Icon set: none chosen; screens use text glyphs for the back arrow and tick. Flutter ships Material Icons; its licence must be confirmed before use (owner and frontend-mobile).
- 200 percent text pushes the primary action of S1 below the fold: keep scrolling, or pin the primary action? (product-design and frontend-mobile, before build)
- Indonesian and English copy deck: the assistant drafts, the owner reviews the Indonesian.
- Real logo and app icon: after the app name is decided.
