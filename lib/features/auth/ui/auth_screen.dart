import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/uzbek_motif.dart';

/// Kirish ekrani (TZ 3.2) — MEHMON rejimi. Ro'yxatdan o'tish shart emas:
/// ixtiyoriy ism + "Mehmon rejimida davom etish". Hammasi lokal saqlanadi.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text = ref.read(userNameProvider);
    _name.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (mounted) setState(() {}); // tugma matnини moslash uchun
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _continue() {
    // Maydon qiymatini HAR DOIM saqlaymiz — bo'sh bo'lsa ismni TOZALAYDI.
    ref.read(userNameProvider.notifier).setName(_name.text.trim());
    ref.read(authDoneProvider.notifier).signIn();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(l10nProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
          // Milliy shamsa naqshi — fon.
          Positioned.fill(
            child: UzbekMotif(
              color: AppColors.accent,
              type: MotifType.star8,
              opacity: 0.06,
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.accent,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Focus AI',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.authWelcome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.authSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _name,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: t.authNameOptional,
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _continue(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _continue,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            _name.text.trim().isEmpty
                                ? t.authGuestButton
                                : t.authContinue,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            t.authNote,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
