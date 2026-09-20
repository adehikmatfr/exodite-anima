---
name: architecture-review
description: Use when a design, ADR, structural pull request, or system needs an independent architectural review, a pre-release architecture sign-off, or a health check of an existing system for risks and technical debt.
---
# Architecture Review

## Purpose
Evaluate a design or system against quantified requirements and shared standards, and produce scored, actionable findings with an approve / conditions / reject outcome.

## When to use
- Before build (design review) or before release (feeds `production-readiness-review.md` rows 2, 5, 6, 7, 11).
- A structural change: new service, data model, integration, or vendor.
- Periodic health check or after an incident with architectural root cause.
- Not for code style or line-level bugs.

## Principles
- Review against stated requirements and ADRs, not personal taste.
- Findings are specific, evidenced, and paired with a recommendation and severity.
- Separate must-fix (blocker) from should-fix and observations.
- Critique the design, not the author; ask questions before asserting defects.
- Timebox: scope to the decisions that are costly to reverse.
- Reviews are recorded; follow-ups become `ADR-` or `RISK-` entries with owners and dates.

## Steps / Checklist
1. Gather inputs: `FEAT-`, NFRs, existing `ADR-`, C4 diagrams, `THR-`, cost estimate, test plan. Missing input is itself a finding.
2. Restate the system in one paragraph and confirm with the author.
3. Open `templates/architecture-review-checklist.md`; score each row 0/1/2 with evidence.
4. Probe the high-risk areas with these questions:
   - What happens when each dependency is slow, down, or wrong? (`reliability-patterns.md`)
   - Where is state, who owns it, how is it recovered? RPO/RTO proven?
   - What is the worst-case blast radius of one bad deploy or one tenant?
   - Which decisions are one-way doors, and are they recorded?
   - How is it observed and operated at 3 a.m.? Who is on call?
   - What breaks at 10x load? At 0.1x budget?
5. Check consistency: diagrams, ADRs, and the implemented reality agree; note drift.
6. Classify findings: blocker (violates NFR/compliance/security baseline), major (material risk), minor, observation.
7. Compute the score and outcome: Approve >= 85% with no blocker at 0; conditions 70-84%; reject < 70% or any blocker at 0.
8. Write findings with owner and due date; raise `RISK-` for accepted gaps; request `ADR-` for undocumented decisions.
9. Re-review only the changed areas after fixes.

## Output format
Review summary: scope, inputs reviewed, outcome, score.

| ID | Sev | Area | Finding | Evidence | Recommendation | Owner | Due |
|----|-----|------|---------|----------|----------------|-------|-----|
| F1 | Blocker | Reliability | Payment call has no timeout or idempotency key | Sequence diagram step 4 | Add 3 s timeout, idempotency key, retry with jitter (max 3) | backend | 2026-10-01 |
| F2 | Major | Data | Restore never tested; RPO unproven | No RB- entry | Run restore drill; record in `RB-` | devops | 2026-10-15 |
| F3 | Minor | Docs | Container diagram omits queue | Diagram v2 | Update C4 level 2 | architect | next sprint |

Follow-ups: `ADR-` needed for tenancy model; `RISK-` for single-region deployment (accepted by product).

## References
- `templates/architecture-review-checklist.md`
- `_shared/standards/production-readiness-review.md`
- `_shared/standards/reliability-patterns.md`
- `_shared/standards/security-baseline.md`
- `_shared/standards/definition-of-done.md`
