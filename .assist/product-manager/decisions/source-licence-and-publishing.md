# Will the repository and source code be public, and under which licence?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided |
| Date | 2026-09-20 raised |
| Decider | Project owner (solo) |
| Related | RISK-006 |
| Supersedes / superseded by | none |

## Context
On 2026-09-20 the owner decided that `.assist/` is tracked and pushed with the repository, so its contents (specifications, decisions, risks, threat model) can be public. It has not been decided whether the remote repository is public or private, whether the source code is public too, or under which licence. Public code and documents would make the privacy claim verifiable by anyone. Without a licence, published code is all rights reserved by default. Related: `.assist/publishing.md`.

## Options considered
| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Publish the code under a permissive licence | Anyone can verify the privacy claim, others may help maintain it | Others can reuse the code | Low | Low |
| 2 | Publish the code under a copyleft licence | Verifiable, and keeps forks open | Restricts some reuse | Low | Low |
| 3 | Keep the code private | Full control | Privacy claim cannot be verified from the code | None | Weaker trust |


## Decision
Decided by the project owner on 2026-09-20 (licence part):
- **Licence: MIT** (option 1, permissive), in `LICENSE` at the repository root. Copyright holder as written there: "Adehikmat" (the public account name, chosen by the owner).
- The licence covers the source code and the documents in this repository. The fonts in `app/assets/fonts/` keep their own licence (SIL Open Font License 1.1, texts next to the files). Packages keep their own licences (`.assist/cyber-security/report/dependency-review.md`; all reviewed ones are permissive: MIT, BSD, Apache-2.0).

Also decided on 2026-09-20:
- **The repository is public.** The source code, `.assist/` and `docs/` are all public.
- The owner confirmed that the material copied from the `_template` project (skills, standards, templates, tools under `.assist/`) may be public under the MIT licence.
- The copyright line ("Adehikmat") is accepted.

Consequence: everything in the repository is read by anyone, so the checklist in `.assist/publishing.md` section 3 must be complete before the first push to a public remote. Recommended: push to a private remote first, complete the checklist, then switch it to public. Pushing and changing visibility stay with the owner.

## Consequences
- Affects the README, dependencies allowed (licence compatibility), and RISK-006.
- Fonts used (Inter, Lora) are under the SIL Open Font License, which allows bundling.
