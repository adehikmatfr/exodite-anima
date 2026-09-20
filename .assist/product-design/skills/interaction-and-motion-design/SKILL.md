---
name: interaction-and-motion-design
description: Use when designing transitions, animations, micro-interactions, loading feedback or gestures, or when motion causes performance, distraction or vestibular-comfort concerns.
---
# Interaction and Motion Design

## Purpose
Use motion only where it explains change, gives feedback or guides attention, and specify it so it is fast, accessible and cheap to render.

## When to use
- Specifying transitions between states or screens, or micro-interactions.
- Designing loading, progress or success feedback.
- Reviewing animation for reduced-motion support or performance.

## Principles
1. Every animation has a purpose: orient (where did it go), confirm (it worked), relate (what changed), or focus (look here). Decoration alone is cut.
2. Duration by distance and size: micro feedback 100-150 ms, standard UI transitions 150-300 ms, large or full-screen 300-400 ms at most; exits shorter than entrances.
3. Easing: decelerate (ease-out) for entering, accelerate (ease-in) for leaving, standard ease-in-out for moving on screen; avoid linear except for progress and loops. Define as tokens (`motion.duration.short`, `motion.easing.standard`).
4. Feedback timing: acknowledge input within 100 ms; show a spinner or skeleton if work exceeds about 1 s; show determinate progress above about 10 s.
5. Reduced motion is a first-class design: honour the OS setting by replacing movement with fades or instant changes.
6. Never flash more than 3 times per second; no auto-playing motion longer than 5 s without a pause control.

## Steps / Checklist
1. State the purpose of each animation in one line; drop those without one.
2. Pick duration and easing from tokens; no per-screen custom curves.
3. Specify property animated: prefer transform and opacity (compositor-friendly); avoid animating layout properties (width, height, top) and large blur or shadow.
4. Specify the reduced-motion alternative for each: parallax and slides become fades or none; looping animation stops or becomes static; spinners may remain.
5. Define interruptibility: a running animation can be cancelled or reversed by new input without jank.
6. Gestures: every gesture (swipe, long-press, pinch) has a visible or button alternative and a keyboard path.
7. Loading patterns: skeletons for content areas, inline spinners for buttons (keep button width), optimistic updates with rollback message on failure.
8. Performance budget: keep frames at 60 fps target on the lowest supported device; no more than a few simultaneous animated elements; check with frontend on cost.
9. Focus and announcements: motion must not move focus unexpectedly; state changes are also announced to assistive tech.

## Output format
Motion table in the spec:

| Element | Trigger | Property | Duration | Easing | Reduced-motion alternative |
|---------|---------|----------|----------|--------|----------------------------|
| Dialog | open | opacity, scale 0.98 to 1 | 200 ms | ease-out | opacity only, 100 ms |

## References
- Common skills `inclusive-and-accessible-design`, `design-handoff-and-design-qa`
- `design-token-authoring` (motion tokens); frontend `accessibility-audit`, frontend-web `web-performance-budget`
- `_shared/standards/nfr-catalog.md`
- IDs: `FEAT-NNN`, `TC-NNN`

## Language notes
Web: `prefers-reduced-motion`, Web Animations API, CSS transitions. iOS: `UIAccessibility.isReduceMotionEnabled`. Android: animator duration scale. Prototypes: use smart-animate with the same token values.
