# Focus AI — Kreativ g'oyalar tavsifi

**Muallif:** Jahongir Sattorov · **Paket:** com.focusai.focus_ai · **Platforma:** Flutter (Android APK)

---

## Asosiy g'oya: vaqtni ko'rsatish emas — his qildirish

Focus AI'da men bitta savoldan boshladim: odat ilovalari nega zerikarli? Javob — ular vaqtni *raqam* qilib ko'rsatadi. Men vaqtni **materiya**ga aylantirdim.

**«Quyma yorug'lik yoyi»** — ilovaning imzo vizuali va butun mahsulotning yuragi. Har diqqat daqiqasi cho'g'dek yoyga quyiladi: ortda sovigan iz qoladi, uchi qizib turadi, undan uchqunlar uchib chiqadi, maqsadga yetganda esa bir martalik portlash bo'ladi. Bu tayyor kutubxona emas — to'liq `CustomPainter`da noldan chizilgan. Progress chizig'ini har kim qo'ya oladi; quyma yoyni esa faqat shu ilovada ko'rasiz.

## Halol vaqt — muhandislik qarori

Taymerim soniyalarni **sanamaydi**. U har doim timestamp'dan qayta hisoblanadi:

```
o'tgan vaqt = accumulatedMs + (hozir − runningSince)
```

Shuning uchun ilovani yopsangiz, telefon o'chsa yoki ilova fonga ketsa ham vaqt soniyasigacha tiklanadi. Taymer maqsaddan oshmaydi va hech qachon manfiy bo'lmaydi. Bu mantiq Flutter'siz, sof Dart'da yozilgan va unit testlar bilan qoplangan — ilovaning yuragiga men ishonchni tasodifga qoldirmadim.

Shu falsafaning davomi: **«Yakunlash»** tugmasi odatni bugun bajarilgan deb belgilaydi, lekin sarflangan vaqtni ko'tarmaydi. Soxta 100% yo'q. Ilova o'zini o'zi aldamaydi.

## Chuqur diqqat (Deep Focus) — telefonni qo'yib yuborish

Akselerometr orqali: telefonni **yuztuban** qo'ysangiz taymer o'zi ishga tushadi, ko'tarsangiz to'xtaydi. Diqqat haqidagi ilova sizni ekranda ushlab turmasligi kerak — u sizni ekrandan uzoqlashtirishi kerak. Bu — mahsulot falsafasining kod darajasidagi ifodasi.

## Milliy dizayn tili — nusxa ko'chirilmagan estetika

Har sahifa o'zbek hunarmandchiligidan olingan geometrik naqsh bilan bezatilgan: sakkiz qirrali **shamsa**, panjara, **ikat** va **suzani** motivlari past shaffoflikda. Ular kontentga xalal bermaydi, lekin ilovaga birorta global tracker'da yo'q kimlik beradi. Shrift (Space Grotesk) ilova ichiga joylangan — internetsiz ham tipografiya buzilmaydi.

## AI murabbiy — ikki qatlamli, maxfiylikni buzmasdan

**Oflayn rejim** kalitsiz ishlaydi: qurilmangizdagi haqiqiy statistikadan tahlil va tavsiya beradi — o'ylab topilgan raqam yo'q. **Onlayn rejim** — Google Gemini bilan jonli suhbat, rasm tahlili (multimodal), ovozli kiritish va saqlanadigan suhbat tarixi. Kalit foydalanuvchining o'zida (BYOK), shuning uchun maxfiylik va'dasi shior emas — arxitektura.

## Qolgan kreativ qatlam

Ixtiyoriy hisob (email + parol, **savol-javob** orqali tiklash) yoki bir bosishda mehmon rejimi — parol hech qachon ochiq saqlanmaydi (salt + SHA-256). Seriya va GitHub uslubidagi faollik xaritasi, interaktiv diqqat-taqsimoti halqasi, kunlik/haftalik/oylik/yillik kesim. Uch til (o'zbek, ingliz, rus), yorug' va tungi mavzu, emoji-avatar, immersiv sessiya ekrani va 100% lahzasida haptika bilan portlash. Chiqishda ma'lumotni saqlash yoki butunlay tozalash tanlovi — nazorat foydalanuvchida.

**Hammasi internetsiz ishlaydi. Server yo'q, kuzatuv yo'q.**

---

*Focus AI — bu shunchaki odat-tracker emas. Bu — diqqatni san'at darajasiga ko'taradigan, milliy ruhga ega va sun'iy intellekt bilan kuchaytirilgan shaxsiy murabbiy.*
