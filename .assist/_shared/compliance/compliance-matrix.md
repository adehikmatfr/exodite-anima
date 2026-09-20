# Compliance Matrix

Frameworks that are clearly not applicable have been removed, as this template asks. Applicability below is the assistant's engineering reading of the project, **not legal advice**; the owner (or counsel) must confirm the rows marked Confirm.

Basis for the reading: the app is offline-only. The developer runs no server and receives no user content, so the developer does not collect or hold personal data. Journal content is still highly sensitive personal data on the user's own device, so `project-tiers.md` escalation rules apply as design constraints regardless of the legal outcome.

| Framework | Applies when | Applicable? | Reason and key obligations |
|-----------|--------------|-------------|----------------------------|
| **UU PDP No. 27/2022** (Indonesia) | Processing personal data of people in Indonesia | **No, while no data reaches the developer** (self-assessed 2026-09-20, sign-off pending; treated as a design constraint) | If all processing stays on the user's device and the developer never receives it, the developer is not a Pengendali or Prosesor (Pasal 1 angka 4 and 5), and the individual user is exempt (Pasal 2 ayat (2)). Becomes **Yes** if any data (telemetry, crash reports, support attachments) reaches the developer. Data-minimisation and no-collection are adopted as product rules either way. |
| **PP 71/2019 (PSTE) and Permenkominfo 5/2020** | Electronic system operators in Indonesia | **No registration duty on this reading** (self-assessed 2026-09-20, sign-off pending; residual doubt) | The general wording of PP 71/2019 Pasal 6 is wide, but Permenkominfo 5/2020 Pasal 2 ayat (2) lists the private operators that must register: internet-based services for trade, finance, paid content, communication, information or search services, or personal-data processing for public transaction services. A free offline journal matches none. Becomes **Yes** if the app gains such features or goes online. Check each store's Indonesia questions at submission. |
| **GDPR / UK GDPR** | EU or UK residents' data | **No, while no data reaches the developer** (self-assessed 2026-09-20, sign-off pending) | Distributed in EU stores, but the developer holds no user data. Becomes **Yes** if any data leaves the device to the developer. Store listings must still state data handling accurately. |
| **WCAG 2.2 AA** | Public-facing UI, or adopted as target | **Yes** (adopted target, not a legal requirement) | Text contrast at least 4.5:1, touch targets at least 44 x 44 pt, screen-reader labels, system font scaling, reduced motion. Applied to the mobile UI as a guideline; owned by product-design with qa verification. |
| **App store rules and encryption declarations** (Sector / other) | Publishing on Apple App Store and Google Play | **Yes** | Accurate privacy labels (Apple) and data-safety form (Google), no content in tracking, encryption export-compliance answers because the app uses encryption, and review-guideline compliance. Owned by frontend-mobile with product-manager; tracked as RISK-007. |

## Cross-framework controls (implement once, map to many)
| Control | Where | Frameworks |
|---------|-------|-----------|
| Encryption at rest and in transit | `security-baseline.md`, ADR-001, ADR-002, ADR-003 | UU PDP, GDPR (if applicable), store rules |
| Data minimisation and no collection | `project.md` rules, `data-governance.md` | UU PDP, GDPR (if applicable), store rules |
| Data retention and deletion (user-controlled) | `data-governance.md`, FEAT-001 | UU PDP, GDPR (if applicable) |
| Accessible UI | product-design and frontend-mobile roles | WCAG 2.2 AA |
| Change management and releases | `release-management.md` | store rules |
| Backup and recovery (user-driven export) | `data-governance.md`, FEAT-006, FEAT-007 | UU PDP, GDPR (if applicable) |

Incident response and breach notification: no developer-held data means no breach of developer-held data is possible; a defect that exposes on-device content is handled as a security incident (`severity-and-incident.md`).

> This matrix is engineering guidance, not legal advice. Have counsel or compliance confirm applicability and current requirements. A self-assessment from the official texts exists (`product-manager/report/legal-self-assessment-v1.md`).

## Evidence log
| Control | Evidence (link/ID) | Owner | Last reviewed |
|---------|--------------------|-------|---------------|
| Applicability of UU PDP, PP 71/2019, GDPR | `product-manager/report/legal-self-assessment-v1.md` (self-assessed from the official texts; not legal advice; owner sign-off pending) | project owner | 2026-09-20 |
