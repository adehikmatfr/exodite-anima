---
name: ui-state-management-review
description: Use when adding or reviewing state handling in a UI, including new stores, caches, forms or navigation state, or when symptoms include stale data, flicker, double fetches, re-render storms, lost input or inconsistent screens.
---

# UI State Management Review

## Purpose
Ensure every piece of state has one owner, a defined lifetime and a predictable update path, so screens stay consistent and cheap to render.

## When to use
- Introducing a store, cache, context, view model or form model.
- Debugging stale or inconsistent UI, race conditions, excess re-renders/recompositions.
- Reviewing a PR that adds "just one more" global variable.

## Principles
- Classify state before choosing a tool: (1) server cache, (2) UI/view state (selection, open panels), (3) form draft, (4) navigation/route state, (5) durable client state (settings, offline queue), (6) ephemeral local (hover, animation).
- Keep state as local as possible; lift only when two siblings need it. Never mirror server data into a second store; cache with keys, staleness times and invalidation instead.
- Derive, do not store: anything computable from other state is a selector/computed value.
- Updates flow one way (event -> reducer/handler -> state -> view). Side effects (network, storage, timers) live in one place and are cancellable.
- Model async state explicitly as `idle | loading | success(data) | error(cause)`; impossible combinations (loading and error) are unrepresentable.
- Navigation state is in the URL/route where the platform supports it, so screens are restorable and deep-linkable.
- Persisted state is versioned and migrated; never persist tokens or personal data in plain storage (`frontend-security`).

## Checklist
- [ ] Each state item listed with owner, lifetime, source of truth.
- [ ] No duplicated copies of the same server entity; invalidation rule stated for each cache key.
- [ ] Concurrent requests: last-write-wins guarded by cancellation or request ids; stale responses ignored.
- [ ] Optimistic updates have rollback and conflict handling (`api-integration-and-resilience`).
- [ ] Form drafts survive rotation/resize/backgrounding and are cleared on submit or logout.
- [ ] Logout and account switch clear all user-scoped state, caches and persisted stores.
- [ ] Subscriptions, listeners and timers are released on teardown (leak check in `performance-budget-common`).
- [ ] Render scope: a keystroke or scroll tick re-renders only the affected subtree (measure, do not guess).
- [ ] State transitions covered by unit tests; complex flows by a state chart.

## Steps
1. Inventory the state touched by the change; classify each item.
2. Assign the simplest owner; delete duplicates and derived copies.
3. Draw the async state machine for each remote resource (including cancel and retry).
4. Profile a representative interaction; fix hot paths only if over budget.
5. Add tests for transitions and for logout cleanup.

## Output format
| State | Class | Owner | Lifetime | Persisted | Invalidation / reset |
|-------|-------|-------|----------|-----------|----------------------|
| `orders` | server cache | `<query key>` | 60 s stale | no | on `order.created`, on logout |
| `draft` | form draft | screen | until submit | secure storage? no | on submit, on logout |

Mini-example: a badge count and a list both fetch `/notifications`. Fix: one cached query; badge selects `unreadCount` from it; marking read updates that cache entry optimistically.

## References
`../_shared/standards/definition-of-done.md`, `nfr-catalog.md`; skills `api-integration-and-resilience`, `performance-budget-common`, `frontend-security`; IDs `FEAT-NNN`, `API-NNN`, `TC-NNN`.

## Language notes
- React: server cache library (TanStack Query, SWR) plus local state; Redux/Zustand for genuine client state. Vue: Pinia. Angular: signals/NgRx. SwiftUI: `@State`, `@Observable`. Compose: `ViewModel` + `StateFlow`. Flutter: Riverpod/Bloc. Electron: main-process state behind typed IPC, renderer holds a projection only.
