/// O'zbekcha sana va salomlashish yordamchilari (intl kutubxonasisiz).

/// Soatga qarab salom: tong / kun / kech / tun.
String greetingForHour(int hour) {
  if (hour >= 5 && hour < 11) return 'Xayrli tong';
  if (hour >= 11 && hour < 17) return 'Xayrli kun';
  if (hour >= 17 && hour < 22) return 'Xayrli kech';
  return 'Xayrli tun';
}

const _uzWeekdays = <String>[
  'Dushanba',
  'Seshanba',
  'Chorshanba',
  'Payshanba',
  'Juma',
  'Shanba',
  'Yakshanba',
];

const _uzMonths = <String>[
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avgust',
  'sentabr',
  'oktabr',
  'noyabr',
  'dekabr',
];

/// Masalan: "Chorshanba, 17-iyun".
String uzLongDate(DateTime d) {
  final wd = _uzWeekdays[(d.weekday - 1) % 7];
  final m = _uzMonths[(d.month - 1) % 12];
  return '$wd, ${d.day}-$m';
}
