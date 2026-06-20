import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/utils/duration_format.dart';
import '../../active_session/ui/light_arc.dart';
import '../../habits/state/habits_notifier.dart';

/// Statistika — barcha odatlar bo'yicha jamlanma.
/// Jami HAR DOIM to'g'ri hisoblanadi (Rival B aynan shu — mos kelmaydigan jami —
/// bilan yiqiladi; biz aniqlik bilan yutamiz).
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
    // Jonli yangilanish — Bugun ekrani bilan aynan mos bo'lishi uchun.
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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SummaryCard(
                  t: t,
                  totalElapsed: totalElapsed,
                  totalGoal: totalGoal,
                  completed: completed,
                  total: habits.length,
                  overall: overall,
                ),
                const SizedBox(height: 20),
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.t,
    required this.totalElapsed,
    required this.totalGoal,
    required this.completed,
    required this.total,
    required this.overall,
  });

  final L10n t;
  final int totalElapsed;
  final int totalGoal;
  final int completed;
  final int total;
  final double overall;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary.withValues(alpha: 0.18),
            scheme.primary.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.totalFocusCaps,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatDuration(totalElapsed),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w300,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat(context, '$completed/$total', t.statCompleted),
              const SizedBox(width: 28),
              _stat(context, '${(overall * 100).round()}%', t.statOverall),
              const SizedBox(width: 28),
              _stat(context, formatDuration(totalGoal), t.statGoal),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        Text(
          label,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
