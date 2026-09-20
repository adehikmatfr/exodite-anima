# Security Baseline

Minimum bar; role skills and threat models go deeper.

## Design
- Threat model new components and trust-boundary changes (`THR-`), e.g. STRIDE.
- Least privilege everywhere: users, services, CI, cloud roles.
- Defence in depth; fail closed; secure defaults.

## Authentication and authorisation
- Centralised identity; MFA for humans and privileged access.
- Authorisation enforced **server-side**, per object (guard against IDOR/BOLA).
- Short-lived tokens; rotate and revoke; no long-lived static credentials.

## Input, output, data
- Validate and encode at every boundary; parameterised queries only.
- Encryption in transit (TLS 1.2+) and at rest; managed keys, rotation.
- Never log secrets, tokens, full card numbers, or unnecessary PII.

## OWASP Top 10 checklist (web/API)
Broken access control, cryptographic failures, injection, insecure design, security misconfiguration, vulnerable components, authentication failures, integrity failures (CI/CD, updates), logging and monitoring failures, SSRF. Also review OWASP API Top 10 and, for LLM features, OWASP LLM Top 10.

## Secrets
- Secret manager only; none in repos, images, or CI logs; secret scanning in CI; rotate on exposure.

## Supply chain
- Pin and lock dependencies; automated vulnerability scanning; generate an SBOM; sign artifacts; minimal base images; review new dependencies (licence, maintenance).

## Audit and detection
- Immutable audit log for security-relevant and financial actions (who, what, when, from where, result).
- Alert on anomalies: auth failures, privilege changes, mass export.

## Vulnerability handling
| Severity | Fix target |
|----------|-----------|
| Critical (exploited or RCE) | 24-72 h |
| High | 7 days |
| Medium | 30 days |
| Low | 90 days |
