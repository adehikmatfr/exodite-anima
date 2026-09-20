---
name: app-version-compatibility
description: Use when changing an API or payload consumed by a mobile app, deciding the supported app-version window, enforcing a minimum version or force update, using feature flags or remote config, or deprecating an endpoint or OS version.
---
# App Version Compatibility

## Purpose
Keep every app version inside the support window working against the live backend, and retire old versions deliberately instead of by accident.

## When to use
- Any backend or contract change (`API-`) that a shipped app calls.
- Adding a feature flag, remote config value or kill switch.
- Raising the minimum supported app version or OS version; sunsetting an endpoint.

## Principles
- Old versions live for months: assume 10-20% of users stay >= 3 releases behind and some never update. The server is the compatibility layer.
- Additive changes only within an API version; breaking change = new version plus deprecation window (`release-management.md`).
- Clients are tolerant readers: ignore unknown fields, map unknown enum values to a safe default, never crash on a missing optional field.
- Flags default to the safe (old) behaviour when config is unreachable.
- Forcing an update is a last resort: it locks out users and needs an approved reason.

## Steps / Checklist
1. **Define the window** in `context.md`: support the last N versions or M months, whichever is longer (typical: 4 releases or 6 months). Publish the policy in-app help and the developer docs.
2. **Measure:** dashboard of active users by app version (24 h, 7 d, 30 d). Review before every backend breaking change.
3. **Contract change review:** for each `API-NNN` change list the oldest app version affected, and confirm with this table:
   | Change | Safe for old apps? |
   |--------|--------------------|
   | New optional response field, new endpoint | yes |
   | New enum value | only if clients have a default branch (verify oldest version) |
   | Removed/renamed field, tighter validation, changed semantics | no: version it |
   | New required request field | no: server must default it |
4. **Version signalling:** app sends `X-App-Version`, platform, OS version, build number on every request. Server logs it, and may respond 426 or a structured `update_required` body.
5. **Minimum version enforcement:** server or remote config holds `min_supported` and `recommended`. Below `recommended`: dismissible prompt, max once per 3 days. Below `min_supported`: blocking screen with store link; use only for security fixes, data corruption or dropped API version. Requires notice >= 30 days when feasible (0 for active exploit), and owner approval recorded as ADR or ticket. Blocking screen must work offline-safe and never trap the user before they can export or sync unsent data.
6. **Flags and remote config:** typed, named `feature.<area>.<name>`, each with owner, default, removal date. Cache last known good value; fetch with timeout <= 3 s and never block startup. Kill switch for every risky new path. Remove a flag within 2 releases after 100% rollout. Server may target flags by app version so a new flag is not sent to versions lacking the code.
7. **Deprecation:** announce (changelog, in-app banner, partner note), monitor remaining traffic per old version, brown-out test (short planned 4xx) for stragglers, then remove. Do not remove while traffic from supported versions > 0.
8. **OS support drops:** follow `device-and-os-matrix-testing` threshold (<2% for two quarters); tell users in-app one release earlier; stores will stop offering updates automatically to unsupported devices.
9. **Local data:** each version must read data written by any supported older version, and newer data must not corrupt an older app after a downgrade or reinstall (`offline-and-sync` migrations).
10. **Tests:** contract tests against the oldest supported build (`TC-NNN`), staging environment with N-3 app builds, and a client fixture with unknown fields and enum values.

## Output format
Compatibility note in the `API-`/`FEAT-` change: oldest affected version, share of active users on it, chosen strategy (additive / new version / flag), enforcement or deprecation dates, rollback method.

Worked example: `API-NNN` v1 `status` gains value `on_hold`. App 4.8 crashes on unknown enums (7% of users). Ship 4.13 with default branch; server maps `on_hold` to `pending` for apps < 4.13 based on `X-App-Version`; remove mapping when 4.8 falls below 1%.

## References
`../_shared/standards/release-management.md`, `nfr-catalog.md`, `severity-and-incident.md`. IDs: `API-`, `FEAT-`, `ADR-`, `TC-`. Common skill: `api-integration-and-resilience`; see also `mobile-release-and-store-compliance` for force-update approval and hotfixes.

## Language notes
- Swift `Codable`: `init(from:)` with `@unknown default`. Kotlin: `kotlinx.serialization` `coerceInputValues = true`, `ignoreUnknownKeys = true`.
- RN/TypeScript: validate with a schema (zod) and fall back on parse failure. Flutter: `json_serializable` with `unknownEnumValue`.
