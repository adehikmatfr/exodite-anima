# Test cases: FEAT-005 Search

Plan: TP-001. Cases `TC-040` to `TC-047`. Written from the acceptance criteria of the spec (one case per criterion) plus negative, boundary, and failure cases chosen by risk. Expected results come from the spec; where the spec is incomplete the case is marked blocked and the question is owned in the spec or in a pending decision. Nothing is executed yet.

### TC-040: Verify the matching entries are listed with the word highlighted

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-1) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** Entries that contain a word. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user searches for that word | synthetic | The matching entries are listed with the word highlighted |



Execution log: Automated, `app/test/search_test.dart` (host) and `app/integration_test/feat005_search_ui_test.dart` (emulator): passed, 2026-09-20; the matched word is drawn bold on a tinted background and named in a 'matched:' note.

### TC-041: Verify A no-results message is shown

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-2) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** No entry contains the query. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user searches | synthetic | A no-results message is shown |



Execution log: Automated, `app/test/search_test.dart` and `app/integration_test/feat005_search_ui_test.dart`: passed, 2026-09-20.

### TC-042: Verify the entry opens

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-3) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | positive |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A result in the list. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user taps it | synthetic | The entry opens |



Execution log: Automated, `app/integration_test/feat005_search_ui_test.dart`: passed on the emulator, 2026-09-20 (a result opens the entry; the query and results are still there when coming back).

### TC-043: Verify the entry is not listed

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-4) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P0 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** An entry that was deleted and contained the word. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user searches for it | synthetic | The entry is not listed |



Execution log: Automated, `app/test/search_test.dart` and `app/integration_test/feat005_search_ui_test.dart`: passed, 2026-09-20 (a deleted entry is not listed; an edited entry is found by its new words only; a deleted word is not left in the files).

### TC-044: Verify search works normally

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-5) |
| Other links | ADR-002, RISK-004 |
| Level | e2e |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | active |
| Owner | qa |

**Preconditions:** No network connection. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user searches | synthetic | Search works normally |



Execution log: Partial, 2026-09-20: the release build has no INTERNET permission (TC-084) and search only reads the local file, but the test was not run in airplane mode. Then: Physical Android phone, 2026-09-20, owner-reported (checklist `../workflow/phone-test-checklist.md`; no per-case notes were kept): Pass. Search works in airplane mode.

### TC-045: Verify results appear within the responsiveness target of `nfr-targets-v1` (criterion incomplete until that decision is made)

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-6) |
| Other links | ADR-002, RISK-004 |
| Level | performance |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** A very large journal. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Perform: the user searches | synthetic | Results appear within the responsiveness target of `nfr-targets-v1` (criterion incomplete until that decision is made) |



Note: Measured on the low-end reference device once the owner chooses it; the numbers come from `nfr-targets-v1` and are provisional until measured: results in at most 300 ms with 20,000 entries.

Execution log: Partial, 2026-09-20, Android emulator, profile build, 20,000 synthetic entries with the index (`app/integration_test/feat005_search_perf_test.dart`): a word in every entry (500 results shown) 21 ms median; a word in one entry 0 ms; a prefix 21 ms; two words 0 ms; no match 0 ms; three common words 24 ms; building the index while inserting 20,000 entries 0.7 s. Far inside the 300 ms target, but an emulator is not the reference device (not chosen), so not passed.

### TC-046: Verify search handles special characters without an error or a wrong result

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (no acceptance criterion yet (see TP-001 section 7)) |
| Other links | none |
| Level | integration |
| Priority | P1 |
| Type | negative |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** Synthetic entries including quotes and punctuation. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Search for a quote, an asterisk, a search-syntax word such as AND, and a very long query | synthetic | No error or crash; results are correct; no unrelated entries appear |



Execution log: Automated, `app/test/search_test.dart`: passed on the host, 2026-09-20 (quotes, brackets, AND, OR, NOT, NEAR, star, caret, column filters, blank and empty input never throw and never change the meaning of the query).

### TC-047: Verify search ignores case and accents

| Field | Value |
|-------|-------|
| Plan | TP-001 |
| Linked FEAT | FEAT-005 (AC-7) |
| Other links | FEAT-005 question 1 |
| Level | integration |
| Priority | P1 |
| Type | boundary |
| Automation | planned |
| Status | draft |
| Owner | qa |

**Preconditions:** The matching rules are decided: not case-sensitive, accents ignored, match from the start of a word. An entry containing the word Café. Environment: see TP-001 section 4. Data: synthetic only, no real content or real passcodes.

| # | Action | Input data | Expected result |
|---|--------|-----------|-----------------|
| 1 | Search for cafe, CAFÉ, and cafe with mixed case | synthetic | The entry is listed each time |



Execution log: Automated, `app/test/search_test.dart` and `app/integration_test/feat005_search_ui_test.dart`: passed, 2026-09-20 (cafe, CAFE, café and CAFÉ all find Café and cafe).

