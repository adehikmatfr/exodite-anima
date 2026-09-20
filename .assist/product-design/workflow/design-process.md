# Design process in exodite-anima

As-built description of how the interface is designed, checked, and handed off. Written after the process was set up on 2026-09-20; update it when the process changes.

## 1. Overview
Product-design owns how the app looks and behaves at the surface: tokens, components, screens, and every state. Designs are generated as OpenPencil `.pen` files from one token file, rendered to PNG with the OpenPencil CLI, checked by the assistant, and opened by the owner in OpenPencil to verify. Research, flows, and information architecture belong to ux-design.

## 2. Trigger / entry points
- A `FEAT-` with a flow from ux-design that needs screens.
- A token, component, or copy change.
- A review finding (design review, RS-001, design QA of a build).

## 3. Step-by-step flow
1. Read `../../_shared/project.md`, this role's `prompts/role.md` and `context.md`, the `FEAT-`, and the ux-design flow and findings.
2. Check the design brief (`../report/design-brief-v1.md`); update it when scope changes.
3. Change tokens only in `../design/library/tokens.json` (`design-token-authoring`); run `tools/gen_docs.py` to regenerate `docs/design-tokens.md` and the contrast matrix. A pair that fails contrast stops the change.
4. Change components in `tools/ui_kit.py` and their spec in `docs/component-specs.md`; draw every state.
5. Change screens in `tools/gen_screens.py` (data) and regenerate: `python gen_screens.py ../design` and `python gen_components.py ../design` from `tools/`. Light and dark are separate files.
6. Render each file with `openpencil export <file>.pen -o <image>.png`, look at the images, and fix layout problems (clipped text, overflow, missing states) before handing over. Copy the previews to `../design/exports/`.
7. Update `docs/screen-specs.md` (`python gen_docs.py`) and `docs/asset-register.md` for any new asset.
8. Run the accessibility checklist (`inclusive-and-accessible-design`) and record findings in a design review record.
9. Hand off by ID: frontend-mobile (build), qa (`TC-` for accessibility and states), product-manager (criteria gaps), ux-design (flow gaps).

## 4. Statuses and data model
Design status: draft, in review, approved, handed off. Files: `design/library/` (tokens and components), `design/features/<area>/` (screens), `design/exports/` (previews), `design/archive/` (superseded work with date and reason). Version checkpoints are named `<area> vX.Y <purpose> YYYY-MM-DD` in the changelog on each file's cover frame.

## 5. External calls and events
None. The OpenPencil desktop app is used by the owner to view files; the CLI renders previews. No design tool is integrated with the assistant beyond that.

## 6. Decisions and gotchas
- A `.pen` frame with no `layout` behaves as horizontal; set `layout: "none"` for overlays.
- Text inside a horizontal frame needs an explicit width or it overflows; the kit sets widths for fields, error lines, and rows.
- At 200 percent text, fixed heights are dropped so boxes grow, and links wrap instead of clipping.
- Previews are not the reference for fonts: Lora is substituted and Inter shows in one weight (owner decision).
- Copy, counts, dates, and wait times on screens are illustrative; real rules are open questions on the specs.
- The first screen drafts (2026-09-20, version 0.1) were drawn before flows and research; they are archived in `../design/archive/` and superseded by version 0.2.
