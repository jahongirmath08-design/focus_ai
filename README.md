# Focus AI ✨

> Diqqatni nurga aylantiruvchi odat kuzatuvchi.

**Focus AI** — vaqtga asoslangan odat (focus) kuzatuvchi mobil ilova. Har bir diqqat
daqiqasi *quyma cho'g'dek* yoyga quyiladi: maqsadga yetganda yoy butunlay yonadi.
Lokal-first, timestamp aniqligidagi taymer — ilova yopilsa, fonga o'tsa yoki telefon
o'chsa ham vaqt qayta ochilganda **aniq** tiklanadi.

---

## Nega bu ilova boshqacha (signature)

Ko'pchilik odat ilovalari **tekis progress chizig'i** ishlatadi — jonsiz, eslab
qolinmaydi. Bizning **signature "quyma yorug'lik yoyi"** (molten light arc) — real
vaqtda to'ladigan, qizigan ember uchi va uchqunlari bo'lgan jonli metafora. Bu —
ilovaning **joni**, va aynan shu bizni har qanday shablon kuzatuvchidan ajratadi.

## Asosiy imkoniyatlar

- **Signature jonli yoy** — diqqat real vaqtda yoyga "quyiladi" (CustomPaint, gradient, ember, uchqunlar).
- **Immersiv faol sessiya** ekrani + **100% nishonlash** (markaziy chaqnash, zarba to'lqini, uchqun portlashi).
- **Chuqur diqqat (Deep Focus)** — telefonni yuztuban qo'ysang taymer o'zi ketadi, ko'tarsang to'xtaydi (akselerometr). *Raqiblarda yo'q.*
- **3 til** — O'zbekcha / English / Русский, to'liq tarjima + til tanlagich (tanlov saqlanadi).
- **Statistika** — diqqat taqsimoti **donut** (interaktiv) + **Kunlik / Haftalik / Oylik / Yillik** + focus-tarix.
- **Shaxsiylashtirish** — ism + emoji avatar, har odatga emoji, 12 rang, qo'lda vaqt kiritish.
- **Timestamp-aniq taymer** — kill/restore'da vaqt yo'qolmaydi; maqsadga **avtomatik to'xtaydi** (oshmaydi).
- **Premium tipografiya** (Space Grotesk) + brendlangan yuklanish ekrani va **ilova belgisi**.
- **Lokal-first / mehmon rejimi** — ro'yxatdan o'tish shart emas, hammasi qurilmada (Hive).
- **AI murabbiy (Pro)** — **oflayn** tahlil + **onlayn Google Gemini** suhbati, **rasm tahlili** (multimodal), **ovozli kiritish** va suhbat tarixi. Kalit foydalanuvchida (BYOK).
- **Seriya 🔥 + faollik xaritasi** — ketma-ket kunlar va GitHub uslubidagi heatmap.
- **Yakunlash** — odatni bugun bajarilgan deb belgilaydi; vaqt **halol** qoladi.
- **Yorug' / tungi mavzu** — almashtiriladi, tanlov saqlanadi.
- **Milliy naqshlar** — shamsa, panjara, ikat va suzani motivlari (har sahifaga moslab).

## Nega g'olib (raqiblardan ustun)

| Mezon | Tipik raqib | Focus AI |
|-------|-------------|----------|
| Vaqt vizuali | tekis chiziq | **jonli quyma yoy** |
| Faol sessiya | ro'yxatdan boshlanadi | **immersiv to'liq ekran** |
| 100% nishonlash | faqat ✓ | **portlash + haptic** |
| Sensor | yo'q | **Deep Focus (yuztuban)** |
| Til | aralash/bitta | **3 til, benuqson** |
| Jami/foiz | ba'zan xato | **har doim mos** |
| AI murabbiy | yo'q / pulli | **oflayn + Gemini (bepul)** |
| Seriya | oddiy raqam | **🔥 + faollik xaritasi** |
| Mavzu | bittasi | **yorug' + tungi** |

## Arxitektura

Feature-first, toza qatlamlar. **State:** Riverpod. **Storage:** Hive CE (lokal-first).
Taymer yuragi — **pure Dart** (Flutter'siz), unit testlar bilan qoplangan.

```
lib/
  core/        l10n (uz/en/ru), state (providers), theme, utils
  features/
    timer/          focus_session.dart — TAYMER YURAGI (timestamp, pure Dart)
    habits/         model + repository + Riverpod notifier
    dashboard/      Bugun ekrani + odat qo'shish
    active_session/ immersiv sessiya + light_arc (signature)
    onboarding/     3 sahifali tanishtiruv
    auth/           kirish (mehmon rejimi)
    home/           pastki navigatsiya (Bugun/Statistika/Pro/Profil)
    statistics/     donut + streak + heatmap
    pro/            AI murabbiy (oflayn + Gemini, rasm, ovoz)
    profile/        til + mavzu + ism + emoji
    history/        focus-tarix (streak, heatmap, davrlar)
test/             focus_session, habit, widget testlari
```

**Muqaddas taymer qoidasi:**
```
elapsed = accumulatedMs + (runningSince != null ? now - runningSince : 0)
```
Manfiy yo'q · maqsaddan oshmaydi · kill/restore'da timestamp'dan tiklanadi · tick-sanash YO'Q.

## Texnologiyalar

Flutter 3.44 / Dart 3.12 · Riverpod · Hive CE · fl_chart · sensors_plus · speech_to_text · image_picker · Google Gemini API. Shrift (Space Grotesk) ilova ichiga joylangan — internetsiz ham to'g'ri chiqadi.

## Ishga tushirish

```bash
flutter pub get
flutter run                                   # qurilma / emulyator
flutter run -d web-server --web-port 8080     # web (tez ishlanma)
flutter test                                  # unit + widget testlar
flutter build apk --release                   # Android APK
```

## AI murabbiyni yoqish (ixtiyoriy)

Oflayn murabbiy **kalitsiz** ishlaydi. Onlayn (Gemini) suhbat uchun:
1. [Google AI Studio](https://aistudio.google.com/app/apikey) dan bepul kalit oling.
2. Ilovada **Pro → murabbiy** bo'limiga bir marta kiriting — kalit faqat shu qurilmada saqlanadi.

## Maxfiylik

Hamma ma'lumot **shu qurilmada** saqlanadi (Hive). Server yo'q, hisob yo'q, kuzatuv yo'q.

---

**Muallif:** Jahongir Sattorov · Tanlov uchun yaratilgan.
