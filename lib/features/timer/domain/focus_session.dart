/// FocusSession — bitta fokus sessiyasining taymer holati (PURE DART, Flutter'siz).
///
/// Asosiy g'oya: vaqt HECH QACHON "sanab" yuritilmaydi. Haqiqat har doim
/// timestamp'lardan hisoblanadi:
///   elapsed = accumulatedMs + (hozir - runningSince)
/// Shuning uchun ilova fonga o'tsa, yopilsa yoki telefon uxlasa ham
/// vaqt qayta ochilganda aniq tiklanadi. Bu — bizning asosiy ustunligimiz.
class FocusSession {
  /// Oldingi (pauza qilingan) bo'laklardan to'plangan vaqt, millisekundlarda.
  final int accumulatedMs;

  /// Taymer ayni paytda ishlayotgan bo'lsa — boshlangan vaqt belgisi (timestamp).
  /// Pauzada bo'lsa `null`.
  final DateTime? runningSince;

  /// Maqsad vaqti (ms). 0 bo'lsa — maqsad belgilanmagan.
  final int goalMs;

  const FocusSession({
    this.accumulatedMs = 0,
    this.runningSince,
    this.goalMs = 0,
  });

  /// Taymer ishlayaptimi?
  bool get isRunning => runningSince != null;

  /// Haqiqiy o'tgan vaqt (ms). [now] tashqaridan beriladi (test uchun qulay).
  /// Soat orqaga ketsa ham manfiy bo'lmaydi.
  int rawElapsedMs(DateTime now) {
    final since = runningSince;
    if (since == null) return accumulatedMs;
    final delta = now.difference(since).inMilliseconds;
    return accumulatedMs + (delta > 0 ? delta : 0);
  }

  /// Ko'rsatish uchun o'tgan vaqt — maqsaddan oshmaydi.
  int elapsedMs(DateTime now) {
    final raw = rawElapsedMs(now);
    if (goalMs > 0 && raw > goalMs) return goalMs;
    return raw;
  }

  /// Qolgan vaqt (ms). Manfiy bo'lmaydi.
  int remainingMs(DateTime now) {
    if (goalMs <= 0) return 0;
    final rem = goalMs - rawElapsedMs(now);
    return rem > 0 ? rem : 0;
  }

  /// Bajarilish darajasi 0.0 .. 1.0.
  double progress(DateTime now) {
    if (goalMs <= 0) return 0;
    final p = rawElapsedMs(now) / goalMs;
    if (p < 0) return 0;
    if (p > 1) return 1;
    return p;
  }

  /// Maqsadga yetildimi?
  bool isComplete(DateTime now) => goalMs > 0 && rawElapsedMs(now) >= goalMs;

  /// Boshlash / davom ettirish.
  FocusSession start(DateTime now) {
    if (isRunning) return this;
    return FocusSession(
      accumulatedMs: accumulatedMs,
      runningSince: now,
      goalMs: goalMs,
    );
  }

  /// Pauza — o'tgan vaqtni to'plamga qo'shadi va timestamp'ni tozalaydi.
  FocusSession pause(DateTime now) {
    if (!isRunning) return this;
    return FocusSession(
      accumulatedMs: rawElapsedMs(now),
      runningSince: null,
      goalMs: goalMs,
    );
  }

  /// Nolga qaytarish (maqsad saqlanadi).
  FocusSession reset() => FocusSession(goalMs: goalMs);

  /// Maqsadga yetganda to'xtatish — to'plangan vaqt aynan maqsadga tenglashadi
  /// (oshmaydi), taymer to'xtaydi. "Maqsaddan oshmaslik" qoidasini ma'lumot
  /// darajasida ham ta'minlaydi.
  FocusSession settle() {
    if (goalMs <= 0) return this;
    return FocusSession(
      accumulatedMs: goalMs,
      runningSince: null,
      goalMs: goalMs,
    );
  }

  /// Saqlash uchun (keyin Hive bilan ishlatamiz).
  Map<String, dynamic> toMap() => {
    'accumulatedMs': accumulatedMs,
    'runningSinceMs': runningSince?.millisecondsSinceEpoch,
    'goalMs': goalMs,
  };

  /// Saqlangandan qayta tiklash.
  factory FocusSession.fromMap(Map<String, dynamic> map) => FocusSession(
    accumulatedMs: (map['accumulatedMs'] as int?) ?? 0,
    runningSince: map['runningSinceMs'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(map['runningSinceMs'] as int),
    goalMs: (map['goalMs'] as int?) ?? 0,
  );
}
