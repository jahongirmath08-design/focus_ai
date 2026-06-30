import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../habits/state/habits_notifier.dart';
import '../../onboarding/ui/onboarding_screen.dart';
import '../../pro/state/conversations_notifier.dart';

/// Profil — emoji avatar + ism + til tanlagich + tanishtiruv + ilova haqida.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const _emojis = <String>[
    '✨', '🔥', '📚', '💪', '🎯', '🧠', '⭐', '🌙',
    '☀️', '🚀', '🎨', '🧘', '🏃', '💡', '🌱', '⚡', //
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final t = ref.watch(l10nProvider);
    final lang = ref.watch(languageProvider);
    final themeMode = ref.watch(themeModeProvider);
    final userName = ref.watch(userNameProvider);
    final emoji = ref.watch(userEmojiProvider);
    final displayName = userName.trim().isEmpty ? t.guest : userName.trim();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(t.profileTitle), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: scheme.primaryContainer,
                child: Text(emoji, style: const TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.localMode,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: t.editName,
                onPressed: () => _editProfile(context, ref, t, userName, emoji),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            t.languageLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              for (final l in AppLanguage.values)
                ChoiceChip(
                  label: Text(l.nativeName),
                  selected: lang == l,
                  onSelected: (_) =>
                      ref.read(languageProvider.notifier).setLanguage(l),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            t.themeLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              for (final m in const [ThemeMode.light, ThemeMode.dark])
                ChoiceChip(
                  label: Text(m == ThemeMode.light ? t.themeLight : t.themeDark),
                  selected: themeMode == m,
                  onSelected: (_) =>
                      ref.read(themeModeProvider.notifier).setMode(m),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _Tile(
            icon: Icons.replay_rounded,
            title: t.replayOnboarding,
            subtitle: t.replayOnboardingSub,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    OnboardingScreen(onDone: () => Navigator.of(context).pop()),
              ),
            ),
          ),
          _Tile(
            icon: Icons.info_outline_rounded,
            title: t.aboutTitle,
            subtitle: t.aboutSub,
            onTap: () => _showAbout(context, t),
          ),
          _Tile(
            icon: Icons.logout_rounded,
            title: t.logout,
            subtitle: t.logoutSubtitle,
            onTap: () => _confirmLogout(context, ref, t),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref, L10n t) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.logout),
        content: Text(t.logoutChoose),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel),
          ),
          // Ma'lumotni saqlab chiqish (yumshoq).
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authDoneProvider.notifier).logout();
            },
            child: Text(t.logoutKeep),
          ),
          // Chiqish + hammasini o'chirish — qo'shimcha (kuchli) tasdiq so'raydi.
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmWipe(context, ref, t);
            },
            child: Text(t.logoutWipe),
          ),
        ],
      ),
    );
  }

  /// "Chiqish va o'chirish" — qaytarib bo'lmaydigan amal uchun ikkinchi tasdiq.
  void _confirmWipe(BuildContext context, WidgetRef ref, L10n t) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
        title: Text(t.wipeTitle),
        content: Text(t.wipeBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(ctx).pop();
              _wipeAllData(ref);
            },
            child: Text(t.wipeConfirm),
          ),
        ],
      ),
    );
  }

  /// Barcha lokal ma'lumotni (odatlar, tarix, suhbatlar, ism) tozalaydi va
  /// kirish ekraniga qaytaradi.
  void _wipeAllData(WidgetRef ref) {
    ref.read(habitsProvider.notifier).clearAll();
    ref.read(conversationsProvider.notifier).clearAll();
    ref.read(userNameProvider.notifier).setName('');
    ref.read(userEmojiProvider.notifier).setEmoji('✨');
    ref.read(geminiKeyProvider.notifier).setKey('');
    ref.read(authDoneProvider.notifier).logout();
  }

  void _editProfile(
    BuildContext context,
    WidgetRef ref,
    L10n t,
    String currentName,
    String currentEmoji,
  ) {
    final controller = TextEditingController(text: currentName);
    var emoji = currentEmoji;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            void save() {
              ref
                  .read(userNameProvider.notifier)
                  .setName(controller.text.trim());
              ref.read(userEmojiProvider.notifier).setEmoji(emoji);
              Navigator.of(ctx).pop();
            }

            return AlertDialog(
              title: Text(t.editName),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: t.nameHint,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => save(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t.avatarLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final e in _emojis)
                          GestureDetector(
                            onTap: () => setLocal(() => emoji = e),
                            child: Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: emoji == e
                                    ? scheme.primaryContainer
                                    : scheme.surfaceContainerHighest.withValues(
                                        alpha: 0.4,
                                      ),
                                border: Border.all(
                                  color: emoji == e
                                      ? scheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                e,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(t.cancel),
                ),
                FilledButton(onPressed: save, child: Text(t.save)),
              ],
            );
          },
        );
      },
    );
  }

  void _showAbout(BuildContext context, L10n t) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Focus AI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.aboutSub,
              style: TextStyle(
                color: Theme.of(ctx).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(t.aboutBody),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              showLicensePage(
                context: context,
                applicationName: 'Focus AI',
                applicationVersion: '1.0',
              );
            },
            child: Text(t.licenses),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.close),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: ListTile(
        leading: Icon(icon, color: scheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
