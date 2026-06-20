import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../timer/domain/focus_session.dart';
import '../data/habits_repository.dart';
import '../domain/habit.dart';

/// Odatlar ro'yxatini boshqaradigan Riverpod state.
/// Holat o'zgargan sayin Hive'ga saqlaydi. UI faqat o'qiydi.
final habitsProvider =
    NotifierProvider<HabitsNotifier, List<Habit>>(HabitsNotifier.new);

class HabitsNotifier extends Notifier<List<Habit>> {
  HabitsRepository? _repo;

  @override
  List<Habit> build() {
    if (Hive.isBoxOpen('habits')) {
      _repo = HabitsRepository(Hive.box('habits'));
      return _repo!.loadAll();
    }
    _repo = null;
    return [];
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
  void pause(String id) => _update(id, (h) => h.pause(DateTime.now()));
  void reset(String id) => _update(id, (h) => h.reset());

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
