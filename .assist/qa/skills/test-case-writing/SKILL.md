---
name: test-case-writing
description: Use when writing, reviewing, or refactoring individual test cases or scenarios from acceptance criteria, including designing inputs with equivalence classes, boundaries, and negative paths; produces TC- entries.
---
# Test Case Writing

## Purpose
Turn requirements into precise, independent, repeatable checks that a different person or a machine can execute with the same result.

## When to use
- After `test-plan` scope and risk are set.
- When an acceptance criterion changes or a defect reveals a missing case.
- When reviewing cases for ambiguity, duplication, or flakiness.

## Principles
- One case verifies one behavior; the title states an observable outcome.
- Expected results are specific and observable (value, state, message, event), never "works correctly".
- Independent and order-agnostic: each case sets up and cleans up its own state.
- Deterministic: control time, randomness, external calls, and data; no sleeps as synchronization.
- Cover positive, negative, boundary, permission, and recovery paths, weighted by risk.
- Every case traces to a `FEAT-` acceptance criterion; orphan cases are deleted or justified.
- Prefer automation at the lowest effective level; keep manual cases for exploration and non-automatable checks.
- Synthetic or masked data only (`data-governance.md`).

## Steps / Checklist
1. Take one acceptance criterion; restate it as testable condition(s).
2. Identify inputs and partition them: valid/invalid classes, boundaries (min, max, min-1, max+1, empty, null, oversize, unicode, time zone edges).
3. Add state-based cases: state transitions, idempotent retries, concurrency, partial failure, timeouts.
4. Add authorization cases: each role allowed, each role denied, unauthenticated, cross-tenant access.
5. Fill `templates/test-case.md`; assign `TC-` ID; register in `_shared/index.md`.
6. Assign priority (below) and level; mark automated/manual.
7. Peer review against the checklist; run once to prove it can fail (mutate or break the behavior).
8. Link the case to the `TP-` traceability table.

### Priority
| Priority | Meaning | Run frequency |
|----------|---------|---------------|
| P0 | Blocks release if failing; critical path, money, data, security | every build |
| P1 | Important feature | every release candidate |
| P2 | Secondary behavior | per cycle |
| P3 | Rare, cosmetic | as time allows |

### Quality checklist
- [ ] Title is verb + outcome; no "and" joining two behaviors
- [ ] Preconditions and data are explicit
- [ ] Each step is one action; each expected result observable
- [ ] Negative and boundary variants exist for P0/P1
- [ ] No hidden dependency on another case
- [ ] Cleanup restores state

## Output format
Filled `templates/test-case.md` per case. For data-heavy behavior use a decision/parameter table listing input combinations and expected result, one row per case variant.

## References
- `_shared/standards/definition-of-done.md`, `data-governance.md`, `security-baseline.md`
- `_shared/index.md` (TC-, FEAT-, THR-)

## Language notes
Automation style (given/when/then, table-driven, property-based) follows the project's test framework; record the convention in `.assist/qa/context.md`.
