import '../../timer/domain/focus_session.dart';

/// Bitta odat: nomi, rangi va o'ziga tegishli taymer sessiyasi (FocusSession).
/// Har bir odat MUSTAQIL ishlaydi (biri ishlayotganda boshqasi pauzada bo'lishi mumkin).
class Habit {
  final String id;
  final String name;
  final int colorValue; // ARGB int (Color(colorValue) bilan tiklanadi)
  final int createdAt; // ms since epoch — tartiblash uchun
  final String emoji; // ixtiyoriy belgi (bo'sh bo'lishi mumkin)
  final FocusSession session;

  /// Foydalanuvchi "Yakunlash"ni bosgan vaqt (ms). null = yakunlanmagan.
  /// Maqsadga yetmasa ham odatni "bugun bajarildi" deb belgilash uchun.
  final int? finishedAtMs;

  const Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
    required this.session,
    this.emoji = '',
    this.finishedAtMs,
  });

  Habit copyWith({
    String? name,
    int? colorValue,
    String? emoji,
    FocusSession? session,
    int? finishedAtMs,
    bool clearFinished = false,
  }) => Habit(
    id: id,
    name: name ?? this.name,
    colorValue: colorValue ?? this.colorValue,
    createdAt: createdAt,
    emoji: emoji ?? this.emoji,
    session: session ?? this.session,
    finishedAtMs: clearFinished ? null : (finishedAtMs ?? this.finishedAtMs),
  );

  Habit start(DateTime now) => copyWith(session: session.start(now));
  Habit pause(DateTime now) => copyWith(session: session.pause(now));
  Habit reset() => copyWith(session: session.reset(), clearFinished: true);

  /// "Yakunlash" — taymerni to'xtatadi (vaqt HALOL, oshmaydi) va odatni
  /// bugun bajarilgan deb belgilaydi.
  Habit finish(DateTime now) => copyWith(
    session: session.pause(now),
    finishedAtMs: now.millisecondsSinceEpoch,
  );

  /// Odat bugun "bajarilgan"mi? — qo'lda yakunlangan YOKI maqsadga yetgan.
  bool isDone(DateTime now) => finishedAtMs != null || session.isComplete(now);

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'createdAt': createdAt,
    'emoji': emoji,
    'accumulatedMs': session.accumulatedMs,
    'runningSinceMs': session.runningSince?.millisecondsSinceEpoch,
    'goalMs': session.goalMs,
    'finishedAtMs': finishedAtMs,
  };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
    id: m['id'] as String,
    name: m['name'] as String,
    colorValue: (m['colorValue'] as int?) ?? 0xFF6C5CE7,
    createdAt: (m['createdAt'] as int?) ?? 0,
    emoji: (m['emoji'] as String?) ?? '',
    session: FocusSession(
      accumulatedMs: (m['accumulatedMs'] as int?) ?? 0,
      runningSince: m['runningSinceMs'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(m['runningSinceMs'] as int),
      goalMs: (m['goalMs'] as int?) ?? 0,
    ),
    finishedAtMs: m['finishedAtMs'] as int?,
  );
}
