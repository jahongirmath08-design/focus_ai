# Focus AI

> **Diqqatni nurga aylantiruvchi odat kuzatuvchi.**

Har diqqat daqiqasi cho'g'dek yoyga quyiladi. Vaqt **timestamp** aniqligida — ilova yopilsa, fonga o'tsa yoki telefon o'chsa ham qayta ochilganda tiklanadi.

| | |
|---|---|
| **Paket** | `com.focusai.focus_ai` |
| **Versiya** | 1.0.0 |
| **Min SDK** | 24 · Android 7.0+ |
| **Target SDK** | 36 · Android 16 |
| **ABI** | arm64-v8a · armeabi-v7a · x86_64 |
| **Texnologiya** | Flutter 3.44 / Dart 3.12 |
| **Muallif** | Jahongir Sattorov |

---

## Nega bu ilova boshqacha — *signature*

Ko'pchilik odat ilovasi tekis progress chizig'i ishlatadi — jonsiz, eslab qolinmaydi. Bizniki real vaqtda to'ladigan **quyma yorug'lik yoyi**: qizigan cho'g' uchi, uchqunlar, maqsadda bir martalik portlash. Bu — ilovaning joni, va u to'liq `CustomPainter`da noldan chizilgan.

## Asosiy imkoniyatlar

- **Quyma yorug'lik yoyi** — diqqat real vaqtda yoyga quyiladi: gradient, cho'g' uchi, uchqunlar. Tashqi kutubxonasiz.
- **100% nishonlash** — immersiv sessiya ekrani, markaziy chaqnash, zarba to'lqini va uchqun portlashi + haptika.
- **Chuqur diqqat (Deep Focus)** — telefonni yuztuban qo'ysang taymer o'zi ketadi, ko'tarsang to'xtaydi (akselerometr).
- **Timestamp-aniq taymer** — kill/restore'da vaqt yo'qolmaydi; maqsadga avtomatik to'xtaydi, oshmaydi.
- **Uch til** — O'zbekcha · English · Русский, to'liq tarjima, tanlov saqlanadi.
- **Statistika** — interaktiv diqqat-taqsimoti halqasi + kunlik/haftalik/oylik/yillik kesim.
- **Seriya va faollik xaritasi** — ketma-ket kunlar hisobi va GitHub uslubidagi heatmap.
- **AI murabbiy (Pro)** — oflayn tahlil kalitsiz + onlayn Gemini suhbati, rasm tahlili, ovozli kiritish.
- **Hisob yoki mehmon** — email/parol bilan haqiqiy ro'yxatdan o'tish (lokal) yoki bir bosishda mehmon.
- **Milliy naqshlar** — shamsa, panjara, ikat va suzani motivlari, har sahifaga moslab.
- **Yorug' / tungi mavzu** — ikkalasi ham to'liq sayqallangan; tanlov saqlanadi.
- **Premium tipografiya** — Space Grotesk ilova ichiga joylangan, internetsiz ham to'g'ri chiqadi.

## Nega Focus AI ajralib turadi

| Mezon | Tipik odat ilovasi | Focus AI |
|---|---|---|
| Vaqt vizuali | tekis progress chizig'i | **jonli quyma yoy** |
| Faol sessiya | ro'yxatdan boshlanadi | **immersiv to'liq ekran** |
| 100% lahzasi | faqat belgi | **portlash + haptika** |
| Sensor | yo'q | **Deep Focus (yuztuban)** |
| Til | aralash yoki bitta | **3 til, benuqson** |
| Jami va foiz | ba'zan mos kelmaydi | **har doim mos** |
| AI murabbiy | yo'q yoki pulli | **oflayn + Gemini (BYOK)** |
| Seriya | oddiy raqam | **seriya + faollik xaritasi** |
| Mavzu | bittasi | **yorug' + tungi** |

## Ekranlar

Onboarding · Kirish (hisob yoki mehmon) · Bugun · Faol sessiya · Statistika · Pro (AI murabbiy) · Profil.
Pastki navigatsiya: **Bugun · Statistika · Pro · Profil**. Har ekran yorug' va tungi mavzuda sinovdan o'tgan; bo'sh va xato holatlar ishlangan.

## Testlar va kod holati

`flutter analyze` → **No issues found**. Testlar: `focus_session_test` (taymer matematikasi — manfiy vaqt, maqsaddan oshish, pauza, tiklanish), `habit_test`, `auth_validator_test`, `widget_test`. Taymer yadrosi Flutter'ga bog'liq emas — **sof Dart**, shuning uchun to'g'ridan-to'g'ri testlanadi.

## Arxitektura — feature-first, toza qatlamlar

```
lib/
  core/              l10n (uz·en·ru) · theme · state
  features/
    timer/           focus_session.dart — TAYMER YURAGI
    active_session/  light_arc.dart — signature
    auth/            validator · account_store · ui
    habits/          model · repository · notifier
    dashboard/       Bugun ekrani · odat qo'shish
    statistics/      donut · streak · heatmap
    history/         focus-tarix · davrlar
    pro/             ai_coach · gemini_service · chat
    onboarding/      3 sahifali tanishtiruv
    home/ profile/   navigatsiya · til · mavzu
test/                focus_session · habit · auth_validator · widget
```

**State:** Riverpod · **Storage:** Hive CE (lokal-first) · **Grafika:** CustomPainter
Flutter 3.44 / Dart 3.12 · fl_chart · sensors_plus · speech_to_text · image_picker · crypto · http · Google Gemini API

### Muqaddas taymer qoidasi

```dart
elapsed = accumulatedMs + (runningSince != null ? now - runningSince : 0)
```

Manfiy vaqt yo'q · maqsaddan oshmaydi · kill/restore'da timestamp'dan tiklanadi · tick-sanash yo'q · bir vaqtda bir nechta mustaqil sessiya.

## Ishga tushirish

Talab: Flutter 3.44+ · Dart 3.12+

```bash
flutter pub get
flutter run                                    # qurilma / emulyator
flutter run -d web-server --web-port 8080      # web (tez ishlanma)
flutter test                                   # unit + widget testlar
flutter build apk --release                    # Android APK
```

### AI murabbiyni yoqish — ixtiyoriy

Oflayn murabbiy **kalitsiz** ishlaydi va real, shaxsiy tahlil beradi. Onlayn Gemini suhbati uchun:

1. [Google AI Studio](https://aistudio.google.com/app/apikey) dan bepul kalit oling.
2. Ilovada **Pro → Murabbiy** bo'limiga bir marta kiriting — kalit faqat shu qurilmada saqlanadi.

## Maxfiylik — lokal-first arxitektura

Hamma ma'lumot **shu qurilmada** saqlanadi (Hive). **Bizda server yo'q, kuzatuv (analytics) yo'q, hech qanday ma'lumot bizga yuborilmaydi** — hisob ochsangiz ham u faqat qurilmada qoladi; parol hech qachon ochiq saqlanmaydi (har hisobga alohida **salt** va **SHA-256**).

Yagona tashqi ulanish — AI murabbiyning **onlayn** rejimi: siz kiritgan kalit bilan to'g'ridan-to'g'ri Google Gemini'ga so'rov ketadi (BYOK). Oflayn rejim hech qayerga ulanmaydi.

> **Android Auto Backup haqida.** Tizim darajasidagi avtomatik zaxira yoqilgan bo'lsa, ilova ma'lumotlari foydalanuvchining **o'z** Google hisobiga zaxiralanishi mumkin — bu Android platformasining standart xatti-harakati, bizga hech narsa yuborilmaydi. Keyingi versiyada bu aniq boshqariladigan qilinadi.

> **Yo'l xaritasi.** Ilovadagi Pro bo'limida `Bulutli zaxira & sinxron` va `Do'stlar kartalari` **«Tez orada»** belgisi bilan ko'rsatilgan — bular rejadagi imkoniyatlar, joriy versiyada ishlamaydi.

---

**Lokal-first. Oflayn. O'z tilingizda.**

Muallif: Jahongir Sattorov · Tanlov uchun yaratilgan · 2026
