# Reliability Patterns

Principles for any language or stack.

- **Timeouts everywhere.** Every network, DB, or queue call has an explicit timeout shorter than its caller's.
- **Retries with backoff and jitter**, only for idempotent or idempotency-keyed operations; cap attempts and total time; never retry validation (4xx) errors.
- **Idempotency.** Any create, pay, or dispatch operation accepts an idempotency key or is naturally idempotent. Consumers of at-least-once messages deduplicate.
- **Circuit breaker and bulkheads.** Stop hammering a failing dependency; isolate resource pools per dependency.
- **Backpressure and limits.** Rate limits, queue bounds, max payload sizes, connection pool caps. Shed load rather than collapse.
- **Graceful degradation.** Define what still works when a dependency is down; use fallbacks and cached data deliberately.
- **Graceful shutdown.** Stop accepting work, drain in-flight requests, flush buffers, then exit within the orchestrator's grace period.
- **Health checks.** Separate liveness (process ok) from readiness (can serve traffic); readiness reflects critical dependencies.
- **Outbox / transactional messaging.** Persist state and outgoing events atomically; publish asynchronously; dead-letter with alerting and replay tooling.
- **Consistency choices are explicit.** Document where eventual consistency is accepted; use sagas or compensation instead of distributed transactions.
- **Safe change.** Backward-compatible schema and API changes (expand, migrate, contract); feature flags for risky logic.
- **Test failure.** Fault injection and chaos experiments for critical paths before launch.
