import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../habits/state/habits_notifier.dart';
import '../domain/ai_coach.dart';
import 'coach_chat_screen.dart';

/// "Pro" bo'lim — premium markaz. Hozir: OFFLINE AI-murabbiy (jonli, kalitsiz)
/// + online imkoniyatlar (internet bilan keyin ulanadi).
class ProScreen extends ConsumerWidget {
  const ProScreen({super.key});

  static const _gradA = AppColors.accent;
  static const _gradB = Color(0xFFB06AB3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(l10nProvider);
    final habits = ref.watch(habitsProvider);
    final history = ref.watch(historyProvider);
    final userName = ref.watch(userNameProvider);
    final now = DateTime.now();

    // Bugungi diqqat (yozilgan) + ayni ishlayotgan delta.
    var todaySec = history?.totalSecondsLastDays(1) ?? 0;
    for (final h in habits) {
      if (h.session.isRunning) {
        final runMs = h.session.rawElapsedMs(now) - h.session.accumulatedMs;
        if (runMs > 0) todaySec += runMs ~/ 1000;
      }
    }

    final report = buildCoachReport(
      t: t,
      now: now,
      userName: userName,
      habits: habits,
      todayFocusSec: todaySec,
      weekFocusSec: history?.totalSecondsLastDays(7) ?? 0,
      activeDaysThisWeek: history?.activeDaysLastDays(7) ?? 0,
      weekByHabit: history?.focusByHabitLastDays(7) ?? const {},
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(t: t, gradA: _gradA, gradB: _gradB),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(
                  text: t.proCoachSection,
                  badge: t.proOfflineBadge,
                ),
                const SizedBox(height: 12),
                _CoachCard(report: report, gradA: _gradA, gradB: _gradB),
                const SizedBox(height: 12),
                for (final ins in report.insights) ...[
                  _InsightTile(insight: ins),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 14),
                _SectionLabel(text: t.proOnlineSection, badge: t.proLiveBadge),
                const SizedBox(height: 12),
                _OnlineTile(
                  icon: Icons.forum_rounded,
                  title: t.proAiChatTitle,
                  body: t.proAiChatBody,
                  badge: t.proNeedsInternet,
                  color: _gradA,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CoachChatScreen()),
                  ),
                ),
                _OnlineTile(
                  icon: Icons.insights_rounded,
                  title: t.proAiAnalysisTitle,
                  body: t.proAiAnalysisBody,
                  badge: t.proNeedsInternet,
                  color: _gradB,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoachChatScreen(
                        title: t.proAiAnalysisTitle,
                        autoPrompt: t.chatAnalyzePrompt,
                        category: 'analysis',
                      ),
                    ),
                  ),
                ),
                _OnlineTile(
                  icon: Icons.cloud_sync_rounded,
                  title: t.proCloudTitle,
                  body: t.proCloudBody,
                  badge: t.proSoon,
                  color: const Color(0xFF4FA3F7),
                  onTap: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(t.proSoon))),
                ),
                _OnlineTile(
                  icon: Icons.emoji_events_rounded,
                  title: t.proFriendsTitle,
                  body: t.proFriendsBody,
                  badge: t.proSoon,
                  color: const Color(0xFFEFA84C),
                  onTap: () => ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(t.proSoon))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.t, required this.gradA, required this.gradB});

  final L10n t;
  final Color gradA;
  final Color gradB;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, top + 28, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradA, gradB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: gradA.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 26),
              const SizedBox(width: 10),
              Text(
                t.proTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            t.proSubtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.badge});

  final String text;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.report,
    required this.gradA,
    required this.gradB,
  });

  final CoachReport report;
  final Color gradA;
  final Color gradB;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradA.withValues(alpha: 0.22),
            gradB.withValues(alpha: 0.18),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gradA.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_rounded, color: AppColors.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  report.headline,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.subline,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  const _InsightTile({required this.insight});

  final CoachInsight insight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = insight.colorValue != null
        ? Color(insight.colorValue!)
        : AppColors.accent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Text(insight.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  insight.body,
                  style: const TextStyle(fontSize: 14.5, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnlineTile extends StatelessWidget {
  const _OnlineTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.badge,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String badge;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
