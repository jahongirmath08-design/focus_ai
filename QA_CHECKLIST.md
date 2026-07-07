# Yakuniy QA Checklist — Android 16+ va Oflayn (QA_CHECKLIST)

> **Sinov muhiti (hakam):** Android **16+** (API 36) fizik qurilma [J6] · APK Telegram orqali yangi o'rnatilgan · **Gemini kaliti kiritilmagan** · standart **mehmon rejimi** · Yorug' va Tungi mavzu — ikkalasi ham.
>
> **Qoida:** har band real qurilmada tekshiriladi. "O'tdi" faqat haqiqatan ishlaganда belgilanadi. Topshiriq bitta — qoralama yuborilmaydi [J3].

---

## 1. O'rnatish va birinchi ishga tushirish
- [ ] APK yangi qurilmaga toza o'rnatiladi (Telegram orqali), o'rnatish xatosi yo'q.
- [ ] Sovuq ishga tushirish — oq ekran yo'q, brendlangan yuklanish.
- [ ] Onboarding: 3 sahifa, **Skip har doim ko'rinadi**, staggered animatsiya + parallaks + haptika ishlaydi.
- [ ] Onboarding faqat bir marta ko'rinadi (qayta ochishda o'tkazib yuboriladi).
- [ ] Ilova nomi **"Focus AI"**, launcher belgisi to'g'ri (adaptiv + legacy).

---

## 2. Android 16+ (API 36) ga xos tekshiruvlar

### 2.1. Ruxsatlar
- [ ] `INTERNET` (o'rnatish vaqtida) — AI va ovoz ishlashiga to'sqinlik yo'q.
- [ ] `RECORD_AUDIO` — mikrofon birinchi bosilganда runtime so'rov chiqadi.
- [ ] Ruxsat **rad etilsa** — ilova qulamaydi, o'zbekcha tushuntirish, matn kiritish ochiq qoladi.
- [ ] Ruxsat **berilsa** — ovozli kiritish (uz/en/ru) ishlaydi.
- [ ] Bildirishnoma ruxsati hozircha talab qilinmaydi (agar keyin qo'shilsa — API 33+ da `POST_NOTIFICATIONS` runtime so'rovi).

### 2.2. Edge-to-edge va insets (API 35+ da majburiy — kritik)
- [ ] Kontent status bar ortiga **kirib ketmaydi** (sarlavhalar to'liq ko'rinadi).
- [ ] Pastki navigatsiya jest paneli/nav bar ostiga **tushmaydi**.
- [ ] O'yiq/kamera teshigi (notch/punch-hole) bo'lgan ekranda safe-area to'g'ri.
- [ ] Status bar ikonkalari Yorug'/Tungi mavzuда o'qilishi mumkin (kontrast to'g'ri).

### 2.3. Predictive back (jest bilan orqaga)
- [ ] Orqaga jesti silliq ishlaydi, ilova to'satdan yopilmaydi.
- [ ] Faol sessiyadan orqaga — taymer holati yo'qolmaydi (timestamp saqlanadi).

### 2.4. Fon va hayot-sikl (background execution)
- [ ] Sessiya ishlayotganда ilovani fonga tashlab qaytish → **o'tgan vaqt aniq** (timestamp, tick emas).
- [ ] Sessiya o'rtasida ilovani **o'ldirib** qayta ochish → timestamp'dan tiklanadi, manfiy yo'q, maqsaddan oshmaydi.
- [ ] **Deep Focus:** telefon yuztuban (ekran yoniq) → taymer avtomatik ketadi; ko'tarilsa to'xtaydi.
- [ ] Ekran o'chganда/fon rejimida akselerometr xulqi tekshirildi (Android sensor throttling holati baholandi).
- [ ] Doze/batareya optimizatsiyasi: uzoq pauzadan keyin davom etganда vaqt aniq.

---

## 3. Oflayn funksionallik va graceful degradation

### 3.1. To'liq oflayn oqim (aeroplan rejimi YONIQ)
- [ ] Yangi mehmon: odat qo'shish (8+ emoji, 12 rang, maqsad soat) — ishlaydi.
- [ ] Sessiya: Boshlash → Pauza → Davom etish → Yakunlash — hammasi oflayn.
- [ ] 100% ga yetganда **PORTLASH** animatsiyasi + haptika ishlaydi, aniq maqsadда to'xtaydi.
- [ ] Ilovani qayta ochganда barcha odat va jarayon tiklanadi (Hive).
- [ ] Streak + heatmap oflayn to'g'ri hisoblanadi.

### 3.2. AI murabbiy — OFLAYN, kalitsiz (hakam buni birinchi ko'radi)
- [ ] Pro bo'limini kalitsiz ochish → **oflayn murabbiy real, shaxsiy tahlil ko'rsatadi** (`ai_coach.dart`), o'zbekcha.
- [ ] Raqamlar mantiqiy (faol kunlarga o'rtachalash — "650%" kabi buzuq raqam yo'q).
- [ ] Kalit so'rovi oflayn murabbiyni **bloklamaydi** (tahlil kalitsiz chiqadi).

### 3.3. Onlayn AI ulanmaganда (graceful)
- [ ] Onlayn suhbat kalitsiz → aniq o'zbekcha yo'riqnoma (3 qadam: 🌐/🔑/📋), qulash emas.
- [ ] Kalit bor, lekin internet yo'q → o'zbekcha xato ("Internet yo'q..."), auto-retry.
- [ ] `429` / `503` → model fallback (flash-lite → flash) + retry + chiroyli o'zbekcha xabar.
- [ ] Foydalanuvchiga **xom exception/stacktrace ko'rsatilmaydi** — faqat o'zbekcha tushuntirish.
- [ ] Ovoz ASR xatosi (raqam qo'shilishi) — append rejim + tahrirlanadigan maydon bilan yumshatilgan.

---

## 4. Mehmon (keyless) va ro'yxatdan o'tgan foydalanuvchi imtiyozlari

### 4.1. Mehmon rejimi
- [ ] Ro'yxatdan o'tishsiz barcha lokal funksiya ishlaydi (odat, sessiya, statistika, oflayn murabbiy).
- [ ] Ixtiyoriy ism kiritish → salomlashishда ko'rinadi; bo'sh qoldirilsa ham davom etadi.

### 4.2. Ro'yxatdan o'tgan foydalanuvchi (auth qo'shilgach — `AUTH_PIPELINE.md`)
- [ ] Email/parol bilan ro'yxatdan o'tish, kirish, **parolni tiklash** ishlaydi.
- [ ] Barcha auth xatolari o'zbekcha va aniq.
- [ ] Oldin kirgan foydalanuvchi **oflayn** ilovani ochsa — keshlangan sessiya bilan kiradi.
- [ ] Mehmon → hisobga ulanganда lokal ma'lumot **o'chirilmaydi**.

### 4.3. Chiqish (logout) — ikki tanlov
- [ ] "Shunchaki chiqish" → kirish ekraniga qaytadi, **lokal ma'lumot saqlanadi**.
- [ ] "Chiqish va o'chirish" (qizil) → ikkinchi tasdiq → `clearAll` (habits + history + conversations + ism/emoji/kalit).

---

## 5. Taymer aniqligi (ilovaning yuragi — muqaddas)
- [ ] Manfiy vaqt YO'Q; maqsaddan oshib ketish YO'Q.
- [ ] Pauza `accumulatedMs` ga to'g'ri qo'shiladi.
- [ ] **Bir nechta parallel sessiya** mustaqil (biri pauzada, boshqasi ishlayotgan bo'lishi mumkin).
- [ ] Bosh ekrandagi jami vaqt kartalar yig'indisiga aniq teng (yaxlitlash izchil).
- [ ] 100% → bir martalik portlash + haptika, aniq maqsadда settle.

---

## 6. Til va dizayn (kreativlik/dizayn ballari)
- [ ] Barcha foydalanuvchi matni **benuqson o'zbekcha** — aralash til yo'q.
- [ ] Til almashtirish (uz/en/ru) → butun ilova **darhol** o'zgaradi.
- [ ] Yorug' va Tungi mavzu — ikkalasida ham yoy yo'lagi, onboarding, sarlavhalar o'qilishi mumkin.
- [ ] Bo'sh holat (odat yo'q) — chiroyli boshlang'ich ekran.
- [ ] Xato holatlari graceful; rang semantikasi izchil (Boshlash qizil emas va h.k.).
- [ ] Mikro-interaksiyalar va haptika his qilinadi (interaktivlik balli).

---

## 7. Kod va topshiriq sifati
- [ ] `flutter analyze` → **No issues found**.
- [ ] Testlar o'tadi: `focus_session_test`, `habit_test`, `widget_test`.
- [ ] `README.md` va `TAVSIF.md` (~370 so'z) repoда mavjud va dolzarb.
- [ ] Yakuniy APK aynan oxirgi commit'dан qurilgan (versionCode tekshirilgan).
- [ ] Demo video **o'zbek tilida**, jonli onlayn AI ko'rsatilgan (o'z kaliting bilan) [J7].
- [ ] Topshiriq to'plami: GitHub havolasi · APK · README · TAVSIF · video havolasi (TZ 8-bo'lim).
