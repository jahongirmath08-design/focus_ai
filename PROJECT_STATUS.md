# Focus AI — PROJECT_STATUS.md

> Sessiyalararo XOTIRAMIZ. Suhbat emas — shu fayl + git tarixi + kod bizning haqiqiy yodimiz.
> Har ishchi qadam oxirida yangilanadi. Yangi sessiya boshida AVVAL shu fayl o'qiladi.
>
> **Oxirgi yangilanish:** 2026-07-07 · **Yakuniy muddat:** **2026-07-27** · **Holat:** ~92% (texnik yadro tayyor)

---

## 1. Strategik kontekst (biznes) — YANGILANDI

Asoschi (Shamsuddeen) bilan savol-javob strategik manzarani aniqlashtirdi:

| Parametr | Qiymat | Manba |
|---|---|---|
| Bevosita mukofot | $300 | TZ |
| Uzoq muddatli stavka | **50/50 foyda ulushli sheriklik** — g'olib ishi real startup mahsuloti bo'ladi | [J2] |
| G'olib aniqlanishi | **Kredit-poyintlar yig'indisi** bilan | [J7] |
| Bazaviy baholash | Kreativlik 30 · Interaktivlik 25 · Dizayn 20 · Funksionallik 15 · Kod 10 | TZ |
| Topshiriq soni | **Bitta**, sayqallangan, qoralamaisiz (asoschi QA-tester emas) | [J3] |

**Muhandislik oqibati:** g'alaba poyint yig'indisiga bog'liq → har ochiq poyint manbasi ataylab yopiladi, LEKIN faqat topshiriladigan Android yadrosi muzlatilgach. Eski xulosa "75 ballda g'alaba" endi "maksimal poyint yig'indisi"ga o'zgardi.

---

## 2. Ikki platformali strategiya

### 2.1. Android — birlamchi (majburiy)
Hakam **shaxsan Android 16+** qurilmasida sinaydi [J6] → barcha yakuniy QA aynan Android 16 (API 36) muhitida (`QA_CHECKLIST.md`).
- applicationId / namespace: `com.focusai.focus_ai` · versiya `1.0.0+1`
- APK: `build/app/outputs/flutter-apk/app-release.apk` (~52 MB, universal), Telegram orqali tarqatiladi

### 2.2. iOS — ikkilamchi (+10 kredit poyint) [J5]
- **Bloker:** Mac yo'q → bulutli build (Codemagic) + Apple Developer ($99/yil) yoki simulator build.
- **Darvoza:** iOS faqat (a) Android muzlagach + (b) real auth tugagach + (c) bulutli yo'l isbotlangach.
- **Ochiq savol asoschiga:** u Android 16 ishlatadi — iOS'ni qanday baholaydi (iPhone yoki simulator build)?

---

## 3. Texnologik stack (tekshirilgan — `pubspec.yaml`)

| Qatlam | Texnologiya | Versiya |
|---|---|---|
| Framework | Flutter / Dart | SDK `^3.12.0` (Flutter 3.44.x) |
| State | `flutter_riverpod` | `^3.3.2` |
| Lokal saqlash | `hive_ce` + `hive_ce_flutter` | `^2.19.3` / `^2.3.4` |
| Grafik | `fl_chart` | `^1.2.0` |
| Sensor (Deep Focus) | `sensors_plus` | `^7.0.0` |
| Tarmoq (Gemini) | `http` | `^1.2.0` |
| Rasm (multimodal) | `image_picker` | `^1.1.2` |
| Ovoz | `speech_to_text` | `^7.0.0` |
| Shrift | `SpaceGrotesk` (ichiga joylangan) | — |

**Muhim:** hozircha Firebase/Supabase paketi **YO'Q** — to'liq oflayn, lokal-first. Real auth (`AUTH_PIPELINE.md`) `firebase_core` + `firebase_auth` (Spark bepul plan) ni **additiv** qo'shadi.

### 3.1. Lokal ma'lumot (Hive box + provayderlar)
```
settings box  → onboarding_seen, auth_done, user_name, user_emoji,
                language, gemini_key, theme_mode, history_v2
habits box    → odatlar (FocusSession: accumulatedMs, runningSince, goalMs)
history box   → kunlik yakunlar (streak / heatmap)
conversations → AI suhbat tarixi (Pro)
```
Provayderlar: `languageProvider`, `l10nProvider`, `userNameProvider`, `userEmojiProvider`, `historyProvider`, `authDoneProvider`, `geminiKeyProvider`, `themeModeProvider`, `habitsProvider`, `conversationsProvider`.

### 3.2. Android konfiguratsiya (tekshirilgan)
- Ruxsatlar (`AndroidManifest.xml`): `INTERNET`, `RECORD_AUDIO`
- `targetSdk`/`minSdk`/`versionCode`: `flutter.*` dan meros (`build.gradle.kts` da qattiq belgilanmagan)
- Release imzo: hozir **debug kalit** bilan — Telegram tarqatish uchun yetarli, ixtiyoriy tuzatish

---

## 4. UI/UX holati

### 4.1. Signature dizayn (kreativlik yadrosi)
- **LightArc / MiniLightArc** (`light_arc.dart`) — "quyma yorug'lik yoyi" `CustomPainter`, tashqi kutubxonasiz; 100% da bir martalik **PORTLASH** (zarba to'lqini + radial uchqun + haptika).
- **Deep Focus** (`sensors_plus`) — telefon yuztuban → taymer avtomatik (real telefonda sinalgan).
- **Milliy naqshlar** (`uzbek_motif.dart`): `star8`, `lattice`, `chevron`, `rosette` — har tabda bittadan (`home_shell`).

### 4.2. Til — o'zbek majburiy (muqaddas qoida)
- Foydalanuvchiga barcha muloqot **o'zbek tilida**; xato xabarlari ham o'zbekcha (TZ 3.2).
- Custom i18n (`core/l10n/l10n.dart`): **3 til** (uz/en/ru) — qo'shimcha poyint [J11]. Profilda til bossang butun ilova darhol o'zgaradi.

### 4.3. Mavzu / holatlar
Yorug' / Tungi (`themeModeProvider`, standart Tungi); empty va error holatlari ishlangan; rang semantikasi izchil.

---

## 5. Kredit-poyint reyestri (strategik yadro)

### 5.1. Yopilgan poyintlar (QAYTA QURISH SHART EMAS)
- ✅ Bazaviy mezonlar: LightArc, Deep Focus, naqsh, streak+heatmap, timestamp taymer, funksionallik
- ✅ Ko'p tillilik — 3 til [J11]
- ✅ AI murabbiy **ishlaydi**: oflayn `ai_coach.dart` (kalitsiz, sof Dart) + onlayn Gemini BYOK [J7]
- ✅ Testlar: `focus_session_test.dart`, `habit_test.dart`, `widget_test.dart`; `flutter analyze` → No issues found

### 5.2. Ochiq poyintlar (ROI tartibida)
| # | Manba | Poyint | Kuch / Xavf | Faza |
|---|---|---|---|---|
| 1 | Jonli AI'ni demo videoda ko'rsatish (o'z kaliting bilan) | [J7] | ~1 soat / juda past | 1 |
| 2 | **Real autentifikatsiya** (ustuvorlik) | [J8] !!! | ~2–4 kun / o'rta, Mac kerak emas | 2 |
| 3 | iOS build | +10 [J5] | yuqori / yuqori, Mac yo'q | 3 (shartli) |

---

## 6. Yo'l xarita (tartib muqaddas)
- **Faza 1 (07-07 … ~07-14) — Android yadrosini muzlatish:** sayqal + **Android 16 smoke-test** + o'zbekcha demo video (jonli AI) + TZ 8-bo'lim 5 elementi. O'z-o'zicha g'olibbop.
- **Faza 2 — Real auth: KOD YOZILDI (qurilmada sinov kutmoqda).** Tanlov: **lokal-first** (Firebase emas) — sabab: tashqi konsol sozlashsiz, oflayn, mehmon buzilmaydi. Yangi: `features/auth/{domain/auth_validator.dart, data/account_store.dart, state/account.dart}` (salt+SHA-256, `accounts` box), `auth_screen.dart` da Mehmon|Hisob, `l10n` 3 tilda, `test/auth_validator_test.dart`. Firebase (`AUTH_PIPELINE.md`) — startupdan keyingi bulut yangilanishi. Sayqal (bajarildi): profilда hisob emaili ko'rinadi; "o'chirish"да `accounts` box tozalanadi; parol hash **10k-round cho'zilgan** (`_rounds`). Keyingi: **loyiha papkasidan** `flutter analyze` + qurilmada sinov.
- **Faza 3 — iOS: BEPUL simulator build yo'li.** Apple Developer $99/yil (faqat yillik — oylik/bepul yo'q) → TestFlight tanlanmadi. TZ 8-bo'lim simulator build'ni qabul qiladi → Codemagic'да **bepul, imzosiz, Apple hisobisiz** (`ios-simulator-focus-ai` workflow). `Info.plist` ruxsatlari + `IOS_BUILD.md` tayyor. Cheklov: akselerometr/mikrofon simulatorда ishlamaydi. Tests: `flutter analyze` toza; `widget_test` (ProviderScope + auth_done) tuzatildi.

---

## 7. MUQADDAS QOIDALAR (o'zgarmaydi)
- **TAYMER:** `elapsed = accumulatedMs + (runningSince != null ? now - runningSince : 0)` — manfiy yo'q; `goalMs`'dan oshmaydi; kill/restore'da timestamp'dan tiklanadi; parallel sessiyalar qo'llab-quvvatlanadi. HECH QACHON tick-counting.
- **TIL:** foydalanuvchiga hammasi o'zbekcha; kod/comment ingliz mumkin.
- **ADDITIV ISH:** ishlab turgan kodni buzmaslik/qayta yozmaslik; har feature'dan oldin/keyin git checkpoint; 5-rolli agent quvuri (Arxitektor → Quruvchi → Red Team → Fixer → QA) + 14-bandli adversarial checklist.
- **HALOLLIK:** "o'tdi" faqat haqiqatan ishga tushganda; aks holda "telefonда/web'da sinab ko'ring".

## 8. Muhit cheklovlari
- Kompyuter: Celeron N4500, 3 GB RAM, Windows — sekin; **release APK build ≈ 17 daqiqa**.
- Terminal: PowerShell 5.1 — `&&` yo'q (alohida qator yoki `;`). Git alohida oynada.
- Tez loop = web: `flutter run -d chrome`, `R` = hot restart; yangi `.dart` fayl → to'liq restart.
- Telefon: Redmi (MIUI/HyperOS), USB debugging o'chiq → APK Telegram orqali.
- Gradle `android/gradle.properties`: -Xmx1024m, daemon off, 1 worker (3GB uchun SHART — o'zgartirmang).

## 9. Papka tuzilishi (feature-first)
```
lib/
  main.dart                          # Hive init -> ProviderScope -> RootGate
  core/{l10n/l10n.dart, state/app_settings.dart, theme/app_colors.dart,
        utils/duration_format.dart, widgets/uzbek_motif.dart}
  features/
    timer/domain/focus_session.dart  # TAYMER YURAGI (timestamp)
    habits/{domain/habit.dart, data/habits_repository.dart, state/habits_notifier.dart}
    home/ui/home_shell.dart
    dashboard/ui/{dashboard_screen.dart, add_habit_sheet.dart}
    statistics/ui/statistics_screen.dart
    history/data/history_repository.dart   # streak / heatmap
    profile/ui/profile_screen.dart
    onboarding/ui/onboarding_screen.dart
    auth/ui/auth_screen.dart               # MEHMON rejimi (auth qo'shiladigan joy)
    active_session/ui/{active_session_screen.dart, light_arc.dart}
    pro/{domain/ai_coach.dart, data/gemini_service.dart,
         state/conversations_notifier.dart, ui/{pro_screen.dart, coach_chat_screen.dart}}
test/  focus_session_test, habit_test, widget_test
```

## 10. Mehnat taqsimoti
- **AI (men):** butun Dart kod, ko'rsatmalar, testlar, status, verifikatsiya (web Chrome).
- **Foydalanuvchi:** terminal (`r`/`R`), git (PowerShell), jonli vizual tasdiq (hakam ko'zi), APK'ni telefonda sinash.
