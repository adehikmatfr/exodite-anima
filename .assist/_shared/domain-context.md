# Domain Context

Business and system overview every role reads first. Keep under ~2 pages.

## Business goal
exodite-anima is a journaling app whose main promise is privacy: everything the user writes stays on their own device. There is no account, no server, and no cloud sync. Users can export their data and import it on another device, for example when they change phones. Entries are text, with optional photos and audio.

The product competes on trust. The privacy claim must be true and verifiable, not marketing.

## Users and stakeholders
| Group | Needs |
|-------|-------|
| Journal writer (primary user) | Fast, calm writing experience; confidence that no one else can read entries; simple way to back up and move to a new phone |
| People around the user (partner, friend, borrowed phone) | Not a stakeholder, but the realistic threat: must not be able to read entries by holding an unlocked phone |
| Developer / owner (solo) | Small scope, no server cost or operations, verifiable privacy claims, store approval |
| App stores (Apple, Google) | Accurate privacy labels, policy compliance |

## System landscape
Single mobile app, two platforms (iOS, Android), one codebase where possible.

```
[User] -> [App UI] -> [Domain logic] -> [Encrypted local DB]
                                     -> [Encrypted media files]
                                     -> [Key in OS Keychain/Keystore, unlocked by biometric/passcode]
[Export]  app -> archive file (manifest + entries + optional media, optionally password-encrypted) -> user-chosen destination
[Import]  archive file -> validate -> migrate schema -> merge/restore -> local DB
```

External systems: none for user content. Only OS services (Keychain/Keystore, biometrics, file picker/share sheet) and the app stores for distribution.

Key entities: Entry, Media attachment (photo, audio), Export archive, Schema version.

## Constraints
- Regulatory: see `compliance/compliance-matrix.md`. The developer does not collect or hold user data, so most data-protection duties are light, but store privacy labels and honest privacy statements are mandatory.
- Availability / scale targets: see `standards/nfr-catalog.md`. No server availability. Relevant targets are offline operation, data durability, startup and write latency, and behavior with large journals and media.
- Data loss risk: no cloud copy exists. A lost or broken device without a recent export loses everything, so the UX must drive regular export. Forgotten passcode may also mean permanent loss, depending on the recovery decision (pending ADR).
- Leak paths beyond the app: OS cloud backups, app-switcher screenshots, notifications, clipboard, logs, and unencrypted export files.
- Budget / timeline: solo developer, no infrastructure budget; only store fees. No fixed deadline yet.
