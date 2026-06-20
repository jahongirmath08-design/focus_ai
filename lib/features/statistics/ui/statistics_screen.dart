import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/utils/duration_format.dart';
import '../../active_session/ui/light_arc.dart';
import '../../habits/domain/habit.dart';
import '../../habits/state/habits_notifier.dart';

/// Statistika — "diqqat taqsimoti" halqasi (donut) + jamlanma + odatlar ro'yxati.
/// Jonli (ticker) va jami HAR DOIM to'g'ri (Rival B aynan shu yerda yiqiladi).
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = ref.watch(l10nProvider);
    final habits = ref.watch(habitsProvider);
    final now = DateTime.now();

    // Har bir odat soniyaga yaxlitlanib qo'shiladi -> jami ro'yxatdagi yig'indiga teng.
    final totalElapsed = habits.fold<int>(
        0, (s, h) => s + (h.session.elapsedMs(now) ~/ 1000) * 1000);
    final totalGoal = habits.fold<int>(0, (s, h) => s + h.session.goalMs);
    final completed = habits.where((h) => h.session.isComplete(now)).length;
    final overall =
        totalGoal == 0 ? 0.0 : (totalElapsed / totalGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(title: Text(t.statsTitle), centerTitle: false),
      body: habits.isEmpty
          ? Center(
              child: Text(
                t.noData,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _FocusDonut(
                  habits: habits,
                  now: now,
                  totalLabel: formatDuration(totalElapsed),
                  t: t,
                ),
                const SizedBox(height: 8),
                _StatRow(
                  completed: completed,
                  total: habits.length,
                  overall: overall,
                  totalGoal: totalGoal,
                  t: t,
                ),
                const SizedBox(height: 24),
                Text(
                  t.byHabit,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                ...habits.map((h) {
                  final color = Color(h.colorValue);
                  final s = h.session;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        MiniLightArc(
                          progress: s.progress(now),
                          color: color,
                          complete: s.isComplete(now),
                          size: 52,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.emoji.isEmpty
                                    ? h.name
                                    : '${h.emoji} ${h.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatDuration(s.elapsedMs(now))} / ${formatDuration(s.goalMs)}',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 13,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${(s.progress(now) * 100).round()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

/// Diqqat taqsimoti halqasi — har odat o'z rangida segment.
/// Segmentni bossang (yoki ustiga kelsang) — ajralib chiqadi, markazda o'sha
/// odat nomi + jami vaqtdan ulushi (%). Segmentlar orasida ajratuvchi chiziq:
/// 12 dan ko'p odatda yoki rang takrorlansa ham har bo'lim farqlanadi.
class _FocusDonut extends StatefulWidget {
  const _FocusDonut({
    required this.habits,
    required this.now,
    required this.totalLabel,
    required this.t,
  });

  final List<Habit> habits;
  final DateTime now;
  final String totalLabel;
  final L10n t;

  @override
  State<_FocusDonut> createState() => _FocusDonutState();
}

class _FocusDonutState extends State<_FocusDonut> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final entries = <MapEntry<Habit, double>>[];
    var sum = 0.0;
    for (final h in widget.habits) {
      final sec = (h.session.elapsedMs(widget.now) ~/ 1000).toDouble();
      if (sec > 0) {
        sum += sec;
        entries.add(MapEntry(h, sec));
      }
    }

    final sections = <PieChartSectionData>[];
    if (entries.isEmpty) {
      sections.add(PieChartSectionData(
        value: 1,
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        radius: 24,
        showTitle: false,
      ));
    } else {
      for (var i = 0; i < entries.length; i++) {
        final touched = i == _touched;
        sections.add(PieChartSectionData(
          value: entries[i].value,
          color: Color(entries[i].key.colorValue),
          radius: touched ? 34 : 24,
          showTitle: false,
          borderSide: BorderSide(color: scheme.surface, width: 2),
        ));
      }
    }

    final showTouched = _touched >= 0 && _touched < entries.length && sum > 0;
    final Widget center;
    if (showTouched) {
      final h = entries[_touched].key;
      final pct = (entries[_touched].value / sum * 100).round();
      center = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            h.emoji.isEmpty ? h.name : '${h.emoji} ${h.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '$pct%',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Color(h.colorValue),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    } else {
      center = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.t.totalFocusCaps,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.totalLabel,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 74,
              sectionsSpace: sum > 0 ? 3 : 0,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(
                touchCallback: (event, resp) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        resp == null ||
                        resp.touchedSection == null) {
                      _touched = -1;
                      return;
                    }
                    _touched = resp.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
          IgnorePointer(child: center),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.completed,
    required this.total,
    required this.overall,
    required this.totalGoal,
    required this.t,
  });

  final int completed;
  final int total;
  final double overall;
  final int totalGoal;
  final L10n t;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _stat(context, '$completed/$total', t.statCompleted),
        _stat(context, '${(overall * 100).round()}%', t.statOverall),
        _stat(context, formatDuration(totalGoal), t.statGoal),
      ],
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
