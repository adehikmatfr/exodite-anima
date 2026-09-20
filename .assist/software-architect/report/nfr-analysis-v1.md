# NFR Analysis: version 1

Method: skill `nfr-analysis`, using `_shared/standards/nfr-catalog.md` as the menu. Status: draft. Many targets were marked `ASSUMPTION` when this was written. On 2026-09-20 the owner accepted them as **provisional targets** in the decision `nfr-targets-v1` ("only realistic ones"): each is confirmed or corrected by measurement in the technical spike. Where a row still says `ASSUMPTION`, read it as a provisional target.

## 1. Journeys
| Journey | Features |
|---------|----------|
| J1 First run: set up and reach the empty timeline | FEAT-004 |
| J2 Unlock | FEAT-003 |
| J3 Write, edit, delete an entry | FEAT-001 |
| J4 Read and browse the timeline | FEAT-002 |
| J5 Find an entry | FEAT-005 |
| J6 Export | FEAT-006, FEAT-008 |
| J7 Import and restore on a new phone | FEAT-007, FEAT-004 |

## 2. Load and growth assumptions
There is one user and one device, so the "load" is the size of the journal.

- `ASSUMPTION:` a heavy long-term user writes about one entry a day, so 5,000 entries is roughly 14 years of daily writing. Owner: project owner. Validate: decide in `nfr-targets-v1`.
- `ASSUMPTION:` an average text entry is about 2 KB, so 5,000 entries is about 10 MB of text (5,000 x 2 KB). Owner: project owner. Validate: measure on real entries after the first release; media (later versions) will change the sizes greatly.
- `ASSUMPTION:` a stress case of 20,000 entries is used for tests so the design has headroom. Owner: software-architect.

## 3. Catalog walk
| Category | Applicable? | Reason or result |
|----------|-------------|------------------|
| Availability | N/A | Nothing is hosted; the app works offline on the device |
| Latency | Yes | NFR-1 to NFR-4 |
| Throughput | N/A | One user, no concurrent load |
| Scalability | Yes | NFR-5 (journal size) |
| Durability (RPO) | Yes | NFR-6, NFR-7 |
| Recoverability (RTO) | Yes | NFR-8 |
| Security | Yes | NFR-9 to NFR-11; server-side authorisation rows of `security-baseline.md` are N/A (no server) |
| Privacy | Yes | NFR-12, NFR-13 |
| Observability | Limited | No telemetry by design; crash and stability data come from the store consoles (NFR-14) |
| Maintainability | Yes | NFR-15 |
| Compatibility | Yes | NFR-16; blocked on `platforms-and-languages` |
| Accessibility | Yes | NFR-17 |
| Localisation | Yes | NFR-18; blocked on `platforms-and-languages` |
| Cost | Yes | NFR-19 |
| Portability | Yes | NFR-20 |

## 4. Requirements
Form: for a journey, a metric shall be a target, measured by a method. "Lowest-tier device" means the lowest-tier device in the device matrix, which the pending decision `platforms-and-languages` will define.

| ID | Journey | Category | Target | Measurement | Priority | Source | Verification |
|----|---------|----------|--------|-------------|----------|--------|--------------|
| NFR-1 | J2 | Latency | `ASSUMPTION:` from a successful biometric check to the timeline shown, p95 at most 1 s | Timed on the lowest-tier device, 30 runs | Must | ADR-001, FEAT-003 | Benchmark in the spike |
| NFR-2 | J1, J2 | Latency | `ASSUMPTION:` cold start to the lock or timeline screen, p95 at most 2 s | Timed on the lowest-tier device, 30 runs | Should | FEAT-002 | Benchmark |
| NFR-3 | J3 | Latency | `ASSUMPTION:` saving an entry acknowledged in at most 300 ms, p95 | Timed on the lowest-tier device with the stress-size journal | Must | FEAT-001 | Benchmark |
| NFR-4 | J5 | Latency | `ASSUMPTION:` search results for the stress-size journal in at most 300 ms, p95 | Timed on the lowest-tier device | Must | ADR-002, FEAT-005 | Benchmark in the spike |
| NFR-5 | J4, J5 | Scalability | The design holds the stress-size journal (assumed 20,000 entries) without redesign | Generated-data test | Should | Section 2 | Generated-data test |
| NFR-6 | J3 | Durability | A committed (saved) entry is never lost or altered by a crash, force close, or low battery: 0 losses | Crash-injection test at each write step | Must | THR-010, ADR-002 | Crash-injection tests |
| NFR-7 | J3 | Durability | Typed but unsaved text is recoverable: at most the last few seconds lost (`ASSUMPTION:` 2 s autosave interval) | Kill the app during typing, then reopen | Should | FEAT-001 | Test |
| NFR-8 | J7 | Recoverability | `ASSUMPTION:` restore of the stress-size export completes in at most 60 s on the lowest-tier device, with progress shown | Timed restore | Should | FEAT-007 | Benchmark |
| NFR-9 | J2, J3 | Security | Stored entries and media are unreadable without the key: 0 bytes of plaintext text in stored files | Raw-file test | Must | ADR-001, THR-002 | Raw-file test |
| NFR-10 | J6, J7 | Security | Encrypted exports are unreadable and unmodifiable without the password; a wrong password or altered byte fails before any data is applied | Tamper and wrong-password tests | Must | ADR-003, THR-006 | Tests |
| NFR-11 | J7 | Security | Malformed archives (traversal names, oversized entries, decompression bombs) are rejected and leave the journal unchanged | Malformed-archive fixtures | Must | ADR-003, THR-008 | Fixtures |
| NFR-12 | all | Privacy | Network requests carrying user content: 0 | Traffic inspection over a full test run, and code review | Must | ADR-005, project principle 1 | Test |
| NFR-13 | all | Privacy | Permissions declared in the release build: only those a feature needs; Android network permissions: 0 | Merged-manifest check in CI | Must | ADR-005 | CI check |
| NFR-14 | all | Observability | Crash-free session rate is read from the store consoles; no in-app telemetry | Console review after release | Should | product decision `free-private-positioning-policy` | Post-release review |
| NFR-15 | all | Maintainability | Test coverage on critical paths (T1 rule in `project-tiers.md`): unlock, save, export, import, migration | Coverage report | Should | `project-tiers.md` | CI |
| NFR-16 | all | Compatibility | Support Android 7.0 (API 24) and later and iOS 13 and later (decided minimums) | Device matrix tests | Must | `platforms-and-languages` (decided 2026-09-20) | Device tests |
| NFR-17 | all | Accessibility | WCAG 2.2 AA behaviours: contrast at least 4.5:1, touch targets at least 44 pt / 48 dp, screen-reader labels, system font scaling | Accessibility audit of the built app | Must | Compliance matrix | Audit |
| NFR-18 | all | Localisation | English and Indonesian, switchable in Settings; text must tolerate 40% expansion; no right-to-left | Design and build review | Must | `platforms-and-languages` (decided 2026-09-20) | Review, TC-098, TC-099 |
| NFR-19 | all | Cost | Recurring infrastructure cost: 0; the only recurring cost is store developer fees | Architecture review | Must | Charter constraints | Review |
| NFR-20 | J6, J7 | Portability | A user can leave with a readable, documented export; every past format version stays importable | Round-trip and cross-version tests | Must | ADR-003, RISK-002 | Fixtures per version |

## 5. Conflicts and proposed resolutions
| Conflict | Resolution |
|----------|-----------|
| Privacy (no telemetry) versus observability (no crash data) | Use only platform-provided store-console data; accept slower feedback (ADR-005) |
| Encryption at rest versus fast search | Whole-file database encryption keeps the search index encrypted while search stays inside the database (ADR-002); measure in the spike |
| No recovery versus usability | Accept, with a setup warning and export reminders (ADR-001, FEAT-004, FEAT-008); residual risk RISK-001 |
| Durability with no cloud | Export is the only copy; the user must be nudged (FEAT-008); RISK-001 |
| Small solo effort versus two platforms | One Flutter codebase (ADR-004); iOS cannot be built locally (RISK-004) |

## 6. Error budget and SLOs
Not applicable: no hosted service, so no availability target and no `SLO-` entries. Post-release stability is watched through the store consoles.

## 7. Open questions and assumptions
| # | Item | Owner | Due |
|---|------|-------|-----|
| 1 | Confirm or correct every provisional number by measurement (`nfr-targets-v1`, accepted 2026-09-20) | Software-architect, at the spike | Before the first release |
| 2 | Choose the lowest-tier reference device (OS minimums are decided) | Project owner | Before benchmarks are run |
| 3 | Confirm the measurement method on real devices in the spike | Software-architect | At the spike |
