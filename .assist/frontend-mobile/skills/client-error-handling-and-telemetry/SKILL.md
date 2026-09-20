---
name: client-error-handling-and-telemetry
description: Use when adding error boundaries, crash reporting, analytics or performance telemetry to a client, deciding what may be logged, handling user consent, or diagnosing a production client issue from reports.
---

# Client Error Handling and Telemetry

## Purpose
Make client failures visible to the team and recoverable for the user, while collecting the minimum data, with consent, and never personal data or secrets.

## When to use
- New screen or flow needs failure containment and analytics.
- Choosing or configuring a crash, analytics or RUM tool.
- Reviewing a log or event payload for privacy.
- Triaging a spike in client errors.

## Principles
- Contain failures at boundaries: a broken widget must not blank the app. Each screen or region has a fallback UI with a retry and a way out.
- Distinguish expected errors (validation, offline, 4xx: handled in UI, counted, not alerted) from unexpected ones (exceptions, render crashes: reported with stack).
- Every report carries build/version, platform/OS version, screen/route, correlation ID of the last failed request, and an anonymous session ID. Nothing else identifying.
- Scrub before send, not after: an allow-list of event properties beats a deny-list. Strip query strings, form values, tokens, emails, phone numbers, IDs of people, and free-text fields from breadcrumbs, URLs and stack context.
- Consent gates non-essential telemetry (analytics, session replay, advertising IDs). Crash reporting without personal data may be legitimate interest; record the decision in `data-governance.md` terms and honour opt-out. Session replay of sensitive screens is off by default and masks all inputs.
- Symbolication artefacts (source maps, dSYM, ProGuard mappings) are uploaded to the tool and never shipped publicly.
- Telemetry must not degrade UX: batched, size-capped, sampled, dropped offline after a bound, off the main thread.

## Checklist
- [ ] Error boundary / global handler installed per screen or region; unhandled promise and async errors captured.
- [ ] Fallback UI has safe text, retry, and support reference (correlation ID); no stack trace shown.
- [ ] Event catalogue exists: name, trigger, allowed properties, owner, consent class. No event without an entry.
- [ ] Naming convention `object_action` (`order_submitted`); no dynamic event names.
- [ ] Scrubbing tested with a fixture that contains fake emails, tokens and card numbers.
- [ ] Consent state stored, respected on next launch, revocable, and defaults to off where the law requires.
- [ ] Sampling and rate limits set (for example errors 100%, performance 10%, dedupe repeated errors).
- [ ] Alerts: crash-free sessions/users below target (default 99.5% T2, per `slo-sli-template.md`), new-error-in-release, error-rate spike.
- [ ] Release health per version enables staged-rollout halt (`release-management.md`).

## Steps
1. Define failure regions and fallback per screen (`screen-spec.md`).
2. Add events from the spec; write catalogue entries; classify consent.
3. Wire the scrubber and assert it in tests.
4. Verify in a pre-production build: force a crash, an API error and offline; check the report content by eye.

## Output format
Event catalogue rows: `Event | Trigger | Properties (allow-list) | Consent | Owner | Retention`. Incident triage note: `Release | Error group | Users affected % | Correlation ID sample | Suspected cause | Action`.

## References
`../_shared/standards/data-governance.md`, `security-baseline.md`, `slo-sli-template.md`, `release-management.md`, `nfr-catalog.md`; skills `api-integration-and-resilience`, `frontend-security`; IDs `THR-NNN`, `RB-NNN`, `FEAT-NNN`.

## Language notes
- React: `ErrorBoundary` + `window.onerror`. Vue: `app.config.errorHandler`. Angular: `ErrorHandler`. SwiftUI/iOS: signal handlers via crash SDK, MetricKit. Android: `Thread.setDefaultUncaughtExceptionHandler` via SDK. Flutter: `FlutterError.onError`, `runZonedGuarded`. Electron: capture renderer and main separately.
