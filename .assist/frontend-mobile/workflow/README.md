# .assist/workflow

As-built workflow docs: one file per domain flow or external integration. Written/updated **after** a decision is made, confirmed, or changed — not before the work.

## Naming

`.assist/workflow/<domain>-<flow>.md` (kebab-case).

## Current docs

- `mobile-build-and-release.md`: how the app is built, checked, and released today
- `release-signing.md`: the release key, how the build uses it, and how an APK is published on GitHub

## Suggested doc structure

1. Overview
2. Trigger / entry points
3. Step-by-step flow
4. Statuses and data model
5. External calls and events
6. Decisions and gotchas
