import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../../core/utils/duration_format.dart';
import '../data/session_repository.dart';
import '../domain/focus_session.dart';

/// Phase 1 ekrani: bitta timestamp taymer + Hive saqlash (xavfsiz).
class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  static const int _demoGoalMs = 60 * 1000; // demo maqsad: 1 daqiqa

  // Hive ochilgan bo'lsa — repository bor; bo'lmasa null (xotirada ishlaymiz).
  SessionRepository? _repo;
  late FocusSession _session;

  // DIQQAT: bu Timer FAQAT ekranni qayta chizish uchun. Vaqt manbai EMAS!
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (Hive.isBoxOpen('focus_session')) {
      _repo = SessionRepository(Hive.box('focus_session'));
      _session = _repo!.load(defaultGoalMs: _demoGoalMs);
    } else {
      _repo = null;
      _session = const FocusSession(goalMs: _demoGoalMs);
    }
    // Agar oldin ishlab turgan bo'lsa, qayta ochilganda o'tgan vaqt
    // runningSince'dan avtomatik to'g'ri hisoblanadi (timestamp sehri).
    if (_session.isRunning) {
      _startTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => setState(() {}),
    );
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _toggleStartPause() {
    final now = DateTime.now();
    setState(() {
      if (_session.isRunning) {
        _session = _session.pause(now);
        _stopTicker();
      } else {
        _session = _session.start(now);
        _startTicker();
      }
    });
    _repo?.save(_session); // holat o'zgardi -> saqlaymiz (agar saqlash mavjud bo'lsa)
  }

  void _reset() {
    setState(() {
      _session = _session.reset();
      _stopTicker();
    });
    _repo?.save(_session);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final elapsed = _session.elapsedMs(now);
    final progress = _session.progress(now);
    final complete = _session.isComplete(now);
    final running = _session.isRunning;
    final scheme = Theme.of(context).colorScheme;
    final saveOn = _repo != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Focus AI — Taymer')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatDuration(elapsed),
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w300,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Maqsad: ${formatDuration(_session.goalMs)}',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 28),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 260,
                  child: LinearProgressIndicator(value: progress, minHeight: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                complete ? 'Maqsadga yetdingiz! 🎉' : '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: complete ? scheme.tertiary : scheme.onSurface,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: _toggleStartPause,
                    icon: Icon(running ? Icons.pause : Icons.play_arrow),
                    label: Text(running ? 'Pauza' : 'Boshlash'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Qayta'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Vaqtinchalik diagnostika yozuvi (saqlash ishlayaptimi?).
              Text(
                saveOn ? 'Saqlash: yoniq 💾' : 'Saqlash: o\'chiq',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
