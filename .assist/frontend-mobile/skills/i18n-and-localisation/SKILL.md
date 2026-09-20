---
name: i18n-and-localisation
description: Use when adding user-visible text, supporting a new locale or right-to-left language, formatting dates, numbers, currency or plurals, or reviewing a screen for hard-coded or locale-dependent behaviour.
---

# i18n and Localisation

## Purpose
Make the UI translatable and locale-correct without code changes, so a new language is a content task and not an engineering project.

## When to use
- Any new or changed user-visible string, label, error message, notification or accessibility text.
- Adding a locale, RTL support or a new regional format.
- Reviewing layout for text expansion.

## Principles
- No user-visible literal in code: strings live in a message catalog with stable keys (`checkout.pay.button`), never keyed by English text.
- Whole sentences with named placeholders; never concatenate fragments. Translators need context: add a description per key.
- Use ICU MessageFormat (or platform equivalent) for plurals and gender; languages have up to six plural forms.
- Format with the locale, never by hand: dates, times, numbers, currency, units, lists, relative time via `Intl` or platform formatters. Store and transmit UTC and ISO 8601; convert at display. Money is amount plus ISO 4217 currency, formatted per locale.
- Locale is a user setting first, then the OS setting, then the default; fall back through region -> language -> default, and never show a raw key (show default language instead and report a missing-key event).
- Layout tolerates +40% text length (German, Finnish) and CJK line heights; truncate deliberately and expose full text accessibly.
- RTL is mirrored by logical properties (start/end, not left/right); icons with direction (arrows, back) mirror, logos and media controls do not.
- Error codes from the API are mapped to message keys locally (`api-integration-and-resilience`); server-side text is not displayed.
- Accessibility text (labels, alt text) is localised too.

## Checklist
- [ ] Lint or CI check rejects literals in UI code and missing keys per locale.
- [ ] Every key has a translator note, placeholder names and max length where relevant.
- [ ] Plural and select cases exist for all supported locales' plural categories.
- [ ] Pseudo-locale (accented, +40% length) screenshot pass finds clipping and hard-coded text.
- [ ] RTL pass on a real RTL locale (Arabic or Hebrew) if listed in `context.md`.
- [ ] Sorting and search use locale-aware collation; case conversion is locale-aware (Turkish i).
- [ ] Names, addresses and phone inputs do not assume one format; no "first/last name" assumption unless the domain demands it.
- [ ] Fonts cover all supported scripts with a defined fallback.
- [ ] Legal, consent and store-listing text localised where required by law or store.

## Steps
1. Extract strings into the catalog with keys and notes.
2. Replace concatenation with placeholders and ICU messages.
3. Route all formatting through locale-aware helpers.
4. Run the pseudo-locale and RTL passes; fix layout issues.
5. Export to translation; import and verify with screenshots per locale.

## Output format
| Key | Default text | Notes for translators | Placeholders | Max length | Screens |
|-----|--------------|----------------------|--------------|------------|---------|
| `cart.items` | `{count, plural, one {# item} other {# items}}` | Cart badge | `count` | 20 | cart |

## References
`../_shared/standards/nfr-catalog.md` (Localisation, Accessibility), `data-governance.md` (regional data rules); template `screen-spec.md`; skills `api-integration-and-resilience`, `accessibility-audit`; IDs `FEAT-NNN`, `TC-NNN`.

## Language notes
- Web: `Intl` APIs, i18next, FormatJS, Angular i18n. iOS: `String Catalog`, `FormatStyle`. Android: `strings.xml` plurals, `Locale`-aware formatters. Flutter: `intl`/ARB. Electron: renderer catalog plus OS locale from the main process.
