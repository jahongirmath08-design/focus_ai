import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../domain/habit.dart';

/// Data qatlami: odatlar ro'yxatini Hive (lokal xotira)ga saqlaydi/o'qiydi.
/// Har bir odat o'z id'si bo'yicha alohida saqlanadi.
class HabitsRepository {
  HabitsRepository(this._box);

  final Box _box;

  List<Habit> loadAll() {
    final list = _box.values
        .map((e) => Habit.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> save(Habit habit) => _box.put(habit.id, habit.toMap());

  Future<void> delete(String id) => _box.delete(id);
}
