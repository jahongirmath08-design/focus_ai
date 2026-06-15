import 'package:flutter_test/flutter_test.dart';
import 'package:focus_ai/features/timer/domain/focus_session.dart';

void main() {
  // Bazaviy vaqt — testlar deterministik (har doim bir xil) bo'lishi uchun.
  final t0 = DateTime(2026, 1, 1, 10, 0, 0);
  DateTime at(int seconds) => t0.add(Duration(seconds: seconds));

  group('FocusSession timestamp mantiqi', () {
    test('boshida o\'tgan vaqt 0 va ishlamayapti', () {
      const s = FocusSession(goalMs: 60000);
      expect(s.isRunning, false);
      expect(s.rawElapsedMs(t0), 0);
    });

    test('start dan keyin 10s o\'tadi', () {
      final s = const FocusSession(goalMs: 60000).start(t0);
      expect(s.isRunning, true);
      expect(s.rawElapsedMs(at(10)), 10000);
    });

    test('pauza vaqtni muzlatadi', () {
      final s = const FocusSession(goalMs: 60000).start(t0).pause(at(10));
      expect(s.isRunning, false);
      // pauzadan keyin vaqt o'tsa ham elapsed o'zgarmaydi
      expect(s.rawElapsedMs(at(100)), 10000);
    });

    test('resume to\'plangan vaqt ustiga davom etadi', () {
      final s = const FocusSession(goalMs: 60000)
          .start(t0)
          .pause(at(10))
          .start(at(20));
      expect(s.rawElapsedMs(at(25)), 15000); // 10s + 5s
    });

    test('ILOVA O\'LDIRILSA HAM vaqt aniq tiklanadi (timestamp sehri)', () {
      // ishlayotgan sessiya saqlandi
      final running = const FocusSession(goalMs: 600000).start(t0);
      final saved = running.toMap();
      // ... ilova o'ldirildi, 5 daqiqadan keyin qayta ochildi
      final restored = FocusSession.fromMap(saved);
      expect(restored.isRunning, true);
      expect(restored.rawElapsedMs(at(300)), 300000); // aynan 5 daqiqa
    });

    test('maqsaddan oshmaydi (overshoot yo\'q)', () {
      final s = const FocusSession(goalMs: 60000).start(t0);
      expect(s.elapsedMs(at(120)), 60000); // 2 daqiqa o'tsa ham 60s
      expect(s.isComplete(at(120)), true);
      expect(s.remainingMs(at(120)), 0);
      expect(s.progress(at(120)), 1.0);
    });

    test('soat orqaga ketsa manfiy vaqt yo\'q', () {
      final s = const FocusSession().start(at(100));
      expect(s.rawElapsedMs(at(50)), 0);
    });
  });
}
