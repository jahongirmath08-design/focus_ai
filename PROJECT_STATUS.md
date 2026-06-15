# Focus AI — PROJECT_STATUS.md

> Bu fayl bizning sessiyalararo XOTIRAMIZ. Suhbat emas — aynan shu fayl + git tarixi + kod bizning haqiqiy yodimiz.
> Har bir ishchi qadam oxirida yangilanadi. Yangi sessiya boshida AVVAL shu fayl o'qiladi.

**Oxirgi yangilanish:** 2026-06-15
**Loyiha:** Focus AI — vaqtga asoslangan odat kuzatuvchi mobil ilova (konkurs uchun)
**Maqsad:** 100 ballik 5 mezon bo'yicha g'olib bo'lish (Krea 30 + Inter 25 + Diz 20 + Funk 15 + Kod 10)

---

## 1. Hozirgi bosqich va BAJARILGANI (DONE)
- **Phase 0 — Muhit: TUGADI ✅**
  - Lokal Windows muhit (FlutLab brauzer varianti sinaldi, beqarorligi uchun rad etildi — hisobda zaxira).
  - Git 2.54.0, Android Studio Quail (2026.1.1), Flutter 3.44.0 / Dart 3.12.0 — o'rnatildi.
  - `flutter doctor`: Flutter, Android toolchain, Chrome — yashil ✅ (Visual Studio kerak emas).
  - `focus_ai` loyihasi yaratildi (`--org com.focusai`), Cowork'ga ulandi.
  - "Hello world" brauzerda (web-server :8080) ishladi.
- **Phase 1 — Taymer yuragi: DAVOM ETMOQDA**
  - `FocusSession` (timestamp mantiq) yozildi + 8 ta test **All tests passed ✅** (foydalanuvchi mashinasida).
  - Taymer ekrani (start/pauza/resume/reset, progress, maqsad) brauzerda ishladi ✅.
  - Math mustaqil (Python) ham 6/6 tekshirildi.

## 2. Aniq KEYINGI qadam (NEXT)
**Phase 1 davomi — Saqlash (persistence):** Hive CE qo'shish; sessiyani lokal saqlash; ilova yopilib/yangilanib qayta ochilganda timestamp'dan aniq tiklanishi ("yopib-ochsa ham vaqt qoladi" sehri). So'ng: Riverpod state + bir nechta parallel sessiya.

## 3. ISH JARAYONI (dev workflow)
- Tez iteratsiya: `flutter run -d web-server --web-port 8080` → brauzerda `localhost:8080`. Kod o'zgargach terminalda **`R`** (hot restart) + brauzer F5.
- Testlar: alohida PowerShell'da `flutter test`.
- Native funksiyalar (sensor/haptic/widget) va yakuniy APK: haqiqiy Android telefon (USB) — keyinroq.
- **Git:** sandbox mount git'ni ko'tara olmadi → git buyruqlari Windows PowerShell'da bajariladi (Git natively ishlaydi).

## 4. KUTILAYOTGAN QARORLAR (tashkilotchi javobiga bog'liq) + PROVISIONAL faraz
| # | Savol | Provisional faraz |
|---|-------|-------------------|
| 1 | Muddat (deadline)? | Noma'lum. ~3–4 hafta deb faraz; poydevor muddatga bog'liq emas. |
| 2 | Platforma: Android/iOS? | **Android only** (Mac yo'q). |
| 3 | Min Android versiya? | Flutter default minSdk; keyin aniqlanadi. |
| 4 | IP / litsenziya? | LICENSE hozircha yo'q. |
| 5 | Brending web'dan saqlansinmi? | Palitra PLACEHOLDER; barcha rang BITTA theme faylda. |
| 6 | AI murabbiy demo onlayn? | Offline-friendly / ixtiyoriy; Phase 5. |
| 7 | Sudyalar guest yoki ro'yxat? | **Guest-first**. |
| 8 | Jamoa baholash? | Solo. |
| 9 | Faqat o'zbek yetarlimi? | **Uzbek-first**; matn BITTA joyda. |
| 10 | Demo video tili / 3 daq? | O'zbekcha, <=3 daq. |
| 11 | Necha variant? | Bitta kuchli variant. |
| 12 | Figma aktivlari? | Yo'q deb faraz; noldan dizayn. |

## 5. QULFLANGAN stack (LOCKED)
- **Flutter 3.44.0 (stable) / Dart 3.12.0** — o'rnatildi ✅. Android Studio Quail 2026.1.1 ✅. Git 2.54.0 ✅.
- Muhit: LOKAL Windows (profil: BLACK). Loyiha: `C:\Users\BLACK\focus_ai`. App id: `com.focusai.focus_ai`.
- **State:** Riverpod (keyingi increment'da `flutter pub add` bilan).
- **Local storage:** Hive CE (`hive_ce`, `hive_ce_flutter`) — keyingi qadam.
- Keyin (Phase 3+): sensors_plus, flutter_local_notifications, just_audio, fl_chart, rive, lottie, flutter_animate, google_fonts, home_widget.
- Qoida: versiyalar `flutter pub add` bilan resolve qilinadi, qo'lda PIN qilinmaydi.

## 6. PAPKA TUZILISHI (hozirgi holat)
```
lib/
  main.dart                         # FocusAiApp (dark theme, placeholder #6C5CE7)
  core/utils/duration_format.dart   # ms -> MM:SS / HH:MM:SS
  features/timer/
    domain/focus_session.dart       # TAYMER YURAGI: timestamp mantiq (pure Dart)
    ui/timer_screen.dart            # vaqtinchalik taymer ekrani (setState)
test/
  focus_session_test.dart           # 7 ta unit test (timestamp logic)
  widget_test.dart                  # 1 ta widget test
```
**Taymer formulasi (muqaddas):** `elapsed = accumulatedMs + (runningSince != null ? now - runningSince : 0)` — manfiy yo'q; goalMs'dan oshmaydi; kill/restore'da timestamp'dan tiklanadi.

## 7. SCOPE (provisional)
Izchil to'plam: **#1 signature metafora (jon)** + #3 (telefon-yuztuban) + #5 (AI murabbiy o'zbekcha) + #8 (mikro-interaksiya/haptic) + #9 (100% nishonlash) + #10 (interaktiv onboarding). Muddat qisqa bo'lsa -> **#1 + minimal MVP**.

## 8. MEHNAT TAQSIMOTI
- **Men (AI):** butun Dart kod (to'g'ridan-to'g'ri fayllarga), aniq ko'rsatmalar, tekshirish, math testlar.
- **Foydalanuvchi:** terminal buyruqlari (men aytaman), git (Windows), telefonni ulash, "Run".
- Sabab: xavfsizlik chegarasi — AI terminalga yoza olmaydi va tizim sozlamalarini o'zgartira olmaydi.
