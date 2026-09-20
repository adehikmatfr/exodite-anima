---
name: offline-and-sync
description: Use when designing or reviewing local storage, offline reads and writes, queued requests, conflict resolution, sync status UX or local schema migrations in a mobile app.
---
# Offline and Sync

## Purpose
Make the app useful with no, slow or flaky connectivity, and guarantee that queued user actions are applied exactly once, in a defined order, without silent data loss.

## When to use
- A feature reads or writes data that the user expects to work in a lift, on a train or in airplane mode.
- Adding or changing a local table, cache, queue or sync endpoint.
- Reviewing a data-loss or duplicate-submission bug.

## Principles
- Local store is the source for the UI; network refreshes it. Screens never block on the network to render known data.
- Classify each entity: **server-authoritative** (balances, stock: read-only offline, show staleness), **user-authoritative** (drafts, notes: local wins), **mergeable** (lists, counters: merge rules).
- Money-moving or irreversible actions are not queued blindly: require online confirmation or a server-side pending state.
- Every queued write carries an idempotency key generated at creation, stable across retries and app restarts.
- Restricted data at rest is encrypted; wipe on logout (`data-governance.md`).

## Steps / Checklist
1. **Inventory data:** per entity list class, size, retention, sensitivity. Cap local size (e.g. 100 MB, oldest-first eviction for caches, never for unsent writes).
2. **Storage choice:** structured relational data in SQLite/Room/Core Data; small key-values in the platform store; secrets only in Keychain/Keystore.
3. **Write path:** user action -> local commit + outbox row (`id`, `idempotency_key`, `payload`, `created_at`, `attempts`, `status`) in one transaction -> UI updates optimistically.
4. **Outbox worker:** runs on connectivity regain and on OS-scheduled background task; FIFO per aggregate, parallel across aggregates; exponential backoff 2 s to 5 min with jitter; max 10 attempts, then `failed` state surfaced to the user (never silent drop). 4xx (non-retryable) moves to `failed` immediately; 5xx/timeouts retry. Server must dedupe on `Idempotency-Key` (see `API-` entry; agree with backend).
5. **Read path:** delta sync with server cursor/`updated_since`; tombstones for deletes; full resync fallback when cursor is invalid.
6. **Conflicts:** pick per entity: last-write-wins with server timestamp (low value data), field-level merge (profiles), version/ETag check with user-prompt (documents). Log conflict count as a metric.
7. **Sync status UX:** show per item `synced / pending / failed`; global banner when offline; timestamp "Updated 5 min ago"; retry and discard actions for failed items; never show a success toast before durable local commit.
8. **Migrations:** numbered, forward-only, tested from every supported previous schema (support window in `app-version-compatibility`). Big rewrites run in background, resumable. Keep a pre-migration backup for one release. Failure path: rebuild cache from server, but never drop the outbox.
9. **Tests:** airplane mode, kill app mid-sync, duplicate delivery, clock skew +/- 10 min, 10,000-row initial sync, migration from oldest supported schema (`device-and-os-matrix-testing`, `TC-`).

## Output format
Sync design note per feature: entity table (class, conflict rule, retention), outbox schema, retry policy numbers, status UX states, migration plan, `TC-NNN` list.

Worked example: "Create expense" offline. Local insert + outbox key `k-9f2`; server receives twice due to timeout, dedupes on `k-9f2`; UI shows Pending then Synced; if the server returns 422, item flips to Failed with edit action.

## References
`../_shared/standards/reliability-patterns.md` (idempotency, retry), `data-governance.md`, `nfr-catalog.md`. IDs: `FEAT-`, `API-`, `TC-`, `DS-`. Common skill: `api-integration-and-resilience`, `ui-state-management-review`.

## Language notes
- Swift: Core Data or GRDB, `BGTaskScheduler`. Kotlin: Room + WorkManager (`setRequiredNetworkType(CONNECTED)`, unique work per aggregate).
- React Native: WatermelonDB/SQLite, not AsyncStorage for large data. Flutter: Drift + workmanager.
