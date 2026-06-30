import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// Focus-tarix: har bir kun + odat uchun jamlangan diqqat (soniya).
/// Kalit: 'YYYYMMDD|habitId'. Qiymat: int (soniya).
/// Diqqat sodir bo'lgan sayin (pauza/qayta bosilganda delta) yoziladi —
/// shunday qilib kunlik/haftalik/oylik/yillik statistikani jamlash mumkin.
class HistoryRepository {
  HistoryRepository(this._box);
  final Box _box;

  static int dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  /// Tugagan diqqat oralig'ini (deltaMs) bugungi kunga yozadi.
  void log({
    required String habitId,
    required int deltaMs,
    required DateTime at,
  }) {
    if (deltaMs <= 0) return;
    final k = '${dayKey(at)}|$habitId';
    final cur = (_box.get(k) as int?) ?? 0;
    _box.put(k, cur + deltaMs ~/ 1000);
  }

  /// Oxirgi [days] kun ichida (bugun ham kiradi) har odat bo'yicha jami soniya.
  Map<String, int> focusByHabitLastDays(int days) {
    final now = DateTime.now();
    final from = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final fromKey = dayKey(from);
    final toKey = dayKey(now);
    final out = <String, int>{};
    for (final key in _box.keys) {
      final s = key.toString();
      final sep = s.indexOf('|');
      if (sep <= 0) continue;
      final dk = int.tryParse(s.substring(0, sep));
      if (dk == null || dk < fromKey || dk > toKey) continue;
      final habitId = s.substring(sep + 1);
      out[habitId] = (out[habitId] ?? 0) + ((_box.get(key) as int?) ?? 0);
    }
    return out;
  }

  /// Oxirgi [days] kun ichidagi jami diqqat (soniya) — barcha odatlar bo'yicha.
  int totalSecondsLastDays(int days) {
    var sum = 0;
    for (final v in focusByHabitLastDays(days).values) {
      sum += v;
    }
    return sum;
  }

  /// Oxirgi [days] kun ichida faoliyat bo'lgan ALOHIDA kunlar soni (izchillik).
  int activeDaysLastDays(int days) {
    final now = DateTime.now();
    final from = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final fromKey = dayKey(from);
    final toKey = dayKey(now);
    final seen = <int>{};
    for (final key in _box.keys) {
      final s = key.toString();
      final sep = s.indexOf('|');
      if (sep <= 0) continue;
      final dk = int.tryParse(s.substring(0, sep));
      if (dk == null || dk < fromKey || dk > toKey) continue;
      if (((_box.get(key) as int?) ?? 0) > 0) seen.add(dk);
    }
    return seen.length;
  }

  /// Faollik bo'lgan (diqqat > 0) barcha kunlarning dayKey to'plami.
  Set<int> _activeDayKeys() {
    final out = <int>{};
    for (final key in _box.keys) {
      final s = key.toString();
      final sep = s.indexOf('|');
      if (sep <= 0) continue;
      final dk = int.tryParse(s.substring(0, sep));
      if (dk == null) continue;
      if (((_box.get(key) as int?) ?? 0) > 0) out.add(dk);
    }
    return out;
  }

  /// dayKey (YYYYMMDD) -> DateTime.
  static DateTime dateFromKey(int dk) =>
      DateTime(dk ~/ 10000, (dk % 10000) ~/ 100, dk % 100);

  /// JORIY seriya — bugundan (yoki bugun hali bo'sh bo'lsa kechadan) orqaga qarab
  /// uzluksiz faol kunlar soni. [todayActive] — bugun hozir ish bo'layotgani.
  int currentStreak({bool todayActive = false}) {
    final active = _activeDayKeys();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayKey = dayKey(today);
    bool isActive(DateTime d) =>
        (dayKey(d) == todayKey && todayActive) || active.contains(dayKey(d));

    var day = today;
    if (!isActive(day)) {
      // bugun hali bo'sh — seriya kechagacha hisoblanadi (bugun uzilmaydi).
      day = day.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (isActive(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// ENG UZUN seriya — barcha tarix bo'yicha eng uzun uzluksiz faol kunlar.
  int longestStreak({bool todayActive = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = _activeDayKeys().map(dateFromKey).toList();
    if (todayActive && !days.contains(today)) days.add(today);
    if (days.isEmpty) return 0;
    days.sort();
    var longest = 1;
    var run = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        run++;
        if (run > longest) longest = run;
      } else if (diff > 1) {
        run = 1;
      }
    }
    return longest;
  }

  /// Heatmap uchun: oxirgi [days] kun bo'yicha dayKey -> jami soniya.
  Map<int, int> dailyTotalsLastDays(int days) {
    final now = DateTime.now();
    final from = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: days - 1));
    final fromKey = dayKey(from);
    final toKey = dayKey(now);
    final out = <int, int>{};
    for (final key in _box.keys) {
      final s = key.toString();
      final sep = s.indexOf('|');
      if (sep <= 0) continue;
      final dk = int.tryParse(s.substring(0, sep));
      if (dk == null || dk < fromKey || dk > toKey) continue;
      out[dk] = (out[dk] ?? 0) + ((_box.get(key) as int?) ?? 0);
    }
    return out;
  }
}
