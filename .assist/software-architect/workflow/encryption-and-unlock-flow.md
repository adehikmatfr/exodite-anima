# Encryption and unlock flow

Status: **built and tested on Android (2026-09-20); not verified on iOS or on a physical phone per case.** Written after ADR-001 and ADR-002 were accepted; update it when the spike or the implementation changes anything. Source decisions: ADR-001, ADR-002, ADR-005. Diagrams: `../report/c4-diagrams.md`.

## 1. Overview
All journal content is encrypted on the device with a single data key. The key is held in the operating system's key store and can be unlocked by biometrics; a second copy is wrapped with a key derived from the user's passcode so the passcode always works. Nobody, including the developer, can recover the key: a forgotten passcode with no biometrics and no export means the journal is gone (ADR-001).

## 2. Trigger / entry points
- Setup (FEAT-004): the key is created.
- Unlock (FEAT-003): cold start, or return from the background after the timeout.
- Change passcode (FEAT-009): the wrapped copy is rebuilt.
- Import on a fresh install (FEAT-007): setup happens first (open question on FEAT-004 and FEAT-007).

## 3. Step-by-step flow
**Setup**
1. The user chooses and confirms a passcode and acknowledges the no-recovery rule.
2. The app generates a random 256-bit data key.
3. The key is stored in the OS key store, protected by biometrics when the user turns them on.
4. A second copy of the key is encrypted with a key derived from the passcode using a memory-hard function, and stored by the app.
5. The empty encrypted database is created with the data key. Nothing is stored until step 1 is acknowledged.

**Unlock**
1. The lock screen shows no content.
2. If biometrics are on, the OS key store releases the data key after a successful check.
3. If biometrics fail, are cancelled, or changed, the passcode is used: derive the wrapping key, unwrap the data key.
4. Wrong passcodes make the wait before the next attempt longer.
5. With the data key, the database opens; the timeline is shown.
6. When the app locks, the data key is cleared from memory.

**Change passcode**
1. Require the current passcode.
2. Derive a new wrapping key from the new passcode and re-wrap the same data key.
3. Confirm the journal still opens before discarding the old wrapped copy. Data is never re-encrypted.

## 4. Statuses and data model
- Stored: the wrapped data key (with its salt and function parameters, so parameters can be raised later), the encrypted database, encrypted media files (later versions).
- Not stored: the passcode, the data key in readable form.
- Media files, when added, are encrypted with the same data key using a unique nonce per file (ADR-002).

## 5. External calls and events
- OS key store and biometric services (failure modes below).
- No network calls.

## 6. Decisions and gotchas
- **Failure modes to design and test** (open finding F8): the key store refuses or is reset (for example after a device restore or a lock-screen change); biometrics unavailable or invalidated; the app killed between rebuilding and discarding the wrapped key on a passcode change; a phone restored from a cloud backup without the key store contents (which is why cloud backup of app data is excluded, ADR-001).
- Backup exclusion is **not configured yet** in the Android project (finding F2).
- Only vetted libraries may implement the ciphers and the key-derivation function; the concrete packages are chosen and verified in the spike (finding F3).
- Unlock timing is an unconfirmed assumption (NFR-1).
