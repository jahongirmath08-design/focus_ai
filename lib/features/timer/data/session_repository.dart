import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../domain/focus_session.dart';

/// Data qatlami: FocusSession holatini Hive (lokal xotira)ga saqlaydi/o'qiydi.
/// Faqat primitiv qiymatlar (int) saqlanadi — adapter/codegen kerak emas.
class SessionRepository {
  SessionRepository(this._box);

  final Box _box;

  static const _accKey = 'accumulatedMs';
  static const _sinceKey = 'runningSinceMs';
  static const _goalKey = 'goalMs';

  /// Saqlangan holatni o'qiydi. Hech narsa saqlanmagan bo'lsa — yangi sessiya.
  FocusSession load({int defaultGoalMs = 0}) {
    final acc = _box.get(_accKey, defaultValue: 0) as int;
    final sinceMs = _box.get(_sinceKey) as int?;
    final goal = _box.get(_goalKey, defaultValue: defaultGoalMs) as int;
    return FocusSession(
      accumulatedMs: acc,
      runningSince:
          sinceMs == null ? null : DateTime.fromMillisecondsSinceEpoch(sinceMs),
      goalMs: goal,
    );
  }

  /// Holatni saqlaydi. DIQQAT: bu har soniyada emas, faqat holat
  /// o'zgarganda (start / pauza / reset) chaqiriladi — haqiqat timestamp'da.
  Future<void> save(FocusSession s) async {
    await _box.put(_accKey, s.accumulatedMs);
    await _box.put(_goalKey, s.goalMs);
    if (s.runningSince == null) {
      await _box.delete(_sinceKey);
    } else {
      await _box.put(_sinceKey, s.runningSince!.millisecondsSinceEpoch);
    }
  }
}
