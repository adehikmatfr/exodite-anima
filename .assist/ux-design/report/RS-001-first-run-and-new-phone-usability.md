# Research Study Protocol: First run and changing phones

Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): materials and environment detail, deliverables detail.

This is a research plan, not a test plan. It defines what we want to learn and how; QA test plans (`TP-`) and test cases (`TC-`) verify built behaviour and are separate.

| Field | Value |
|-------|-------|
| Study ID | `RS-001` |
| Owner | ux-design |
| Status | draft (not approved, not fielded) |
| Linked | FEAT-004, FEAT-006, FEAT-007, FEAT-001, RISK-001 |

## 1. Research Question
Can a new user, without help, set up the app, understand that a forgotten passcode cannot be recovered, and later back up their journal and restore it on a new phone?

Secondary: which words do people use for backing up and restoring, and do the labels "Export" and "Import" make sense to them?

## 2. Decision It Informs
The project owner, with product-design, decides whether the onboarding wording, the order of passcode setup and restore, and the labels for export and import are final, or must change before the first store submission. If participants cannot complete the move-phone task unaided, the flow in `user-flows.md` (F6) changes. If they misunderstand the no-recovery rule, the warning wording and RISK-001 mitigation change. There is no calendar date: the deadline is "before the first store submission".

## 3. Existing Evidence
None. No study, analytics, or support data exists; the app has no users. The segment is a hypothesis (`context.md`).

## 4. Method and Why
| Chosen method | Why it fits the question | Methods rejected and why | Known limits |
|---------------|--------------------------|--------------------------|--------------|
| Moderated usability test on a prototype, with think-aloud | The question is whether people can complete tasks and where they misunderstand. A low-fidelity prototype is enough for flow and wording. | Survey: cannot show whether tasks succeed, and needs far more people. Interviews: attitudes, not behaviour. Tree test and card sort: the structure is only about 13 screens, so structure is not the doubt. | 5 participants find problems but give no percentages; a problem affecting about 1 in 3 users is likely to show up, rarer ones may not. SUS is not meaningful below about 12 responses, so it is not used. |

## 5. Participants and Recruitment
| Item | Value |
|------|-------|
| Segments and screening criteria | Must: adult, uses a smartphone, has kept or has tried to keep a journal or diary in any form. Exclude: people who work on the app, and anyone under 18. |
| Sample size and rationale | 5 for a first formative round (T1), including at least 1 assistive-technology user (screen reader or large text). Run a second small round after fixes if the first finds serious problems. Over-recruit by 1 for no-shows. |
| Recruitment channel | Decided 2026-09-20: friends and acquaintances of the owner, no payment. Known bias (they may be kinder and more alike than real users); the report must say so, and the owner should still try to include at least one person who does not know them. |
| Accessibility and inclusion needs | Include an assistive-technology user; offer sessions in the participant's stronger language once the language decision is made. |
| Incentive | Not decided. Must be fair for the time and never depend on answers. |

## 6. Consent and Data Handling
| Item | Value |
|------|-------|
| Consent form | To be written before recruiting. Covers purpose, what is recorded, who sees it, retention, withdrawal, and contact. A separate explicit yes for recording. |
| Data collected | Screen and audio recording of the prototype session, moderator notes, task outcomes. No real journal content. |
| Minimisation and pseudonyms | Participants are P01 to P05. Names are stored separately from notes. Participants type made-up entries and made-up passcodes only, never real ones. |
| Storage and access | Outside the repository, in a folder only the owner can open. |
| Retention and deletion | Recordings deleted 90 days after synthesis (default); notes pseudonymised; the deletion date is written into each participant's record. Deletion owner: ux-design. |
| Special groups or topics | Journaling can touch on emotional subjects. Do not ask about journal content. If a participant becomes distressed, pause, offer to stop, and do not press. No minors. |

## 7. Tasks or Questions
Neutral wording; no rescuing; log every assist.

| # | Task or question | Success criterion | Linked |
|---|------------------|-------------------|--------|
| T1 | "You have just installed this app. Set it up so you can start writing." | Reaches the empty timeline without an assist | FEAT-004 |
| Q1 | After T1: "In your own words, what happens if you forget your passcode?" | States that the journal cannot be recovered | FEAT-004, RISK-001 |
| T2 | "Write a short made-up entry and save it." | Entry appears in the timeline | FEAT-001 |
| T3 | "Lock the app and open it again." | Unlocks with the passcode | FEAT-003 |
| T4 | "Imagine you want to be sure you would not lose your journal if your phone broke. Do what you would do." | Completes an export | FEAT-006 |
| T5 | "You now have a new phone with the app freshly installed. Get your journal onto it." | All made-up entries restored, unaided | FEAT-007, FEAT-004 |
| Q2 | "What would you call what you just did in T4 and T5?" | Record the words used | vocabulary |

After each task: Single Ease Question (1 to 7). Prototype: the screens in `../product-design/design/features/` (version 0.2, all states drawn), extended when needed.

## 9. Analysis Approach
Outcome codes per task: success, success with assist, partial, fail, abandoned, timed out. Record time, errors, and assists. Severity per the usability scale: 0 not a problem, 1 cosmetic, 2 minor, 3 major, 4 blocker. Weigh by how many of the participants were affected. There is one analyst (the owner or the assistant), so the limit is one rater; findings are labelled accordingly. Disconfirming evidence: if 4 or more of 5 complete T5 unaided and state the no-recovery rule correctly, the current wording and flow are supported for this small sample; it does not prove it for all users.

## 10. Timeline and Roles
| Step | Date | Owner |
|------|------|-------|
| Protocol approved | not scheduled | ux-design and project owner |
| Prototype ready | depends on product-design | product-design |
| Pilot with one person | not scheduled | ux-design |
| Fieldwork | not scheduled | ux-design |
| Synthesis and readout | within 3 working days of the last session | ux-design |

## 11. Risks and Mitigations
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Prototype does not behave like the real app, so results do not carry over | M | Say so to participants; retest on the built app before release |
| Biased sample (friends only) | H | Mix in people outside the owner's circle |
| Participant distress about personal topics | L | Made-up content only; pause and stop on request |
| Recording or notes leak | L | Store outside the repository; pseudonyms; deletion date |
| Only iOS or only Android participants | M | Balance where possible; note the platform in each record |

## 12. Open Questions
| # | Question | Owner | Due |
|---|----------|-------|-----|
| 1 | Recruitment channel | Project owner | Before protocol approval |
| 2 | Incentive | Project owner | Before protocol approval |
| 3 | Consent form wording and where the signed forms are kept | ux-design | Before recruiting |
