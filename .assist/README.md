# .assist: exodite-anima

The private working knowledge base for this project. It holds the context, rules, skills, and every artifact (specs, decisions, risks, ADRs, threat models, test plans, design specs) that an AI assistant needs to work on exodite-anima without re-scanning the repository.

Read [orchestration.md](orchestration.md) next: it says which role does what, in which order, and what must happen before and after any piece of work.

## Ground rules

- **Tracked and pushed.** `.assist/` is committed and pushed with the repository (owner decision 2026-09-20), so it can be public. Never put secrets, personal data, participant data, or local machine details in it; see `publishing.md`.
- **English only.** Everything under `.assist/` is written in English, whatever language the conversation uses.
- **Source of truth.** Every artifact lives here, inside a role folder. The repository's `docs/` folder holds end-user and contributor documentation (privacy statement, export format specification, guides), not copies of these artifacts.
- **IDs, not paths.** Roles refer to each other's artifacts by stable ID (`FEAT-NNN`, `ADR-NNN`), never by file path. IDs are registered in `_shared/index.md`, are never reused or renumbered, and are checked by `tools/check-registry.js`.
- **LF line endings** in every file (`.gitattributes`).
- **No invented numbers.** Unknown values become open questions with an owner and a due point; see the product-manager and architect role rules.

## Project in one paragraph

A free, fully private journaling app for iOS and Android, built with Flutter. All data stays on the device (no account, no server, no cloud); users move phones through export and import. Tier T1 with escalations for sensitive personal data. One person plays every role. Details: `_shared/project.md` and `_shared/domain-context.md`.

## Layout

```
.assist/
├── README.md                  This file
├── orchestration.md           How roles, skills, hand-offs, and gates fit together
├── status.md                  Where the project stands: phase, gates, pending decisions, next steps
├── publishing.md              What may be pushed or published, and the pre-publish checklist
├── tools/                     preflight.js (readiness, publish-safety and freshness of status.md and role contexts), check-registry.js (IDs and spec-to-test links), mutate.js
├── _shared/                   Cross-role layer, one copy for the project
│   ├── project.md             Identity, tier, principles, rules, decisions that bind every role
│   ├── domain-context.md      Business and system overview
│   ├── glossary.md            Domain terms used by more than one role
│   ├── index.md               ID registry (FEAT, ADR, RISK, THR, RS, ...)
│   ├── compliance/            Compliance matrix
│   └── standards/             Definition of done, PRR, security baseline, NFR catalog, and others
└── <role>/                    One folder per role
    ├── prompts/role.md        Charter, read-first list, working rules, skill map, hand-offs
    ├── context.md             Role-specific facts
    ├── skills/                One folder per skill, each with a SKILL.md
    ├── templates/             Fill-in templates
    ├── workflow/              As-built docs, written after decisions
    ├── report/                Standalone reports, diagrams, studies, registers
    └── docs/                  Guides and references
```

Role-specific extra folders exist where the template defines them (for example `product-manager/features/`, `product-manager/decisions/`, `product-manager/capabilities/`).

## Roles in this project

| Role | Owns |
|------|------|
| product-manager | What is built and why: specs (`FEAT-`), product decisions, risk register (`RISK-`), roadmap |
| ux-design | Research, user flows, information architecture, usability studies (`RS-`) |
| product-design | Visual and interface design: tokens, screens, component states, design specs |
| software-architect | Structure and quality goals: decisions (`ADR-`), NFRs, diagrams |
| cyber-security | Threat model (`THR-`), security requirements and reviews, compliance evidence |
| qa | Test strategy, test plans (`TP-`) and cases (`TC-`), release sign-off |
| frontend-mobile | Building the app, local data, permissions, store release and rollout |

The `devops` role was removed because the app has no backend; where a role prompt still mentions it, use the redirect in `_shared/project.md`.

## Where things live

| Artifact | Home |
|----------|------|
| Feature specs (`FEAT-`) | `product-manager/features/` |
| Product decisions | `product-manager/decisions/` |
| Risk register (`RISK-`) | `product-manager/report/` |
| Research studies (`RS-`), flows, IA, design reviews | `ux-design/report/` |
| Threat model (`THR-`), security reviews, dependency review | `cyber-security/report/` |
| Architecture decisions (`ADR-`) | `software-architect/adr/` |
| NFR analysis, C4 diagrams, architecture review | `software-architect/report/` |
| UI tokens, components, screens, design specs | `product-design/design/` and `product-design/docs/` |
| Test plans and cases (`TP-`, `TC-`) | `qa/test-plans/`, `qa/test-cases/` |
| Permission register, local data design, release plan, spike plan | `frontend-mobile/report/` |
| As-built process docs | each role's `workflow/` |

Where a row says "moves", the current copy is a draft outside `.assist/` waiting to be migrated by that role's stage.

## Starting a session

1. Read `README.md` (this file), `orchestration.md`, and `status.md`.
2. Read `_shared/project.md`, then the acting role's `prompts/role.md` and `context.md`.
3. Read `_shared/index.md` to resolve IDs, then only the skills and standards the task needs.
4. Do the work as that role, following its skill order and templates.
5. Finish with the postflight in `orchestration.md`.

## Tools

```
node .assist/tools/preflight.js               # required files, unfilled context, pending decisions, publish-safety scan
node .assist/tools/check-registry.js          # verify IDs and that each acceptance criterion cites a test
node .assist/tools/check-registry.js --strict # also fail on tests no criterion cites
```

## Backup

Because `.assist/` is tracked in git, the remote repository is its backup once pushed. Until the first push, the only copy is on this machine.
