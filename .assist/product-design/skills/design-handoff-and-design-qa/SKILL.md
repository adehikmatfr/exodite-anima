---
name: design-handoff-and-design-qa
description: Use when a design is ready to be built, when an engineer asks what is missing from a spec, or when a built screen must be checked against the design before acceptance.
---
# Design Hand-off and Design QA

## Purpose

Give engineers a complete, unambiguous package so nothing is guessed, then verify the built result against it with a pass/fail check tied to acceptance.

## When to use

- A design passes review and moves to build.
- Engineers raise repeated clarification questions.
- A feature reaches staging and needs design QA before acceptance.

## Principles

- **Tokens over redlines.** Reference token names and system components; use measured redlines only for genuine deviations.
- **Every state is specified**, including the ones nobody wants to draw.
- **One package, one link.** The hand-off lives in a single place that is versioned; chat messages are not the spec.
- **Hand-off is a conversation.** Walk engineers through it (30 min) before build starts; agree feasibility early.
- **Acceptance is traceable**: each criterion maps to `FEAT-NNN` and a `TC-NNN`.

## Steps / Checklist

Complete hand-off contains:
- [ ] Link to brief, `FEAT-NNN`, success criteria, and the frozen design version (`design-file-hygiene-and-versioning`).
- [ ] Flows and screens for all platforms and breakpoints in `context.md`.
- [ ] States: default, hover, pressed, focus, disabled, loading, empty, error, offline, permission-denied, success, first-use.
- [ ] Edge cases: long text (+40% expansion), very long unbroken strings, zero/one/many items, max values, missing image, RTL, 200% text scale, slow network.
- [ ] Tokens and components used by name; deviations listed with reason.
- [ ] Interaction and motion: triggers, durations (<= 500 ms), easing, reduced-motion behaviour.
- [ ] Accessibility notes: reading and focus order, accessible names, roles, live-region messages, target sizes.
- [ ] Content: final copy or copy keys, error messages, empty-state text (owner: technical-writer).
- [ ] Assets: exported icons/images with licences, formats and sizes.
- [ ] Analytics events required, without personal data.
- [ ] Open questions with owners; nothing marked "TBD" without a date.

Design QA of the built result (staging build, real device or browser matrix from `TP-NNN`):

| Check | Pass criterion |
|-------|----------------|
| Layout and spacing | Matches tokens; no deviation > 2 px unless documented |
| Typography and colour | Token values; contrast >= 4.5:1 text, 3:1 UI |
| States | Every specified state reachable and correct |
| Responsive | All breakpoints; no clipping at 200% text scale or 320 px width |
| Interaction and motion | Timings and reduced-motion behave as specified |
| Accessibility | Keyboard-only path complete, focus visible, screen reader names correct |
| Content and locale | Final copy, RTL and long-language checked |
| Performance feel | No layout shift on load, no visible jank |

Rules: log each miss with severity (blocker / major / minor), owner and `TC-NNN`; blockers fail acceptance; minor visual items may ship with a tracked ticket.

## Output format

Hand-off note (links plus checklist result) and design QA record using `templates/design-review-record.md` with review type "design QA": findings table, pass/fail per check, decision, follow-ups.

Worked mini-example: QA finds the empty-state illustration missing at 320 px and the error toast not announced; both logged as major, mapped to `TC-NNN`, retest after fix.

## References

- `_shared/standards/definition-of-done.md`, `_shared/standards/project-tiers.md` (T1: checklist in the brief, spot QA of primary flow).
- Frontend role: `accessibility-audit`, `component-design-system`. Related: `design-critique`, `inclusive-and-accessible-design`.
- IDs: `FEAT-NNN`, `TC-NNN`, `TP-NNN`, `RISK-NNN`.

## Language notes

Example (Figma): use Dev Mode, variables and annotations for tokens and specs; freeze the version with a named version or tag.
