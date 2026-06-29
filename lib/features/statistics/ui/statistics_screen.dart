import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/utils/duration_format.dart';
import '../../habits/domain/habit.dart';
import '../../habits/state/habits_notifier.dart';

/// Statistika — davr tanlagich (Kunlik/Haftalik/Oylik/Yillik) + diqqat taqsimoti
/// donut + odatlar bo'yicha bar. Ma'lumot focus-tarixdan (Hive 'history').
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  Timer? _ticker;
  int _periodDays = 1; // Kunlik

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
    final history = ref.watch(historyProvider);
    final now = DateTime.now();

    // Tanlangan davr bo'yicha har odat uchun diqqat (soniya).
    final base = history?.focusByHabitLastDays(_periodDays) ?? <String, int>{};
    final periodSec = Map<String, int>.from(base);
    // Bugungi hali yozilmagan (ishlab turgan) diqqatni qo'shamiz.
    for (final h in habits) {
      if (h.session.isRunning) {
        final runMs = h.session.rawElapsedMs(now) - h.session.accumulatedMs;
        if (runMs > 0) {
          periodSec[h.id] = (periodSec[h.id] ?? 0) + runMs ~/ 1000;
        }
      }
    }

    final entries = <MapEntry<Habit, double>>[];
    for (final h in habits) {
      final sec = periodSec[h.id] ?? 0;
      if (sec > 0) entries.add(MapEntry(h, sec.toDouble()));
    }
    entries.sort((a, b) => b.value.compareTo(a.value));
    final totalSec = entries.fold<double>(0, (s, e) => s + e.value).toInt();
    final maxSec = entries.isEmpty ? 0.0 : entries.first.value;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                _PeriodSelector(
                  days: _periodDays,
                  onChanged: (d) => setState(() => _periodDays = d),
                  t: t,
                ),
                const SizedBox(height: 16),
                _FocusDonut(
                  entries: entries,
                  totalLabel: formatDuration(totalSec * 1000),
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
                const SizedBox(height: 14),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      t.noData,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                else
                  for (final e in entries)
                    _HabitBar(
                      habit: e.key,
                      seconds: e.value,
                      maxSeconds: maxSec,
                    ),
              ],
            ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.days,
    required this.onChanged,
    required this.t,
  });

  final int days;
  final ValueChanged<int> onChanged;
  final L10n t;

  @override
  Widget build(BuildContext context) {
    final options = <int, String>{
      1: t.periodDay,
      7: t.periodWeek,
      30: t.periodMonth,
      365: t.periodYear,
    };
    return Wrap(
      spacing: 8,
      children: [
        for (final entry in options.entries)
          ChoiceChip(
            label: Text(entry.value),
            selected: days == entry.key,
            onSelected: (_) => onChanged(entry.key),
          ),
      ],
    );
  }
}

/// Diqqat taqsimoti halqasi (davr bo'yicha). Segmentni bossang — ajralib chiqadi,
/// markazda o'sha odat nomi + ulushi (%). Segmentlar orasida ajratuvchi chiziq.
class _FocusDonut extends StatefulWidget {
  const _FocusDonut({
    required this.entries,
    required this.totalLabel,
    required this.t,
  });

  final List<MapEntry<Habit, double>> entries;
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
    final entries = widget.entries;
    final sum = entries.fold<double>(0, (s, e) => s + e.value);

    final sections = <PieChartSectionData>[];
    if (entries.isEmpty) {
      sections.add(
        PieChartSectionData(
          value: 1,
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          radius: 24,
          showTitle: false,
        ),
      );
    } else {
      for (var i = 0; i < entries.length; i++) {
        final touched = i == _touched;
        sections.add(
          PieChartSectionData(
            value: entries[i].value,
            color: Color(entries[i].key.colorValue),
            radius: touched ? 34 : 24,
            showTitle: false,
            borderSide: BorderSide(color: scheme.surface, width: 2),
          ),
        );
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

class _HabitBar extends StatelessWidget {
  const _HabitBar({
    required this.habit,
    required this.seconds,
    required this.maxSeconds,
  });

  final Habit habit;
  final double seconds;
  final double maxSeconds;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color(habit.colorValue);
    final frac = maxSeconds <= 0 ? 0.0 : (seconds / maxSeconds).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  habit.emoji.isEmpty
                      ? habit.name
                      : '${habit.emoji} ${habit.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                formatDuration(seconds.toInt() * 1000),
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
