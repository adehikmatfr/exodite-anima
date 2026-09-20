# Information Architecture and Navigation (version 1)

Status: draft, based on the flows in `user-flows.md`. No user evidence yet (RS-001).

## Why no card sort or tree test
The app has about 13 screens and 3 top-level areas, far below the "growth past about 7 top-level items" trigger in the skill, and structure is not where the doubt lies. Card sorting and tree testing need 15 to 50 or more participants and would not answer the real questions. Vocabulary and the move-phone flow are tested in RS-001 instead.

## Content and function inventory
| ID | Screen or function | Feature | Keep / merge / retire |
|----|--------------------|---------|-----------------------|
| S1 to S4 | First-run: Welcome, Create passcode, Biometrics, No-recovery warning | FEAT-004 | keep |
| S5 | Lock screen | FEAT-003 | keep |
| S6 | Timeline (with reminder banner, empty state) | FEAT-002, FEAT-008 | keep |
| S7 | Editor (with delete confirmation) | FEAT-001 | keep |
| S8 | Search | FEAT-005 | keep |
| S9 | Settings | FEAT-009 | keep |
| S10 | Change passcode | FEAT-009 | keep |
| S11 | Export | FEAT-006 | keep |
| S12 | Import | FEAT-007 | keep |
| S13 | About and privacy | FEAT-009 | keep |

## Sitemap
```
Entry states (not places): First run (S1-S4) | Lock (S5)

Timeline (hub)
├── Write / edit an entry (Editor)
├── Search
└── Settings
    ├── Appearance (theme)
    ├── Security: Change passcode, Biometrics, Lock timeout
    ├── Backup: Export, Import, Last export
    └── About and privacy
```

## Navigation model
Hub and spoke, with the timeline as the hub. There is no tab bar: only three destinations exist (write, find, settings), and each is reached from the timeline in one step. The primary action ("New entry") is reachable with one thumb at the bottom. Settings is reached from the top of the timeline. Back always returns to the previous place, and a draft is never lost on the way (F3).

## Labels
Rule: nouns for places, verbs for actions, words from the glossary (`../_shared/glossary.md`), no jargon.

| Label | Type | Glossary term | Synonyms users might use | Note |
|-------|------|---------------|--------------------------|------|
| Journal | place | Journal | diary, notes | Timeline title |
| New entry | action | Entry | write, add, new note | |
| Search your entries | action | Entry | find | |
| Settings | place | none | preferences, options | |
| Export | action | Export | back up, save a copy, download | **Unsettled**, see below |
| Import / Restore from a backup | action | Import | restore, load, recover | **Unsettled**, see below |
| Passcode | thing | Passcode | password, PIN, code | The product uses "passcode" for the app unlock and "export password" for the file; users may blur them |
| Export password | thing | Export password | password, key | Must not read as the same as the passcode |
| Delete entry | action | Entry | remove | Sheet says it cannot be undone |

## Vocabulary decision needed
The screens drawn so far mix "backup" (Welcome: "Restore from a backup"; reminder: "no backup yet") with "Export" and "Import" (Settings). The glossary uses "Export" and "Import". Users likely think "back up" and "restore", but that is an assumption. Options:

| Option | For | Against |
|--------|-----|---------|
| A. "Back up" and "Restore" in the interface, "export/import" only in technical notes | Closest to common phone wording (assumed) | Differs from the glossary and specs; glossary must change |
| B. "Export" and "Import" everywhere | Matches glossary and specs | "Export" may not signal "safety copy" to some users |
| C. "Back up (export)" and "Restore (import)" together | Bridges both | Longer labels |

Not decided. Test the words in RS-001 (question Q2), then decide with product-design and the owner.

## Findability targets
Not set: tree-test targets in the skill do not apply to a structure this small. Task success for the key tasks is measured in RS-001.
