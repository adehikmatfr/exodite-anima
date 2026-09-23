# Product Manager Context: exodite-anima

Project identity, tier, and shared rules live in `../_shared/project.md`. This file holds only product-specific facts. Keep it factual and current; put hypotheses in `FEAT-` specs.

## Users and segments
| Segment | Description | Size / share | Primary job to be done | Priority |
|---------|-------------|--------------|------------------------|----------|
| Journal writer (hypothesis) | People who want to keep a journal without paying and without trusting a company with their writing | unknown, no data | Write privately and keep the journal safe, including when changing phones | primary |

No research or usage data exists yet. The segment comes from the owner's positioning; treat it as a hypothesis (assumption A-1 in `report/risk-register.md`).

## Business goals and metrics
The product has no revenue goal: it is free by decision (`decisions/free-private-positioning-policy.md`). The app collects no usage data by design, so goals are verified by tests, and after release by store-console data.

| Goal | Metric | Definition | Baseline | Target | Review cadence | Owner |
|------|--------|-----------|----------|--------|----------------|-------|
| The privacy promise holds | Requests carrying user content | Network requests that include entry text or metadata, found by test and code review | none (no prior version) | 0 | each release | Project owner |
| Users can move to a new device | Export round trip | Entries that differ after export then import, found by test | none (no prior version) | 0 | each release | qa |
| The app is stable | Crash-free sessions | Store consoles (platform data, not app telemetry) | none until the first release | to be set after the first release | monthly after release | Project owner |

Guardrail metrics that must not regress: requests carrying user content stay at 0; entries lost or altered after saving stay at 0.

## Stakeholders and decision rights
| Stakeholder | Role | Interest | Decides | Consulted on | Informed of |
|-------------|------|----------|---------|--------------|-------------|
| Project owner (solo) | Owner, developer, all roles | A free, private journal that works | Scope, release, policy, risk acceptance | none | none |
| Apple and Google stores | Distribution and review | Policy and privacy-label compliance | Whether a release is accepted | none | Release contents |
| Future users | Users | Privacy, no cost, not losing data | none (no direct channel) | none | Release notes, store listing |

Escalation path when stakeholders disagree: the project owner decides.

## Roadmap horizon
| Horizon | Theme / outcome | Candidate `FEAT-` | Confidence |
|---------|-----------------|-------------------|-----------|
| Now (current cycle) | Version 1: private journal with lock, search, export and import | FEAT-001 to FEAT-009 | medium |
| Next (1-2 cycles) | Photos (v1.1), plus tags, mood, and On this day (owner decided 2026-09-23 to bundle them) | Photos not yet specified; FEAT-010 `ready` (2026-09-23) | low |
| Later (unscheduled) | Audio (v1.2), favourites, daily writing reminder, rich text | not yet specified | low |

Planning cadence: no fixed cycle. Capacity per cycle: unknown (one person, no effort read yet). No FEAT- ID is reserved for later items; each gets one when its spec is written.

## Capability map
| Capability | Status | Doc in `capabilities/` | Owner |
|-----------|--------|------------------------|-------|
| none live | not applicable yet | none | none |

## Constraints
- Budget and timeline: no infrastructure cost; only store developer fees. No deadline set.
- Regulatory or contractual: see `../_shared/compliance/compliance-matrix.md` (WCAG 2.2 AA and app store rules apply; UU PDP, PP 71/2019, and GDPR are Confirm).
- Technical or platform limits that shape scope: no backend or accounts, so no server-side recovery or sync; a shipped mobile build cannot be rolled back; iOS cannot be built on the current development machine.
- Policy or brand rules: free, no ads, no tracking, no accounts (`decisions/free-private-positioning-policy.md`).

## Feedback and data sources
| Source | What it tells us | Access | Refresh |
|--------|------------------|--------|---------|
| Store reviews and ratings | User sentiment, reports of lost data | Store consoles | after release |
| Store-console crash and stability data | Crash-free sessions (platform data) | Store consoles | after release |
| The owner's own testing | Behaviour on test devices | Direct | each build |

No in-app analytics, by design.

## Known gaps
- No user evidence for the segment or for the free-and-private positioning (A-1).
- Relative effort reads exist (2026-09-20, sizes only, low confidence); no person-days, so no prioritisation scores (`decisions/v1-scope-and-non-goals.md`). Specs wait for the owner to confirm `ready`.
- Numeric targets are provisional until measured in the spike (`decisions/nfr-targets-v1.md`, decided 2026-09-20).
- Legal applicability: self-assessed from the official texts (`report/legal-self-assessment-v1.md`); owner accepted it as the basis for the first Android release on 2026-09-23 (not legal advice; residual doubts remain, RISK-008).
- Public name decided (Exodite Anima); availability on the stores unchecked (`decisions/public-app-name.md`).
- Public repository and MIT licence decided (`decisions/source-licence-and-publishing.md`); the publishing checklist is not finished.
- Staged rollout decided (`decisions/v1-rollout-plan.md`); halt-trigger numbers follow the internal test.
- Indonesian copy: reviewed and accepted by the owner 2026-09-23 (180 strings, `app/lib/l10n/strings.dart`); two minor wording fixes applied.
