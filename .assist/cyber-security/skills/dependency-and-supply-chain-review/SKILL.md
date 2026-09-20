---
name: dependency-and-supply-chain-review
description: Use when adding or upgrading a dependency, base image, GitHub Action or build plugin, changing the build and release pipeline, or answering an SBOM, licence, or provenance request.
---
# Dependency and Supply Chain Review

## Purpose
Keep third-party code and the build pipeline trustworthy: know what ships (SBOM), lock what you use, check licences and maintenance, and verify where artifacts come from.

## When to use
- New direct dependency, major upgrade, or new base image.
- CI/CD, registry, or signing change.
- Advisory affecting a shipped component (then also `vulnerability-triage`).
- Customer, regulator, or audit asks for an SBOM or provenance evidence.

## Principles
- Every dependency is code you own the risk for: the smaller the set, the smaller the risk.
- Pin and lock; reproducible builds beat trust in a moving tag.
- Provenance over popularity: who publishes it, how is it signed, is it maintained.
- Pipelines are production: least-privilege tokens, protected branches, no secrets in logs.
- Licence obligations are legal constraints; flag conflicts to counsel, do not decide alone.

## Steps / Checklist
1. New dependency review:
   - [ ] Need justified; no existing library covers it
   - [ ] Maintenance: recent releases, responsive maintainers, more than one maintainer for critical components
   - [ ] Known advisories and their fix status; transitive dependency count
   - [ ] Licence compatible with project policy (record type; copyleft or unknown goes to counsel)
   - [ ] Source is the official registry and publisher; check for lookalike or typosquatted names
   - [ ] Install-time scripts and requested permissions reviewed
2. Pinning: lockfile committed; versions pinned; container images pinned by digest; CI actions pinned by commit hash.
3. SBOM: generated per release in a standard format, stored with the artifact, diffed between releases.
4. Scanning: dependency and container scans in CI and nightly; results triaged with `vulnerability-triage` and fix-target table.
5. Provenance: artifacts signed; build runs on a controlled runner from a protected branch; provenance attestation stored; verify signatures on deploy where feasible.
6. Minimal base images; remove build tools from runtime images; separate build and runtime credentials.
7. Pipeline hardening: least-privilege CI tokens, short-lived credentials, required review on pipeline changes, secret scanning.
8. Register threats (dependency confusion, compromised maintainer, poisoned build) as `THR-` where the risk is real.

Decision guide:
| Signal | Action |
|--------|--------|
| Abandoned (no release 2 years), critical path | Replace or fork with owner named; `RISK-NNN` meanwhile |
| Copyleft or unknown licence in shipped code | Counsel review before merge |
| Critical advisory, reachable | Emergency upgrade (24-72 h) |
| Unpinned action or `latest` tag | Pin, then merge |

Worked mini-example: request to add a small string-formatting package with 40 transitive dependencies and an install script. Decision: reject; a standard-library function covers the need. Recorded in the review comment.

## Output format
| Dependency | Version | Purpose | Licence | Advisories | Maintenance | Decision | Owner |
|-----------|---------|---------|---------|-----------|-------------|----------|-------|
| `<name>` | `<pinned>` | `<why>` | `<type>` | none | active | approve / reject / conditions | `<team>` |
Plus SBOM location and pipeline findings as `THR-` entries.

## References
- `_shared/standards/security-baseline.md` (supply chain, fix-target table)
- `_shared/standards/project-tiers.md`, `_shared/compliance/compliance-matrix.md`
- `_shared/index.md` (THR, RISK, ADR)
- Related skills: `vulnerability-triage`, `secure-code-review`

## Language notes
Optional: each ecosystem has its own lockfile and integrity mechanism; enable hash verification where the package manager supports it and disable or review install-time scripts.
