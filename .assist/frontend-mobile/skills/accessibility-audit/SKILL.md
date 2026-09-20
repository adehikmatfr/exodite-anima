---
name: accessibility-audit
description: Use when auditing or building a screen or component for accessibility, before release of any user-facing UI, or when a defect mentions screen readers, keyboard, focus, contrast, zoom or text scaling.
---

# Accessibility Audit

## Purpose
Verify that people using assistive technology, keyboards, switch devices, zoom or large text can complete every journey. Default target: WCAG 2.2 Level AA on every platform, mapped to the native accessibility API where there is no browser.

## When to use
- New or changed screen, component or flow; before a release candidate.
- A11y defect reported; an external audit or legal requirement applies.

## Principles
- Semantics first: use native controls and platform roles; custom widgets must replicate role, name, value and state.
- Everything operable without a pointer or touch gesture; every gesture has a simple alternative (WCAG 2.5.1, 2.5.7 dragging).
- Information is never by colour, sound or position alone.
- Automated tools catch about a third of issues; manual assistive-technology passes are required for T2+ and any personal-data, payment or public-sector UI.
- Accessibility bugs are functional bugs and follow normal severity rules.

## Checklist (WCAG 2.2 AA essentials)
- [ ] Text contrast >= 4.5:1; large text, icons, focus rings and input borders >= 3:1 (1.4.3, 1.4.11), in every theme.
- [ ] Layout usable at 200% text size and 400% zoom / large dynamic type without loss or 2-D scrolling (1.4.4, 1.4.10).
- [ ] Every control has an accessible name, role and state; names match visible labels (2.5.3).
- [ ] Focus order follows reading order; focus visible and not obscured by sticky bars (2.4.3, 2.4.7, 2.4.11); no keyboard traps.
- [ ] Modals move focus in, trap it, restore it to the trigger on close.
- [ ] Target size >= 24x24 CSS px (2.5.8); >= 44 pt iOS / 48 dp Android as platform guidance.
- [ ] Form fields have programmatic labels, errors are associated, announced and suggest a fix (3.3.1, 3.3.3); no re-entry of known data (3.3.7).
- [ ] Status changes (loading, success, error) announced via live region / accessibility announcement without stealing focus (4.1.3).
- [ ] Reduced motion honoured; nothing flashes more than 3 times per second; auto-moving content can be paused.
- [ ] Images: meaningful alt text; decorative ones hidden from assistive tech. Media has captions/transcripts.
- [ ] Authentication does not depend on a cognitive test alone (3.3.8).

## Platform mapping
| Need | Web | iOS | Android | Desktop (Electron / native) |
|------|-----|-----|---------|-----------------------------|
| Name / role | HTML semantics, ARIA only if needed | `accessibilityLabel`, traits | `contentDescription`, `Role` semantics | ARIA in renderer; UIA / NSAccessibility / AT-SPI for native |
| Screen reader | NVDA, JAWS, VoiceOver | VoiceOver | TalkBack | Narrator, VoiceOver, Orca |
| Text scale | rem units, zoom | Dynamic Type | `sp`, font scale | OS text scaling |
| Reduced motion | `prefers-reduced-motion` | `isReduceMotionEnabled` | animator duration scale | OS setting |

## Steps
1. Run automated checks in CI (axe, Accessibility Scanner, Xcode Accessibility Inspector, or equivalent).
2. Keyboard-only pass of each journey; then screen reader pass of the top journeys with the primary reader per platform.
3. Test 200% text, high contrast / dark theme, reduced motion.
4. Log findings; fix Blockers before release; track others.

## Output format
| # | Screen / component | WCAG SC | Platform | Severity | Evidence | Fix | Status |
|---|--------------------|---------|----------|----------|----------|-----|--------|
| 1 | `<name>` | 1.4.3 | <all> | Major | <screenshot, tool output> | <change> | open |

Severity: Blocker (journey impossible), Major (workaround hard), Minor. Link defects to `FEAT-NNN` and tests `TC-NNN`.

## References
`../_shared/standards/nfr-catalog.md` (Accessibility), `definition-of-done.md`, `production-readiness-review.md`, `project-tiers.md`; skill `component-design-system`; templates `component-spec.md`, `screen-spec.md`.

## Language notes
- React/Vue/Angular: prefer `<button>` over clickable `div`; `jest-axe` / `axe-core`. SwiftUI: `.accessibilityLabel`, `.accessibilityElement(children:)`. Compose: `Modifier.semantics`, `clearAndSetSemantics`. Flutter: `Semantics` widget. Electron: test with the OS reader, not only axe.
