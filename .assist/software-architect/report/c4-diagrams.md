# C4 Diagrams

Method: skill `c4-diagramming`. Diagrams are Mermaid text, so they diff and live with the repo. Names follow `_shared/glossary.md`. Status: draft, version 1, 2026-09-20. Related: ADR-001 to ADR-005, THR-001 to THR-013.

Legend: dashed border = external to the app (owned by the OS or a store); solid = owned by the project. Trust boundaries are shown as subgraphs.

## Level 1: System context
Question: who and what does the app touch? Scope: production build. No technology is shown.

```mermaid
flowchart LR
  user([Journal writer])
  nearby([Another person near the phone])
  app[exodite-anima: private journal on the phone]
  os[[Phone operating system services: secure key store, biometrics, file and share dialogs]]
  store[[App stores: distribution and review]]
  dest[[Place the user saves an export: files, messaging, cloud folder]]

  user -->|writes, reads, searches, locks and unlocks| app
  nearby -.->|tries to read: blocked by the lock, THR-001| app
  app -->|asks for keys and biometric checks| os
  app -->|hands over one export file, user picks the place| dest
  store -->|delivers releases| app
```

Notes: there is no server, account, or analytics endpoint. The app sends nothing anywhere by itself; the only outward path is the export file the user chooses to save (ADR-005).

## Level 2: Containers
Question: what runs on the phone, and where does data live? Trust boundary: everything inside "The phone" is on the user's device; the export destination is outside the app's control.

```mermaid
flowchart TB
  subgraph phone[The phone]
    subgraph appbox[exodite-anima app process]
      ui[User interface: screens, theme, screen-reader support - Flutter]
      domain[Journal logic: entries, search, lock, export and import rules - Dart]
    end
    db[(Encrypted journal database: entries and search index - drift with SQLite3MultipleCiphers)]
    media[(Encrypted media files: reserved for photos and audio in v1.1 and later)]
    keys[[OS key store: holds the data key - Keychain or Keystore]]
  end
  dest[[Export destination chosen by the user]]

  ui -->|calls, in process| domain
  domain -->|reads and writes entries, in process| db
  domain -->|reads and writes files, in process| media
  domain -->|gets the data key after biometrics or passcode| keys
  domain -->|writes one export file through the share or save dialog| dest
```

Every arrow within the phone is a direct in-process or local call. There are no network arrows, which ADR-005 turns into a build-checked property.

## Level 3: Components of the app process
Question: what are the main building blocks inside the app, and who may talk to whom? Shown because the app holds all the logic and the security-sensitive parts must stay small and separate.

```mermaid
flowchart TB
  subgraph ui[User interface]
    screens[Screens and navigation]
    theme[Theme from design tokens]
  end
  subgraph domain[Journal logic]
    lock[Lock and unlock: auto-lock, wait after wrong tries]
    entries[Entry service: save, edit, delete, drafts]
    search[Search service]
    exporter[Export service: builds the archive]
    importer[Import service: validates, upgrades, applies all-or-nothing]
    remind[Export reminder rules]
  end
  subgraph data[Data and crypto]
    repo[Journal repository: schema versions and migrations]
    crypto[Crypto service: vetted library only, key wrapping, export encryption]
    keystore[Key store adapter]
    files[File adapter: share and save dialog]
  end

  screens --> lock
  screens --> entries
  screens --> search
  screens --> exporter
  screens --> importer
  screens --> remind
  lock --> crypto
  lock --> keystore
  entries --> repo
  search --> repo
  exporter --> repo
  exporter --> crypto
  exporter --> files
  importer --> files
  importer --> crypto
  importer --> repo
  remind --> repo
  crypto --> keystore
```

Rules this view enforces: only the crypto service handles keys or ciphers (no custom cryptography); only the file adapter touches the outside world; no component depends on a network library.

## Dynamic view: unlock (FEAT-003, ADR-001)
```mermaid
sequenceDiagram
  actor U as Journal writer
  participant UI as User interface
  participant L as Lock service
  participant K as OS key store
  participant DB as Encrypted database
  U->>UI: opens the app
  UI->>L: request unlock
  L->>K: ask for the data key, biometric check
  alt biometric succeeds
    K-->>L: data key
  else biometric cancelled or failed
    L->>U: ask for the passcode
    U->>L: passcode
    L->>L: derive the wrapping key, unwrap the data key
    Note over L: wrong passcode: wait grows before the next try
  end
  L->>DB: open with the data key
  DB-->>UI: timeline data
```

## Dynamic view: export (FEAT-006, ADR-003)
```mermaid
sequenceDiagram
  actor U as Journal writer
  participant UI as User interface
  participant X as Export service
  participant DB as Encrypted database
  participant C as Crypto service
  participant F as File adapter
  U->>UI: chooses encrypted export and sets a password
  UI->>X: start export
  X->>DB: read all entries
  X->>X: build manifest and entries file
  X->>C: encrypt with a key derived from the password
  X->>F: hand the file to the share or save dialog
  alt saved
    F-->>X: done
    X->>DB: record the last export time
  else dismissed or failed
    F-->>X: error
    Note over X: last export time is not changed
  end
```

## Deployment view
Not needed: the app is installed on the user's phone from an app store; there is no hosted infrastructure.
