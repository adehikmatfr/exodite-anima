# Security review of ADR-001 to ADR-005

The cyber-security role reviews architectural decisions and may block on security grounds (`prompts/role.md`). Date: 2026-09-20. Reviewer: cyber-security role (**self-review, not independent**). No ADR is blocked. Recommendations are proposals to the software-architect and the owner; an accepted ADR is changed only by superseding it, with the owner's confirmation.

| ADR | Outcome | Summary |
|-----|---------|---------|
| ADR-001 | concur with conditions | Sound model; conditions R1, R2, R3 |
| ADR-002 | concur with conditions | Conditions R4, R5 |
| ADR-003 | concur with conditions | Conditions R6, R7 |
| ADR-004 | concur | No security objection; supply-chain note R8 |
| ADR-005 | concur (recommend the owner accepts it) | Closes threats THR-005 and THR-015 |

## ADR-001: application-level encryption, no recovery
Concur. The realistic attacker is a nearby person, and the design defeats them.

- **R1 (recommended, THR-007, AP-2, AP-3):** the passcode-wrapped copy of the data key is stored by the app, so anyone who copies the app's files (a thief, or a cloud backup) can attack the passcode offline. The strength of that attack depends entirely on the passcode and the derivation parameters. Recommended hardening: also wrap the data key with a key held in the OS key store (hardware-backed where available), so an offline attacker needs the device as well as the passcode. Effect: files copied off the phone are useless without the phone. Trade-off: the wrapped key cannot be used on another device, which is acceptable because the move-phone path is export and import. This would be a superseding ADR or an amendment decided by the owner. On 2026-09-20 the owner asked for R1 to be evaluated in the spike (S5) and decided with evidence; until then R2 and R3 matter more.
- **R2 (G1):** set and record the key-derivation parameters from vetted guidance and measure them on the lowest-tier device, so unlock stays quick while guessing stays expensive. Store the parameters with the wrapped key so they can be raised later.
- **R3 (G3):** passcode rules must exist before release (FEAT-004 open question). A short numeric passcode weakens everything above.
- **Not yet true in code:** backup exclusion (supporting decision 5, G11).
- Memory: clear the data key from memory when the app locks (G4).

## ADR-002: encrypted SQLite with drift
Concur.
- **R4:** the raw-file test must cover every file the database creates, not only the main file: the journal, the write-ahead file, and any temporary files, and it must prove none holds plaintext entry text. Add this to the test plan (NFR-9, THR-002).
- **R5:** give the database a random 256-bit key (the data key), never a passphrase typed by the user, so the passcode strength does not become the database's strength.
- Full-text index lives inside the encrypted file (good). Confirm during the spike that search does not create an unencrypted index or cache elsewhere.
- Library claims are unverified until the spike; if the spike fails, reopen the ADR.

## ADR-003: export archive format
Concur.
- **R6 (G7):** set numeric import limits before implementation (file count, unpacked size, entry size), and reject anything above them (THR-008).
- **R7:** the header of an encrypted export must contain only the format version, the derivation parameters, the salt and the nonce, and must be authenticated; nothing about the journal (entry count, dates) may sit outside the encrypted payload. Check this when the envelope is chosen. Export file names should not reveal content.
- Plaintext exports cannot be authenticated; accepted (THR-009, RISK-009).
- If the spike chooses an existing standard envelope, prefer it to a custom header.

## ADR-004: Flutter
Concur. Security depends on packages for the key store, biometrics, and the encrypted database.
- **R8:** each such package is reviewed before it is added (`dependency-review.md`): maintenance, licence, requested permissions, install-time scripts. A package that adds a network permission is rejected under ADR-005.

## ADR-005: no network, enforced by the build
Concur; recommend the owner accepts it. It turns the central privacy claim into a build-checked fact on Android and a reviewed and tested property on iOS, and it is the control for THR-005 and THR-015.
- Residual: iOS has no OS-level switch, so enforcement there is dependency review plus a traffic-inspection test (THR-013 residual).
