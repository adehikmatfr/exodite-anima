# Legal applicability self-assessment (version 1)

Status: accepted, 2026-09-23 (owner sign-off, section 7). Method: skill `compliance-and-legal-check`, following the owner's decision to self-assess from the official texts (`decisions/legal-applicability-confirmation.md`). Related: RISK-008, `_shared/compliance/compliance-matrix.md`.

**This is not legal advice.** It is an engineering reading of the official texts, written by the assistant from the sources listed at the end. It can be wrong. The owner reads it and signs off (section 7). If a store, a regulator, or a lawyer says otherwise, that view wins.

## 1. Facts this reading rests on
Each fact is checked in the build or the documents named.

| # | Fact | Where it is true |
|---|------|------------------|
| F1 | The app has no server and no account; the developer receives no data from the app | `_shared/project.md`, ADR-005 |
| F2 | The release build declares no network permission | Merged release manifest checked 2026-09-20 (TC-084); `permission-and-privacy-register.md` |
| F3 | No analytics, crash reporting, ads, remote config, or third-party SDK that sends data | `cyber-security/report/dependency-review.md` |
| F4 | The journal is stored encrypted on the device; the user alone holds the passcode; there is no recovery | ADR-001, ADR-002 |
| F5 | Content leaves the phone only when the user exports and chooses a destination in the phone's share dialog | FEAT-006 |
| F6 | The app is free, sells nothing, and offers no paid content | `decisions/free-private-positioning-policy.md` |
| F7 | Face and fingerprint are checked by the operating system; the app never receives biometric data | FEAT-003, `permission-and-privacy-register.md` |

## 2. UU PDP No. 27/2022 (Indonesia)
What the text says (Indonesian, exact):
- Pasal 1 angka 4: "Pengendali Data Pribadi adalah setiap orang, badan publik, dan organisasi internasional yang bertindak sendiri-sendiri atau bersama-sama dalam menentukan tujuan dan melakukan kendali pemrosesan Data Pribadi."
- Pasal 1 angka 5: a Prosesor "melakukan pemrosesan Data Pribadi atas nama Pengendali Data Pribadi".
- Pasal 2 ayat (2): "Undang-Undang ini tidak berlaku untuk pemrosesan Data Pribadi oleh orang perseorangan dalam kegiatan pribadi atau rumah tangga."
- Pasal 4 ayat (2) huruf b lists biometric data as specific personal data.

Reading:
- The person writing a private journal is an individual acting in a personal activity, so for them the law does not apply (Pasal 2 ayat (2)).
- The developer is a Pengendali or Prosesor only if the developer determines the purposes of and controls the processing. The purposes are the user's, and by F1 to F3 the developer never receives, stores, or accesses the content. So the developer is not, on this reading, a Pengendali or Prosesor.
- **Residual doubt:** the text does not say whether supplying software that processes data only on the user's own phone counts as "melakukan kendali pemrosesan". The GDPR comparison in section 4 points the same way, but no Indonesian authority text was found that settles it.

**Result: No, while F1 to F3 hold.** Treated as a design constraint anyway (project rule: no collection, encryption, user-controlled deletion).

## 3. PP 71/2019 and Permenkominfo 5/2020 (registration of electronic system operators)
What the texts say (exact):
- PP 71/2019 Pasal 1 angka 4: a Penyelenggara Sistem Elektronik (PSE) is anyone "yang menyediakan, mengelola, dan/atau mengoperasikan Sistem Elektronik ... kepada Pengguna Sistem Elektronik". Angka 6: PSE Lingkup Privat is such an operation "oleh Orang, Badan Usaha, dan masyarakat".
- PP 71/2019 Pasal 6 ayat (1): "Setiap Penyelenggara Sistem Elektronik ... wajib melakukan pendaftaran." Ayat (2): before the system is used by users.
- PP 71/2019 Pasal 2 ayat (5) and Permenkominfo 5/2020 Pasal 2 ayat (2) define which private operators are covered: (a) those "diatur atau diawasi oleh Kementerian atau Lembaga berdasarkan ketentuan peraturan perundang-undangan"; and (b) those with "portal, situs, atau aplikasi dalam jaringan melalui internet" used for: 1. offering or trading goods or services; 2. financial transaction services; 3. sending paid digital content; 4. communication services (messages, calls, email, social media); 5. search-engine services or providing text, sound, image, animation, music, video, film or games; 6. "pemrosesan Data Pribadi untuk kegiatan operasional melayani masyarakat yang terkait dengan aktivitas Transaksi Elektronik".

Reading:
- The general wording of Pasal 6 is wide, but Permenkominfo 5/2020 Pasal 2 ayat (2) names the private operators that must register.
- The app is not supervised by a ministry that we know of (no financial, health, or other regulated service), and by F2 it does not use the internet at all. Its purpose is none of the six listed: it sells nothing (F6), moves no money, sends no paid content, offers no communication between people, provides no online information or search service (the in-app search reads only the user's own entries), and processes no personal data to serve the public in electronic transactions (F1).
- **Residual doubt:** whether a lawyer or the ministry would still call the developer a PSE under Pasal 1 angka 4 and expect a registration; and whether Indonesian store listings ask for registration details. Neither was verifiable from the texts. The registration form itself asks for a URL, an IP, and a business model, which shows it is built for online services.

**Result: No registration duty on this reading (Permenkominfo 5/2020 Pasal 2 ayat (2) is not met), with the residual doubt above.** The owner should check each store's Indonesia-specific questions at submission and, if one asks, decide then whether to register voluntarily.

## 4. GDPR (EU) and UK GDPR
What the text says (exact):
- Article 2(1): applies to "the processing of personal data wholly or partly by automated means".
- Article 2(2)(c): does not apply to processing "by a natural person in the course of a purely personal or household activity".
- Recital 18: the Regulation "applies to controllers or processors which provide the means for processing personal data for such personal or household activities".
- Article 4(7): a controller is one who "determines the purposes and means of the processing of personal data". Article 4(2): "processing" includes collection, storage, retrieval, use.
- Article 3(2): applies to a controller or processor not established in the Union when offering goods or services to people in the Union.

Reading:
- The user's own journal is a purely personal activity (Article 2(2)(c)).
- Recital 18 keeps controllers and processors who "provide the means" in scope, but only if they are controllers or processors, that is, they themselves determine purposes and means of processing personal data. By F1 to F3 the developer performs no operation on the user's data: no collection, storage, or access. The software runs on the user's device under the user's control.
- **Residual doubt:** whether "means" chosen by the developer (the app's design) could make the developer a joint controller. This reading says no because no personal data is ever available to the developer; no case law was checked.

**Result: No, while F1 to F3 hold** (also for the UK GDPR, which mirrors these provisions; not read separately).

## 5. App store rules
- Google Play, Data safety: "collecting" means "transmitting data from your app off a user's device"; "User data accessed by your app that is only processed locally on the user's device and not sent off device does not need to be disclosed." The form must still be completed, declaring that no data is collected or shared.
- Apple, App Privacy: "Data that is processed only on device is not 'collected' and does not need to be disclosed." Later, for iOS.
- The export goes through the share dialog at the user's own request (F5); the app does not transmit it, so it is not collection by the developer.
- Not assessed here: Apple's export-compliance questions about encryption (iOS only, later) and any export-control rules for the encryption used.

**Result: Yes, the store forms apply; the honest answers are "no data collected, no data shared".**

## 6. What would change these results
Any of the following makes the answers above wrong and this assessment must be redone before release:
1. Any data reaches the developer or a third party: analytics, crash reports, cloud sync, support attachments, an account, remote configuration.
2. A network permission is added (ADR-005 forbids it).
3. Paid features, in-app purchases, or ads.
4. Any messaging, sharing, or social feature between users.
5. A store, regulator, or lawyer states that registration or a controller role applies.

## 7. Owner sign-off
| Item | Value |
|------|-------|
| Read by | project owner (summary reviewed in conversation; residual doubts in sections 2, 3, 4 acknowledged) |
| Accepted as the basis for the first Android release | yes |
| Date | 2026-09-23 |

## Sources (read on 2026-09-20)
- UU No. 27/2022 (Pelindungan Data Pribadi), text of Pasal 1, 2 and 4, from the PDF published at hukumonline: https://learning.hukumonline.com/wp-content/uploads/2023/07/Undang-Undang-No.27-Tahun-2022-Hukumonline.pdf (official record: https://peraturan.bpk.go.id/Details/229798/uu-no-27-tahun-2022)
- PP No. 71/2019, Pasal 1, 2 and 6, from https://peraturan.bpk.go.id/Details/122030/pp-no-71-tahun-2019
- Permenkominfo No. 5/2020, Pasal 2 and 3, from https://peraturan.bpk.go.id/Details/203049/permenkominfo-no-5-tahun-2020
- GDPR, Articles 2, 3 and 4 and Recital 18: https://gdpr-info.eu/art-2-gdpr/ and https://eur-lex.europa.eu/legal-content/EN/TXT/HTML/?uri=CELEX:32016R0679
- Google Play Data safety help: https://support.google.com/googleplay/android-developer/answer/10787469
- Apple App Privacy details: https://developer.apple.com/app-store/app-privacy-details/
