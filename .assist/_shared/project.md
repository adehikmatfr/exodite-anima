# Project: exodite-anima

Single source for project identity and rules shared by every role. Each role folder adds only its own `prompts/role.md`. Do not copy this content into role folders.

## 1. Project Identity

| Attribute | Value |
|-----------|-------|
| Name | `exodite-anima` |
| Repo / location | Local working copy of a git repository. Everything, including `.assist/`, is tracked and may be pushed (owner decision 2026-09-20); visibility of the remote is undecided (`.assist/publishing.md`). |
| Product | Offline-first, fully private journaling app for iOS and Android. No backend, no accounts. |
| Primary language(s) | Dart (with Flutter) |
| Framework(s) | Flutter, one codebase for iOS and Android (ADR-004). Code lives in `app/` (created 2026-09-20, Dart package `exoditeanima`). |
| Bundle ID | `io.github.adehikmatfr.exoditeanima` (Android applicationId and iOS bundle identifier). Decided by the owner; cannot change after the first store release without becoming a new app. The public app name is still unconfirmed. |
| Data store(s) | On-device only: encrypted local database plus separately encrypted media files. Encrypted SQLite via drift + SQLite3MultipleCiphers (ADR-002); media as separate encrypted files. |
| Deploy target | Apple App Store and Google Play. No servers, no cloud infrastructure. |
| Project tier | **T1** (solo developer, no backend, no outage concept), **escalated**: journal content is highly sensitive personal data, so Security, Data, and Compliance rows in the PRR are blockers, and every privacy claim must be verifiable. See `standards/project-tiers.md`. |
| Team | One person, wearing all roles in turn. Roles exist to load the right context, not to imply separate people. |

## 1a. Product Principles

These override convenience in every role:

1. **Private by construction.** Journal content never leaves the device unless the user explicitly exports it. No accounts, no server, no analytics on content.
2. **The user owns the data.** Export uses an open, documented, versioned format so the user is never locked in. Import must restore an export fully.
3. **Losing data is the worst failure.** Durability, atomic writes, and export reminders outrank new features.
4. **Never claim more privacy than is built.** Any user-facing privacy statement must trace to a control and a test.

## 2. First Steps for the AI

1. Read this file, then your role's `prompts/role.md`.
2. Read `domain-context.md` and `glossary.md` in this folder.
3. Read your role's `context.md` and `context/*` if present.
4. Consult `index.md` to resolve any ID (`FEAT-`, `ADR-`, ...).
5. Read only the `workflow/` docs and `skills/` relevant to the task.
6. Do **not** scan the whole repository unless asked; start from the role's entrypoint map.

## 3. Working Rules (all roles)

- Follow existing conventions in the code and docs before introducing new ones.
- "Done" means `standards/definition-of-done.md`.
- Anything user-facing or production-bound must pass `standards/production-readiness-review.md`.
- Never commit secrets, real customer data, or credentials; see `standards/security-baseline.md`.
- Confirm before destructive or hard-to-reverse actions.
- Record decisions as `ADR-` and register new IDs in `index.md`; run `tools/check-registry.js` before finishing.
- Write all `.assist/` content in English.

## 4. Project-specific rules

- **No network for user content.** No code path may send entry text, media, or metadata off the device. Any new network call needs an ADR and a threat model entry.
- **Telemetry default is none.** Crash reporting or analytics only if opt-in, content-free, and recorded in an ADR.
- **No hand-rolled cryptography.** Use vetted libraries and the OS Keychain / Keystore for keys.
- **No content in logs, crash reports, notifications, screenshots (app switcher), or clipboard** unless the user acts explicitly.
- **Every persisted format is versioned** (database schema and export archive carry a `schemaVersion`) and has a migration path plus a round-trip test.
- **Exclude app data from OS cloud backup** unless an ADR decides otherwise; the user's safety net is export.
- **Media (photo, audio) is optional** in export; media files are stored separately from the database, encrypted, with metadata (for example GPS) handling decided per ADR.
- **Roles in this project:** product-manager, software-architect, ux-design, product-design, frontend-mobile, qa, cyber-security. UX research, flows and information architecture belong to ux-design; visual and interface design (tokens, screens, component states) belongs to product-design. The `devops` role was removed: the app has no backend or infrastructure. Where a role prompt hands off to `devops`, use instead: store release, rollout and signing to frontend-mobile (`mobile-release-and-store-compliance`); the PRR Operations row is N/A with reason "no server" unless a backend is added. The ID prefixes `RB-`, `INC-`, `SLO-` stay in the shared registry.
- **Where artifacts live (decided by the owner, revised 2026-09-20):** the source of truth for every artifact (specs, decisions, ADRs, threat models, risks, test plans, design specs) is inside `.assist/<role>/` in the folders the role defines, registered in `_shared/index.md`. `.assist/` is tracked in git and is pushed with the repository, so it can become public: never write secrets, personal data, participant data, or local machine details into it (`.assist/publishing.md`). `docs/` holds end-user and contributor documentation (privacy statement, export format specification, guides), not copies of `.assist/` artifacts. This supersedes the earlier rule that `.assist/` stays private.
- **Preflight before any work:** read this file, the role's `prompts/role.md` and `context.md`, `_shared/index.md`, the matching skill, and the relevant standards; write or update the role's `workflow/` docs after each decision.
- **UI design workflow:** the product-design role writes tokens, components, and screens as OpenPencil `.pen` files (plain JSON) under `.assist/product-design/design/`, generated from one token file, from the feature specs and the ux-design flows. The owner opens them in OpenPencil (installed locally) only to verify. No MCP or tool integration. Flutter code is written from `docs/design-tokens.md`, `docs/component-specs.md`, `docs/screen-specs.md`, and the `.pen` files.
- **Self-check of designs:** render a `.pen` to PNG with `openpencil export <file>.pen -o <out>.png` (CLI `@open-pencil/cli` 0.15.1, installed globally) and look at the image before handing it over. `openpencil lint` and `openpencil info` also work. `.pen` is read-only for the CLI (write `.pen` by hand; `.fig` is the writable format). Run the CLI from PowerShell or Bash; scratch renders go to the scratchpad, not the repo.
- **Dev environment:** Flutter 3.44.4 / Dart 3.12.2, Android SDK 36 installed, one Android emulator `flutter_avd` (used for the tests; its graphics speed is not stable, so it is not used to judge frame rates). No Mac, so iOS cannot be built or run locally; iOS verification needs a Mac or cloud CI. Visual Studio is not installed (only needed for Windows desktop, which is out of scope).
- **Fonts on this machine:** Lora (variable TrueType, SIL OFL 1.1, from google/fonts) is installed per user at `%LOCALAPPDATA%\Microsoft\Windows\Fonts\Lora[wght].ttf` with an entry under `HKCU\...\Fonts`. The OpenPencil CLI does not read system fonts (it uses only its bundled fonts), so CLI previews still substitute Lora; whether the desktop app uses it must be checked by opening a `.pen` there. When Lora is bundled into the Flutter app, ship its `OFL.txt` with it.
- **Design generators:** `.assist/product-design/tools/` (`tokens_lib.py`, `ui_kit.py`, `gen_screens.py`, `gen_components.py`, `gen_docs.py`); run from that folder: `python gen_screens.py ../design`, `python gen_components.py ../design`, `python gen_docs.py`. `design/library/tokens.json` is the source of truth for values; the `.pen` files and the token and screen docs are generated. The CLI ignores `theme` on frames, so light and dark are separate files.
- **`.pen` gotchas:** a frame with no `layout` behaves as horizontal, so `x`/`y` of its children are ignored; set `"layout": "none"` for overlays and sheets. Generators (`.assist/product-design/tools/`): `gen_onboarding.py` (S1 to S5) and `gen_journal.py` (S6, S7) share `ui_lib.py`.
- **Local patch (Windows):** CLI 0.15.1 fails to load its WASM (path becomes `C:\C:\...`). Two files under the global package (`@open-pencil/cli/node_modules/@open-pencil/core/dist/`: `canvaskit.js` and `io/formats/raster/headless.js`) were patched to use `fileURLToPath`; originals are kept as `*.orig`. A reinstall or upgrade of the CLI overwrites the patch; re-apply it or check whether upstream fixed it.
- **Interface languages:** English and Indonesian, switchable in Settings; the default follows the phone (decision `platforms-and-languages`, 2026-09-20).
- **Decided:** encryption and key recovery (ADR-001), database (ADR-002, proven on Android by the spike), export archive format (ADR-003, custom envelope on vetted primitives, decided in the spike), Flutter (ADR-004). no network, enforced through the build (ADR-005, accepted 2026-09-20); migration safety rules (ADR-006). Do not contradict them; supersede with a new ADR instead. Each becomes an `ADR-` before dependent code is written.
