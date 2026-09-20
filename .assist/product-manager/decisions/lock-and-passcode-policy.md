# What are the rules for the passcode, the wait after wrong tries, the lock timeout, and screenshots?

> Optional sections dropped for T1 (`_shared/standards/project-tiers.md`): criteria and scoring, communication.

| Field | Value |
|-------|-------|
| Status | decided |
| Date | 2026-09-20 raised / 2026-09-20 decided |
| Decider | Project owner (solo) |
| Related | FEAT-003, FEAT-004, FEAT-006, FEAT-009, ADR-001, THR-001, THR-004, THR-007, RISK-001 |
| Supersedes / superseded by | none |

## Context
These values were open questions on several specs. The security review (`G1` to `G3`, `G9`) required them before release. The passcode protects a key that a copied file lets an attacker guess offline, so the rules matter (THR-007).

## Options considered
Options are listed by the assistant; the owner chose the first in each row.

| # | Option | Pros | Cons | Cost / effort | Risk |
|---|--------|------|------|---------------|------|
| 1 | Passcode of at least 8 characters (letters, digits, symbols) and a refusal list of very common passcodes (chosen) | Resists offline guessing much better than a short PIN; matches common guidance for memorised secrets | Slower to type than a PIN | Low | Some users pick weak but long passcodes |
| 2 | A 6-digit PIN | Fast to type | Easy to guess offline | Low | Weak protection for the journal |
| 3 | Do nothing | none | Setup rules undefined | none | Blocks readiness |

## Decision
Decided by the project owner on 2026-09-20.

- **Passcode:** at least 8 characters, letters, digits, and symbols allowed; a passcode on a list of very common passcodes is refused, with a reason.
- **Export password:** at least 8 characters, separate from the passcode, with a reminder to keep it somewhere safe.
- **Wait after wrong passcodes:** 5 wrong attempts are free; after that the wait is 30 seconds and doubles with each further wrong attempt, up to a maximum of 1 hour. The count and the wait continue after the app is closed and reopened.
- **Lock timeout choices:** Immediately (the default), 1 minute, 5 minutes, 15 minutes.
- **Screenshots:** on Android, screenshots and screen recording are blocked by default. On iOS the content is hidden in the app-switcher preview (iOS cannot block screenshots).

## Consequences
- FEAT-003, FEAT-004, FEAT-006, and FEAT-009 carry these values in their Decisions and criteria; the open questions on them are closed.
- Blocking Android screenshots also blocks the owner's own store screenshots of real content; store screenshots must use made-up content.
- The wait must survive process death and clock changes (TC-029, TC-030).
- Security review gaps G2, G3, and G9 are decided; G1 (key-derivation parameters) is settled in the spike.
