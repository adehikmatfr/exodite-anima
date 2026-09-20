# UX process in exodite-anima

As-built description of how UX work runs in this project. Written after the process was set up on 2026-09-20; update it when the process changes.

## 1. Overview
The project is T1 and solo, with no users yet and no analytics by design. UX work is therefore lightweight: evidence is gathered through small usability rounds, and everything without evidence is labelled a hypothesis. UX owns research, flows, information architecture, and usability evaluation. Visual and interface design belongs to product-design.

## 2. Trigger / entry points
- A new or changed FEAT- with more than one screen or a new key journey.
- A finding from a test, review, or store feedback about confusion or task failure.
- A design change proposed by product-design that alters a flow or a label.

## 3. Step-by-step flow
1. Read `../../_shared/project.md`, `prompts/role.md`, `context.md`, the FEAT-, and `../../_shared/index.md`.
2. Write the research question and the decision it informs before any design (`user-research-planning`). Stop if existing evidence already answers it.
3. Draw the flow with error paths and record edge cases (`report/user-flows.md`); note effort per flow.
4. Update the information architecture and label list (`report/information-architecture.md`), using words from the glossary.
5. Hand validated flows and IA to product-design by ID; the brief and screen specs are product-design's.
6. Review designs (`design-critique`, `inclusive-and-accessible-design`) and record findings in a design review record.
7. Plan and run usability rounds (`usability-testing`), starting with RS-001; hand findings to product-manager (scope, criteria) and qa (regression tests).
8. Turn edge paths into acceptance criteria on the FEAT- (through product-manager); hazards become RISK-.

## 4. Statuses and data model
Study status: draft, approved, fielding, synthesis, closed (`report/RS-NNN-*.md`). Findings: open, fixed, wont-fix. Journey maps carry `JRN-NNN` and are local to this role (not registered).

## 5. External calls and events
None. Participant data (recordings, consent forms) is stored outside the repository (`context.md`).

## 6. Decisions and gotchas
- Research before solution: screens S1 to S7 were drawn before this process existed; they are hypotheses and have a review record (`report/design-review-ui-s1-s7.md`).
- No invented personas or numbers: every journey cell without data says "assumed".
- With five participants no percentages are reported, and SUS is not used (needs about 12 responses).
- Participants use made-up content and made-up passcodes only.
- Open, unresolved design questions: restore versus passcode order, and the backup/export vocabulary.
