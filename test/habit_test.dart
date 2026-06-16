import 'package:flutter_test/flutter_test.dart';
import 'package:focus_ai/features/habits/domain/habit.dart';
import 'package:focus_ai/features/timer/domain/focus_session.dart';

void main() {
  final t0 = DateTime(2026, 1, 1, 10, 0, 0);
  DateTime at(int seconds) => t0.add(Duration(seconds: seconds));

  test('Habit start/pause sessiyaga to\'g\'ri delegatsiya qiladi', () {
    final h = Habit(
      id: '1',
      name: 'Test',
      colorValue: 0xFF6C5CE7,
      createdAt: 0,
      session: const FocusSession(goalMs: 60000),
    );
    final started = h.start(t0);
    expect(started.session.isRunning, true);
    expect(started.session.rawElapsedMs(at(10)), 10000);

    final paused = started.pause(at(10));
    expect(paused.session.isRunning, false);
    expect(paused.session.rawElapsedMs(at(99)), 10000); // pauzada o'zgarmaydi
  });

  test('Habit toMap/fromMap roundtrip (ishlab turgan holatni saqlaydi)', () {
    final h = Habit(
      id: '7',
      name: "O'qish",
      colorValue: 0xFF00D2D3,
      createdAt: 123,
      session: const FocusSession(accumulatedMs: 5000, goalMs: 60000),
    ).start(t0);

    final back = Habit.fromMap(h.toMap());
    expect(back.id, '7');
    expect(back.name, "O'qish");
    expect(back.colorValue, 0xFF00D2D3);
    expect(back.createdAt, 123);
    expect(back.session.accumulatedMs, 5000);
    expect(back.session.isRunning, true);
    expect(back.session.goalMs, 60000);
  });
}
