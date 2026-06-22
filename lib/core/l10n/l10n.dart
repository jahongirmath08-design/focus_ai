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

  // ---------- Pro bo'lim ----------
  String get tabPro => _p('Pro', 'Pro', 'Pro');
  String get proTitle => 'Focus AI Pro';
  String get proSubtitle => _p(
    'Diqqatingni keyingi bosqichga olib chiqamiz',
    'Take your focus to the next level',
    'Выведи фокус на новый уровень',
  );
  String get proCoachSection => _p('AI-murabbiy', 'AI Coach', 'AI-наставник');
  String get proOnlineSection =>
      _p('Online imkoniyatlar', 'Online features', 'Онлайн-возможности');
  String get proOfflineBadge =>
      _p('Offline ishlaydi', 'Works offline', 'Работает офлайн');
  String get proLiveBadge => _p('Jonli', 'Live', 'Живой');
  String get proNeedsInternet =>
      _p('Internet kerak', 'Needs internet', 'Нужен интернет');
  String get proSoon => _p('Tez orada', 'Coming soon', 'Скоро');

  String get proAiChatTitle =>
      _p('Murabbiy bilan suhbat', 'Chat with your coach', 'Чат с наставником');
  String get proAiChatBody => _p(
    'Diqqat va odatlaring haqida jonli murabbiy bilan suhbatlash.',
    'Chat with a live coach about your focus and habits.',
    'Общайся с живым наставником о фокусе и привычках.',
  );
  String get proAiAnalysisTitle => _p(
    'Aqlli statistika tahlili',
    'Smart insights',
    'Умный анализ статистики',
  );
  String get proAiAnalysisBody => _p(
    "Sun'iy intellekt diqqat namunalaringni chuqur tahlil qiladi.",
    'Smart, deep analysis of your focus patterns.',
    'Глубокий умный анализ твоих шаблонов фокуса.',
  );
  String get proCloudTitle => _p(
    'Bulutli zaxira & sinxron',
    'Cloud backup & sync',
    'Облако и синхронизация',
  );
  String get proCloudBody => _p(
    "Ma'lumotlaring bulutda saqlanadi, har qurilmada ochiladi.",
    'Your data is backed up and synced across devices.',
    'Данные в облаке и синхронизируются на устройствах.',
  );
  String get proFriendsTitle =>
      _p("Do'stlar challenge'i", 'Friends challenge', 'Челлендж с друзьями');
  String get proFriendsBody => _p(
    "Do'stlaring bilan musobaqalash va reyting.",
    'Compete with friends on a leaderboard.',
    'Соревнуйся с друзьями в рейтинге.',
  );

  // ---------- AI-murabbiy ----------
  String humanDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0 && m > 0) {
      return _p('$h soat $m daqiqa', '${h}h ${m}m', '$h ч $m мин');
    }
    if (h > 0) return _p('$h soat', '${h}h', '$h ч');
    if (m > 0) return _p('$m daqiqa', '${m}m', '$m мин');
    return _p('$seconds soniya', '${seconds}s', '$seconds сек');
  }

  String get coachTitle => _p('Bugungi tahlil', "Today's read", 'Анализ дня');

  String coachHeadlineGood(String name) => name.isEmpty
      ? _p("Zo'r ketyapsan! 🔥", "You're on fire! 🔥", 'Ты в ударе! 🔥')
      : _p(
          "Zo'r ketyapsan, $name! 🔥",
          "You're on fire, $name! 🔥",
          'Ты в ударе, $name! 🔥',
        );
  String coachHeadlinePush(String name) => name.isEmpty
      ? _p(
          'Bugun boshlasak-chi? 💪',
          'Shall we start today? 💪',
          'Начнём сегодня? 💪',
        )
      : _p(
          'Bugun boshlasak-chi, $name? 💪',
          'Shall we start today, $name? 💪',
          'Начнём сегодня, $name? 💪',
        );
  String coachHeadlineNeutral(String name) => name.isEmpty
      ? _p('Davom etamiz 🌱', "Let's keep going 🌱", 'Продолжаем 🌱')
      : _p(
          'Davom etamiz, $name 🌱',
          'Keep going, $name 🌱',
          'Продолжаем, $name 🌱',
        );
  String get coachHeadlineEmpty => _p(
    'Birinchi odatdan boshlaymiz',
    'Start with your first habit',
    'Начни с первой привычки',
  );

  String get coachSubGood => _p(
    "Bugungi sur'atingni ushlab tur.",
    'Hold this pace today.',
    'Удержи этот темп сегодня.',
  );
  String get coachSubPush => _p(
    'Kichik qadam ham — qadam.',
    'A small step is still a step.',
    'Маленький шаг — тоже шаг.',
  );
  String get coachSubNeutral =>
      _p('Sekin, lekin barqaror.', 'Slow but steady.', 'Медленно, но верно.');
  String get coachSubEmpty => _p(
    "Bugun sahifasidan odat qo'sh.",
    'Add a habit on the Today tab.',
    'Добавь привычку на вкладке «Сегодня».',
  );

  String get coachTodayVsAvgTitle =>
      _p("Bugun vs o'rtacha", 'Today vs average', 'Сегодня vs среднее');
  String coachTodayUp(int pct) => _p(
    "O'rtacha kunlikdan $pct% yuqori. Ajoyib!",
    '$pct% above your daily average. Great!',
    'На $pct% выше среднего. Отлично!',
  );
  String coachTodayDown(int pct) => _p(
    "O'rtacha kunlikdan $pct% past. Yana biroz!",
    '$pct% below your daily average. A bit more!',
    'На $pct% ниже среднего. Ещё немного!',
  );
  String get coachTodayFlat => _p(
    "Aynan o'rtacha darajadasan.",
    'Right at your average.',
    'Точно на уровне среднего.',
  );

  String get coachStrongestTitle =>
      _p('Bu hafta yetakchi', "This week's leader", 'Лидер недели');
  String coachStrongestBody(String habit, String time) => _p(
    "$habit — $time. Eng ko'p diqqat shunga ketdi.",
    '$habit — $time. Your top focus.',
    '$habit — $time. Больше всего фокуса.',
  );

  String get coachConsistencyTitle =>
      _p('Izchillik', 'Consistency', 'Постоянство');
  String coachConsistencyBody(int days) => _p(
    "Oxirgi 7 kunda $days kun shug'ullanding.",
    'You showed up $days of the last 7 days.',
    'Ты занимался $days из 7 дней.',
  );

  String get coachCompletionTitle =>
      _p('Bugungi yakun', 'Completed today', 'Выполнено сегодня');
  String coachCompletionBody(int done, int total) => _p(
    '$total odatdan $done tasi yakunlandi.',
    '$done of $total habits done.',
    '$done из $total привычек выполнено.',
  );

  String get coachTipTitle => _p('Maslahat', 'Tip', 'Совет');
  List<String> get coachTips => switch (lang) {
    AppLanguage.uz => const [
      "Telefonni \"ekran pastga\" qo'yib, Chuqur diqqatni sina.",
      'Diqqat 25 daqiqa + dam 5 daqiqa — Pomodoro ritmi.',
      "Bitta odatga to'liq berilish ikkitasiga yarim qarashdan yaxshi.",
      "Eng og'ir ishni ertalab, kuching to'la paytda boshla.",
      "Kichik maqsad qo'y: 1 daqiqa ham hisoblanadi.",
      'Har kuni bir xil vaqtda boshlasang, odat mustahkamlanadi.',
      "Dam olish ham reja: charchaganda to'xtashni bil.",
    ],
    AppLanguage.en => const [
      'Try Deep Focus — place your phone face down.',
      '25 min focus + 5 min break — the Pomodoro rhythm.',
      'Full attention on one habit beats half on two.',
      'Start the hardest task in the morning, at full energy.',
      'Set a tiny goal: even 1 minute counts.',
      'Start at the same time daily to lock in the habit.',
      'Rest is part of the plan: know when to stop.',
    ],
    AppLanguage.ru => const [
      'Попробуй «Глубокий фокус» — положи телефон экраном вниз.',
      '25 мин фокуса + 5 мин отдыха — ритм Помодоро.',
      'Полное внимание к одной привычке лучше половины к двум.',
      'Начни самое сложное утром, на полной энергии.',
      'Поставь маленькую цель: даже 1 минута важна.',
      'Начинай в одно время каждый день — привычка закрепится.',
      'Отдых — часть плана: знай, когда остановиться.',
    ],
  };

  // ---------- Jonli AI suhbat (Gemini) ----------
  String get chatSetupTitle =>
      _p("Jonli AI'ni yoqing", 'Enable live AI', 'Включите живой ИИ');
  String get chatSetupBody => _p(
    "Bepul Gemini kalitini bir marta kiriting — murabbiy jonli javob beradi. "
        "Kalit faqat shu qurilmada saqlanadi, hech qayerga yuborilmaydi.",
    'Enter a free Gemini key once — the coach replies live. '
        'The key is stored only on this device and sent nowhere else.',
    'Введите бесплатный ключ Gemini один раз — наставник ответит вживую. '
        'Ключ хранится только на этом устройстве.',
  );
  String get chatSetupButton =>
      _p('Kalit kiritish', 'Enter key', 'Ввести ключ');
  String get chatGetKeyHint => _p(
    'Bepul kalit: aistudio.google.com',
    'Free key at: aistudio.google.com',
    'Бесплатный ключ: aistudio.google.com',
  );
  String get chatKeyDialogTitle =>
      _p('Gemini API kaliti', 'Gemini API key', 'Ключ Gemini API');
  String get chatKeyDialogHint => _p(
    'Kalitni shu yerga joylashtiring',
    'Paste your key here',
    'Вставьте ключ сюда',
  );
  String get chatChangeKey =>
      _p("Kalitni o'zgartirish", 'Change key', 'Изменить ключ');
  String get chatInputHint =>
      _p('Xabar yozing…', 'Type a message…', 'Напишите сообщение…');
  String get chatThinking => _p("O'ylayapti…", 'Thinking…', 'Думает…');
  String get chatWelcome => _p(
    "Salom! Men diqqat murabbiyingman. Odatlaring, vaqt rejang yoki "
        "motivatsiya haqida xohlagan narsangni so'ra.",
    "Hi! I'm your focus coach. Ask me anything about your habits, "
        'scheduling, or motivation.',
    'Привет! Я твой наставник по фокусу. Спрашивай о привычках, '
        'расписании или мотивации.',
  );
  String get chatAnalyzePrompt => _p(
    "Mening diqqat statistikamni tahlil qil va 3 ta aniq, amaliy maslahat ber.",
    'Analyze my focus stats and give me 3 specific, practical tips.',
    'Проанализируй мою статистику фокуса и дай 3 конкретных совета.',
  );
  String get chatErrorNetwork => _p(
    "Internetga ulanib bo'lmadi. Aloqani tekshirib, qayta urin.",
    "Couldn't reach the internet. Check your connection and retry.",
    'Нет связи с интернетом. Проверь соединение и повтори.',
  );
  String get chatErrorKey => _p(
    "Kalit noto'g'ri ko'rinadi. Uni qayta kiriting.",
    'The key looks invalid. Please re-enter it.',
    'Ключ недействителен. Введите его заново.',
  );
  String get chatErrorGeneric => _p(
    "Nimadir xato ketdi. Birozdan so'ng qayta urin.",
    'Something went wrong. Try again shortly.',
    'Что-то пошло не так. Попробуй позже.',
  );
  String get chatErrorQuota => _p(
    "Bepul AI limiti vaqtincha tugadi. Bir-ikki daqiqadan so'ng yoki ertaga qayta urin.",
    'The free AI limit is temporarily used up. Try again in a minute or tomorrow.',
    'Бесплатный лимит ИИ временно исчерпан. Попробуй через минуту или завтра.',
  );
  String get chatErrorBusy => _p(
    "AI hozir juda band. Bir oz kutib qayta yuboring.",
    'The AI is very busy right now. Wait a moment and try again.',
    'ИИ сейчас очень занят. Подожди немного и повтори.',
  );
  String get chatCopy => _p('Nusxalash', 'Copy', 'Копировать');
  String get chatCopied => _p('Nusxalandi', 'Copied', 'Скопировано');
  String get chatVoiceHint => _p('Gapiring…', 'Speak…', 'Говорите…');
  String get chatListening => _p('Tinglayapman…', 'Listening…', 'Слушаю…');
  String get chatImageBadge => _p('Rasm', 'Image', 'Изображение');
  String get chatAttachImage =>
      _p('Rasm biriktirish', 'Attach image', 'Прикрепить изображение');
  String get chatImageReady => _p('Rasm tayyor', 'Image ready', 'Фото готово');
  String get chatImagePrompt => _p(
    'Bu rasmga qarab menga maslahat ber.',
    'Look at this image and advise me.',
    'Посмотри на это изображение и дай совет.',
  );

  // ---------- Suhbat tarixi ----------
  String get chatHistory =>
      _p('Suhbatlar tarixi', 'Chat history', 'История чатов');
  String get chatNewChat => _p('Yangi suhbat', 'New chat', 'Новый чат');
  String get chatNoHistory =>
      _p("Hali suhbatlar yo'q", 'No conversations yet', 'Пока нет чатов');
  String get chatUntitled =>
      _p('Nomsiz suhbat', 'Untitled chat', 'Без названия');
  String get chatDeleteConv =>
      _p("Suhbatni o'chirish", 'Delete chat', 'Удалить чат');
}
