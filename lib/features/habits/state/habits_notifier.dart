import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../history/data/history_repository.dart';
import '../../timer/domain/focus_session.dart';
import '../data/habits_repository.dart';
import '../domain/habit.dart';

/// Odatlar ro'yxatini boshqaradigan Riverpod state.
/// Holat o'zgargan sayin Hive'ga saqlaydi. UI faqat o'qiydi.
final habitsProvider = NotifierProvider<HabitsNotifier, List<Habit>>(
  HabitsNotifier.new,
);

class HabitsNotifier extends Notifier<List<Habit>> {
  HabitsRepository? _repo;
  HistoryRepository? _history;

  @override
  List<Habit> build() {
    if (Hive.isBoxOpen('history')) {
      _history = HistoryRepository(Hive.box('history'));
    }
    if (Hive.isBoxOpen('habits')) {
      _repo = HabitsRepository(Hive.box('habits'));
      return _migrate(_repo!.loadAll());
    }
    _repo = null;
    return [];
  }

  /// Bir martalik tuzatish (v2): maqsaddan oshib ketgan to'plangan vaqtni
  /// maqsadga chegaralaymiz va focus-tarixni qaytadan (chegaralangan) seed qilamiz.
  List<Habit> _migrate(List<Habit> habits) {
    try {
      final settings = Hive.box('settings');
      if (settings.get('history_v2', defaultValue: false) == true) {
        return habits;
      }

      // 1) Maqsaddan oshgan vaqtni maqsadga tenglashtiramiz.
      final fixed = <Habit>[];
      for (final h in habits) {
        final s = h.session;
        if (s.goalMs > 0 && s.accumulatedMs > s.goalMs) {
          final f = h.copyWith(session: s.settle());
          _repo?.save(f);
          fixed.add(f);
        } else {
          fixed.add(h);
        }
      }

      // 2) Tarixni qaytadan, chegaralangan holda seed qilamiz.
      final hist = _history;
      if (hist != null && Hive.isBoxOpen('history')) {
        Hive.box('history').clear();
        final now = DateTime.now();
        for (final h in fixed) {
          final ms = h.session.accumulatedMs;
          if (ms > 0) hist.log(habitId: h.id, deltaMs: ms, at: now);
        }
      }

      settings.put('history_v2', true);
      return fixed;
    } catch (_) {
      return habits;
    }
  }

  /// Maqsadga yetgan (ishlab turgan yoki oshib ketgan) odatlarni to'xtatadi —
  /// taymer aniq maqsadda to'xtaydi. UI tikeridan davriy chaqiriladi.
  void settleCompleted() {
    final now = DateTime.now();
    var changed = false;
    final next = <Habit>[];
    for (final h in state) {
      final s = h.session;
      final over = s.goalMs > 0 && s.rawElapsedMs(now) >= s.goalMs;
      final needs = over && (s.isRunning || s.accumulatedMs > s.goalMs);
      if (needs) {
        final delta = s.goalMs - s.accumulatedMs;
        if (delta > 0) _history?.log(habitId: h.id, deltaMs: delta, at: now);
        final settled = h.copyWith(session: s.settle());
        _repo?.save(settled);
        next.add(settled);
        changed = true;
      } else {
        next.add(h);
      }
    }
    if (changed) state = next;
  }

  void addHabit({
    required String name,
    required int goalMs,
    required int colorValue,
    String emoji = '',
  }) {
    final now = DateTime.now();
    final habit = Habit(
      id: now.microsecondsSinceEpoch.toString(),
      name: name,
      colorValue: colorValue,
      createdAt: now.millisecondsSinceEpoch,
      emoji: emoji,
      session: FocusSession(goalMs: goalMs),
    );
    state = [...state, habit];
    _repo?.save(habit);
  }

  void start(String id) => _update(id, (h) => h.start(DateTime.now()));

  void pause(String id) {
    final now = DateTime.now();
    _logRunning(id, now);
    _update(id, (h) => h.pause(now));
  }

  void reset(String id) {
    final now = DateTime.now();
    _logRunning(id, now);
    _update(id, (h) => h.reset());
  }

  /// "Yakunlash" — ishlab turgan vaqtni tarixga yozadi, taymerni to'xtatadi va
  /// odatni bugun bajarilgan deb belgilaydi (vaqt halol, oshmaydi).
  void finish(String id) {
    final now = DateTime.now();
    _logRunning(id, now);
    _update(id, (h) => h.finish(now));
  }

  /// Ishlab turgan oraliqning hali yozilmagan qismini focus-tarixga yozadi.
  void _logRunning(String id, DateTime now) {
    final matches = state.where((h) => h.id == id);
    if (matches.isEmpty) return;
    final s = matches.first.session;
    if (!s.isRunning) return;
    final deltaMs = s.rawElapsedMs(now) - s.accumulatedMs;
    if (deltaMs > 0) {
      _history?.log(habitId: id, deltaMs: deltaMs, at: now);
    }
  }

  void delete(String id) {
    state = state.where((h) => h.id != id).toList();
    _repo?.delete(id);
  }

  /// Barcha odatlar va focus-tarixni o'chiradi (ma'lumotni tozalash).
  void clearAll() {
    try {
      if (Hive.isBoxOpen('habits')) Hive.box('habits').clear();
      if (Hive.isBoxOpen('history')) Hive.box('history').clear();
    } catch (_) {}
    state = [];
  }

  void _update(String id, Habit Function(Habit) transform) {
    final next = <Habit>[];
    for (final h in state) {
      if (h.id == id) {
        final updated = transform(h);
        _repo?.save(updated);
        next.add(updated);
      } else {
        next.add(h);
      }
    }
    state = next;
  }
}
