# Publishing

What may be committed, pushed, and made public, and what must be checked first. Owner decision (2026-09-20): `.assist/` is tracked and pushed with the repository. The remote will be public (decided 2026-09-20, `product-manager/decisions/source-licence-and-publishing.md`). Write everything as if it will be read by anyone.

## 1. What is in the repository

| Path | Holds | Public-safe if the remote is public? |
|------|-------|--------------------------------------|
| `.assist/` | Roles, rules, skills, templates, specs, decisions, risks, threat model, research plans, status | Yes, after the checks below; skills, standards, and templates come from the owner's own template (see section 4) |
| `docs/` | End-user and contributor documentation, and design drafts waiting to be migrated | Yes |
| `app/` | Flutter application source | Yes (MIT) |
| `README.md`, `CLAUDE.md` | Overview and the assistant entry point | Yes |

## 2. Never commit

- Secrets and signing material: `.env`, `*.jks`, `*.keystore`, `key.properties`, `*.p12`, `*.p8`, `*.mobileprovision`, `google-services.json`, `GoogleService-Info.plist`, tokens, passwords. (The root `.gitignore` blocks these names.)
- Research participant data: recordings, consent forms, names, contact details, or notes that identify a person (`ux-design/context.md`). Use pseudonyms `P01`, `P02` and keep raw data outside the repository.
- Real journal content in fixtures, screenshots, or test data. Use made-up text and made-up passcodes only.
- Local machine details: absolute paths that contain a username, device names, or serial numbers.
- Unfixed vulnerability details. Report and fix privately first, then document (add a `SECURITY.md` with a private reporting route before the repo is public).

## 3. Before making the remote public (checklist)

- [x] Licence decided and added: MIT, `LICENSE` at the root (2026-09-20), recorded in `source-licence-and-publishing`. The owner confirmed on 2026-09-20 that the copied `.assist/` template material may be public under it.
- [x] Public app name decided: exodite-anima (2026-09-20). Store availability still to be checked before submission, not before the repository goes public.
- [x] `node .assist/tools/preflight.js` reports no publish-safety errors and every warning is understood.
- [x] `node .assist/tools/check-registry.js` passes (2026-09-20; 43 warnings about tests not yet cited by criteria, understood).
- [ ] Read the wording of public-facing risk and legal notes: `product-manager/report/risk-register.md` (for example RISK-006 and RISK-008), `_shared/compliance/compliance-matrix.md`, and `product-manager/decisions/legal-applicability-confirmation.md`. Confirm you are comfortable with them being public.
- [x] No participant data, secrets, or local paths in the tree (section 2). Scanned on 2026-09-20: no secret patterns, no user names or local paths, `android/local.properties` is ignored. Re-scan before the push.
- [ ] A `README.md` that a stranger can follow, and a plain-language privacy statement in `docs/` if the store listing will link to it.
- [x] `SECURITY.md` written (2026-09-20). It points to GitHub private vulnerability reporting, which the owner must switch on in the repository settings (Settings, Code security, Private vulnerability reporting) after creating the remote.
- [x] Outside contributions are welcome (owner, 2026-09-20); `CONTRIBUTING.md` added.

## 4. Template-derived content
The skills, standards, templates, and tools under `.assist/` were copied from the owner's `_template` project. Publishing them is the owner's call; confirm the owner is happy for that material to be public and under the chosen licence.

## 5. Publishing procedure
1. Run `git status` and read the list of files to be added.
2. Run `node .assist/tools/preflight.js` and `node .assist/tools/check-registry.js`.
3. Review the diff of anything that mentions people, paths, or legal matters.
4. Commit; push to a private remote first if visibility is undecided.
5. Change the remote to public only after the checklist in section 3 is complete.

## 6. What the assistant does
The assistant never pushes, changes remote visibility, or publishes anything without the owner asking (`orchestration.md` section 7). It runs the checks above and reports the result.
