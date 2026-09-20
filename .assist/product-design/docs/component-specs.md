# Component specs (version 1)

Method: skill `component-and-state-design`. Drawn in `design/library/components-light.pen` and `-dark.pen`, every state each component has. Tokens: `design-tokens.md` (semantic tokens only). Status: draft, owner product-design.

Common rules for every interactive component:
- Touch target at least 48 x 48 (`touch.min`). Hover is not designed: the app is touch-first; a pointer or keyboard user gets the focus state.
- Focus is always visible: a 2 px ring in `color.focus.ring`, 3:1 against its neighbours.
- Pressed feedback within 100 ms. Loading keeps the layout stable and states what is happening.
- Errors appear next to the cause, say what happened and what to do next, are announced to assistive technology, and never rely on colour alone (icon plus words).
- Disabled is a last resort; where possible the control stays enabled and explains itself. Where a control is disabled, the reason is written next to it.
- Every label is visible text, never placeholder-only.

## Button
Purpose: trigger an action. Variants (four, by purpose): **primary** (the one main action per screen), **secondary** (outlined alternative), **danger** (destructive, filled), **text link** (low-emphasis action).

| State | Primary | Secondary | Danger | Text link |
|-------|---------|-----------|--------|-----------|
| Default | `action.primary.bg` fill, `action.primary.fg` label | `surface.base` fill, `border.strong` outline, `text.primary` label | `status.danger.solid` fill, `status.danger.on-solid` label | `action.primary.bg` label |
| Pressed | `action.primary.pressed` fill | outline stays, fill darkens one step | fill darkens one step | label darkens |
| Focus | 2 px `focus.ring` outside the button | same | same | same |
| Disabled | `surface.raised` fill, `border.default`, `text.secondary` label | same | same | `text.secondary` label |
| Loading | label "Working...", fill as default, not tappable | same | same | not used |
| Error / empty | not applicable | | | |

Size: height 52 (link 48), radius `radius.lg`, label `type.label`. At large text the height is dropped and the button grows with its label. Rule: at most one primary button per screen. Do: give a destructive action its own danger button with the consequence named above it. Do not: use danger for anything but destroying data.

## Text field
Purpose: enter text. Anatomy: visible label above, input box, optional trailing action (Show or Hide), helper or error line below. Kinds: text, secure (dots by default), search.

| State | Treatment |
|-------|-----------|
| Default | `surface.raised` fill, 1 px `border.strong` |
| Focus | 2 px `focus.ring` border |
| Error | 2 px `status.danger.fg` border, an error icon (circle with "!") and a message below in `status.danger.fg` |
| Disabled | `surface.raised`, value in `text.secondary`, helper explains why |
| Filled | value in `text.primary` (secure: dots) |
| Loading, empty | not applicable (placeholder text is a hint, not a label) |

Size: height 56, radius `radius.md`, padding 16. Secure fields: a Show or Hide toggle named "Show passcode" or "Hide passcode"; no copy out of the field; paste allowed so password managers work; no keyboard suggestions. Validate on blur, then on change after the first error; never clear valid input when another field fails. The search field keeps a persistent "Search" prefix inside the box so its purpose stays visible while typing; its accessible name is "Search your entries".

## Checkbox row and switch
The whole row is the control (height 56). Checkbox: 24 px box, 2 px `border.strong`, radius 6; checked shows a tick on `action.primary.bg`. States: unchecked, checked, focus, disabled. The row text is the accessible name. Switch: 52 x 32 track; on uses `action.primary.bg`, off uses `surface.raised` with a `border.strong` outline; the word "On" or "Off" is shown beside it so state never relies on colour.

## Option (radio)
A card-shaped choice with a title and a description; selected uses a 2 px `action.primary.bg` border and a filled dot, unselected a 1 px `border.strong` border and an empty ring. Exactly one option is selected in a group.

## Banner
Purpose: a message that stays on screen and may offer actions. Kinds: **info** (neutral border) and **warning** (1 px `status.warning.fg` border, the word "Important" above the title). Content: title, one or two sentences, and up to two text actions (each 48 high). A banner never contains entry text. Dismissal (where it exists) is an explicit action.

## List rows
- **Entry row**: time (caption), then a two-to-three line preview in `type.journal`; bottom divider `border.default` (decorative).
- **Setting row**: label, optional value, optional chevron; height 56; the label wraps and the value never truncates (at large text it wraps under the label).

## Bottom sheet and dialog
A sheet (destructive confirmation) slides from the bottom over a `overlay.scrim` at 50 percent; a dialog (draft recovery) is centred. Both are announced as dialogs, trap focus, and close only through their actions. A destructive sheet names the consequence and offers Cancel.

## Progress
A 8 px track with a fill and a caption such as "120 of 340 entries". The caption is announced at intervals, not continuously. Long work offers Cancel. No animation is required; if one is added it respects "reduce motion".

## Loading skeleton
Grey bars in `surface.raised` matching the shape of the content; used only while the journal opens. The screen also says "Opening your journal..." so the state is not visual only.

## Empty state
Logo placeholder, a title, one sentence, and one primary action. First use ("Nothing here yet") and no results are different empties with different words.

## Logo placeholder
A ring in `color.brand.mark`, decorative (hidden from screen readers). It is a placeholder: the real logo waits for the app name (`product-manager/decisions/public-app-name.md`).

## Component coverage
| Component | Design | States drawn | Code | Notes |
|-----------|--------|--------------|------|-------|
| Button (4 variants) | draft | yes | none | |
| Text field, search field | draft | yes | none | |
| Checkbox row, switch, option | draft | yes | none | |
| Banner, rows, sheet, dialog | draft | yes | none | |
| Progress, skeleton, empty state, logo | draft | yes | none | |
