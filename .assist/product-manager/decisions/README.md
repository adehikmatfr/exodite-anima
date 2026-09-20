# decisions

Where product decisions and open product questions are kept so they are not lost or re-litigated.

## Where a decision goes
| Kind of decision | Home | ID |
|------------------|------|----|
| Architectural (structure, technology, data model, trust boundary, NFR trade-off) | Software architect's ADR | `ADR-NNN` |
| Product-level and tied to one feature (scope cut, behaviour choice, rollout choice) | The `FEAT-` spec, Decisions section | inherits `FEAT-NNN` |
| Product-level, cross-feature or long-lived (prioritisation outcome, policy, pricing rule, open question) | `decisions/<slug>.md` | referenced from each affected `FEAT-` |

Do not invent a new ID prefix. If a decision is architectural, hand it to the architect and reference the resulting `ADR-`.

## Naming
`decisions/<slug>.md`, kebab-case, describing the question, for example `bulk-export-retention-policy.md`. Put the date inside the file.

## Rules
- Use `../templates/decision-record.md`.
- A decision doc may be `Pending`; its job is to keep a real open question visible, with an owner and a due date.
- When decided, fill Decision and Consequences with the date; do not delete the options that lost.
- A reversed decision is not edited away: mark it `superseded` and link the new one.
- Prioritisation outcomes must include the scores, not only the final order.

## Index
| Slug | Question | Status | Date | Related |
|------|----------|--------|------|---------|
| `v1-scope-and-non-goals` | What goes into version 1, and what is deliberately left out? | decided | 2026-09-20 | FEAT-001 to FEAT-009 |
| `free-private-positioning-policy` | Which money and data policies does the product hold to? | decided | 2026-09-20 | RISK-006, RISK-008 |
| `nfr-targets-v1` | What numeric targets apply to speed and size in version 1? | decided (provisional) | 2026-09-20 | FEAT-001, FEAT-002, FEAT-005 |
| `platforms-and-languages` | Which OS versions and interface languages does version 1 support? | decided | 2026-09-20 | FEAT-004, FEAT-009 |
| `source-licence-and-publishing` | Will the repository and source code be public, and under which licence? | decided | 2026-09-20 | RISK-006 |
| `v1-choices-2026-09-20` | iOS, performance device, contrast, icons, first-screen action, study recruiting | decided | 2026-09-20 | RISK-004, RISK-007 |
| `public-app-name` | What is the public name, and is it available on both stores? | decided (store availability unconfirmed) | 2026-09-20 | RISK-007 |
| `legal-applicability-confirmation` | Which legal frameworks actually apply? | decided; assessment written, sign-off pending | 2026-09-20 | RISK-008 |
| `v1-rollout-plan` | How is version 1 released and how is a bad release handled? | decided (numbers to follow) | 2026-09-20 | all FEAT, RISK-007 |
| `lock-and-passcode-policy` | What are the rules for the passcode, the wait after wrong tries, the lock timeout, and screenshots? | decided | 2026-09-20 | FEAT-003, FEAT-004, FEAT-006, FEAT-009 |
