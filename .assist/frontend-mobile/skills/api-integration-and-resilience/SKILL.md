---
name: api-integration-and-resilience
description: Use when a UI calls an API, adds retries, offline support, optimistic updates or pagination, or maps server errors to user messages, or when users report hangs, duplicate submissions or lost data on poor networks.
---

# API Integration and Resilience

## Purpose
Consume `API-` contracts through one typed, observable client layer that behaves predictably on slow, flaky and offline networks.

## When to use
- Adding or changing any remote call; wiring a new screen's data needs.
- Adding offline mode, background sync, optimistic UI, upload/download.
- Reviewing how errors reach the user.

## Principles
- One client layer per app: base URL, auth header, timeouts, retry policy, error mapping, correlation ID in one place. Screens never call raw `fetch`/HTTP.
- The contract is the source of truth: generate types from the schema where possible; unknown enum values and extra fields must not crash the client (tolerant reader).
- Every call has a timeout (default 10 s interactive, 30 s upload/large; never infinite) and is cancellable on navigation away.
- Retry only what is safe: GET and idempotent writes. Non-idempotent writes send an `Idempotency-Key` (UUID generated once per user intent, reused on retry). Backoff exponential with jitter, max 3 attempts, honour `Retry-After`. Never retry 4xx except 408/429.
- Prevent double submits: disable the control while in flight and rely on the idempotency key for the rest.
- Optimistic UI only for low-risk, easily reversible actions; always define rollback and a visible failure message. Never optimistic for payments or irreversible actions.
- Offline: define per screen whether it is readable (cached), writable (queued with visible "pending" state) or blocked (clear message). Queued writes are ordered, idempotent and expire.
- Server error envelope `{code, message, details[], correlation_id}` is mapped by `code` to a localised message key and an action; never show server `message` or stack text raw.

## Checklist
- [ ] Contract `API-NNN` referenced; gaps raised to backend, not patched client-side.
- [ ] Timeout, cancellation, retry policy, and idempotency key per call recorded.
- [ ] 401 triggers one refresh attempt then sign-out flow; concurrent 401s share a single refresh.
- [ ] 403, 404, 409, 422, 429, 5xx, network failure and timeout each map to a distinct user action.
- [ ] Pagination uses cursors from the API; list handles empty, end-of-list, and page-load error separately.
- [ ] Payloads sized for mobile networks: field selection, compression, image variants.
- [ ] Correlation ID from the response is attached to error reports and offered to the user for support.
- [ ] Contract tests or mocks generated from the schema; tests cover error and offline paths.

## Steps
1. List the calls a screen needs (`screen-spec.md` section 4) with contract IDs.
2. Fill the resilience table below; decide offline behaviour.
3. Implement in the client layer; consume through the state layer (`ui-state-management-review`).
4. Simulate slow 3G, packet loss, offline, 5xx and expired token; verify UI states.

## Output format
| Call | Contract | Timeout | Retry | Idempotency | Offline behaviour | Error mapping |
|------|----------|---------|-------|-------------|-------------------|---------------|
| Create order | `API-NNN` | 15 s | 3x, jitter | key per submit | queue, show "pending" | `ORDER_EXISTS` -> open existing; `RATE_LIMITED` -> wait, retry |

## References
`../_shared/standards/reliability-patterns.md`, `nfr-catalog.md`, `security-baseline.md`; backend skills `error-handling-standard`, `idempotency-and-retry`, `api-contract-and-versioning`; IDs `API-NNN`, `FEAT-NNN`, `TC-NNN`; skills `client-error-handling-and-telemetry`.

## Language notes
- Web: `fetch` + `AbortController`, service worker for offline. Android: OkHttp interceptors, WorkManager. iOS: `URLSession` with `URLSessionConfiguration.timeoutInterval`, background sessions. Flutter: `dio` interceptors. Electron: do network in main process only if secrets or certificates require it.
