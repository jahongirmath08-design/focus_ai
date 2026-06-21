import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../habits/state/habits_notifier.dart';
import '../data/gemini_service.dart';

/// Jonli AI-murabbiy suhbati (Gemini). Internet + foydalanuvchi kaliti kerak.
/// [autoPrompt] berilsa — ochilishi bilan o'sha savol avtomatik yuboriladi
/// ("Aqlli statistika tahlili" kartasi shu orqali ishlaydi).
class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({super.key, this.autoPrompt, this.title});

  final String? autoPrompt;
  final String? title;

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _Msg {
  _Msg(this.fromUser, this.text);
  final bool fromUser;
  final String text;
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[];
  bool _sending = false;
  bool _autoStarted = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// AI uchun tizim ko'rsatmasi — tilni majburlaydi va foydalanuvchining
  /// HAQIQIY statistikasini kontekst sifatida beradi (shaxsiy maslahat uchun).
  String _buildSystemPrompt() {
    final lang = ref.read(languageProvider);
    final name = ref.read(userNameProvider).trim();
    final habits = ref.read(habitsProvider);
    final history = ref.read(historyProvider);
    final now = DateTime.now();

    var todaySec = history?.totalSecondsLastDays(1) ?? 0;
    for (final h in habits) {
      if (h.session.isRunning) {
        final runMs = h.session.rawElapsedMs(now) - h.session.accumulatedMs;
        if (runMs > 0) todaySec += runMs ~/ 1000;
      }
    }
    final weekSec = history?.totalSecondsLastDays(7) ?? 0;
    final activeDays = history?.activeDaysLastDays(7) ?? 0;

    final langName = switch (lang) {
      AppLanguage.uz => 'Uzbek',
      AppLanguage.en => 'English',
      AppLanguage.ru => 'Russian',
    };

    final habitList = habits.isEmpty
        ? 'none yet'
        : habits
              .map((h) {
                final goalMin = h.session.goalMs ~/ 60000;
                final done = h.session.isComplete(now)
                    ? 'completed'
                    : 'in progress';
                return '${h.name} (goal ${goalMin}m, $done)';
              })
              .join('; ');

    final data =
        'User name: ${name.isEmpty ? "unknown" : name}. '
        'Habits: $habitList. '
        'Focus today: ${todaySec ~/ 60} min. '
        'Focus last 7 days: ${weekSec ~/ 60} min across $activeDays active day(s).';

    return 'You are a warm, human-like personal focus & habit coach living '
        'inside the "Focus AI" app (it turns focus time into glowing light '
        'arcs). Speak like a real, caring mentor — natural and conversational, '
        'never robotic, no bullet lists unless asked. ALWAYS reply in '
        '$langName. Address the user by name when it feels natural. Be '
        'specific: weave in their REAL numbers (minutes, habit names, active '
        'days) from the data below. Keep it to 2–5 warm sentences, ALWAYS '
        'finish your thought completely, and end with one concrete, kind next '
        'step. Celebrate small wins; never shame. If asked something '
        'unrelated, gently bring it back to focus, habits, productivity and '
        'wellbeing.\n\nUSER DATA: $data';
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    final key = ref.read(geminiKeyProvider).trim();
    if (text.isEmpty || key.isEmpty || _sending) return;
    final t = ref.read(l10nProvider);

    setState(() {
      _messages.add(_Msg(true, text));
      _sending = true;
    });
    _controller.clear();
    _scrollToEnd();

    try {
      final service = GeminiService(key);
      final reply = await service.chat(
        systemPrompt: _buildSystemPrompt(),
        history: [
          for (final m in _messages) (fromUser: m.fromUser, text: m.text),
        ],
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(false, reply.isEmpty ? t.chatErrorGeneric : reply));
        _sending = false;
      });
    } on GeminiException catch (e) {
      if (!mounted) return;
      final msg = (e.code == 400 || e.code == 401 || e.code == 403)
          ? t.chatErrorKey
          : (e.code == -1 ? t.chatErrorNetwork : t.chatErrorGeneric);
      setState(() {
        _messages.add(_Msg(false, msg));
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(false, t.chatErrorNetwork));
        _sending = false;
      });
    }
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _enterKey() async {
    final t = ref.read(l10nProvider);
    final controller = TextEditingController(text: ref.read(geminiKeyProvider));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.chatKeyDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: t.chatKeyDialogHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.chatGetKeyHint,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(geminiKeyProvider.notifier).setKey(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(l10nProvider);
    final key = ref.watch(geminiKeyProvider).trim();

    // Kalit bor + autoPrompt berilgan bo'lsa — bir marta avtomatik yuboramiz.
    if (key.isNotEmpty &&
        widget.autoPrompt != null &&
        widget.autoPrompt!.trim().isNotEmpty &&
        !_autoStarted) {
      _autoStarted = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _send(widget.autoPrompt!),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? t.proAiChatTitle),
        actions: [
          if (key.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.vpn_key_rounded),
              tooltip: t.chatChangeKey,
              onPressed: _enterKey,
            ),
        ],
      ),
      body: key.isEmpty ? _SetupView(t: t, onEnter: _enterKey) : _chatView(t),
    );
  }

  Widget _chatView(L10n t) {
    final scheme = Theme.of(context).colorScheme;
    final items = <Widget>[
      _Bubble(
        text: t.chatWelcome,
        fromUser: false,
        copyLabel: t.chatCopy,
        copiedLabel: t.chatCopied,
      ),
      for (final m in _messages)
        _Bubble(
          text: m.text,
          fromUser: m.fromUser,
          copyLabel: t.chatCopy,
          copiedLabel: t.chatCopied,
        ),
      if (_sending) _ThinkingBubble(label: t.chatThinking),
    ];

    return Column(
      children: [
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            children: items,
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: _send,
                    decoration: InputDecoration(
                      hintText: t.chatInputHint,
                      filled: true,
                      fillColor: scheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SendButton(
                  enabled: !_sending,
                  onTap: () => _send(_controller.text),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SetupView extends StatelessWidget {
  const _SetupView({required this.t, required this.onEnter});

  final L10n t;
  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.forum_rounded,
                color: AppColors.accent,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              t.chatSetupTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              t.chatSetupBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.chatGetKeyHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onEnter,
              icon: const Icon(Icons.vpn_key_rounded, size: 18),
              label: Text(t.chatSetupButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.fromUser,
    required this.copyLabel,
    required this.copiedLabel,
  });

  final String text;
  final bool fromUser;
  final String copyLabel;
  final String copiedLabel;

  void _copyAll(BuildContext context) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(copiedLabel),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxW = MediaQuery.of(context).size.width * 0.78;
    final textColor = fromUser ? Colors.white : scheme.onSurface;
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.fromLTRB(14, 10, 14, fromUser ? 10 : 4),
        decoration: BoxDecoration(
          color: fromUser
              ? AppColors.accent
              : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(fromUser ? 16 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // So'z-darajada tanlash: istalgan so'zni belgilab nusxalash mumkin.
            SelectableText(
              text,
              style: TextStyle(fontSize: 14.5, height: 1.35, color: textColor),
            ),
            // Butun xabarni bir bosishda nusxalash (faqat murabbiy xabarida).
            if (!fromUser)
              InkWell(
                onTap: () => _copyAll(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 15,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        copyLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.accent
          : AppColors.accent.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.arrow_upward_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
