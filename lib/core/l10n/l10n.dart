/// Ilova matnlari — UCHALA til bitta joyda (uz / en / ru).
/// Har bir kalit uchun `_p(uz, en, ru)` — shunday qilib hech qaysi til unutilmaydi.
library;

enum AppLanguage { uz, en, ru }

extension AppLanguageX on AppLanguage {
  String get code => switch (this) {
    AppLanguage.uz => 'uz',
    AppLanguage.en => 'en',
    AppLanguage.ru => 'ru',
  };

  String get nativeName => switch (this) {
    AppLanguage.uz => "O'zbekcha",
    AppLanguage.en => 'English',
    AppLanguage.ru => 'Русский',
  };

  static AppLanguage fromCode(String c) => switch (c) {
    'en' => AppLanguage.en,
    'ru' => AppLanguage.ru,
    _ => AppLanguage.uz,
  };
}

class L10n {
  const L10n(this.lang);
  final AppLanguage lang;

  String _p(String uz, String en, String ru) => switch (lang) {
    AppLanguage.uz => uz,
    AppLanguage.en => en,
    AppLanguage.ru => ru,
  };

  // ---------- Pastki navigatsiya ----------
  String get tabToday => _p('Bugun', 'Today', 'Сегодня');
  String get tabStats => _p('Statistika', 'Statistics', 'Статистика');
  String get tabProfile => _p('Profil', 'Profile', 'Профиль');

  // ---------- Salom + sana ----------
  String greeting(int hour) {
    if (hour >= 5 && hour < 11) {
      return _p('Xayrli tong', 'Good morning', 'Доброе утро');
    }
    if (hour >= 11 && hour < 17) {
      return _p('Xayrli kun', 'Good afternoon', 'Добрый день');
    }
    if (hour >= 17 && hour < 22) {
      return _p('Xayrli kech', 'Good evening', 'Добрый вечер');
    }
    return _p('Xayrli tun', 'Good night', 'Доброй ночи');
  }

  String greetingWithName(int hour, String name) {
    final g = greeting(hour);
    return name.trim().isEmpty ? g : '$g, ${name.trim()}';
  }

  static const _wdUz = [
    'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba',
    'Yakshanba', //
  ];
  static const _wdEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
    'Sunday', //
  ];
  static const _wdRu = [
    'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота',
    'Воскресенье', //
  ];
  static const _moUz = [
    'yanvar', 'fevral', 'mart', 'aprel', 'may', 'iyun', 'iyul', 'avgust',
    'sentabr', 'oktabr', 'noyabr', 'dekabr', //
  ];
  static const _moEn = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
    'September', 'October', 'November', 'December', //
  ];
  static const _moRu = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа',
    'сентября', 'октября', 'ноября', 'декабря', //
  ];

  String longDate(DateTime d) {
    final wi = (d.weekday - 1) % 7;
    final mi = (d.month - 1) % 12;
    switch (lang) {
      case AppLanguage.uz:
        return '${_wdUz[wi]}, ${d.day}-${_moUz[mi]}';
      case AppLanguage.en:
        return '${_wdEn[wi]}, ${_moEn[mi]} ${d.day}';
      case AppLanguage.ru:
        return '${_wdRu[wi]}, ${d.day} ${_moRu[mi]}';
    }
  }

  // ---------- Bugun (dashboard) ----------
  String get totalFocus => _p('jami diqqat', 'total focus', 'всего фокуса');
  String get activeLabel => _p('faol', 'active', 'активные');
  String get completedLabel => _p('bajarilgan', 'completed', 'выполнено');
  String get addHabit => _p("Odat qo'shish", 'Add habit', 'Добавить привычку');
  String get emptyTitle =>
      _p("Hali odat yo'q", 'No habits yet', 'Пока нет привычек');
  String get emptyBody => _p(
    'Pastdagi tugma bilan birinchi odatingizni qo\'shing.',
    'Tap the button below to create your first habit.',
    'Нажмите кнопку ниже, чтобы создать первую привычку.',
  );

  // ---------- Odat holati ----------
  String get statusDone => _p('Bajarildi! 🎉', 'Done! 🎉', 'Готово! 🎉');
  String get statusRunning => _p('Davom etmoqda…', 'In progress…', 'Идёт…');
  String get statusPaused => _p("To'xtatilgan", 'Paused', 'На паузе');
  String get menuReset =>
      _p('Qaytadan (0 ga)', 'Reset (to 0)', 'Сбросить (на 0)');
  String get menuDelete => _p("O'chirish", 'Delete', 'Удалить');

  // ---------- Faol sessiya ----------
  String get start => _p('Boshlash', 'Start', 'Начать');
  String get pause => _p('Pauza', 'Pause', 'Пауза');
  String get restart => _p('Qaytadan', 'Restart', 'Заново');
  String get resetShort => _p('Qayta', 'Reset', 'Сброс');
  String remaining(String time) =>
      _p('qoldi $time', '$time left', 'осталось $time');
  String get habitNotFound =>
      _p('Odat topilmadi', 'Habit not found', 'Привычка не найдена');
  String get deepFocus => _p('Chuqur diqqat', 'Deep Focus', 'Глубокий фокус');
  String get deepFocusHint => _p(
    "📱 Telefonni ekran pastga qo'ying — taymer o'zi ketadi",
    '📱 Place your phone face down — the timer runs on its own',
    '📱 Положите телефон экраном вниз — таймер идёт сам',
  );
  String get deepFocusActive => _p(
    'Chuqur diqqat — ekran pastga',
    'Deep focus — screen down',
    'Глубокий фокус — экраном вниз',
  );

  // ---------- Statistika ----------
  String get statsTitle => _p('Statistika', 'Statistics', 'Статистика');
  String get totalFocusCaps => _p('JAMI DIQQAT', 'TOTAL FOCUS', 'ВСЕГО ФОКУСА');
  String get statCompleted => _p('Bajarilgan', 'Completed', 'Выполнено');
  String get statOverall => _p('Umumiy', 'Overall', 'Всего');
  String get statGoal => _p('Maqsad', 'Goal', 'Цель');
  String get byHabit => _p("Odatlar bo'yicha", 'By habit', 'По привычкам');
  String get noData =>
      _p("Hali ma'lumot yo'q", 'No data yet', 'Пока нет данных');
  String get periodDay => _p('Kunlik', 'Daily', 'День');
  String get periodWeek => _p('Haftalik', 'Weekly', 'Неделя');
  String get periodMonth => _p('Oylik', 'Monthly', 'Месяц');
  String get periodYear => _p('Yillik', 'Yearly', 'Год');

  // ---------- Profil ----------
  String get profileTitle => _p('Profil', 'Profile', 'Профиль');
  String get guest => _p('Mehmon', 'Guest', 'Гость');
  String get localMode => _p(
    'Lokal rejim — hamma narsa shu qurilmada saqlanadi',
    'Local mode — everything stays on this device',
    'Локальный режим — всё хранится на этом устройстве',
  );
  String get replayOnboarding =>
      _p("Tanishtiruvni qayta ko'rish", 'Replay intro', 'Повторить знакомство');
  String get replayOnboardingSub => _p(
    "Boshlang'ich 3 sahifani qayta ko'rsatish",
    'Show the 3 intro pages again',
    'Показать 3 вводные страницы снова',
  );
  String get aboutTitle => _p('Ilova haqida', 'About', 'О приложении');
  String get aboutSub => _p(
    'Focus AI — versiya 1.0',
    'Focus AI — version 1.0',
    'Focus AI — версия 1.0',
  );
  String get aboutBody => _p(
    'Diqqatni nurga aylantiruvchi odat kuzatuvchi. '
        'Lokal-first, timestamp aniqligidagi taymer.',
    'A habit tracker that turns focus into light. '
        'Local-first, timestamp-precise timer.',
    'Трекер привычек, превращающий фокус в свет. '
        'Локально, таймер на основе точных меток времени.',
  );
  String get languageLabel => _p('Til', 'Language', 'Язык');
  String get nameLabel => _p('Ism', 'Name', 'Имя');
  String get editName => _p('Ismni tahrirlash', 'Edit name', 'Изменить имя');
  String get nameHint => _p('Ismingiz', 'Your name', 'Ваше имя');
  String get save => _p('Saqlash', 'Save', 'Сохранить');
  String get cancel => _p('Bekor qilish', 'Cancel', 'Отмена');
  String get close => _p('Yopish', 'Close', 'Закрыть');
  String get avatarLabel => _p('Belgi', 'Emoji', 'Значок');
  String get licenses => _p('Litsenziyalar', 'Licenses', 'Лицензии');

  // ---------- Onboarding ----------
  String get onbSkip => _p("O'tkazib yuborish", 'Skip', 'Пропустить');
  String get onbNext => _p('Keyingi', 'Next', 'Далее');
  String get onbStart => _p('Boshlaymiz', "Let's start", 'Начнём');
  String get onbTagline => _p(
    'Diqqatni nurga aylantir',
    'Turn focus into light',
    'Преврати фокус в свет',
  );
  String get onb1Title => onbTagline;
  String get onb1Body => _p(
    "Har bir diqqat daqiqasi yoyga quyma cho'g'dek quyiladi. "
        "Maqsadingga yetganda — u butunlay yonadi.",
    'Every minute of focus pours into the arc like molten light. '
        'Reach your goal and it fully ignites.',
    'Каждая минута фокуса вливается в дугу, как расплавленный свет. '
        'Достигни цели — и она вспыхнет полностью.',
  );
  String get onb2Title => _p(
    "Har bir odat — o'z olovi",
    'Each habit — its own flame',
    'У каждой привычки — свой огонь',
  );
  String get onb2Body => _p(
    'Bir nechta odatni bir vaqtda yurit. '
        'Har biri mustaqil yonadi va biri ikkinchisiga xalal bermaydi.',
    'Run several habits at once. '
        'Each burns independently, without interfering with the others.',
    'Веди несколько привычек одновременно. '
        'Каждая горит независимо, не мешая другим.',
  );
  String get onb3Title => _p(
    "Vaqting yo'qolmaydi",
    'Your time is never lost',
    'Твоё время не пропадёт',
  );
  String get onb3Body => _p(
    "Ilovani yopsang ham, taymer aniq vaqt bo'yicha davom etadi. "
        "Hech narsa o'chmaydi.",
    'Even if you close the app, the timer keeps exact time. '
        'Nothing is lost.',
    'Даже если закроешь приложение, таймер точно продолжит счёт. '
        'Ничего не пропадёт.',
  );

  // ---------- Odat qo'shish ----------
  String get newHabit => _p('Yangi odat', 'New habit', 'Новая привычка');
  String get habitNameLabel => _p('Nomi', 'Name', 'Название');
  String get habitNameExample =>
      _p("Masalan: Kitob o'qish", 'e.g. Read a book', 'Напр.: Чтение книги');
  String get goalMinutesLabel =>
      _p('Maqsad (daqiqa)', 'Goal (minutes)', 'Цель (минуты)');
  String get colorLabel => _p('Rang', 'Color', 'Цвет');
  String get add => _p("Qo'shish", 'Add', 'Добавить');
  String get customMinutes => _p('Boshqa', 'Custom', 'Другое');
}
