---
name: performance-budget-common
description: Use when setting or checking performance targets for a UI client, investigating slow startup, jank, large bundles or app size, or memory growth, or when a change may regress any of these.
---

# Performance Budget (common metrics)

## Purpose
Define measurable budgets for the metrics every UI client shares, measure them in CI and in the field, and fail changes that break them. Platform-specific metrics and tooling are added by the variants.

## When to use
- Starting a screen or app: set budgets in `context.md`.
- Adding a dependency, image, font, animation or list.
- Users report slowness, battery drain or crashes from memory pressure.

## Principles
- A budget is a number, a reference device/network and a percentile. "Fast" is not a budget.
- Measure on real, mid-range hardware and throttled networks; the developer laptop is not the user.
- Lab data (CI, deterministic) gates changes; field data (real user monitoring) confirms reality. Track p75 for experience metrics, p95 for latency.
- Budgets are enforced in CI as failing checks, with an explicit waiver path (owner, reason, expiry).
- Cheapest fix first: ship less (code, images, fonts), do less on the critical path, defer the rest.
- Never trade accessibility or correctness for a benchmark.

## Default budgets (tune in `context.md`; tier scales enforcement)
| Metric | Meaning | Default target |
|--------|---------|----------------|
| Startup / first render | launch or navigation to first meaningful content | cold <= 2.5 s (p75), warm <= 1 s on reference mid-range device, throttled network |
| Interaction latency | input to visible response | <= 100 ms p95 for taps/keys; <= 200 ms for navigation |
| Frame stability | rendering during scroll/animation | >= 95% frames at 60 fps (16 ms budget); no long task > 50 ms on main thread repeatedly |
| Bundle / app size | download size (compressed) | set per project: web initial JS <= 200 KB gzip; app package <= `<n>` MB; each new dependency > 20 KB needs justification |
| Memory | steady-state and growth | no monotonic growth over a 30-minute session; peak below `<n>` MB on the low-end reference device |
| Network payload | bytes per screen | first screen <= 500 KB; images resized and modern-format |
| Responsiveness under load | list of 1,000 items | virtualised; scroll stays within frame budget |

## Tier scaling
- T1: measure once per release on one reference device; keep size budget; fix obvious regressions.
- T2: budgets automated in CI, RUM dashboards, alert on p75 regression > 10% release over release.
- T3: plus per-release performance report, soak/memory test, evidence attached to the PRR (`production-readiness-review.md`).

## Checklist
- [ ] Reference devices and network profiles named in `context.md`.
- [ ] Budgets recorded per screen in `screen-spec.md` (optional for T1).
- [ ] Size analysis (bundle analyser, app thinning, APK analyzer) in CI with a threshold.
- [ ] Heavy work off the main/UI thread; lists virtualised; images lazy-loaded and sized.
- [ ] No unbounded caches, listeners or timers; teardown verified (`ui-state-management-review`).
- [ ] Animations use compositor-friendly properties and respect reduced motion.
- [ ] Telemetry overhead itself measured (`client-error-handling-and-telemetry`).

## Steps
1. Set or confirm budgets; capture a baseline for the reference device.
2. Profile the slowest journey; list top three costs.
3. Fix in order of user impact; re-measure; record before/after.
4. Add or tighten the CI guard so the gain persists.

## Output format
| Metric | Budget | Baseline | After | Device / network | Verdict |
|--------|--------|----------|-------|------------------|---------|
| Cold start | 2.5 s p75 | 3.1 s | 2.2 s | mid-range, 4G throttled | pass |

## References
`../_shared/standards/nfr-catalog.md` (Latency, Compatibility), `project-tiers.md`, `definition-of-done.md`, `production-readiness-review.md`, `cost-awareness.md`; skills `ui-state-management-review`, `ui-testing-strategy`; IDs `FEAT-NNN`, `TC-NNN`, `SLO-NNN`.

## Language notes
- Web: Lighthouse CI, Core Web Vitals, `size-limit`. iOS: Instruments, MetricKit. Android: Macrobenchmark, Baseline Profiles. Flutter: DevTools timeline, `--analyze-size`. Electron: measure main and renderer separately; startup cost of the runtime counts.
