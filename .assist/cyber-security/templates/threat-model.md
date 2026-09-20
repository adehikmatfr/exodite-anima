# Threat Model: THR-NNN <system or feature>

> Sections marked (optional) may be dropped for T1 projects (`_shared/standards/project-tiers.md`); all other sections are required.

| Field | Value |
|-------|-------|
| Threat model ID | THR-NNN (one ID per threat row: THR-NNN, THR-NNN+1; this header groups them) |
| Scope | `<component, FEAT-NNN, ADR-NNN>` |
| Tier | `<T1/T2/T3>` |
| Author / reviewer | `cyber-security` / `cyber-security` |
| Date / next review | `<date>` / `<trigger or date>` |
| Related | `FEAT-NNN`, `ADR-NNN`, `RISK-NNN` |

## 1. Assets
| Asset | Data class | Why it matters (confidentiality / integrity / availability) |
|-------|-----------|-------------------------------------------------------------|
| `<asset>` | Restricted | `<impact if lost or altered>` |

## 2. Trust boundaries and data flows
Diagram reference or list. Mark each boundary crossing and who can act on each side.
| Boundary | From -> to | Data crossing | Controls at crossing (authn, authz, validation, logging) |
|----------|-----------|---------------|-----------------------------------------------------------|
| `<name>` | `<a -> b>` | `<data>` | `<controls>` |

## 3. Actors and assumptions (optional)
Anonymous user, authenticated user, admin, service account, insider, compromised dependency. List assumptions that, if false, invalidate the model.

## 4. Threats (STRIDE)
Likelihood 1-3 x Impact 1-3 = Score 1-9. Score 6-9: mitigate before release. 3-5: owner and date. 1-2: accept and record.
| ID | Boundary / asset | STRIDE | Threat | Likelihood | Impact | Score | Mitigation | Owner | Status |
|----|------------------|--------|--------|-----------|--------|-------|-----------|-------|--------|
| THR-NNN | `<boundary>` | S | `<attacker does X to obtain Y>` | 2 | 3 | 6 | `<control and where implemented>` | `cyber-security` | open / mitigated / accepted / verified |

Status changes to `verified` only with evidence (test, review, or scan result linked).

## 5. Data handling decisions
| Data | Class | Stored where | Encrypted at rest / in transit | Retention and deletion | Masked in non-prod | Logged? |
|------|-------|--------------|-------------------------------|------------------------|--------------------|---------|
| `<field group>` | Restricted | `<store>` | yes / yes | `<period, method>` | yes | no |

## 6. Abuse cases and misuse of features (optional)
`<business-logic abuse: coupon farming, enumeration, replay, mass export>` with the detection or limit in place.

## 7. Compliance and residual risk
- Frameworks touched (`compliance-matrix.md`): `<list>`.
- Residual risk accepted by `<named owner>` until `<date>` as `RISK-NNN`.

## 8. Verification plan (optional)
| THR | How verified (code review, test, scan, pentest item) | Evidence link | Date |
|-----|-------------------------------------------------------|---------------|------|
