# .assist/workflow

As-built workflow docs: one file per domain flow or external integration. Written/updated **after** a decision is made, confirmed, or changed — not before the work.

## Naming

`.assist/workflow/<domain>-<flow>.md` (kebab-case).

## Current docs

- `encryption-and-unlock-flow.md`: key creation, unlock, passcode change (built and tested on Android)
- `export-import-flow.md`: export and import of the journal (built and tested on Android)

## Suggested doc structure

1. Overview
2. Trigger / entry points
3. Step-by-step flow
4. Statuses and data model
5. External calls and events
6. Decisions and gotchas
