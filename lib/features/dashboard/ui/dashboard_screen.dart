import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/utils/duration_format.dart';
import '../../active_session/ui/active_session_screen.dart';
import '../../active_session/ui/light_arc.dart';
import '../../habits/domain/habit.dart';
import '../../habits/state/habits_notifier.dart';
import 'add_habit_sheet.dart';

/// Asosiy ekran: odatlar ro'yxati. Har biri mustaqil taymer.
/// Kartani bosish -> Faol sessiya ekrani (signature yorug'lik yoyi).
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        // Maqsadga yetgan odatlarni aniq maqsadda to'xtatamiz (oshmasin).
        ref.read(habitsProvider.notifier).settleCompleted();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);
    final now = DateTime.now();
    final t = ref.watch(l10nProvider);
    final userName = ref.watch(userNameProvider);
    final userEmoji = ref.watch(userEmojiProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(
              habits: habits,
              now: now,
              t: t,
              userName: userName,
              userEmoji: userEmoji,
            ),
            Expanded(
              child: habits.isEmpty
                  ? _EmptyState(t: t)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: habits.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final h = habits[i];
                        return _HabitCard(
                          habit: h,
                          now: now,
                          t: t,
                          onOpen: () => Navigator.of(context).push(
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 600,
                              ),
                              reverseTransitionDuration: const Duration(
                                milliseconds: 480,
                              ),
                              pageBuilder: (_, _, _) =>
                                  ActiveSessionScreen(habitId: h.id),
                              transitionsBuilder: (_, anim, _, child) {
                                // Hero yoy silliq o'sadi; bundan tashqari butun
                                // ekran ozgina kattalashib (scale) fade bilan kiradi.
                                final curved = CurvedAnimation(
                                  parent: anim,
                                  curve: Curves.easeOutCubic,
                                  reverseCurve: Curves.easeInCubic,
                                );
                                return FadeTransition(
                                  opacity: curved,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.85,
                                      end: 1.0,
                                    ).animate(curved),
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          ),
                          onToggle: () => h.session.isRunning
                              ? notifier.pause(h.id)
                              : notifier.start(h.id),
                          onReset: () => notifier.reset(h.id),
                          onDelete: () => notifier.delete(h.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddHabitSheet(context),
        icon: const Icon(Icons.add),
        label: Text(t.addHabit),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.habits,
    required this.now,
    required this.t,
    required this.userName,
    required this.userEmoji,
  });

  final List<Habit> habits;
  final DateTime now;
  final L10n t;
  final String userName;
  final String userEmoji;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Har bir odat soniyaga yaxlitlanib qo'shiladi -> jami kartalardagi yig'indiga teng.
    final totalElapsed = habits.fold<int>(
      0,
      (s, h) => s + (h.session.elapsedMs(now) ~/ 1000) * 1000,
    );
    final active = habits
        .where((h) => h.session.isRunning && !h.session.isComplete(now))
        .length;
    final done = habits.where((h) => h.session.isComplete(now)).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$userEmoji ${t.greetingWithName(now.hour, userName)}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            t.longDate(now),
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _chip(
                context,
                Icons.bolt_rounded,
                formatDuration(totalElapsed),
                t.totalFocus,
                scheme.primary,
              ),
              const SizedBox(width: 10),
              _chip(
                context,
                Icons.play_arrow_rounded,
                '$active',
                t.activeLabel,
                const Color(0xFF00D2D3),
              ),
              const SizedBox(width: 10),
              _chip(
                context,
                Icons.check_rounded,
                '$done',
                t.completedLabel,
                const Color(0xFF55EFC4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.t});

  final L10n t;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_empty, size: 72, color: scheme.primary),
            const SizedBox(height: 16),
            Text(t.emptyTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              t.emptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.now,
    required this.t,
    required this.onOpen,
    required this.onToggle,
    required this.onReset,
    required this.onDelete,
  });

  final Habit habit;
  final DateTime now;
  final L10n t;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = Color(habit.colorValue);
    final s = habit.session;
    final elapsed = s.elapsedMs(now);
    final progress = s.progress(now);
    final complete = s.isComplete(now);
    final running = s.isRunning;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // SIGNATURE mini yoy — markazda % yoki ✓
              Hero(
                tag: 'habitArc_${habit.id}',
                flightShuttleBuilder: arcFlightShuttleBuilder(
                  progress: progress,
                  color: color,
                  complete: complete,
                ),
                child: MiniLightArc(
                  progress: progress,
                  color: color,
                  complete: complete,
                  size: 66,
                  child: complete
                      ? Icon(Icons.check_rounded, color: color, size: 24)
                      : Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Nom + vaqt + holat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            onSelected: (v) {
                              if (v == 'reset') onReset();
                              if (v == 'delete') onDelete();
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'reset',
                                child: Text(t.menuReset),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(t.menuDelete),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${formatDuration(elapsed)} / ${formatDuration(s.goalMs)}',
                      style: TextStyle(
                        fontSize: 15,
                        color: scheme.onSurfaceVariant,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      complete
                          ? t.statusDone
                          : running
                          ? t.statusRunning
                          : t.statusPaused,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: complete || running
                            ? color
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Tugaganda Qaytadan (⟳), aks holda Boshlash/Pauza — dumaloq tugma
              SizedBox(
                width: 50,
                height: 50,
                child: complete
                    ? FilledButton(
                        onPressed: onReset,
                        style: FilledButton.styleFrom(
                          backgroundColor: color.withValues(alpha: 0.18),
                          foregroundColor: color,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                          elevation: 0,
                        ),
                        child: const Icon(Icons.refresh),
                      )
                    : FilledButton(
                        onPressed: onToggle,
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.black,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: Icon(running ? Icons.pause : Icons.play_arrow),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
