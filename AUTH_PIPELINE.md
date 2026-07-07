# Real Autentifikatsiya — 5-Agentli Quvur (AUTH_PIPELINE)

> **Maqsad:** ilovaga haqiqiy foydalanuvchi autentifikatsiyasini qo'shish — asoschi ustuvorlik beradigan funksiya [J8]. **Additiv:** mavjud mehmon (guest) rejimi hech qachon buzilmaydi; auth uning ustidagi ixtiyoriy qatlam.
>
> **Muhim farq:** bu yerdagi 5 "agent" — bu **runtime arxitektura bosqichlari** (ma'lumot oqimi). Ular `PROJECT_STATUS.md` §7 dagi 5 **dev-jarayon roli** (Arxitektor → Quruvchi → Red Team → Fixer → QA) bilan aralashtirilmasin. Har bir runtime agenti aynan o'sha dev-quvur orqali quriladi.

---

## 1. Arxitektura tamoyillari (murosasiz)

1. **Lokal-first saqlanadi.** Odat ma'lumotlari `habits`/`history` Hive box'larida **lokal qoladi**. Auth faqat **identifikatsiya qatlami** — sprint doirasida bulutga ma'lumot ko'chirilmaydi (migratsiya yo'q).
2. **Mehmon rejimi buzilmaydi.** `auth_screen.dart` dagi mavjud mehmon oqimi va `authDoneProvider` semantikasi saqlanadi.
3. **Oflayn-bardosh.** Firebase sessiyani qurilmada saqlaydi → oldin kirgan foydalanuvchi internet yo'q bo'lsa ham `AuthedSession` sifatida kiradi va barcha lokal funksiyalar ishlaydi.
4. **Token xavfsizligi.** ID/refresh token'lar Firebase SDK tomonidan platforma xavfsiz xotirasida saqlanadi — **hech qachon Hive'da ochiq matn sifatida emas**.
5. **Barcha xato — o'zbekcha.** TIL QOIDASI: har bir xato holati o'zbek tilida (TZ 3.2).

**Backend tanlovi:** Firebase Auth — **Spark (bepul) plan**. TZ pullik xizmatni talab qilmaydi; Spark email/parol uchun yetarli. Paketlar: `firebase_core`, `firebase_auth`.

---

## 2. Umumiy ma'lumot oqimi

```
┌──────────────────────────────────────────────────────────────┐
│ RootGate (main.dart)                                          │
│   firebase.currentUser != null  OR  authDoneProvider == true  │
│        │ ha → HomeShell             │ yo'q → AuthScreen        │
└──────────────────────────────────────────────────────────────┘
                                         │
                           ┌─────────────┴─────────────┐
                           │  Rejim: [ Mehmon ] [ Hisob ] │
                           └─────────────┬─────────────┘
        Mehmon (mavjud, o'zgarmaydi) │   │ Hisob (yangi quvur)
                            │            ▼
                            │   ① UI/Input Agent      auth_screen.dart
                            │        email · parol · rejim(signup|signin|reset)
                            │            ▼
                            │   ② Validation Agent    sof Dart, OFLAYN
                            │        ok? ──yo'q──► o'zbekcha xato ─► UI
                            │            │ ha
                            │            ▼
                            │   ③ Secure Token Agent  firebase_auth
                            │        create / signIn / sendReset
                            │        ID+refresh token → SDK xavfsiz xotira
                            │        FirebaseAuthException ─► o'zbekcha ─► UI
                            │            ▼
                            │   ④ Database/Cloud Agent Firebase (Spark)
                            │        faqat identity · Firestore sync = KEYINGA
                            │            ▼
                            ▼            ▼
                     ⑤ Session State Agent   Riverpod: sessionProvider
                          GuestSession  |  AuthedSession(uid, email)
                                         │
                                         ▼
                          HomeShell — MA'LUMOT: LOKAL Hive (o'zgarmaydi)
```

---

## 3. Agentlar (bosqichma-bosqich)

### ① UI/Input Agent
**Fayl:** `features/auth/ui/auth_screen.dart` (mavjud ekran kengaytiriladi — qayta yozilmaydi).

**Vazifa:** kirish/chiqish nuqtasi. Yuqorida segmentli tanlagich: **Mehmon | Hisob**.
- *Mehmon* — mavjud ixtiyoriy ism maydoni + "Mehmon sifatida davom etish" (o'zgarishsiz).
- *Hisob* — email, parol maydonlari; uchta amal tugmasi: **Ro'yxatdan o'tish**, **Kirish**, **Parolni unutdingizmi?**.

**Chiqish:** `{mode: signup|signin|reset, email, password}` → Validation Agent.
**Qoida:** hech qanday tarmoq chaqiruvi bu qatlamda YO'Q — faqat kiritish va holatni ko'rsatish (yuklanish spinneri, xato matni).

### ② Validation Agent
**Fayl (yangi):** `features/auth/domain/auth_validator.dart` — **sof Dart, oflayn, unit-testlanadi** (mavjud test madaniyatiga mos).

**Vazifa:** tarmoqqa chiqishdan oldingi darvoza.
- Email formati (regex), parol uzunligi (min 6), bo'sh maydon, parol mosligi (signup).
- Har qoidabuzarlik uchun **o'zbekcha** matn qaytaradi (masalan: "Email formati noto'g'ri", "Parol kamida 6 belgidan iborat bo'lsin").

```dart
sealed class ValidationResult {}
class Valid extends ValidationResult {}
class Invalid extends ValidationResult { Invalid(this.uzMessage); final String uzMessage; }
```
**Chiqish:** `Valid` → Secure Token Agent; `Invalid` → UI (tarmoqqa chiqmaydi).

### ③ Secure Token Agent
**Fayl (yangi):** `features/auth/data/auth_service.dart` (`firebase_auth` o'rami).

**Vazifa:** haqiqiy hisobga olish almashuvi va token hayot-sikli.
```dart
Future<UserCredential> signUp(email, password)  // createUserWithEmailAndPassword
Future<UserCredential> signIn(email, password)  // signInWithEmailAndPassword
Future<void> sendReset(email)                   // sendPasswordResetEmail
Future<void> signOut()                          // signOut
```
- **Token'lar:** ID + refresh token'ni Firebase SDK **o'zi** xavfsiz saqlaydi va yangilaydi. Biz Hive'ga token yozmaymiz.
- **Xato tarjimasi:** `FirebaseAuthException.code` → o'zbekcha (markazlashtirilgan `_mapError`):

| code | O'zbekcha xabar |
|---|---|
| `email-already-in-use` | Bu email allaqachon ro'yxatdan o'tgan |
| `invalid-email` | Email formati noto'g'ri |
| `weak-password` | Parol juda oddiy — kamida 6 belgi |
| `user-not-found` / `wrong-password` | Email yoki parol noto'g'ri |
| `network-request-failed` | Internet yo'q — mehmon rejimida davom etishingiz mumkin |
| `too-many-requests` | Juda ko'p urinish — birozdan keyin qayta urining |

### ④ Database/Cloud Agent
**Manba:** Firebase loyihasi (Spark plan).

**Sprint doirasi — faqat identity:**
- Firebase Auth foydalanuvchini yaratadi/saqlaydi (`uid`, `email`).
- **Ma'lumot bazasi (Firestore) sinxronizatsiyasi — SPRINTDAN TASHQARIDA.** Kod interfeys darajasida tayyor turadi (kelajakdagi startup uchun ilgak), lekin odat ma'lumotlari lokal Hive'da qoladi. Bu "additiv ish" qoidasini va oflayn kafolatni buzmaydi.
- **Konfiguratsiya:** `google-services.json` → `android/app/`; `com.google.gms.google-services` Gradle plaginini qo'shish. `applicationId` allaqachon `com.focusai.focus_ai` — Firebase konsolidagi paket nomi shunga mos bo'lsin.

### ⑤ Session State Agent
**Fayl (yangi):** `features/auth/state/session_notifier.dart` — Riverpod, mavjud `authDoneProvider` bilan birga.

**Vazifa:** yagona haqiqat manbasi — foydalanuvchi kim.
```dart
sealed class AuthSession { const AuthSession(); }
class GuestSession  extends AuthSession { const GuestSession({this.name}); final String? name; }
class AuthedSession extends AuthSession {
  const AuthedSession({required this.uid, required this.email, this.name});
  final String uid; final String email; final String? name;
}

final authStateChangesProvider = StreamProvider<User?>((ref) =>
    FirebaseAuth.instance.authStateChanges());

final sessionProvider = Provider<AuthSession>((ref) {
  final user = ref.watch(authStateChangesProvider).valueOrNull;
  if (user != null) {
    return AuthedSession(uid: user.uid, email: user.email ?? '',
                         name: ref.watch(userNameProvider));
  }
  final guestDone = ref.watch(authDoneProvider);
  return GuestSession(name: guestDone ? ref.watch(userNameProvider) : null);
});
```
- **Chiqish (logout):** mavjud ikki tanlov saqlanadi — "Shunchaki chiqish" (lokal ma'lumot qoladi) va "Chiqish va o'chirish" (`clearAll`). Auth qo'shilgach: "Shunchaki chiqish" `signOut()` ni ham chaqiradi, lokal Hive tegilmaydi.

---

## 4. Guest bilan qanday ishlaydi: parallel + override

- **Standart = Mehmon.** Hech narsa o'zgarmasa, ilova avvalgidek mehmon rejimida to'liq ishlaydi (`authDoneProvider == true`).
- **Hisob = ixtiyoriy yuksaltirish (override).** Firebase foydalanuvchisi mavjud bo'lsa, `sessionProvider` **`AuthedSession` ni ustun qiladi**; mehmon — zaxira standart.
- **Mehmon → Hisobga ulash (ma'lumot saqlanadi).** Mehmon (lokal odatlari bor) ro'yxatdan o'tsa: lokal Hive ma'lumoti **o'chirilmaydi**, yangi `uid` bilan bog'lanadi. Ma'lumot yagona lokal do'konda bo'lgani uchun sprint doirasida "ulash" = shunchaki `authDone` + `uid` ni belgilash; migratsiya shart emas.
- **Ma'lumot qatlami bir xil.** Mehmon ham, ro'yxatdan o'tgan ham bir xil lokal Hive'dan foydalanadi. Farq — **identity va ustuvorlik zonasi**, funksionallik emas.

---

## 5. Oflayn xulq-atvor (hakam sinovida muhim)

| Holat | Natija |
|---|---|
| Yangi ro'yxatdan o'tish / kirish, internet YO'Q | Gracefully bloklanadi → "Internet yo'q — mehmon rejimida davom etishingiz mumkin"; ilova qulamaydi |
| Oldin kirgan foydalanuvchi, internet YO'Q | Firebase `currentUser` keshlangan → `AuthedSession` bilan kiradi; barcha lokal funksiya ishlaydi |
| Parolni tiklash, internet YO'Q | O'zbekcha xato; mehmon oqimi ochiq qoladi |

---

## 6. Integratsiya cheklovlari (jamoa e'tibori)

- **pubspec qo'shimchasi:**
  ```yaml
  dependencies:
    firebase_core: ^3.x
    firebase_auth: ^5.x
  ```
- **minSdk:** `firebase_auth` **minSdk 23** talab qiladi. `build.gradle.kts` da `minSdk = flutter.minSdkVersion` hozir mumkin bo'lgan 21 → kerak bo'lsa `minSdk = 23` ga aniq ko'tariladi (Android 16 hakam qurilmasiga ta'sir qilmaydi).
- **Build narxi:** Firebase qo'shilishi birinchi release build'ni sekinlashtiradi (Celeron, ~17 daq). Rejalashtiring.
- **Additiv checkpoint:** Firebase qo'shishdan **oldin** git checkpoint; har agent alohida commit; `flutter analyze` toza bo'lishi va **haqiqiy qurilmada** kirish/chiqish sinaltanini tasdiqlash ("o'tdi" faqat haqiqatan ishlaganда).
- **Dev-quvur:** har 5 runtime agenti PROJECT_STATUS §7 dagi 5-rolli jarayon + 14-bandli adversarial checklist orqali o'tadi.

---

## 7. Qabul mezonlari (Definition of Done)
- [ ] Mehmon rejimi 100% avvalgidek ishlaydi (regressiya yo'q).
- [ ] Email/parol bilan ro'yxatdan o'tish, kirish, parol tiklash — haqiqiy qurilmada ishlaydi.
- [ ] Barcha xato holatlari o'zbekcha, aniq.
- [ ] Oflayn: yangi auth grazli bloklanadi; oldin kirgan foydalanuvchi kiradi.
- [ ] `AuthValidator` uchun unit testlar (mavjud test madaniyatiga mos).
- [ ] Token'lar Hive'da ochiq saqlanmaydi (faqat Firebase SDK).
- [ ] `flutter analyze` → No issues found.
