# Glossary

Single source of truth for domain terms used by more than one role.

| Term | Definition | Owner role | Related IDs |
|------|------------|-----------|-------------|
| Journal | All entries of one user on one device. Exists only on that device. | product-manager | FEAT-001 |
| Entry | One journal record: text and a date the user can change. Media (photo, audio) is out of scope for v1. | product-manager | FEAT-001 |
| Draft | Unsaved text of an entry being written, kept safely so an interruption does not lose it. | product-manager | FEAT-001 |
| Timeline | The main list of entries, newest first, grouped by day. | product-manager | FEAT-002 |
| Lock | The state in which no journal content is visible until the user proves it is them. | product-manager | FEAT-003 |
| Auto-lock | Locking again after the app has been in the background for a chosen time. | product-manager | FEAT-003 |
| Passcode | The secret the user chooses at setup. It opens the journal when biometrics are unavailable. It can never be recovered. | product-manager | FEAT-004, ADR-001 |
| Biometrics | Face or fingerprint recognition provided by the phone, used as a convenient way to unlock. | product-manager | FEAT-003, FEAT-004 |
| No-recovery rule | The product rule that a forgotten passcode cannot be reset or recovered by anyone, because no one else holds the data. | product-manager | FEAT-004, ADR-001 |
| Data key | The secret key that protects all stored journal content on the device. Never leaves the device. | software-architect | ADR-001 |
| Export | Creating one file that contains the whole journal, for backup or moving to another device. | product-manager | FEAT-006 |
| Encrypted export | An export protected by an export password. This is the default. | product-manager | FEAT-006, ADR-003 |
| Plaintext export | An export anyone can read, offered only after an explicit warning. | product-manager | FEAT-006, ADR-003 |
| Export password | A password chosen at export time. It is separate from the passcode and protects only the export file. | product-manager | FEAT-006, ADR-003 |
| Import | Restoring a journal from an export file, on the same or a new device. | product-manager | FEAT-007 |
| Last export | The date and time of the most recent successful export, shown so the user knows how safe the backup is. | product-manager | FEAT-008 |
| Export reminder | An in-app prompt asking the user to export when no recent backup exists. It never shows entry content. | product-manager | FEAT-008 |
| Schema version | The version number of how data is stored inside the app. Every stored format carries one. | software-architect | ADR-002, ADR-003 |
| Format version | The version number of the export file layout. Every past version must stay importable. | software-architect | ADR-003 |
| Side-channel leak | Content escaping through a path other than the app screen: cloud backup, app-switcher preview, screenshots, notifications, clipboard, logs. | cyber-security | THR-001..013 |
| Design token | A named design value (colour, font, spacing, radius) used instead of a raw number or hex code. | product-design | none yet |
| Wait after wrong tries | The delay imposed after wrong passcodes: five are free, then 30 seconds that doubles up to one hour. It continues after the app is closed. | product-manager | FEAT-003 |
| Language setting | The choice of interface language: follow the phone (default), English, or Indonesian. | product-manager | FEAT-009 |
