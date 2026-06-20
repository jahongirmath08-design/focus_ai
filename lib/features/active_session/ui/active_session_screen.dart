import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/app_settings.dart';
import '../../../core/utils/duration_format.dart';
import '../../habits/state/habits_notifier.dart';
import 'light_arc.dart';

/// Faol sessiya ekrani — bitta odatning to'liq taymeri + signature yorug'lik yoyi.
/// Ambient fon: progress bilan ekran odat rangида "qizib" boradi ("o'choq" hissi).
class ActiveSessionScreen extends ConsumerStatefulWidget {
  const ActiveSessionScreen({super.key, required this.habitId});

  final String habitId;

  @override
  ConsumerState<ActiveSessionScreen> createState() =>
      _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends ConsumerState<ActiveSessionScreen> {
  Timer? _ticker;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 200), (_) {
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
    final t = ref.watch(l10nProvider);
    final habits = ref.watch(habitsProvider);
    final notifier = ref.read(habitsProvider.notifier);
    final matches = habits.where((h) => h.id == widget.habitId);
    if (matches.isEmpty) {
      return Scaffold(body: Center(child: Text(t.habitNotFound)));
    }
    final habit = matches.first;
    final color = Color(habit.colorValue);
    final s = habit.session;
    final now = DateTime.now();
    final elapsed = s.elapsedMs(now);
    final progress = s.progress(now);
    final complete = s.isComplete(now);
    final running = s.isRunning;

    // 100% ga yetganda bir marta haptic
    if (complete && !_celebrated) {
      _celebrated = true;
      HapticFeedback.heavyImpact();
    } else if (!complete) {
      _celebrated = false;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(habit.emoji.isEmpty
            ? habit.name
            : '${habit.emoji} ${habit.name}'),
      ),
      // Ambient "o'choq" foni — progress bilan qizийdi.
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.15),
            radius: 1.0,
            colors: [
              color.withValues(alpha: 0.06 + 0.32 * progress),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'habitArc_${widget.habitId}',
                flightShuttleBuilder: arcFlightShuttleBuilder(
                  progress: progress,
                  color: color,
                  complete: complete,
                ),
                child: LightArc(
                  progress: progress,
                  color: color,
                  running: running,
                  complete: complete,
                  size: 300,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatDuration(elapsed),
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w300,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        complete
                            ? t.statusDone
                            : t.remaining(formatDuration(s.remainingMs(now),
                                roundUp: true)),
                        style: TextStyle(
                          color: complete ? color : Colors.white54,
                          fontWeight:
                              complete ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 56),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      if (complete) {
                        HapticFeedback.lightImpact();
                        notifier.reset(habit.id);
                      } else {
                        HapticFeedback.mediumImpact();
                        if (running) {
                          notifier.pause(habit.id);
                        } else {
                          notifier.start(habit.id);
                        }
                      }
                    },
                    icon: Icon(complete
                        ? Icons.refresh
                        : (running ? Icons.pause : Icons.play_arrow)),
                    label: Text(complete
                        ? t.restart
                        : (running ? t.pause : t.start)),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (!complete) ...[
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        notifier.reset(habit.id);
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(t.resetShort),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
