import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../history/data/history_repository.dart';
import '../../timer/domain/focus_session.dart';
import '../data/habits_repository.dart';
import '../domain/habit.dart';

/// Odatlar ro'yxatini boshqaradigan Riverpod state.
/// Holat o'zgargan sayin Hive'ga saqlaydi. UI faqat o'qiydi.
final habitsProvider =
    NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

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
      final habits = _repo!.loadAll();
      _seedHistoryIfNeeded(habits);
      return habits;
    }
    _repo = null;
    return [];
  }

  /// Bir martalik: tarix bo'sh bo'lsa, mavjud diqqatni bugunga ko'chiramiz —
  /// shunda statistika darhol mazmunli bo'ladi (keyin aniq kunlik yoziladi).
  void _seedHistoryIfNeeded(List<Habit> habits) {
    final hist = _history;
    if (hist == null) return;
    try {
      final settings = Hive.box('settings');
      if (settings.get('history_seeded', defaultValue: false) == true) return;
      final now = DateTime.now();
      for (final h in habits) {
        final ms = h.session.accumulatedMs;
        if (ms > 0) hist.log(habitId: h.id, deltaMs: ms, at: now);
      }
      settings.put('history_seeded', true);
    } catch (_) {}
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
