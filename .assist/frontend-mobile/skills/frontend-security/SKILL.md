---
name: frontend-security
description: Use when a client handles authentication tokens, local storage, user-generated content, deep links or redirects, embedded web content, third-party SDKs or configuration, or when reviewing UI code for security before release.
---

# Frontend Security

## Purpose
Treat the client as an untrusted, inspectable environment: reduce what an attacker can steal or abuse from it, and never rely on it for enforcement.

## When to use
- Implementing sign-in, session, storage, payments, file upload or sensitive screens.
- Rendering user or server-supplied content; opening links, deep links, WebViews.
- Adding a dependency or SDK; preparing a security review (`THR-`).

## Principles
- Anything shipped to the client is public: no API secrets, private keys, service credentials or signing material in bundles, app packages or config. Public identifiers (client IDs, publishable keys) are fine and are restricted server-side.
- Authorisation lives on the server; client checks are UX only. Treat hidden routes and feature flags as visible.
- Output-encode by default: render untrusted data as text; avoid raw HTML sinks (`innerHTML`, `dangerouslySetInnerHTML`, `v-html`, WebView `loadData`). If HTML is required, sanitise with a maintained allow-list library.
- Tokens: short-lived access token, rotating refresh token, stored in the platform's secure store (Keychain, Keystore/EncryptedSharedPreferences, OS credential vault; on web, HttpOnly Secure SameSite cookie preferred over script-readable storage). Never in URLs, logs, analytics or plain files.
- Validate every external input: deep-link parameters, intent extras, `postMessage` origin and payload, clipboard, file names, push payloads.
- Redirects and links: allow-list destinations for post-login redirects and in-app navigation; block `javascript:` and unexpected schemes; `rel="noopener"` for external links.
- Third-party SDKs are code with your users' privileges: justify, pin, review permissions and network endpoints, load least privilege, and list them in the privacy disclosure.
- Data minimisation: do not store what you can refetch; wipe on logout; mask sensitive fields; disable autofill/screenshots/caching for highly sensitive screens.

## Checklist
- [ ] Secret scan of built artefacts (bundle, IPA/APK, installer) shows no credentials.
- [ ] Token storage location, lifetime, refresh and logout wipe documented and tested.
- [ ] No raw HTML sinks with untrusted data; sanitiser used where unavoidable.
- [ ] Deep links, redirect targets and message origins validated against an allow-list.
- [ ] Transport TLS 1.2+ only; certificate pinning decision recorded (`THR-NNN`) with rotation plan if used.
- [ ] Cross-origin/embedded content isolated (CSP and frame rules on web; WebView JavaScript bridge minimal, no file access).
- [ ] Dependencies and SDKs scanned, locked, and reviewed; new ones justified in the PR.
- [ ] No sensitive data in logs, crash reports, screenshots, clipboard or backups.
- [ ] Security-relevant client errors do not disclose internals; rate-limit and lockout messaging is generic.
- [ ] Abuse cases from the threat model have tests (`TC-NNN`).

## Steps
1. List assets and entry points touched by the change; check `THR-` entries; raise a new one for a new trust boundary.
2. Walk the checklist; fix or record accepted risk with owner.
3. Run SAST, dependency and secret scanning in CI; review results.
4. Hand off to cyber-security for changes to authentication, storage or SDK set.

## Output format
| Area | Finding | Severity | THR / CWE | Fix | Status |
|------|---------|----------|-----------|-----|--------|
| Storage | Refresh token in `localStorage` | High | THR-NNN / CWE-922 | Move to HttpOnly cookie | open |

Fix targets follow `security-baseline.md` (Critical 24-72 h, High 7 days).

## References
`../_shared/standards/security-baseline.md`, `data-governance.md`, `project-tiers.md`; cyber-security skills `threat-modeling`, `secure-code-review`, `dependency-and-supply-chain-review`; skills `client-error-handling-and-telemetry`, `api-integration-and-resilience`; IDs `THR-NNN`, `API-NNN`, `FEAT-NNN`.

## Language notes
- Web: CSP, Trusted Types, SameSite cookies. iOS: Keychain, ATS, universal-link validation. Android: Keystore, App Links, `exported` components. Flutter: `flutter_secure_storage`, obfuscation is not security. Electron: `contextIsolation` on, `nodeIntegration` off, validate IPC senders.
