# Release Management

## Pipeline (minimum)
Commit, build, unit tests, lint and static analysis, dependency and secret scan, integration tests, package (immutable, versioned, signed), deploy to staging, smoke/e2e, progressive rollout, verify SLOs, done.

## Principles
- Trunk-based or short-lived branches; small, frequent releases.
- Build once, promote the same artifact across environments; config injected per environment.
- Semantic versioning for libraries and APIs; breaking changes need a deprecation notice and a migration path.
- Every release has a changelog entry and a linked `FEAT-`.

## Rollout strategies
| Strategy | Use when |
|----------|---------|
| Feature flag | decouple deploy from release; kill switch for risky logic |
| Canary (1% > 10% > 50% > 100%) | user-facing services; auto-halt on SLO burn |
| Blue/green | fast full rollback needed |
| Dark launch / shadow traffic | validating new systems or ML models |

## Rollback
- Every release states the rollback method and the point of no return (e.g. irreversible migration).
- Practise rollback; target time-to-rollback in minutes.

## Change control
- Risk-classified changes (standard / normal / emergency) with approvals proportional to risk.
- Freeze windows for peak periods; emergency changes get a retrospective.

## Post-release
- Watch dashboards for a defined window; record the outcome; close the loop in the registry.
