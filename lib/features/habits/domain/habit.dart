import '../../timer/domain/focus_session.dart';

/// Bitta odat: nomi, rangi va o'ziga tegishli taymer sessiyasi (FocusSession).
/// Har bir odat MUSTAQIL ishlaydi (biri ishlayotganda boshqasi pauzada bo'lishi mumkin).
class Habit {
  final String id;
  final String name;
  final int colorValue; // ARGB int (Color(colorValue) bilan tiklanadi)
  final int createdAt; // ms since epoch — tartiblash uchun
  final FocusSession session;

  const Habit({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
    required this.session,
  });

  Habit copyWith({String? name, int? colorValue, FocusSession? session}) => Habit(
        id: id,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        createdAt: createdAt,
        session: session ?? this.session,
      );

  Habit start(DateTime now) => copyWith(session: session.start(now));
  Habit pause(DateTime now) => copyWith(session: session.pause(now));
  Habit reset() => copyWith(session: session.reset());

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'createdAt': createdAt,
        'accumulatedMs': session.accumulatedMs,
        'runningSinceMs': session.runningSince?.millisecondsSinceEpoch,
        'goalMs': session.goalMs,
      };

  factory Habit.fromMap(Map<String, dynamic> m) => Habit(
        id: m['id'] as String,
        name: m['name'] as String,
        colorValue: (m['colorValue'] as int?) ?? 0xFF6C5CE7,
        createdAt: (m['createdAt'] as int?) ?? 0,
        session: FocusSession(
          accumulatedMs: (m['accumulatedMs'] as int?) ?? 0,
          runningSince: m['runningSinceMs'] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(m['runningSinceMs'] as int),
          goalMs: (m['goalMs'] as int?) ?? 0,
        ),
      );
}
