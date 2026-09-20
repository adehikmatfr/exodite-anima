# Data Governance

## Classification
| Class | Examples | Handling |
|-------|----------|----------|
| Public | Marketing content | none special |
| Internal | Metrics, non-sensitive configs | access-controlled |
| Confidential | Contracts, financial records | encrypted, need-to-know, audited |
| Restricted | PII, credentials, health, payment data | encrypted, masked in non-prod, strict retention, access logged |

## Principles
- Collect the minimum; state purpose; obtain consent where required.
- Define owner, retention period, and deletion method for every dataset (`DS-`).
- Mask or synthesise data in non-production; never copy production PII to dev.
- Support data-subject rights (access, correction, deletion, portability) where applicable.
- Cross-border transfer only with a lawful basis; record data residency.

## Backup and recovery
- Automated, encrypted, off-site or off-account backups; **restore tested on a schedule** (an untested backup is not a backup).
- Define RPO/RTO per system (`nfr-catalog.md`); DR drill at least yearly.
- **Erasure must survive a restore.** Restoring an old backup brings back people who were erased since. Record every accepted erasure in an append-only log kept **outside** the database being restored (ids and timestamps only, durable and retained at least as long as the backups), and replay it before the restored system serves traffic. A ledger table inside the same database does not work: it is restored to its old state together with the data (verified in a restore drill).
- A dump-based restore loses everything written after the backup; meeting a short RPO needs point-in-time recovery, which must be drilled separately.

## Schema and migration safety
- Versioned migrations, reviewed, run in CI against a production-like copy.
- Expand, migrate, contract; no destructive change in the same release that stops using the data.
- Big backfills throttled, resumable, observable.

## Quality
- Data contracts with producers; validation at ingestion; monitor freshness, volume, and schema drift.
- Lineage documented for reports that drive decisions.

## Breach handling
Follow `severity-and-incident.md`; notify per legal deadlines in `compliance-matrix.md`.
