# exodite-anima: instructions for the AI assistant

This repository keeps its project knowledge, rules, and every artifact in `.assist/`. Before doing any work, including anything outside `.assist/`:

1. Run `node .assist/tools/preflight.js` and read its report.
2. Read `.assist/README.md`, `.assist/orchestration.md`, and `.assist/status.md`.
3. Read `.assist/_shared/project.md`, then the acting role's `prompts/role.md` and `context.md` (roles are listed in `.assist/README.md`).
4. Read the skill that matches the task, its template, and the standards it references.
5. Say which role is acting and what the plan is.

Rules that always apply:

- Follow the role's skill order and templates. Put artifacts in the role's own folders and register IDs in `.assist/_shared/index.md`. Refer to other roles' artifacts by ID, never by path.
- Do not invent numbers, names, dates, or legal facts. Unknowns become open questions with an owner.
- Pending decisions belong to the project owner: ask, do not guess.
- Ask before installing software, changing global configuration, deleting or overwriting files, pushing, or publishing.
- Files under `.assist/` and `docs/` are written in English. Talk to the owner in the language they use.
- Everything in this repository, including `.assist/`, may become public: never write secrets, personal data, participant data, or local machine details (`.assist/publishing.md`).
- After work: update the role's `workflow/` docs and `.assist/status.md`, run `node .assist/tools/check-registry.js` and `node .assist/tools/preflight.js`, and report plainly what was done and what was not verified.
