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
}
