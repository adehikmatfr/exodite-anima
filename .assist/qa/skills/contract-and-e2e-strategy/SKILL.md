---
name: contract-and-e2e-strategy
description: Use when a system has multiple services, external or internal APIs, or critical user journeys and you must decide how to split contract, integration, and end-to-end tests, or when e2e suites are slow, flaky, or overgrown.
---
# Contract and End-to-End Strategy

## Purpose
Verify that independently deployed components work together with the fewest, fastest, most reliable tests, avoiding a bloated e2e suite that catches everything slowly.

## When to use
- Designing or reviewing the integration test layer of a `TP-`.
- Introducing, versioning, or deprecating an `API-` contract.
- E2E suite runtime exceeds budget or flake rate is above target.
- Choosing what to mock in a pre-release environment.

## Principles
- Pyramid: many unit, fewer integration and contract, a few e2e on critical journeys only.
- Contract tests verify the agreement at each boundary without deploying both sides together.
- Consumer-driven where consumers are known; provider-verified against every consumer before release.
- E2E covers journeys that make or lose money or trust (sign-up, login, pay, core action), not every permutation.
- Tests own their data; no shared mutable fixtures across tests.
- Third-party systems are stubbed by default; run a small scheduled test against real sandboxes to catch drift.
- Backward compatibility is testable: old consumers against the new provider before rollout (`release-management.md`).

## Steps / Checklist
1. Inventory boundaries: internal APIs, events/queues, external providers, databases owned by others.
2. For each boundary choose the mechanism:
   | Boundary | Primary check | Secondary |
   |----------|--------------|-----------|
   | Sync API (internal) | Consumer-driven contract + provider verification | Schema/compatibility diff in CI |
   | Async events | Message schema contract, versioned, with compatibility rules | Consumer dedupe/replay test |
   | External provider | Recorded/stubbed contract + sandbox smoke on schedule | Failure-mode tests (timeout, 5xx, malformed) |
   | Own DB/migration | Migration test on production-like data volume | Rollback test |
3. Define contract content: schema, status codes, error model, required/optional fields, ordering, idempotency, auth, rate limits.
4. Gate merges: provider build fails if it breaks a published consumer contract; breaking change requires a version bump and deprecation notice.
5. Select e2e journeys (3-10 per product): rank by risk; each has an owner and a stable data setup.
6. Run e2e in a production-like environment against a deployed build; keep one smoke subset (< 5 min) for every deploy.
7. Manage flake: retry does not hide failures; quarantine with owner and 5-day deadline; target flake rate < 1%.
8. Track suite health: runtime, flake rate, failure-to-defect ratio.

### Budgets (defaults; tune)
| Suite | Trigger | Runtime budget |
|-------|---------|----------------|
| Contract | Every PR | < 3 min |
| Integration | Every merge | < 10 min |
| E2E smoke | Every deploy | < 5 min |
| E2E full | Nightly / release candidate | < 45 min |

## Output format
Boundary table (boundary, mechanism, owner, gate), e2e journey list with `TC-` IDs and priority, and suite health metrics; placed in the `TP-` strategy section.

## References
- `_shared/standards/release-management.md`, `reliability-patterns.md`
- `_shared/index.md` (API-, TC-, TP-)

## Language notes
Tools differ by ecosystem (consumer-driven contract frameworks, OpenAPI/AsyncAPI diff tools, browser or API drivers); record the chosen ones in `.assist/qa/context.md`.
