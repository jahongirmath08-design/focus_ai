# Focus AI — PROJECT_STATUS.md

> Sessiyalararo XOTIRAMIZ. Suhbat emas — shu fayl + git tarixi + kod bizning haqiqiy yodimiz.
> Har ishchi qadam oxirida yangilanadi. Yangi sessiya boshida AVVAL shu fayl o'qiladi.

**Oxirgi yangilanish:** 2026-06-21
**Loyiha:** Focus AI — vaqtga asoslangan odat kuzatuvchi mobil ilova (konkurs)
**Maqsad:** 100 ballik 5 mezon bo'yicha g'olib (Krea 30 + Inter 25 + Diz 20 + Funk 15 + Kod 10). G'alaba 75 ballda (Krea+Inter+Diz).

---

## 1. BAJARILGANI (DONE)
- **Phase 0 — Muhit ✅** (Flutter 3.44.0/Dart 3.12.0, Android Studio, Git 2.54.0).
- **Phase 1 — Taymer + saqlash + ko'p odat ✅**: `FocusSession` (timestamp, 8 test), `Habit`, Riverpod `habitsProvider`, Hive saqlash, kill/restore.
- **SIGNATURE DIZAYN ✅**: "Molten light arc" (LightArc) — quyma cho'g' yoy, ember uch, uchqunlar, ambient o'choq foni, 100% PORTLASH. Active Session ekrani (o'tgan UP + "qoldi" countdown). Dashboard kartalarida MiniLightArc. Tugagan holatda "Qaytadan" tugma. Kartadan active'ga **scale+fade+Hero** o'tish.
- **ONBOARDING ✅**: 3 sahifa, yoy **0 dan to'ladi** (signature), staggered entrance (sakrab kattalashish + matn suzishi), "FOCUS AI" wordmark. Bir marta ko'rinadi (Hive 'settings' 'onboarding_seen'). Profilda "qayta ko'rish" bor.
- **WEB YUKLANISH EKRANI ✅**: `web/index.html` — qora brendlangan loader (amber aylanma + "Focus AI"). Oq ekran yo'q.
- **BOSH EKRAN + PASTKI NAVIGATSIYA ✅**: HomeShell (Bugun / Statistika / Profil), IndexedStack.
  - **Bugun**: salom (emoji + vaqtga qarab + ism) + o'zbekcha sana + signature xulosa chiplar (jami diqqat / faol / bajarilgan). Jami vaqt **soniyaga yaxlitlab** hisoblanadi (kartalar yig'indisiga aniq teng).
  - **Statistika**: jonli (ticker), jami diqqat + bajarilgan + umumiy% + har odat mini-yoy bilan. Jami HAR DOIM to'g'ri.
  - **Profil**: emoji avatar + ism (tahrirlanadi) + **til tanlagich** + tanishtiruvni qayta ko'rish + "Ilova haqida" (o'zbekcha + Litsenziyalar tugmasi).
- **KO'P TILLILIK (uz/en/ru) ✅**: `L10n` (barcha matn 3 tilda, bitta joyda), `languageProvider`+`l10nProvider` (Hive saqlanadi). BARCHA ekran tilga ulangan. Profilda til bossang — butun ilova darhol o'zgaradi.
- **SHAXSIYLASHTIRISH ✅**: foydalanuvchi ismi + emoji avatar (`userNameProvider`, `userEmojiProvider`). Odatga ham emoji (modelda `emoji`), nom oldida ko'rinadi. Odat qo'shishda: emoji tanlagich + **qo'lda vaqt** (preset + "Boshqa") + **12 rang**.
- **Git:** … onboarding/loader → Home+i18n+emoji → `5e64162` overflow+DeepFocus matn → `a7a0356` Space Grotesk (bundled)+lint toza (analyze:0). **Saqlanmagan (ishlaydi):** Pro+offline murabbiy, jonli AI (Gemini)+nusxalash.

## 1b. KEYIN QO'SHILGANI (2026-06-21)
- **Deep Focus (sensors_plus) ✅** ekran-pastga → taymer avtomatik (REAL telefonda sinab ko'rildi).
- **Space Grotesk shrift ✅** ilova ICHIGA joylangan (`assets/fonts/`), offline premium. google_fonts olib tashlandi.
- **Statistika grafik ✅** davr tanlagich (kun/hafta/oy/yil) + fl_chart donut + bar.
- **Yakuniy APK ✅** `build/app/outputs/flutter-apk/app-release.apk` (~50MB), telefonda ishlaydi. `flutter analyze`: No issues found.
- **PRO BO'LIM ✅** 4-tab "Pro" (premium gradient hub). Offline AI-murabbiy (statistikadan shaxsiy tahlil, kalitsiz) + online teaser kartalar. 3 til.
- **JONLI AI (Gemini) ✅** `gemini-2.5-flash`, kalit `x-goog-api-key` sarlavhada (URL emas), kalit faqat qurilmada (Hive). "Thinking" o'chirilgan → javob TO'LIQ. Murabbiy real statistikani biladi. Suhbat: SelectableText so'z-tanlash + "Nusxalash" tugmasi + haptika. Kalitsiz fallback (`GeminiKeyNotifier._embeddedKey`) tayyor.
- Yangi fayllar: `features/pro/{domain/ai_coach.dart, ui/pro_screen.dart, ui/coach_chat_screen.dart, data/gemini_service.dart}`; `app_settings.dart`+`geminiKeyProvider`; `http` paket.
- **MULTIMODAL ✅** suhbatga rasm (`image_picker`) → Gemini `inline_data`; murabbiy rasmni KO'RIB, foydalanuvchi nima bilan shug'ullanishini fahmlab, real statistikaga bog'lab tahlil qiladi. MIME avtomatik aniqlanadi.
- **ISHONCHLILIK ✅** model fallback (flash-lite→flash band/kvota bo'lsa) + auto-retry; 429/503/tarmoq uchun chiroyli o'zbekcha xabarlar. SelectableText so'z-nusxalash + "Nusxalash" tugmasi.
- **SUHBAT TARIXI ✅** suhbatlar Hive 'conversations' box'ida saqlanadi (sessiyalararo). AppBar'da tarix + yangi suhbat tugmalari; pastdan ro'yxat (ochish/o'chirish); sarlavha 1-xabardan. Yangi: `pro/{domain/conversation.dart, state/conversations_notifier.dart}`; main.dart 'conversations' box. **Har bo'lim ALOHIDA tarix** (`category`: chat / analysis / kelajakda boshqalar).
- **OVOZLI KIRITISH ✅** mikrofon → matn (`speech_to_text`, tilga mos uz/en/ru). Suhbat kiritishida mic tugmasi + "Tinglayapman" holati. Manifest: **INTERNET + RECORD_AUDIO** ruxsatlari (release APK uchun MUHIM — busiz AI ishlamaydi!).
- **KALIT YO'RIQNOMA ✅** ikonkali 3 qadam (🌐/🔑/📋) + "bepul·bir marta·shu qurilmada"; har bo'limga o'z salomi (murabbiy vs tahlilchi).
- **MILLIY NAQSH ✅** `core/widgets/uzbek_motif.dart` (CustomPaint, 4 geometrik tur): Bugun=panjara, Statistika=ikat-zigzag, Pro=shamsa-yulduz, Profil=suzani. `home_shell` har tabni o'z naqshi bilan o'raydi; ekran Scaffold fonlari shaffof.
- **Keyingi:** yangi yakuniy APK (barcha funksiyalar); demo video. (Bulut/do'stlar — konkursdan keyin, backend kerak.)

## 2. KEYINGI qadam (NEXT)
1. **Rasm (multimodal)** — `image_picker` → Gemini `inline_data`; murabbiy rasmni tushunadi/tahlil qiladi.
2. **Ovoz** — `speech_to_text` → mikrofon → matnga → yuborish (Android RECORD_AUDIO ruxsati kerak).
3. Bildirishnomalar (`flutter_local_notifications`).
4. Yakuniy: `_embeddedKey`ga kalit → kalitsiz APK + demo video (o'zbekcha, ≤3 daq).

## 3. RAQOBAT STRATEGIYASI (raqiblar tahlili — MUHIM)
**G'alaba 3 strukturaviy ustunlikda — uchchalasi bizda BOR, raqiblarda YO'Q:** (1) jonli "vaqt" vizuali (quyma yoy), (2) immersiv to'liq ekran sessiya, (3) 100% nishonlash.
- **Rival A (web):** generik, tekis chiziq, 0% qizil (xatodek), Boshlash tugmasi qizil (buzuq semantika), nishonlash yo'q. → Biz: signature yoy, to'g'ri semantika.
- **Rival B (mobil, jiddiy):** tekis chiziq, **aralash til** (ingliz nomlar), %/jami **mos kelmaydi** (xato), nishonlash yo'q, immersiv sessiya yo'q. → Biz: jonli yoy, **3 til benuqson**, timestamp aniq, jami doim mos, immersiv sessiya, nishonlash.
- **COMPETITIVE CHECK (har ekran uchun):** 1) ikkala raqibdan aniq yaxshimi? 2) signature ruhi bormi? 3) ko'chirmadikmi? 4) til benuqsonmi?

## 4. ISH JARAYONI (dev workflow)
- **TEZ LOOP = WEB:** `flutter run -d web-server --web-port 8080` ochiq qoladi. Brauzer: localhost:8080.
  - Kod o'zgarsa → **`r`** (hot reload). Web'da `r` ba'zan TIMEOUT (qizil) → **`R`** (KATTA, hot restart) ishonchli. Taymerlar `R` dan keyin omon (Hive).
  - 3GB RAM'da yuklash sekin (~20-40s) — endi brendlangan loader ko'rinadi (oq emas). Android'da sekinlik yo'q.
  - PowerShell oynasini yopib qo'ysa: yangi oyna → `cd C:\Users\BLACK\focus_ai` → `flutter run -d web-server --web-port 8080`.
- **Git:** Windows PowerShell'da, ALOHIDA oynada (flutter oynasi band). `git add lib/ test/ ...`. CRLF churn'dan qochish uchun faqat kerakli yo'llarni qo'shamiz. Identity: Jahongir / jahongirmath08@gmail.com.
- **TIL QOIDASI:** foydalanuvchiga BARCHA tushuntirish — O'ZBEK tilida. Kod/comment ingliz mumkin.
- **Verifikatsiya:** men web'ni Chrome orqali ko'ra olaman, LEKIN <1s animatsiyalarni skrinshot ushlay olmaydi → foydalanuvchining jonli ko'zi hakam. Chrome MCP ba'zan beqaror.

## 5. QULFLANGAN stack
- Flutter 3.44.0 / Dart 3.12.0. Lokal Windows (BLACK, Celeron N4500, 3GB RAM — zaif). Loyiha: `C:\Users\BLACK\focus_ai`. App id: `com.focusai.focus_ai`.
- State: Riverpod. Storage: Hive CE ('habits' + 'settings' box).
- Gradle: `android/gradle.properties` — -Xmx1024m, daemon off, 1 worker (3GB uchun SHART).
- Rang: `app_colors.dart` — accent #6C5CE7, `habitColors` **12 ta**.
- Keyin: fl_chart, flutter_local_notifications, sensors_plus, google_fonts.

## 6. PAPKA TUZILISHI
```
lib/
  main.dart                         # Hive init (habits+settings, 15s) -> ProviderScope -> RootGate (onboarding/HomeShell)
  core/
    l10n/l10n.dart                  # L10n: barcha matn uz/en/ru, AppLanguage enum
    state/app_settings.dart         # languageProvider, l10nProvider, userNameProvider, userEmojiProvider (Hive 'settings')
    theme/app_colors.dart           # accent + 12 habit rang
    utils/duration_format.dart      # ms->MM:SS, roundUp (qoldi uchun)
    utils/uz_date.dart              # O'LIK (ishlatilmaydi, o'chirilsin)
  features/
    timer/domain/focus_session.dart # TAYMER YURAGI (timestamp, 8 test)
    timer/{ui/timer_screen.dart, data/session_repository.dart}  # ESKI, o'chirilsin
    habits/domain/habit.dart        # Habit (id,name,colorValue,createdAt,emoji,session)
    habits/data/habits_repository.dart, state/habits_notifier.dart
    home/ui/home_shell.dart         # pastki navigatsiya (Bugun/Statistika/Profil)
    dashboard/ui/{dashboard_screen.dart, add_habit_sheet.dart}
    statistics/ui/statistics_screen.dart
    profile/ui/profile_screen.dart  # emoji avatar + ism + til tanlagich + about
    onboarding/ui/onboarding_screen.dart
    active_session/ui/{active_session_screen.dart, light_arc.dart}  # LightArc+MiniLightArc+ArcRing
test/  focus_session_test(7), habit_test(2), widget_test(Home)
web/index.html                      # brendlangan qora loader
android/gradle.properties           # 3GB sozlama (o'zgartirmang)
```
**Taymer formulasi (muqaddas):** `elapsed = accumulatedMs + (runningSince!=null ? now-runningSince : 0)` — manfiy yo'q; goalMs'dan oshmaydi; kill/restore'da timestamp'dan tiklanadi.

## 7. MEHNAT TAQSIMOTI
- **Men (AI):** butun Dart kod, ko'rsatmalar, tekshirish (web Chrome), testlar, status.
- **Foydalanuvchi:** terminal (`r`/`R`), git (Windows PowerShell), jonli vizual tasdiq.
- Sabab: AI terminal stdin'ga (`r`) yoza olmaydi, tizim sozlamalarini o'zgartira olmaydi.
