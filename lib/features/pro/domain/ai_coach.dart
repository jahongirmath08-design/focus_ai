import '../../../core/l10n/l10n.dart';
import '../../habits/domain/habit.dart';

/// AI-murabbiyning kayfiyati — sarlavha va rangni tanlash uchun.
enum CoachTone { empty, push, neutral, good }

/// Bitta tahliliy karta (emoji + sarlavha + matn + ixtiyoriy rang).
class CoachInsight {
  const CoachInsight({
    required this.emoji,
    required this.title,
    required this.body,
    this.colorValue,
  });

  final String emoji;
  final String title;
  final String body;
  final int? colorValue;
}

/// Murabbiy hisoboti — bosh xabar + tahliliy kartalar.
class CoachReport {
  const CoachReport({
    required this.tone,
    required this.headline,
    required this.subline,
    required this.insights,
  });

  final CoachTone tone;
  final String headline;
  final String subline;
  final List<CoachInsight> insights;
}

/// OFFLINE AI-murabbiy: foydalanuvchi statistikasidan shaxsiy maslahat yasaydi.
/// PURE DART — internet/kalit talab qilmaydi, shuning uchun har doim ishlaydi.
/// (Online jonli AI keyin shu yadro ustiga qo'shiladi.)
CoachReport buildCoachReport({
  required L10n t,
  required DateTime now,
  required String userName,
  required List<Habit> habits,
  required int todayFocusSec,
  required int weekFocusSec,
  required int activeDaysThisWeek,
  required Map<String, int> weekByHabit,
}) {
  final name = userName.trim();

  if (habits.isEmpty) {
    return CoachReport(
      tone: CoachTone.empty,
      headline: t.coachHeadlineEmpty,
      subline: t.coachSubEmpty,
      insights: const [],
    );
  }

  final completedToday = habits.where((h) => h.session.isComplete(now)).length;
  final total = habits.length;
  // O'rtacha — FAOL kunlar bo'yicha hisoblanadi (kalendar 7 kunga bo'lmaymiz,
  // aks holda bitta faol kun "650%" kabi mantiqsiz raqam berardi).
  final hasBaseline = activeDaysThisWeek >= 2;
  final avgPerActiveDay = activeDaysThisWeek > 0
      ? weekFocusSec / activeDaysThisWeek
      : 0.0;

  // Bu hafta eng ko'p diqqat ketgan odat.
  Habit? strongest;
  var strongestSec = 0;
  for (final h in habits) {
    final sec = weekByHabit[h.id] ?? 0;
    if (sec > strongestSec) {
      strongestSec = sec;
      strongest = h;
    }
  }

  // Kayfiyatni aniqlaymiz.
  final CoachTone tone;
  if (total > 0 && completedToday == total) {
    tone = CoachTone.good;
  } else if (todayFocusSec == 0) {
    tone = CoachTone.push;
  } else if (hasBaseline && todayFocusSec >= avgPerActiveDay) {
    tone = CoachTone.good;
  } else {
    tone = CoachTone.neutral;
  }

  final String headline;
  final String subline;
  switch (tone) {
    case CoachTone.good:
      headline = t.coachHeadlineGood(name);
      subline = t.coachSubGood;
    case CoachTone.push:
      headline = t.coachHeadlinePush(name);
      subline = t.coachSubPush;
    case CoachTone.neutral:
      headline = t.coachHeadlineNeutral(name);
      subline = t.coachSubNeutral;
    case CoachTone.empty:
      headline = t.coachHeadlineEmpty;
      subline = t.coachSubEmpty;
  }

  final insights = <CoachInsight>[];

  // 1) Bugun vs o'rtacha — faqat mazmunli baza bo'lganda (kamida 2 faol kun).
  if (hasBaseline && avgPerActiveDay > 0) {
    final ratio = todayFocusSec / avgPerActiveDay;
    if (ratio >= 1.05) {
      final pct = ((ratio - 1) * 100).round().clamp(1, 300).toInt();
      insights.add(
        CoachInsight(
          emoji: '📈',
          title: t.coachTodayVsAvgTitle,
          body: t.coachTodayUp(pct),
        ),
      );
    } else if (ratio <= 0.95) {
      final pct = ((1 - ratio) * 100).round().clamp(1, 99).toInt();
      insights.add(
        CoachInsight(
          emoji: '📉',
          title: t.coachTodayVsAvgTitle,
          body: t.coachTodayDown(pct),
        ),
      );
    } else {
      insights.add(
        CoachInsight(
          emoji: '⚖️',
          title: t.coachTodayVsAvgTitle,
          body: t.coachTodayFlat,
        ),
      );
    }
  }

  // 2) Bu haftaning yetakchisi.
  final s = strongest;
  if (s != null && strongestSec > 0) {
    final label = s.emoji.isEmpty ? s.name : '${s.emoji} ${s.name}';
    insights.add(
      CoachInsight(
        emoji: '🏆',
        title: t.coachStrongestTitle,
        body: t.coachStrongestBody(label, t.humanDuration(strongestSec)),
        colorValue: s.colorValue,
      ),
    );
  }

  // 3) Izchillik (oxirgi 7 kun).
  insights.add(
    CoachInsight(
      emoji: '🔥',
      title: t.coachConsistencyTitle,
      body: t.coachConsistencyBody(activeDaysThisWeek),
    ),
  );

  // 4) Bugungi yakun.
  insights.add(
    CoachInsight(
      emoji: '✅',
      title: t.coachCompletionTitle,
      body: t.coachCompletionBody(completedToday, total),
    ),
  );

  // 5) Kunlik aylanma maslahat.
  final tips = t.coachTips;
  insights.add(
    CoachInsight(
      emoji: '💡',
      title: t.coachTipTitle,
      body: tips[now.weekday % tips.length],
    ),
  );

  return CoachReport(
    tone: tone,
    headline: headline,
    subline: subline,
    insights: insights,
  );
}
