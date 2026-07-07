# iOS Build Yo'li (Faza 3) — BEPUL simulator build (Mac'siz quriladi)

> **Xulosa:** Apple Developer Program **$99/yil, faqat yillik** — oylik yoki bepul varianti yo'q. Shu sababli TestFlight (haqiqiy iPhone'ga o'rnatish) hozircha **tanlanmadi**. Buning o'rniga **BEPUL yo'l**: TZ 8-bo'lim qabul qiladigan **iOS simulator build** — Apple hisobisiz, imzosiz, Codemagic bulutida quriladi.

## 1. Nega bu yo'l
- iOS'ni faqat macOS'да qurish mumkin, loyihada Mac yo'q → **Codemagic** bulutli macOS mashinasi.
- **Simulator build** (`flutter build ios --simulator`) **imzo talab qilmaydi** va **Apple Developer hisobisiz** ishlaydi → to'liq bepul.
- TZ 8-bo'lim: "iOS uchun TestFlight havolasi **yoki simulator build**" — ya'ni sudyalar simulator build'ni qabul qiladi va +10 kredit poyint [J5] shu orqali olinishi mumkin.

## 2. Qadamlar (bepul)
1. `codemagic.io`'ga **GitHub bilan** kiring (bepul build-daqiqalari bor — joriy miqdorni saytda tasdiqlang).
2. `focus_ai` repozitoriyni ulang.
3. Codemagic `codemagic.yaml`'ni topadi → **`ios-simulator-focus-ai`** workflow'ni ishga tushiring.
4. Natija artefakti: **`Runner-simulator.app.zip`** — yuklab oling.

## 3. Sudyaga qanday yetkaziladi
- `Runner-simulator.app.zip`'ni topshiriqда beriladi (GitHub Release yoki Drive havolasi).
- Sudya (Mac + Xcode bilan): arxivни oching → `Runner.app`'ni **iOS Simulator**ga sudrab tashlang → ishga tushadi.
- Eslatma: bu haqiqiy iPhone'ga o'rnatilmaydi (buning uchun TestFlight + $99/yil kerak edi). Lekin TZ simulator build'ni qabul qiladi.

## 4. Halol cheklovlar (simulatorда)
- **Chuqur diqqat (akselerometr)** simulatorда ishlamaydi — simulatorда sensor yo'q.
- **Ovozli kiritish / mikrofon** simulatorда ishlamasligi mumkin.
- Timer, UI, imzo yoyi, statistika, oflayn murabbiy, Gemini (internet bilan) — ishlaydi.
- Ya'ni simulator build iOS'ни **isbotlaydi**, lekin ba'zi qurilma-xos funksiyalar faqat haqiqiy iPhone'да to'liq ko'rinadi.

## 5. Allaqachon tayyor
- `codemagic.yaml` — **`ios-simulator-focus-ai`** (bepul, imzosiz) workflow.
- `ios/Runner/Info.plist` — o'zbekcha ruxsat izohlari (mikrofon/nutq/galereya/kamera). Busiz iOS'да rasm/ovoz ilovani qulatishi mumkin.

## 6. Agar keyinchalik $99/yil to'lansa (ixtiyoriy, haqiqiy iPhone uchun)
- Apple Developer Program'ga a'zo bo'ling (yillik $99).
- App Store Connect'да ilova (Bundle ID `com.focusai.focusAi`).
- Codemagic'да signing + `app_store_connect` publishing yoqiladi → `flutter build ipa` → **TestFlight** havolasi → hakam iPhone'ida o'rnatadi.
- `codemagic.yaml`'даgi izohlangan `ios-testflight-focus-ai` blokи shu uchun.

## 7. Ochiq sayqal (ixtiyoriy)
- iOS app belgisi: `flutter_launcher_icons`да `ios: false` → `true` + qayta generatsiya.
- Bundle ID'ni `com.focusai.focusAi`ga moslash (Android bilan bir xil).

> **Halol eslatma:** men bu yerда iOS build'ni ishga tushira olmayman (Mac/Codemagic yo'q). Bu fayl bepul yo'lni tayyorlaydi; birinchi bulutli build haqiqiy holatни ko'rsatadi.
