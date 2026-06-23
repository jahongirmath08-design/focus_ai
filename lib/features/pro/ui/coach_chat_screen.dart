import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../habits/state/habits_notifier.dart';
import '../data/gemini_service.dart';
import '../domain/conversation.dart';
import '../state/conversations_notifier.dart';

/// Jonli AI-murabbiy suhbati (Gemini). Internet + foydalanuvchi kaliti kerak.
/// [autoPrompt] berilsa — ochilishi bilan o'sha savol avtomatik yuboriladi
/// ("Aqlli statistika tahlili" kartasi shu orqali ishlaydi).
class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({
    super.key,
    this.autoPrompt,
    this.title,
    this.conversationId,
    this.category = 'chat',
  });

  final String? autoPrompt;
  final String? title;
  final String? conversationId;
  final String category; // tarix shu kategoriya bo'yicha ajratiladi

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _Msg {
  _Msg(this.fromUser, this.text, {this.image});
  final bool fromUser;
  final String text;
  final Uint8List? image;
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_Msg>[];
  Uint8List? _pendingImage;
  String _pendingMime = 'image/jpeg';
  bool _sending = false;
  bool _autoStarted = false;
  String? _convId;
  bool _loaded = false;
  final SpeechToText _speech = SpeechToText();
  bool _speechReady = false;
  bool _listening = false;
  String _speechBase =
      ''; // mikrofon boshlangandagi mavjud matn (ustiga qo'shamiz)

  @override
  void dispose() {
    _speech.cancel();
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
        'step. Celebrate small wins; never shame. If the user shares an image, '
        'FIRST briefly say what you actually see, then thoughtfully infer what '
        'they seem interested in or working on, and connect it warmly and '
        'specifically to their focus & habits with practical advice (e.g. a '
        'sport photo → discipline, training routine; study material → focus '
        'sessions; a schedule → time-blocking). NEVER dismiss the image or say '
        '"our app is only about focus". If a question is truly unrelated, still '
        'answer it briefly and kindly, then gently steer back to focus and '
        'wellbeing.\n\nUSER DATA: $data';
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    final image = _pendingImage;
    final mime = _pendingMime;
    final key = ref.read(geminiKeyProvider).trim();
    if ((text.isEmpty && image == null) || key.isEmpty || _sending) return;
    final t = ref.read(l10nProvider);
    final promptText = text.isEmpty ? t.chatImagePrompt : text;
    _convId ??= ref
        .read(conversationsProvider.notifier)
        .create(category: widget.category)
        .id;

    setState(() {
      _messages.add(_Msg(true, promptText, image: image));
      _sending = true;
      _pendingImage = null;
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
        imageBytes: image,
        imageMime: mime,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(false, reply.isEmpty ? t.chatErrorGeneric : reply));
        _sending = false;
      });
    } on GeminiException catch (e) {
      if (!mounted) return;
      final base = (e.code == 400 || e.code == 401 || e.code == 403)
          ? t.chatErrorKey
          : e.code == 429
          ? t.chatErrorQuota
          : e.code == 503
          ? t.chatErrorBusy
          : (e.code == -1 ? t.chatErrorNetwork : t.chatErrorGeneric);
      // Tushunarli xatolarda (kvota/band/tarmoq) xom API matnini ko'rsatmaymiz.
      final detail = (e.code == 429 || e.code == 503 || e.code == -1)
          ? ''
          : e.shortDetail();
      setState(() {
        _messages.add(
          _Msg(false, detail.isEmpty ? base : '$base\n\n⚠️ $detail'),
        );
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(false, t.chatErrorNetwork));
        _sending = false;
      });
    }
    _persist();
    _scrollToEnd();
  }

  /// Joriy xabarlarni saqlangan suhbatga yozadi (har almashuvdan keyin).
  void _persist() {
    final id = _convId;
    if (id == null) return;
    final msgs = [for (final m in _messages) ChatMessage(m.fromUser, m.text)];
    String? title;
    for (final m in _messages) {
      if (m.fromUser) {
        title = m.text;
        break;
      }
    }
    ref.read(conversationsProvider.notifier).save(id, msgs, title: title);
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

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _pendingImage = bytes;
        _pendingMime = picked.mimeType ?? _mimeFromName(picked.name);
      });
      HapticFeedback.selectionClick();
    } catch (_) {
      // Bekor qilindi yoki ruxsat berilmadi — jim o'tamiz.
    }
  }

  String _mimeFromName(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.gif')) return 'image/gif';
    if (n.endsWith('.heic') || n.endsWith('.heif')) return 'image/heic';
    return 'image/jpeg';
  }

  /// Mikrofon: gapni matnga aylantiradi (jonli, tilga mos). Web brauzer mic
  /// so'raydi; Android'da RECORD_AUDIO ruxsatini speech_to_text o'zi so'raydi.
  Future<void> _toggleMic() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: (s) {
          if ((s == 'done' || s == 'notListening') && mounted) {
            setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    }
    if (!_speechReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(l10nProvider).chatMicUnavailable)),
        );
      }
      return; // mikrofon yo'q yoki ruxsat berilmadi
    }
    final locale = switch (ref.read(languageProvider)) {
      AppLanguage.uz => 'uz_UZ',
      AppLanguage.en => 'en_US',
      AppLanguage.ru => 'ru_RU',
    };
    final base = _controller.text.trim();
    _speechBase = base.isEmpty ? '' : '$base ';
    HapticFeedback.selectionClick();
    setState(() => _listening = true);
    await _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        final text = _speechBase + r.recognizedWords;
        setState(() {
          _controller.value = TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
        });
      },
      localeId: locale,
    );
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

  void _newChat() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CoachChatScreen(category: widget.category),
      ),
    );
  }

  void _openHistory() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _HistorySheet(category: widget.category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(l10nProvider);
    final key = ref.watch(geminiKeyProvider).trim();

    // Tarixdan ochilgan suhbat bo'lsa — xabarlarni bir marta yuklaymiz.
    if (widget.conversationId != null && !_loaded) {
      _loaded = true;
      _convId = widget.conversationId;
      for (final c in ref.read(conversationsProvider)) {
        if (c.id == widget.conversationId) {
          for (final m in c.messages) {
            _messages.add(_Msg(m.fromUser, m.text));
          }
          break;
        }
      }
    }

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
        title: Text(
          widget.title ??
              (widget.category == 'analysis'
                  ? t.proAiAnalysisTitle
                  : t.proAiChatTitle),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: t.chatHistory,
            onPressed: _openHistory,
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: t.chatNewChat,
            onPressed: _newChat,
          ),
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
        text: widget.category == 'analysis'
            ? t.chatWelcomeAnalysis
            : t.chatWelcome,
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
          image: m.image,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_pendingImage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          _pendingImage!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          t.chatImageReady,
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: t.cancel,
                        onPressed: () => setState(() => _pendingImage = null),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 10, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_photo_alternate_rounded),
                      tooltip: t.chatAttachImage,
                      color: AppColors.accent,
                      onPressed: _sending ? null : _pickImage,
                    ),
                    IconButton(
                      icon: Icon(
                        _listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      ),
                      tooltip: t.chatVoiceHint,
                      color: _listening ? Colors.redAccent : AppColors.accent,
                      onPressed: _sending ? null : _toggleMic,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: _send,
                        decoration: InputDecoration(
                          hintText: _listening
                              ? t.chatListening
                              : t.chatInputHint,
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
            ],
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
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepRow(icon: Icons.public_rounded, text: t.chatSetupStep1),
                  const SizedBox(height: 12),
                  _StepRow(icon: Icons.vpn_key_rounded, text: t.chatSetupStep2),
                  const SizedBox(height: 12),
                  _StepRow(
                    icon: Icons.content_paste_rounded,
                    text: t.chatSetupStep3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.chatSetupNote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
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

/// Kalit olish yo'riqnomasi uchun bitta raqamli qadam qatori.
class _StepRow extends StatelessWidget {
  const _StepRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accent, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.3,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.fromUser,
    required this.copyLabel,
    required this.copiedLabel,
    this.image,
  });

  final String text;
  final bool fromUser;
  final String copyLabel;
  final String copiedLabel;
  final Uint8List? image;

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
            // Biriktirilgan rasm (agar bo'lsa).
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: Image.memory(image!, fit: BoxFit.contain),
                  ),
                ),
              ),
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

/// Suhbatlar tarixi — pastdan chiqadigan ro'yxat (ochish / yangi / o'chirish).
class _HistorySheet extends ConsumerWidget {
  const _HistorySheet({required this.category});

  final String category;

  void _open(BuildContext context, {String? conversationId}) {
    final nav = Navigator.of(context);
    nav.pop(); // tarix oynasini yopamiz
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            CoachChatScreen(conversationId: conversationId, category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(l10nProvider);
    final scheme = Theme.of(context).colorScheme;
    final convs = ref
        .watch(conversationsProvider)
        .where((c) => c.category == category)
        .toList();
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 10, 6),
              child: Row(
                children: [
                  Text(
                    t.chatHistory,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _open(context),
                    icon: const Icon(Icons.add_comment_outlined, size: 18),
                    label: Text(t.chatNewChat),
                  ),
                ],
              ),
            ),
            if (convs.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Text(
                  t.chatNoHistory,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: convs.length,
                  itemBuilder: (_, i) {
                    final c = convs[i];
                    final title = c.title.isEmpty ? t.chatUntitled : c.title;
                    return ListTile(
                      leading: const Icon(Icons.chat_bubble_outline_rounded),
                      title: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: t.chatDeleteConv,
                        onPressed: () => ref
                            .read(conversationsProvider.notifier)
                            .delete(c.id),
                      ),
                      onTap: () => _open(context, conversationId: c.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
