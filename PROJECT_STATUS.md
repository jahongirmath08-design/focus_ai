# Focus AI — PROJECT_STATUS.md

> Bu fayl bizning sessiyalararo XOTIRAMIZ. Suhbat emas — aynan shu fayl + git tarixi + kod bizning haqiqiy yodimiz.
> Har bir ishchi qadam oxirida yangilanadi. Yangi sessiya boshida AVVAL shu fayl o'qiladi.

**Oxirgi yangilanish:** 2026-06-16
**Loyiha:** Focus AI — vaqtga asoslangan odat kuzatuvchi mobil ilova (konkurs uchun)
**Maqsad:** 100 ballik 5 mezon bo'yicha g'olib bo'lish (Krea 30 + Inter 25 + Diz 20 + Funk 15 + Kod 10)

---

## 1. Hozirgi bosqich va BAJARILGANI (DONE)
- **Phase 0 — Muhit: TUGADI ✅** (Git 2.54.0, Android Studio Quail 2026.1.1, Flutter 3.44.0/Dart 3.12.0; flutter doctor yashil).
- **Phase 1 — Taymer yuragi + saqlash: TELEFONDA ISHLADI ✅ (Redmi 10A, Android 11)**
  - `FocusSession` (timestamp mantiq) + 8 test **All tests passed ✅**. Math mustaqil (Python) 6/6 ✅.
  - Taymer ekrani (start/pauza/resume/reset, progress, maqsad) ✅.
  - **Hive CE saqlash** ishladi ("Saqlash: yoniq", kill/restore sehri) ✅.
  - **GRADLE XOTIRA TUZATILDI:** `android/gradle.properties` -Xmx8G -> -Xmx1024m, daemon off, 1 worker (3GB RAM Celeron uchun). Build muvaffaqiyatli (birinchi build ~30 daq, bir martalik).
  - **Ilova Redmi 10A'da o'rnatildi va OCHILDI ✅** (MIUI "Install via USB" yoqildi).
  - Git: `ac499b4` (timer core), `4f8d75d` (Hive persistence + resilient startup). gradle.properties hali commit qilinmagan.
- **MUHIM QAROR:** Web-debug (flutter run -d web-server) BEQAROR (oq ekran) — RUN-target sifatida rad etildi. Haqiqiy run = **Android telefon (USB)**.

## 2. Aniq KEYINGI qadam (NEXT)
1. **gradle.properties + bu STATUS'ni commit qilish** (joriy ishlaydigan holatni saqlash).
2. **Kichik tuzatishlar (keyingi build bilan birga):**
   - Hive init timeout **3s -> 10s** (sekin telefon cold start'da bir marta timeout bo'ldi; lekin "yoniq" chiqdi — ehtiyot uchun oshiramiz).
   - Vaqtinchalik **"Saqlash: yoniq/o'chiq" debug yozuvini o'chirish** (timer_screen.dart).
3. **Phase 1 yakuni:** Riverpod state + **bir nechta parallel sessiya (ko'p odat)**.
4. **Phase 2:** 6 majburiy ekran skeleti (Onboarding, Auth+guest, Dashboard, Add Habit, Active Session, Profil) — o'zbekcha.

## 3. ISH JARAYONI (dev workflow) — MUHIM
- **RUN = Android telefon (USB).** `flutter run -d QG89QWP7BEGI45PZ`.
- **TEZ LOOP:** `flutter run`ni ishga tushirib **OCHIQ qoldiring** → men kod o'zgartirsam, terminalda **`r`** (hot reload) → telefonda ~1 soniyada ko'rinadi. Build qayta kerak emas!
- To'liq qayta build (sekin, ~5–30 daq bu PC'da) faqat: birinchi marta YOKI yangi native plugin qo'shilganda. Shuning uchun flutter run'ni yopmaslikka harakat qilamiz.
- **Testlar:** alohida PowerShell'da `flutter test`.
- **Git:** Windows PowerShell'da (sandbox mount git'ni ko'tarmaydi). Identity: Jahongir / jahongirmath08@gmail.com.

## 4. KUTILAYOTGAN QARORLAR (tashkilotchi javobiga bog'liq) + PROVISIONAL faraz
| # | Savol | Provisional faraz |
|---|-------|-------------------|
| 1 | Muddat (deadline)? | Noma'lum. ~3–4 hafta deb faraz; poydevor muddatga bog'liq emas. |
| 2 | Platforma: Android/iOS? | **Android only** (Mac yo'q). Telefon: Redmi 10A, Android 11 (API 30). |
| 3 | Min Android versiya? | Flutter default minSdk; keyin aniqlanadi. |
| 4 | IP / litsenziya? | LICENSE hozircha yo'q. |
| 5 | Brending web'dan saqlansinmi? | Palitra PLACEHOLDER (#6C5CE7); barcha rang BITTA theme faylda. |
| 6 | AI murabbiy demo onlayn? | Offline-friendly / ixtiyoriy; Phase 5. |
| 7 | Sudyalar guest yoki ro'yxat? | **Guest-first**. |
| 8 | Jamoa baholash? | Solo. |
| 9 | Faqat o'zbek yetarlimi? | **Uzbek-first**; matn BITTA joyda. |
| 10 | Demo video tili / 3 daq? | O'zbekcha, <=3 daq. |
| 11 | Necha variant? | Bitta kuchli variant. |
| 12 | Figma aktivlari? | Yo'q deb faraz; noldan dizayn. |

## 5. QULFLANGAN stack (LOCKED)
- **Flutter 3.44.0 / Dart 3.12.0** ✅. Android Studio Quail 2026.1.1 ✅. Git 2.54.0 ✅.
- Muhit: LOKAL Windows (profil: BLACK, Celeron N4500, **3GB RAM** — zaif, build sekin). Loyiha: `C:\Users\BLACK\focus_ai`. App id: `com.focusai.focus_ai`.
- **Gradle:** android/gradle.properties — -Xmx1024m, daemon off, workers.max=1, parallel false (3GB uchun shart!).
- **Local storage:** Hive CE (`hive_ce` + `hive_ce_flutter`) ✅ ishladi.
- **State:** Riverpod — keyingi increment'da `flutter pub add` bilan.
- Keyin (Phase 3+): sensors_plus, flutter_local_notifications, just_audio, fl_chart, rive, lottie, flutter_animate, google_fonts, home_widget.
- Qoida: versiyalar `flutter pub add` bilan resolve qilinadi, qo'lda PIN qilinmaydi.

## 6. PAPKA TUZILISHI (hozirgi holat)
```
lib/
  main.dart                          # async: Hive init (timeout 3s -> 10s ga oshirilsin) -> FocusAiApp (dark, #6C5CE7)
  core/utils/duration_format.dart    # ms -> MM:SS / HH:MM:SS
  features/timer/
    domain/focus_session.dart        # TAYMER YURAGI: timestamp mantiq (pure Dart)
    data/session_repository.dart     # Hive saqlash/o'qish (primitiv int)
    ui/timer_screen.dart             # vaqtinchalik taymer (setState) + DEBUG "Saqlash" yozuvi (O'CHIRILSIN)
test/
  focus_session_test.dart            # 7 unit test
  widget_test.dart                   # 1 widget test (Hive temp init)
android/gradle.properties            # 3GB RAM uchun moslangan (MUHIM — o'zgartirmang)
```
**Taymer formulasi (muqaddas):** `elapsed = accumulatedMs + (runningSince != null ? now - runningSince : 0)` — manfiy yo'q; goalMs'dan oshmaydi; kill/restore'da timestamp'dan tiklanadi.

## 7. SCOPE (provisional)
Izchil to'plam: **#1 signature metafora (jon)** + #3 (telefon-yuztuban) + #5 (AI murabbiy o'zbekcha) + #8 (mikro-interaksiya/haptic) + #9 (100% nishonlash) + #10 (interaktiv onboarding). Muddat qisqa -> **#1 + minimal MVP**.

## 8. MEHNAT TAQSIMOTI
- **Men (AI):** butun Dart kod (to'g'ridan-to'g'ri fayllarga), aniq ko'rsatmalar, tekshirish, math testlar.
- **Foydalanuvchi:** terminal buyruqlari (men aytaman), git (Windows), telefonni ulash, hot reload uchun "r".
- Sabab: xavfsizlik chegarasi — AI terminalga yoza olmaydi va tizim sozlamalarini o'zgartira olmaydi.
