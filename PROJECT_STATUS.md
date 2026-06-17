# Focus AI — PROJECT_STATUS.md

> Bu fayl bizning sessiyalararo XOTIRAMIZ. Suhbat emas — aynan shu fayl + git tarixi + kod bizning haqiqiy yodimiz.
> Har bir ishchi qadam oxirida yangilanadi. Yangi sessiya boshida AVVAL shu fayl o'qiladi.

**Oxirgi yangilanish:** 2026-06-17
**Loyiha:** Focus AI — vaqtga asoslangan odat kuzatuvchi mobil ilova (konkurs uchun)
**Maqsad:** 100 ballik 5 mezon bo'yicha g'olib bo'lish (Krea 30 + Inter 25 + Diz 20 + Funk 15 + Kod 10). G'alaba 75 ball (Krea+Inter+Diz)da.

---

## 1. BAJARILGANI (DONE)
- **Phase 0 — Muhit ✅** (Git 2.54.0, Android Studio Quail 2026.1.1, Flutter 3.44.0/Dart 3.12.0; flutter doctor yashil).
- **Phase 1 — Taymer yuragi + saqlash + ko'p odat ✅**
  - `FocusSession` (timestamp mantiq, pure Dart) + **8 test pass ✅**.
  - `Habit` model, `HabitsRepository` (Hive), `HabitsNotifier` (Riverpod `NotifierProvider`, `habitsProvider`).
  - Dashboard: **bir nechta parallel odat**, har biri MUSTAQIL taymer; qo'shish/start/pauza/reset/delete; Hive saqlash; kill/restore ishladi.
  - Hive init timeout **15s** (sekin telefon cold start uchun).
  - Gradle xotira tuzatildi (3GB RAM) — `android/gradle.properties`.
- **SIGNATURE DIZAYN BOSQICHI ✅ (web'da JONLI tasdiqlandi)**
  - **"Molten light arc"** — quyma cho'g' yoy: SweepGradient (sovigan→rang→qizigan), porlayotgan ember uch, uchqunlar, ambient "o'choq" foni (progress bilan qiziydi), 100% da bir martalik PORTLASH (markaziy chaqnash + ikki zarba to'lqini + 20 radial uchqun + doimiy korona).
  - **Active Session ekrani:** katta yoy + o'tgan vaqt (UP sanaydi, 54px tabular) + "qoldi" countdown (yuqoriga yaxlitlanadi → o'tgan + qoldi = maqsad, off-by-one tuzatildi). Haptic (start/pauza/reset/100%).
  - **Dashboard kartalari:** chapda MINI yoy (yengil, AnimationController YO'Q — ro'yxat performansi uchun) markazida % yoki ✓; o'rtada nom/vaqt/holat; o'ngda dumaloq tugma.
  - **Tugagan holat tugmasi:** "Qaytadan" (⟳) — pauza EMAS (karta + active ekran ikkalasida ham). Tugma `complete`ni hisobga oladi.
  - **Kartadan active ekranga o'tish:** `PageRouteBuilder` — scale (0.85→1.0) + fade, 600ms (easeOutCubic). Ustiga Hero yoy tag (`habitArc_<id>`). Jonli tasdiqlandi ✅.
- **Git tarixi:** `ac499b4` timer core → `4f8d75d` Hive persistence → `9bbca37` Gradle/Hive verified → `aec1fef` Phase 1 complete (Riverpod+multi-habit) → `ce4abd3` signature design (arc+active+ambient+burst+off-by-one). **Keyingi commit:** Hero/scale transition + restart button + mini-arc (hozir saqlanmoqda).

## 2. KEYINGI qadam (NEXT)
1. **(hozir)** Hero/transition + restart button commit (lib/ + bu STATUS).
2. **Qolgan majburiy ekranlar:** Onboarding (interaktiv), Auth + **guest**, Profil — o'zbekcha.
3. **Boshqa "wow":** haptic (bor) kengaytirish, bildirishnomalar, AI murabbiy (o'zbekcha), statistika (fl_chart), google_fonts (Inter/Manrope).
4. **Tozalash:** ishlatilmayotgan `timer_screen.dart` + `session_repository.dart` o'chirish (dead code).
5. **Yakuniy:** Android APK build + demo video (o'zbekcha, ≤3 daq).

## 3. ISH JARAYONI (dev workflow) — YANGILANDI, MUHIM
- **TEZ LOOP = WEB.** `flutter run -d web-server --web-port 8080` — terminal OCHIQ qoladi. Brauzer: http://localhost:8080.
  - Kod o'zgarsa → terminalda **`r`** (hot reload, ~1s). Web'da `r` ba'zan reassemble TIMEOUT beradi (qizil) — u holda **`R`** (KATTA harf, hot restart) — ishonchli. **Taymerlar `R` dan keyin omon qoladi** (Hive — bu arxitektura isboti).
  - Birinchi/qayta to'liq yuklash 3GB RAM'da SEKIN (~20–40s). Sabr.
- **ESKI QAROR BEKOR:** "web rad etildi (oq ekran)" — sabab Hive init edi, tuzatildi (try/catch + timeout). Endi **web = asosiy iteratsiya muhiti**. Android faqat **yakuniy APK/native test** uchun (build sekin ~30 daq).
- **Testlar:** alohida PowerShell'da `flutter test`.
- **Git:** Windows PowerShell'da (sandbox `.git/index.lock`ni o'chira olmaydi + CRLF churn). `git add lib/ PROJECT_STATUS.md` → toza commit (boilerplate'siz). Identity: Jahongir / jahongirmath08@gmail.com.
- **TIL QOIDASI:** foydalanuvchiga BARCHA tushuntirish — **O'ZBEK** tilida. Kod/fayl/comment — inglizcha mumkin.
- **Verifikatsiya:** men web'ni Chrome orqali o'zim ko'ra olaman (skrinshot), LEKIN <1s animatsiyalarni skrinshot ushlay olmaydi — bunday hollarda foydalanuvchining jonli ko'zi hakam.

## 4. KUTILAYOTGAN QARORLAR + PROVISIONAL faraz
| # | Savol | Faraz |
|---|-------|-------|
| 1 | Deadline? | Noma'lum (~3–4 hafta faraz). |
| 2 | Platforma? | **Android only** (Mac yo'q). Redmi 10A, Android 11 (API 30). |
| 3 | Min Android? | Flutter default minSdk. |
| 4 | IP/litsenziya? | LICENSE hozircha yo'q. |
| 5 | Brending? | Palitra PLACEHOLDER (#6C5CE7); barcha rang BITTA theme faylda. |
| 6 | AI murabbiy onlayn? | Offline-friendly; keyingi phase. |
| 7 | Sudyalar guest/ro'yxat? | **Guest-first**. |
| 8 | Jamoa? | Solo. |
| 9 | Faqat o'zbek? | **Uzbek-first**; matn bir joyda. |
| 10 | Demo video? | O'zbekcha, ≤3 daq. |

## 5. QULFLANGAN stack (LOCKED)
- **Flutter 3.44.0 / Dart 3.12.0** ✅. Android Studio Quail 2026.1.1 ✅. Git 2.54.0 ✅.
- Muhit: LOKAL Windows (profil: BLACK, Celeron N4500, **3GB RAM** — zaif). Loyiha: `C:\Users\BLACK\focus_ai`. App id: `com.focusai.focus_ai`.
- **State:** Riverpod (`flutter_riverpod`) ✅ ishlatilmoqda. **Storage:** Hive CE (`hive_ce` + `hive_ce_flutter`) ✅.
- **Gradle:** `android/gradle.properties` — -Xmx1024m, daemon off, workers.max=1, parallel false (3GB uchun SHART — o'zgartirmang).
- **Rang:** `core/theme/app_colors.dart` — accent #6C5CE7 (PLACEHOLDER), `habitColors` 6 ta.
- Keyin (Phase 3+): google_fonts, fl_chart, flutter_local_notifications, just_audio, sensors_plus, flutter_animate, lottie/rive.
- Qoida: versiyalar `flutter pub add` bilan resolve, qo'lda PIN qilinmaydi.

## 6. PAPKA TUZILISHI (hozirgi holat)
```
lib/
  main.dart                              # async Hive init (timeout 15s) -> ProviderScope -> DashboardScreen (dark M3, #6C5CE7)
  core/theme/app_colors.dart             # accent + 6 habit rang
  core/utils/duration_format.dart        # ms -> MM:SS / HH:MM:SS; roundUp (qoldi countdown uchun)
  features/timer/
    domain/focus_session.dart            # TAYMER YURAGI: timestamp mantiq (pure Dart, 8 test)
    ui/timer_screen.dart                 # ESKI, ISHLATILMAYDI (o'chirilsin)
    data/session_repository.dart         # ESKI, ISHLATILMAYDI (o'chirilsin)
  features/habits/
    domain/habit.dart                    # Habit model (id, name, colorValue, createdAt, FocusSession)
    data/habits_repository.dart          # Hive 'habits' box repo
    state/habits_notifier.dart           # Riverpod NotifierProvider -> habitsProvider
  features/dashboard/ui/
    dashboard_screen.dart                # ro'yxat + MiniLightArc karta + Hero/scale o'tish
    add_habit_sheet.dart                 # nom + maqsad(chip) + rang tanlash
  features/active_session/ui/
    active_session_screen.dart           # katta yoy + vaqt + qoldi + tugmalar + ambient fon
    light_arc.dart                       # LightArc (signature) + MiniLightArc + ArcRing (Hero shuttle) + arcFlightShuttleBuilder
test/
  focus_session_test.dart                # 7 test    habit_test.dart # 2 test    widget_test.dart # Dashboard
android/gradle.properties                # 3GB RAM uchun moslangan (O'ZGARTIRMANG)
```
**Taymer formulasi (muqaddas):** `elapsed = accumulatedMs + (runningSince != null ? now - runningSince : 0)` — manfiy yo'q; goalMs'dan oshmaydi; kill/restore'da timestamp'dan tiklanadi. Tick-sanash YO'Q.

## 7. SCOPE (provisional)
Izchil to'plam: **#1 signature metafora (jon) — BAJARILDI** + #3 (telefon-yuztuban) + #5 (AI murabbiy o'zbekcha) + #8 (mikro-interaksiya/haptic — qisman bor) + #9 (100% nishonlash — bor) + #10 (interaktiv onboarding).

## 8. MEHNAT TAQSIMOTI
- **Men (AI):** butun Dart kod (to'g'ridan-to'g'ri fayllarga), aniq ko'rsatmalar, tekshirish (web Chrome orqali), math/unit testlar, status yuritish.
- **Foydalanuvchi:** terminal buyruqlari (men aytaman), git (Windows PowerShell), hot reload uchun `r`/`R`, jonli vizual tasdiq.
- Sabab: xavfsizlik chegarasi — AI terminal stdin'ga yoza olmaydi (flutter `r`) va tizim sozlamalarini o'zgartira olmaydi.
