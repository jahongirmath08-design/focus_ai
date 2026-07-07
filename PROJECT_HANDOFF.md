# Focus AI — Loyiha Holati va Topshiruv Hujjati (Handoff)

> **Maqsad:** ushbu hujjat yangi ishlab chiqish/coworking sessiyasini kontekstni yo'qotmasdan ishga tushirish uchun mo'ljallangan. Holat: **~92% tugallangan** (texnik ish yakunlangan; demo video + topshirish qoldi).
> **Sana:** 2026-07-06 · **Muddat (deadline):** **2026-07-27**

---

## 1. Loyiha Umumiy Ko'rinishi va Arxitektura

### 1.1. Asosiy maqsad
Focus AI — diqqatni mashq qilish va foydali odatlarni shakllantirish uchun mo'ljallangan **Android (Flutter) mobil ilova**. Har bir odat mustaqil "fokus sessiya"ga aylanadi; vaqt **halol** (timestamp asosida) o'lchanadi; interfeys milliy o'zbek ruhi bilan bezatilgan. Ilova **to'liq oflayn** ishlaydi; onlayn AI faqat ixtiyoriy Pro imkoniyat.

### 1.2. Tanlov konteksti (biznes)
- **Konkurs:** $300 mukofot. **Buyurtmachi:** Shamsuddeen.
- **Baholash mezoni:** Kreativlik 30 · Interaktivlik 25 · Dizayn 20 · Funksionallik 15 · Kod 10.
- **G'olib zonasi (strategiya):** Kreativlik + Interaktivlik + Dizayn = **75 ball**. Asosiy urg'u shu uchtaga.
- **Foydalanuvchi/muallif:** Jahongir Sattorov (`jahongirmath08@gmail.com`) — **dasturchi emas**; AI yordamchi lead engineer + UX hamkor + mentor rolini bajaradi.

### 1.3. Texnologik stack
- **Framework:** Flutter 3.44.0 / Dart 3.12.0
- **State management:** Riverpod (`NotifierProvider` / `Notifier` / `Provider`)
- **Lokal saqlash:** Hive CE (`hive_ce` + `hive_ce_flutter`) — boxlar: `habits`, `settings`, `history`, `conversations`
- **AI:** Google **Gemini API** (REST, `v1beta/models/{model}:generateContent`)
- **Paketlar:** `fl_chart`, `sensors_plus ^7.0.0`, `http ^1.2.0`, `image_picker ^1.1.2`, `speech_to_text ^7.0.0`, `flutter_launcher_icons` (dev)
- **Shrift:** Space Grotesk — **ilova ichiga joylangan** (`assets/fonts/`), `google_fonts` OLIB TASHLANGAN (oflayn kafolat uchun)
- **Grafika:** signature vizual `CustomPainter` bilan (LightArc) — tashqi kutubxonasiz

### 1.4. Asosiy CHEKLOVLAR (majburiy qoidalar)
- **TIL QOIDASI (muqaddas):** foydalanuvchiga BARCHA tushuntirish/muloqot **O'ZBEK TILIDA**. Kod, fayl nomlari, kommentlar — inglizcha bo'lishi mumkin.
- **TAYMER QOIDASI (muqaddas):** vaqt HECH QACHON "sanab" (tick-counting) yuritilmaydi. Har doim:
  `elapsed = accumulatedMs + (runningSince != null ? now - runningSince : 0)`. Manfiy yo'q; maqsaddan oshmaydi; kill/restart'da timestamp'dan tiklanadi; bir nechta parallel sessiya qo'llab-quvvatlanadi.
- **REJIM:** haqiqiy ro'yxatdan o'tish YO'Q — faqat **mehmon (guest) rejimi**, lokal-first. "Kirish" = kirish ekraniga qaytish flagini o'zgartirish, akkaunt emas.
- **ADDITIV ISH:** ishlab turgan kodni HECH QACHON buzmaslik/qayta yozmaslik. Har feature'dan oldin/keyin git checkpoint.
- **HALOLLIK:** build/test "o'tdi" deb faqat u haqiqatan ishga tushgan bo'lsa aytiladi; aks holda "siz telefonda sinab ko'rishingiz kerak".

### 1.5. Ishlab chiqish muhiti
- **Kompyuter:** Celeron N4500, 3GB RAM, Windows — **sekin**; release APK build ≈ **17 daqiqa**.
- **Terminal:** Windows PowerShell 5.1 — **`&&` ishlamaydi** (buyruqlar alohida qatorda yoki `;` bilan).
- **Tez ishlanma:** dev'da **web (Chrome)** ishlatiladi (`flutter run -d chrome`, `R` = hot restart). YANGI `.dart` fayl qo'shilsa to'liq restart kerak; mavjud faylni tahrirlash — `R` yetadi.
- **Telefon:** Redmi (MIUI/HyperOS). USB debugging YOQILMAGAN → `flutter install` telefonni ko'rmaydi; APK **Telegram orqali** o'rnatiladi.

### 1.6. Operatsion rejim — "Virtual Agent Team" (5 rol)
Har feature bitta-bitta quyidagi ketma-ketlikда: **Agent 1 (Bosh arxitektor)** → **Agent 2 (Quruvchi)** → **Agent 3 (Red Team / adversarial)** → **Agent 4 (Fixer)** → **Agent 5 (Yakuniy QA)**. Har rol o'zbekcha qisqa e'lon qilinadi. 14-bandli adversarial checklist bo'yicha baholanadi (signature ruhi, mikro-interaksiya/haptika, silliqlik, timestamp taymer, foiz/jami mosligi, oflayn resume, benuqson o'zbekcha, yorug'+tungi, empty/error holatlar, rang semantikasi, raqiblardan ustunlik, edge-case'lar, toza kod, eski ish buzilmaganligi).

---

## 2. Bajarilgan Bosqichlar (to'liq, granular)

### 2.1. Majburiy TZ ekranlari (barchasi TAYYOR)

#### 3.1 Onboarding (`features/onboarding/ui/onboarding_screen.dart`)
- 3 sahifali interaktiv tanishtiruv; qahramon element — signature **LightArc/MiniLightArc** (yoy "quyiladi").
- Staggered entrance animatsiyasi (yoy sakrab kattalashadi, matn suzib chiqadi), parallaks, haptika.
- Sahifa ranglari: amber / siyan / yashil. Milliy **star8** naqsh foni.
- **[Oxirgi tuzatish]** endi **har doim to'q "kinematik intro"** (`backgroundColor: 0xFF0F0D17`) — mavzudan qat'i nazar; sarlavhaga `color: Colors.white` — shunda yorug' mavzuда ham barcha yozuvlar (yuqori/o'rta/past) aniq ko'rinadi.

#### 3.2 Kirish / Sign In (`features/auth/ui/auth_screen.dart`)
- **Mehmon rejimi** — ro'yxatdan o'tish shart emas; ixtiyoriy ism kiritish maydoni.
- Tugma adaptiv: ism bo'sh → "Mehmon sifatida davom etish"; ism bor → "Davom etish".
- `_continue()` ismni HAR DOIM saqlaydi (bo'sh bo'lsa tozalaydi) → `authDoneProvider.signIn()`.
- Shamsa (`star8`) naqsh foni, `AppColors.accent`.

#### 3.3 Dashboard / Bugun (`features/dashboard/ui/dashboard_screen.dart`)
- Sarlavha: emoji + vaqtga mos salomlashish + sana + 🔥 **seriya (streak) pill** (`streak > 0` bo'lsa).
- 3 statistika chip: **jami diqqat** / **faol** / **bajarilgan**.
- Odat kartalari: `MiniLightArc` markazida **foiz (%)** yoki tugagach **✓**; nom + `elapsed / goal`; holat (Ishlayapti / To'xtatilgan / Bajarildi); dumaloq Boshlash/Pauza yoki Qaytadan tugmasi; `⋮` menyu (Reset / Delete).
- `settleCompleted()` tickeri maqsadga yetganда aniq to'xtatadi (oshmaydi).

#### 3.4 Odat qo'shish (`features/dashboard/ui/add_habit_sheet.dart`)
- 8+ emoji/belgi, **12 rang** (`AppColors.habitColors`), maqsad (soat/daqiqa), nom.

#### 3.5 Faol sessiya (`features/active_session/ui/active_session_screen.dart`)
- Signature **LightArc** (`light_arc.dart`): "quyma yorug'lik yoyi" — sovigan iz, qizigan ember uch, uchqunlar, 100% da bir martalik PORTLASH (zarba to'lqini + radial uchqunlar + haptic).
- Boshqaruv (`Wrap`): asosiy tugma **Boshlash → Pauza → Davom etish** (pauzadan keyin `accumulatedMs>0`); **Yakunlash** (odatni bugun bajarildi deb belgilaydi); tugagach **Qaytadan**. Standalone "Qayta" faol boshqaruvdan OLIB TASHLANGAN (kartadagi `⋮` va tugagan holatda "Qaytadan" bor).
- **Chuqur diqqat (Deep Focus):** `sensors_plus` akselerometr — telefon yuztuban bo'lsa taymer avtomatik ketadi, ko'tarsa to'xtaydi.
- Ambient fon: progress bilan odat rangida "qiziydi" (RadialGradient).

#### 3.6 Profil (`features/profile/ui/profile_screen.dart`)
- Emoji avatar + ism (tahrirlanadi), **til tanlagich** (O'zbekcha / English / Русский).
- **MAVZU tanlagich:** faqat **Yorug' / Tungi** (System OLIB TASHLANGAN — chalkashlik sababli).
- Tanishtiruvni qayta ko'rish; Ilova haqida; **Chiqish**.
- **Chiqish (2 tanlov):** dialog → "Shunchaki chiqish" (ma'lumot saqlanadi) yoki "Chiqish va o'chirish" (qizil) → ikkinchi tasdiq → `clearAll` (habits + history + conversations + name/emoji/key) + logout.

### 2.2. Signature va Bonus funksiyalar (TAYYOR)
- **Timestamp taymer** — `features/timer/domain/focus_session.dart` (pure Dart): `accumulatedMs`, `runningSince`, `goalMs`; `start/pause/reset/settle`; `elapsedMs/remainingMs/progress/isComplete`.
- **Yakunlash** — `Habit.finishedAtMs` (nullable) + `isDone(now)`; `HabitsNotifier.finish()` (vaqtni tarixga yozadi, pauza qiladi, bugun bajarildi deb belgilaydi — **vaqt halol, oshmaydi**).
- **Streak + heatmap** — `features/history/data/history_repository.dart`: `currentStreak({todayActive})`, `longestStreak(...)`, `dailyTotalsLastDays(n)`, `dateFromKey`. UI: Statistika ekranida `_StreakHeatmap` (🔥 joriy + eng uzun + 14 haftalik GitHub-uslub heatmap) + dashboard'da 🔥 pill.
- **AI murabbiy (Pro)** — `features/pro/`:
  - **Oflayn:** lokal ma'lumotdan haqiqiy tahlil/tavsiya (`domain/ai_coach.dart`).
  - **Onlayn:** Gemini suhbat (`data/gemini_service.dart`) + multimodal rasm tahlili + **ovozli kiritish** (`speech_to_text`) + **suhbat tarixi** (`state/conversations_notifier.dart`, `conversations` box).
  - **BYOK:** kalit foydalanuvchida (`geminiKeyProvider`), faqat qurilmada.
- **Milliy naqshlar** — `core/widgets/uzbek_motif.dart` (`enum MotifType { star8, lattice, chevron, rosette }`); har sahifaga bittadan (home_shell wrapping).
- **3 til** — custom i18n `core/l10n/l10n.dart` (`_p(uz,en,ru)` helper).
- **Yorug'/Tungi mavzu** — `themeModeProvider` (Hive `theme_mode`); `main.dart` `theme`+`darkTheme`+`themeMode`; standart **Tungi**.
- **Ma'lumot nazorati** — `HabitsNotifier.clearAll()` + `ConversationsNotifier.clearAll()`.
- **Brend belgisi + nomi** — `flutter_launcher_icons` (adaptiv + legacy), manba `assets/icon/icon.png` + `icon_foreground.png` (binafsha yorug'lik yoyi); `AndroidManifest.xml` `android:label="Focus AI"`.

### 2.3. Muhim texnik kelishuvlar (Gemini)
- Model fallback ro'yxati: `['gemini-2.5-flash-lite', 'gemini-2.5-flash']` (flash-lite standart — 1000/kun limit).
- Kalit **`x-goog-api-key` HEADER'da** (URL'da emas).
- `generationConfig.thinkingConfig.thinkingBudget = 0` (thinking o'chirilgan — output token'ni yeb qo'ymasin) + `maxOutputTokens: 2048`.
- Rasm: `inline_data` (`mime_type` + base64).
- Avto-retry: 429/503/network xatolarда; `GeminiException.shortDetail()` diagnostikasi.

### 2.4. Hive kalitlari (`settings` box)
`onboarding_seen`, `auth_done`, `user_name`, `user_emoji`, `language`, `gemini_key`, `theme_mode`, `history_v2`.
**Provayderlar:** `languageProvider`, `l10nProvider`, `userNameProvider`, `userEmojiProvider`, `historyProvider`, `authDoneProvider`, `geminiKeyProvider`, `themeModeProvider`, `habitsProvider`, `conversationsProvider`.

### 2.5. Yechilgan xatolar (log)
- "650%" murabbiy bug (haftani 7 kunga bo'lgan) → faol kunlarga o'rtachalash.
- AI javob kesilishi → `thinkingBudget:0` + maxOutputTokens.
- Rasm tahlili 429 → flash-lite + fallback + retry.
- Ovoz "raqam qo'shadi" → Google ASR mishearing (bizniki emas); append rejim + tahrirlanadigan maydon bilan yumshatildi.
- Auth ism-persist bug → `setName` HAR DOIM chaqiriladi.
- **Yorug' mavzu polishi (oxirgi):** (1) yoy yo'lagi (track) rangini oqdan → odat rangiga (`color.withValues(alpha: 0.14/0.16)`) — yorug'/tungiда ko'rinadi; (2) onboarding har doim to'q + sarlavha oq; (3) MAVZUда System olib tashlandi (eski `'system'` → tungiga map).

### 2.6. Topshiriladigan hujjatlar (TAYYOR)
- `README.md` — professional loyiha hujjati (funksiyalar, arxitektura, ishga tushirish, AI sozlash).
- `TAVSIF.md` — ~370 so'zlik tavsif (TZ 300–500 talabi).
- `DEMO_VIDEO_SSENARIY.md` — 8 sahnali ssenariy (≈2 daqiqa) + yozib olish maslahatlari.

### 2.7. Versiya nazorati va build holati
- **GitHub:** `https://github.com/jahongirmath08-design/focus_ai` (**Public**), branch **`main`**.
- Oxirgi commit: **`ca94218`** — `fix: yorug' mavzu polishi (track, onboarding intro, mavzu tanlovi)`. Push qilingan.
- **`flutter analyze lib` → "No issues found!"** (oxirgi holatда toza).
- **APK:** `build/app/outputs/flutter-apk/app-release.apk` (~**52.2MB**) — yangi belgi + "Focus AI" nomi + barcha tuzatishlar bilan qayta qurilgan; telefonда sinaб ko'rilgan (yorug' mavzu, onboarding, mavzu tanlovi tasdiqlandi).

---

## 3. Qolgan Vazifalar va Yo'l Xaritasi

### 3.1. Zudlik bilan (foydalanuvchi bajaradi)
- **Demo video (🎬):** `DEMO_VIDEO_SSENARIY.md` bo'yicha Redmi ichki "Ekran yozuvi" bilan telefon ekranini yozish (1–3 daqiqa) → YouTube (Unlisted) yoki Google Drive'ga yuklab, **havola** olish.
- **Topshirish (📤):** konkursga 5 narsa — (1) GitHub havola, (2) APK fayl, (3) README (repoда), (4) Tavsif matni, (5) video havola.

### 3.2. Ixtiyoriy sayqal (vaqt bo'lsa — muddatgacha)
- Push bildirishnomalar/eslatmalar (hali YO'Q).
- Bosh ekran vidjeti / Live Activity (YO'Q).
- Ambient audio/ohang (YO'Q).
- Tungi mavzuда yoy yo'lagi rangi bo'yicha foydalanuvchi qarori (rangli halqa qoldirilsinmi — tasdiqlanishi kutilyapti).

### 3.3. Chiqarishdan oldingi tekshiruv
- Video yozilgach — sifat/uzunlik (1–3 daqiqa) va TZ mosligini ko'rib chiqish.
- Yakuniy APK aynan `ca94218` (yoki undan keyingi) holatдан qurilganini tasdiqlash.

---

## 4. Keyingi AI Assistentga Ko'rsatmalar (Transition Directives)

1. **TIL VA TAYMER QOIDASINI BUZMANG.** Foydalanuvchiga barcha muloqot **o'zbek tilida**. Taymer har doim **timestamp asosida** (`accumulatedMs + (now - runningSince)`) — hech qachon tick-counting. Bu ikki qoida muzokara qilinmaydi.

2. **ADDITIV ISHLANG + AGENT PIPELINE.** Ishlab turgan kodni qayta yozmang/buzmang; har o'zgarishдан oldin/keyin git checkpoint. Har feature'ni 5 rolli pipeline (Arxitektor → Quruvchi → Red Team → Fixer → QA) va 14-bandli adversarial checklist orqali o'tkazing. `flutter analyze` toza ekanini VA import/lintlarni **o'zingiz** tekshiring; "o'tdi" deб faqat haqiqatan ishga tushgan bo'lsa ayting — aks holsa foydalanuvchi telefon/webда sinasin.

3. **KONTEKST VA MUHITNI HISOBGA OLING.** Muddat **2026-07-27**; ustuvorlik **Kreativlik+Interaktivlik+Dizayn (75 ball)**. Kompyuter sekin (APK ≈17 daq — behuda qayta qurmang), PowerShell'да `&&` yo'q, dev'да **web** tez. Fayl tuzilishi feature-first (`lib/core`, `lib/features/*`). Repo: `github.com/jahongirmath08-design/focus_ai` (branch `main`). Yangi ish boshlashdan oldin `PROJECT_HANDOFF.md` va joriy kodni o'qib chiqing.
