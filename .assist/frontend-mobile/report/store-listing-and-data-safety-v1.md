# Store listing text and data-safety form answers (version 1, draft)

Method: skill `mobile-release-and-store-compliance`. Status: draft, 2026-09-23; reviewed and accepted by the owner 2026-09-23; not yet reconciled with the final package list. Related: `permission-and-privacy-register.md` (Store declarations plan), `product-manager/report/legal-self-assessment-v1.md` (accepted 2026-09-23), `product-manager/decisions/public-app-name.md`, `docs/privacy.md`.

This fills in the "Store declarations plan" and "Public app name and store listing" rows left open in `permission-and-privacy-register.md` and `release-plan-v1.md`. It is text ready to paste into each store's console; the owner reviews and pastes it, and it is reconciled against the actual release build before submission (nothing here is final until then).

## Google Play Data safety form

| Question | Answer | Basis |
|----------|--------|-------|
| Does your app collect or share any of the required user data types? | **No** | No network permission in the release build (ADR-005, TC-084); no analytics or third-party SDK that collects data (`dependency-review.md`) |
| Is all user data encrypted in transit? | Not applicable (no data in transit) | ADR-005 |
| Do you provide a way for users to request their data be deleted? | Not applicable (no data is held by the developer; the user deletes their own on-device journal and controls their own export files) | `docs/privacy.md` |
| Data safety section summary text | "This app doesn't collect or share any user data with anyone, including us. Your journal stays encrypted on your device; there is no account and no server." | `legal-self-assessment-v1.md` section 5 |

Reconcile before submission: re-check the merged manifest and the final `pubspec.yaml` package list for any permission or SDK added since 2026-09-20.

## Apple App Privacy ("Nutrition label")

| Question | Answer | Basis |
|----------|--------|-------|
| Data Not Collected | **Yes** (select this label) | Same basis as Google Play, above |
| Privacy manifest (`PrivacyInfo.xcprivacy`), required-reason API entries | To be filled at the first iOS build (not built locally; no Mac) | `permission-and-privacy-register.md` |
| Export compliance (uses encryption) | **Yes**, the app encrypts data at rest and encrypted exports use standard, non-proprietary cryptography (see `ADR-001`, `ADR-003`); the exact self-classification question (`ITSAppUsesNonExemptEncryption` / whether an annual self-classification report is owed) is a legal question for the owner or counsel, tracked as RISK-007 | `legal-self-assessment-v1.md` section 5 (not assessed there for iOS) |

## Content rating / age rating questionnaire

Draft answers for both stores: no user-generated content shared with others, no violence, no gambling, no in-app purchases, no ads, no location sharing, no account creation, no communication features. Journal content is private to the user and never reviewed, shared, or moderated by the developer. Suggested rating: the lowest tier available on each store (for example Google Play "PEGI 3" / Everyone); the owner confirms at submission since only the console gives the final rating.

## Store listing text (draft)

**Short description (Google Play, up to 80 characters):**
> A private, offline journal. No account, no cloud, no ads. Your writing stays yours.

**Full description (draft):**
> Exodite Anima is a journal that keeps your writing entirely on your phone.
>
> - No account, no sign-up, no server, no ads, no tracking.
> - Your entries are encrypted and locked behind a passcode (and, if you choose, your face or fingerprint).
> - The app never uses the internet — it doesn't ask for permission to.
> - When you want to move to a new phone or keep a backup, export your journal to a file you control; import restores it fully.
> - Free, and always will be.
>
> This app cannot recover your journal if you forget your passcode: nobody, including the developer, can read it. That is the whole point. Export regularly, and the app will remind you.
>
> Available in English and Indonesian.

**Keywords / category (draft):** Lifestyle or Productivity category; keywords: journal, diary, private, offline, encrypted, no account, no cloud.

**App icon and screenshots:** already produced (`product-design/design/social/`, logo A2, adaptive icon); screenshots are real debug-build screenshots with made-up entries (no real journal content, per the security baseline).

## Still open (owner or a later session)
- Owner reviewed and accepted this draft 2026-09-23. Reconcile every answer above against the actual release build's manifest and package list immediately before submission (this draft is from 2026-09-23 facts).
- iOS-specific rows (privacy manifest, export compliance self-classification) once an iOS build exists.
- Final content/age rating comes from each store's own questionnaire, not from this draft.
- Store listing text is not localised into Indonesian yet.
- Public app name availability: informal web search found no conflict (`public-app-name.md`, 2026-09-23), but the real check happens when the name is entered in Play Console / App Store Connect at submission.
