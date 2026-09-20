---
name: device-and-os-matrix-testing
description: Use when choosing which devices and OS versions to support and test, planning real-device versus emulator coverage, or designing network, lifecycle, interruption and accessibility-setting tests for a mobile release.
---
# Device and OS Matrix Testing

## Purpose
Cover the devices and conditions real users have, at a cost proportional to risk, and produce evidence that a release works on them.

## When to use
- Defining or refreshing the device matrix in `context.md`.
- Planning test scope for a release or a new `FEAT-`.
- A bug reproduces only on some devices, OS versions or conditions.

## Principles
- Decide from **usage data** (analytics, store console), not from what the team owns. Refresh quarterly and after every major OS release.
- Real devices for anything touching hardware, performance, permissions, push, biometrics, camera, background behaviour. Emulators for logic, layout smoke, and fast CI.
- Include the worst plausible device, not just the median: lowest RAM, oldest supported OS, smallest and largest screens.
- Test conditions, not only devices: network, interruptions, lifecycle, settings.

## Steps / Checklist
1. **Pull data:** active users by device model, OS version, screen size, RAM class, last 30 days.
2. **Build the matrix** (typical sizes):
   - Primary: smallest set covering >= 80% of active users; test every release, real devices. Usually 6-10 devices.
   - Secondary: next 15% plus known-problem vendors (aggressive battery managers, custom skins); test each minor release, farm or sample.
   - Edge: oldest supported OS on lowest-RAM device (<= 3 GB); newest OS beta (pre-release check, informational); foldable/tablet if supported.
   - Rule: every supported OS major has at least one real device; iOS latest two majors plus any major with >= 5% share; Android API levels with >= 3% share.
3. **Drop support** when an OS version falls under 2% of active users for two quarters; announce per `app-version-compatibility`.
4. **Network conditions:** offline, airplane toggle mid-request, 3G-like (400 kbps, 400 ms RTT), 2% packet loss, Wi-Fi to cellular handover, captive portal, DNS failure, expired TLS. Use network link conditioner / emulator throttling / proxy.
5. **Lifecycle and interruptions:** background then foreground after 30 s and 30 min; process death and restore state; low-memory kill; incoming call; notification tap from cold, warm and running states; deep link while logged out; rotation and split-screen; low-power mode; storage full; permission revoked in Settings while backgrounded; time zone and clock change.
6. **Accessibility settings:** dynamic type / font scale 200%, bold text, reduce motion, dark mode, high contrast, VoiceOver and TalkBack passes on critical journeys, RTL locale (`accessibility-audit`).
7. **Upgrade tests:** install oldest supported app version, populate data, upgrade to release candidate; verify local migration and login persistence (`offline-and-sync`).
8. **Automation split:** unit and component tests on CI emulators every PR; UI smoke on 3 emulators nightly; critical journeys on device farm per release candidate; manual exploratory on real devices for permissions and hardware (`ui-testing-strategy`).
9. **Record evidence:** device, OS build, app build, network profile, result, screen recording for failures. Flaky device tests get an owner and 5-day deadline.

## Output format
Matrix table: tier | device | OS | screen | RAM | share % | test type (real/emulator) | cadence. Plus a condition checklist per release with pass/fail and linked `TC-NNN`.

Worked example: data shows Android 12-14 = 78%, Android 9 = 6% (low-end 2 GB devices). Add a 2 GB Android 9 real device as low-end reference; run cold-start and offline-sync `TC-NNN` there each release.

## References
`../_shared/standards/definition-of-done.md`, `nfr-catalog.md`, `release-management.md`. IDs: `TC-`, `TP-`, `FEAT-`, `SLO-`. Common skills: `ui-testing-strategy`, `accessibility-audit`.

## Language notes
- Xcode: XCUITest + simulators; Android: Espresso/Compose test + Gradle managed devices, Firebase Test Lab. RN: Detox/Maestro. Flutter: `integration_test` on farm.
