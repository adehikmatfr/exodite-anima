# .assist / qa

This folder holds the **context**, **prompts**, **skills**, and **documentation** that let an AI assistant work as `qa` on `exodite-anima` without re-scanning the whole codebase.

## Language Policy

Everything under `.assist/` is written in **English only**, regardless of the language used in conversation.

## Folder Structure

```
.assist/
├── tools/check-registry.js      # Verifies the ID registry
├── _shared/                     # Cross-role layer (one copy per project)
│   ├── project.md               # Project identity and rules for every role
│   ├── glossary.md  domain-context.md
│   ├── index.md                 # ID registry
│   ├── standards/               # Enterprise production-readiness standards
│   └── compliance/              # Compliance matrix
└── qa/
    ├── README.md                # This document
    ├── context.md               # Role-specific facts (stack, tools, topology, ...)
    ├── prompts/role.md          # Role charter
    ├── context/                 # Role-specific machine-readable context (optional)
    ├── docs/                    # Guides and command references
    ├── workflow/                # As-built docs, one per flow, integration, or process
    ├── report/                  # Standalone reports, diagrams, write-ups
    ├── templates/               # Fill-in templates (optional, role overlay)
    └── skills/                  # Role skills (see skills/README.md)
```

## How to Use

At the start of a session, the AI assistant reads, in order:

1. `../_shared/project.md`, then `prompts/role.md`.
2. `../_shared/domain-context.md` and `../_shared/glossary.md`.
3. `context.md` (and `context/*` if present).
4. `../_shared/index.md` to resolve IDs, then only the workflow docs and skills relevant to the task.

Production-bound work must satisfy `../_shared/standards/definition-of-done.md` and `production-readiness-review.md`.

## Maintenance

- Keep project-wide facts in `../_shared/`; keep only role-specific facts here.
- Update `context.md` and `context/*` when the system changes.
- Write or update `workflow/` docs after a decision is made, confirmed, or changed.
- Register new features, tests, runbooks, incidents, and decisions in `../_shared/index.md`, then run `node ../tools/check-registry.js`.
- Do not hand-edit generated output.
