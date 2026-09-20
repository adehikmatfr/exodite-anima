# Orchestration

How the roles, skills, hand-offs, and gates of this project fit together. One person owns the project and every role is a "hat" the assistant wears in turn, so the point of this document is to make each hat's work predictable and auditable, not to imply a team.

## 1. Principles

1. **Preflight before any work**, especially before touching anything outside `.assist/` (section 4).
2. **One role at a time.** Say which role is acting at the start of a piece of work, follow that role's `prompts/role.md`, and use only its own folders for its artifacts.
3. **Skills define the method.** Each role has a typical skill order; follow it and use the role's templates.
4. **Hand off by ID.** Cross-role references are IDs from `_shared/index.md`; never paths.
5. **The owner decides.** The assistant proposes and records; decisions listed as pending are asked, not guessed. Confirm before anything hard to reverse or outward-facing (publishing, installing software, deleting, changing global configuration).
6. **Evidence over opinion, and no invented numbers.** Unknowns become open questions with an owner and a due point.
7. **Record after every decision.** Update the role's `workflow/` docs, `_shared/index.md`, and run the registry check.

## 2. Phases, roles, and outputs

Work runs per feature, not as a strict waterfall, but each phase has an owner and a gate. Status as of 2026-09-20 is in the last column.

| Phase | Lead role | Supporting roles | Main skills (in order) | Outputs | State |
|-------|-----------|------------------|------------------------|---------|-------|
| 0. Foundation | (owner) | all | project setup | `_shared/` project, domain-context, glossary, compliance matrix, tier | done |
| 1. Planning and requirements | product-manager | ux-design, software-architect | write-feature-spec, success-metrics-and-kpi, compliance-and-legal-check, risk-register, prioritization, decision-record, rollout-plan | context.md, `FEAT-` specs, decisions, `RISK-` register | draft; all specs in-progress (built), no open question; legal self-assessment written, owner sign-off pending |
| 2. UX discovery | ux-design | product-manager | user-research-planning, user-flow-and-journey-mapping, information-architecture-and-navigation, usability-testing | flows, IA, journey map, `RS-` studies, design review | draft; RS-001 not fielded (friends, no payment) |
| 3. Architecture | software-architect | cyber-security, product-manager | nfr-analysis, tradeoff-analysis, threat-informed-design, adr-writing, c4-diagramming, architecture-review | `ADR-`, quality goals, C4 diagrams | ADR-001 to 006 accepted; self-review done; spike results in; independent review pending |
| 4. Security design | cyber-security | software-architect | security-requirements-review, threat-modeling, dependency-and-supply-chain-review | `THR-` register, security requirements | threat model (15 threats), requirements review, ADR review, dependency review; open blockers G1, G10 (CI written, never run), G11 (iOS); not independently reviewed |
| 5. Test strategy | qa | product-manager | risk-based-testing, test-plan, test-case-writing | `TP-`, `TC-` linked to acceptance criteria | TP-001 with 102 cases; 66 passed by automated test, 16 partial, 18 not executed, 1 failed (TC-091); none recorded on a physical phone per case |
| 6. Visual and interface design | product-design | ux-design, frontend-mobile | design-token-authoring, colour-and-theming, component-and-state-design, visual-hierarchy-and-layout, design-handoff-and-design-qa | tokens, screen and component specs, all states | brief, tokens, components, 14 screens with all states, logo A2, Lucide icons; owner has not reviewed the `.pen` files since the rebuild |
| 7. Build | frontend-mobile | software-architect, cyber-security | role skills (offline-and-sync, mobile-permissions-and-privacy, ui-testing-strategy, and others) | app code, local data layer | all nine v1 features built for Android and tested on host and emulator; owner tried the release APK on a phone (owner-reported); iOS not built; no signing key |
| 8. Verify and release | qa, frontend-mobile | cyber-security, product-manager | release-sign-off, mobile-release-and-store-compliance, secure-code-review | `PRR-` decision, store release | PRR-001 written: No-Go for production; internal test on a physical phone is the next step |
| 9. Maintain | product-manager | all | vulnerability-triage, post-release review | reviews, updated capability docs, new `FEAT-` | not started |

## 3. Feature gates

Every `FEAT-` passes these gates in order. A gate is passed only with evidence.

| Gate | Owner | Passes when |
|------|-------|-------------|
| G1 Spec ready | product-manager | Owner named, problem stated, non-goals listed, every criterion testable, no open question without an owner, risks registered, no risk at 20 or more without a written waiver |
| G2 Design ready | ux-design, product-design, software-architect, cyber-security | Flow with error paths, all screen states designed, accessibility check done, needed `ADR-` accepted, needed `THR-` reviewed |
| G3 Test plan ready | qa | Each acceptance criterion has a `TC-` in a `TP-`; `check-registry.js` passes |
| G4 Built and done | frontend-mobile | `_shared/standards/definition-of-done.md` met; tests pass; criteria demonstrated |
| G5 Release go | qa, cyber-security, product-manager, frontend-mobile | `_shared/standards/production-readiness-review.md` rows meet the T1 bar; blockers Pass or waived in writing |
| G6 Post-release review | product-manager | Result recorded against the success metrics; follow-up `FEAT-` raised |

## 4. Session protocol

### Preflight (before work)
1. Run `node .assist/tools/preflight.js` and read its report (missing files, unfilled context, pending decisions, publish-safety warnings).
2. Read `README.md`, this file, and `status.md`.
3. Read `_shared/project.md`, then the acting role's `prompts/role.md` and `context.md`.
4. Read `_shared/index.md`; open the `FEAT-`, `ADR-`, `RISK-`, `THR-` the task names.
5. Read the skill that matches the task, its template, and the standards it references. Read the role's `workflow/` docs.
6. Check `product-manager/decisions/` for pending decisions that affect the task. If the task depends on one, ask the owner.
7. State the acting role and the plan in one or two lines.

### During
- Follow the role's skill order and templates; place artifacts in the role's own folders.
- Stay inside the role's remit; raise a hand-off (by ID) for anything owned elsewhere.
- Do not create files outside `.assist/` (docs, app code) until the role's own artifacts for that step exist.

### Postflight (after work)
1. Register any new ID in `_shared/index.md`; set statuses correctly.
2. Write or update the role's `workflow/` doc for any decision made or changed.
3. Update `context.md` if role facts changed.
4. Run `node .assist/tools/check-registry.js` and `node .assist/tools/preflight.js`; fix errors and read the publish-safety warnings.
5. Update `status.md` (phase, gates, pending decisions, next steps, recent changes).
6. If end-user or contributor documentation changed (privacy statement, format specification), update `docs/` from the `.assist/` source.
7. Report what was done, what was verified, what was not, and any pending decision, plainly.

## 5. Hand-offs adapted to this project

Role prompts describe hand-offs to a backend and a devops role. Here:

| Role prompt says | In this project |
|------------------|-----------------|
| Hand off to `backend` (API contract, effort) | frontend-mobile (the app owns local data; there is no API) |
| Hand off to `devops` (rollout, runbook, SLO) | frontend-mobile for store release, signing, and staged rollout; the PRR Operations row is N/A (no server) |
| `RB-`, `INC-`, `SLO-` | not used unless a backend is added |
| software-architect returns `ADR-` | unchanged |
| cyber-security returns `THR-` | unchanged |
| qa returns `TP-`, `TC-` | unchanged |

## 6. Change control

- **Specs:** status moves `draft`, `ready`, `in-progress`, `released`; changes to a `ready` spec are logged in its status log and re-run G1.
- **ADRs:** accepted ADRs are immutable; change one by superseding it with a new ADR and confirming with the owner first.
- **Decisions:** a reversed decision is marked superseded and linked, never edited away.
- **IDs:** never reused or renumbered.
- **Standards and skills:** edit only when the owner asks, and record why.

## 7. Where the assistant must stop and ask

- A pending decision blocks the task.
- The work needs software installed or global configuration changed on the owner's machine.
- Anything would be pushed or published, deleted, or overwritten. Everything under `.assist/` is tracked and may become public (`publishing.md`).
- A number, name, date, or legal fact is not known.
- A skill or standard conflicts with an owner decision.
