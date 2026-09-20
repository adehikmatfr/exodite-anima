---
name: mobile-performance-and-battery
description: Use when a mobile app is slow to start, janky, memory-hungry, too large, or drains battery or data, or when setting performance budgets and reviewing background work for a release.
---
# Mobile Performance and Battery

## Purpose
Keep the app fast, small and light on battery on the worst supported device, and prevent regressions with budgets enforced in CI and monitored in the field.

## When to use
- Defining budgets for a new app or `FEAT-`.
- Startup, scroll, memory, size or battery complaints; store vitals warnings.
- Adding background work, push handling, location, sockets or a large SDK.

## Principles
- Measure on the low-end reference device from `context.md`, release build, not debug, not the developer phone.
- Budgets before code; regressions fail the build. Field data (p50/p90/p99) beats lab data.
- The cheapest work is work not done: defer, batch, cache, cancel.
- The OS decides background time; design for being killed and for being throttled (`performance-budget-common` for the cross-platform principles).

## Steps / Checklist
1. **Budgets** (defaults; tune per product, record as `SLO-NNN`):
   | Metric | Budget (low-end device) |
   |--------|-------------------------|
   | Cold start to first interactive frame | p90 <= 2.0 s (<= 1.2 s on flagship) |
   | Warm start | p90 <= 0.8 s |
   | Frame rate | >= 95% frames under 16.7 ms (60 Hz); slow frames < 5%, frozen frames (> 700 ms) < 0.1% |
   | Screen transition to content | p90 <= 500 ms from local data |
   | Memory (foreground steady) | <= 250 MB on 3 GB devices; no growth > 10% over a 30-min soak |
   | Download size | <= 50 MB store download (Android AAB / iOS thinned), track delta per release; alert on +5% |
   | Network per session | <= 2 MB typical; images resized to display size, WebP/AVIF/HEIC |
   | Battery | < 2% per hour foreground active use; no wake lock > 60 s |
   | Crash-free sessions / ANR | >= 99.5% / < 0.47% |
2. **Startup:** initialise only what the first screen needs; lazy-load SDKs; no network call before first frame; use baseline/startup profiles (Android), avoid heavy `+load`/static init (iOS); measure with Instruments App Launch, Macrobenchmark.
3. **Rendering:** no work on main thread over 8 ms; virtualised lists with stable keys and item recycling; avoid overdraw and unbounded recomposition/re-render; images decoded off-thread and downsampled.
4. **Memory:** profile for leaks (LeakCanary, Instruments Leaks); bound caches by bytes; release on memory warning / `onTrimMemory`; test on 2-3 GB device.
5. **Size:** R8/ProGuard shrink and resource shrinking, app thinning, remove unused SDKs and ABIs, compress assets, on-demand delivery for rarely used features. Track SDK cost in KB.
6. **Network:** HTTP/2, compression, ETag/If-None-Match, pagination, batching, request coalescing, cancel on screen exit; avoid polling (use push or long-interval sync with backoff).
7. **Background limits:** iOS background tasks get about 30 s; Android Doze, App Standby buckets and background-start restrictions apply. Use `BGTaskScheduler` / WorkManager with constraints (unmetered, charging when large); foreground services need user-visible justification; location updates batched, lowest accuracy that works; no sticky sockets while backgrounded.
8. **Battery diagnosis:** Xcode Energy gauge / MetricKit, Android Battery Historian and vitals (excessive wakeups, stuck wake locks). Compare 1-hour idle-background drain before and after.
9. **CI gates:** startup benchmark, size diff, and slow-frame test on every release candidate; block on breach unless waived with owner and date.
10. **Field monitoring:** report startup, slow frames, ANR, memory warnings via performance tool; dashboard by app version and device tier; alert on p90 regression > 15%.

## Output format
Performance report: metric | budget | measured (device, build) | delta vs previous release | pass/fail | fix ticket. Regression note with cause, trace link, and fix.

Worked example: cold start p90 rose 1.8 s to 2.6 s after adding analytics SDK; trace shows 700 ms sync init on main thread; move to lazy background init, p90 back to 1.9 s.

## References
`../_shared/standards/nfr-catalog.md`, `slo-sli-template.md`, `cost-awareness.md`, `production-readiness-review.md`. IDs: `SLO-`, `FEAT-`, `TC-`. Common skills: `performance-budget-common`, `client-error-handling-and-telemetry`.

## Language notes
- SwiftUI: avoid heavy `body`, use `Equatable` views, `LazyVStack`. Compose: stable params, `remember`, `derivedStateOf`, `LazyColumn` keys.
- React Native: Hermes, `FlatList` tuning, avoid bridge chatter, new architecture. Flutter: `const` widgets, `ListView.builder`, profile mode for measurement.
