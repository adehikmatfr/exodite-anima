# Threat register process

As-built description of how threats are recorded and tracked in this project. Written after the process was set up on 2026-09-20; update it when the process changes.

## 1. Overview
The cyber-security role owns the `THR-` register (`../report/threat-model-v1.md`). The software-architect proposes design-level threats (`threat-informed-design`); this role deepens them, scores them, assigns owners and verification, and tracks them to closure. The project owner accepts residual risk in writing.

## 2. Trigger / entry points
- A new or changed trust boundary, data class, dependency, or build step (architect hand-off by ID).
- A new or changed `ADR-` or `FEAT-` with security impact.
- A test, review, or store report that shows a weakness.
- The scheduled review: at each release and at each boundary change.

## 3. Step-by-step flow
1. Read `../../_shared/project.md`, this role's `prompts/role.md` and `context.md`, and `../../_shared/index.md`.
2. Run `security-requirements-review` on the affected `FEAT-` and record gaps (`../report/security-requirements-review-v1.md`).
3. Run `threat-modeling`: confirm the data flow against `../../software-architect/report/c4-diagrams.md`, apply STRIDE per boundary crossing, add attacker paths and chained threats, score likelihood x impact from 1 to 3.
4. For each threat choose mitigate, transfer, avoid, or accept. Accepting needs a `RISK-` entry and a named owner.
5. Attach a verification method to every mitigation. A threat becomes `verified` only with evidence.
6. Register new `THR-` and `RISK-` IDs in `../../_shared/index.md`.
7. Review new or changed `ADR-` for security and record the outcome (`../report/adr-security-review-v1.md`); block only on security grounds.
8. Review each new dependency before it is added (`../report/dependency-review.md`).

## 4. Statuses and data model
Threat status: `open`, `mitigated`, `accepted`, `verified`. Scores 6 to 9 are mitigated before release; 3 to 5 need an owner and a date; 1 to 2 are accepted. `THR-` IDs are never reused. Residual risks live in the shared risk register (`../../product-manager/report/risk-register.md`), where this role contributes ratings and evidence.

## 5. External calls and events
None. No scanner or tracker is connected yet (`../context.md`, security tooling).

## 6. Decisions and gotchas
- Every security artifact so far was written by the same assistant that wrote the design, so none is independent. Independent review is an open gap.
- No threat is marked `verified` yet (2026-09-20): controls for most threats are built and tested on the host and the Android emulator, but verification also needs a physical phone and an independent reviewer. Statuses stay `open`.
- Blockers open for the Security row of the readiness review: see `../report/security-requirements-review-v1.md`.
- Residual risks: RISK-001 is accepted by the owner (ADR-001); the owner accepted RISK-009 and RISK-010 on 2026-09-20.
- Testing that touches real systems needs a written scope (`../templates/pentest-scope.md`); none is planned.
