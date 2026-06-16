import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/duration_format.dart';
import '../../habits/domain/habit.dart';
import '../../habits/state/habits_notifier.dart';
import 'add_habit_sheet.dart';

/// Asosiy ekran: odatlar ro'yxati. Har biri mustaqil taymer.
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
    // FAQAT ekranni yangilash uchun (har 0.5s). Vaqt manbai — timestamp.
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
    final habits = ref.watch(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Focus AI'), centerTitle: false),
      body: habits.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: habits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final h = habits[i];
                return _HabitCard(
                  habit: h,
                  now: now,
                  onToggle: () => h.session.isRunning
                      ? notifier.pause(h.id)
                      : notifier.start(h.id),
                  onReset: () => notifier.reset(h.id),
                  onDelete: () => notifier.delete(h.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddHabitSheet(context),
        icon: const Icon(Icons.add),
        label: const Text("Odat qo'shish"),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            Text("Hali odat yo'q",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Pastdagi "Odat qo\'shish" tugmasi bilan birinchi odatingizni qo\'shing.',
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
    required this.onToggle,
    required this.onReset,
    required this.onDelete,
  });

  final Habit habit;
  final DateTime now;
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

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(habit.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'reset') onReset();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'reset', child: Text('Qaytadan (0 ga)')),
                  PopupMenuItem(value: 'delete', child: Text("O'chirish")),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatDuration(elapsed),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('/ ${formatDuration(s.goalMs)}',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                complete ? 'Bajarildi! 🎉' : '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: complete ? color : scheme.onSurfaceVariant,
                ),
              ),
              FilledButton.icon(
                onPressed: onToggle,
                icon: Icon(running ? Icons.pause : Icons.play_arrow),
                label: Text(running ? 'Pauza' : 'Boshlash'),
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
