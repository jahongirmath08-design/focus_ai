import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/uzbek_motif.dart';
import '../data/account_store.dart';
import '../domain/auth_validator.dart';
import '../state/account.dart';

/// Kirish ekrani (TZ 3.2).
///
/// Ikki rejim:
///  • MEHMON — ro'yxatdan o'tishsiz, lokal (oldingidek, buzilmaydi).
///  • HISOB  — real email/parol ro'yxatdan o'tish; qurilmada xavfsiz saqlanadi.
/// Barcha ma'lumot lokal Hive'da qoladi — auth faqat identifikatsiya qatlami.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

enum _Mode { guest, account }

enum _AccountMode { signIn, signUp }

class _AuthScreenState extends ConsumerState<AuthScreen> {
  _Mode _mode = _Mode.guest;
  _AccountMode _accMode = _AccountMode.signUp;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _question = TextEditingController();
  final _answer = TextEditingController();

  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _name.text = ref.read(userNameProvider);
    _name.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _question.dispose();
    _answer.dispose();
    super.dispose();
  }

  String _msg(L10n t, String code) => switch (code) {
    'invalid-email' => t.errInvalidEmail,
    'weak-password' => t.errWeakPassword,
    'empty' || 'empty-question' || 'empty-answer' => t.errEmptyField,
    'email-taken' => t.errEmailTaken,
    'not-found' => t.errAccountNotFound,
    'wrong-password' => t.errWrongPassword,
    'wrong-answer' => t.errWrongAnswer,
    _ => t.errGeneric,
  };

  // ----- Mehmon -----
  void _continueGuest() {
    ref.read(sessionControllerProvider).continueAsGuest(_name.text);
  }

  // ----- Hisob: ro'yxatdan o'tish / kirish -----
  void _submitAccount() {
    setState(() => _errorCode = null);
    final store = ref.read(accountStoreProvider);
    if (store == null) {
      setState(() => _errorCode = 'store');
      return;
    }
    final email = _email.text.trim();
    final pass = _password.text;

    if (_accMode == _AccountMode.signUp) {
      final err = AuthValidator.signUp(
        email: email,
        password: pass,
        question: _question.text,
        answer: _answer.text,
      );
      if (err != null) {
        setState(() => _errorCode = err);
        return;
      }
      try {
        store.register(
          email: email,
          password: pass,
          name: _name.text,
          question: _question.text,
          answer: _answer.text,
        );
        ref
            .read(sessionControllerProvider)
            .enterWithAccount(Account(email: email, name: _name.text.trim()));
      } on AccountError catch (e) {
        setState(() => _errorCode = e.code);
      } catch (_) {
        setState(() => _errorCode = 'store');
      }
    } else {
      final err = AuthValidator.signIn(email: email, password: pass);
      if (err != null) {
        setState(() => _errorCode = err);
        return;
      }
      try {
        final who = store.verify(email, pass);
        ref
            .read(sessionControllerProvider)
            .enterWithAccount(Account(email: who.email, name: who.name));
      } on AccountError catch (e) {
        setState(() => _errorCode = e.code);
      } catch (_) {
        setState(() => _errorCode = 'store');
      }
    }
  }

  // ----- Parolni tiklash (xavfsizlik savoli — oflayn) -----
  Future<void> _forgotFlow() async {
    final t = ref.read(l10nProvider);
    final store = ref.read(accountStoreProvider);
    if (store == null) return;
    final email = _email.text.trim();
    if (AuthValidator.email(email) != null) {
      setState(() => _errorCode = 'invalid-email');
      return;
    }
    final String question;
    try {
      question = store.questionFor(email);
    } on AccountError {
      setState(() => _errorCode = 'not-found');
      return;
    } catch (_) {
      setState(() => _errorCode = 'store');
      return;
    }

    final answerCtl = TextEditingController();
    final passCtl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.authReset),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(
              controller: answerCtl,
              decoration: InputDecoration(labelText: t.authSecurityAnswer),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passCtl,
              obscureText: true,
              decoration: InputDecoration(labelText: t.authNewPassword),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.authReset),
          ),
        ],
      ),
    );

    final ans = answerCtl.text;
    final newPass = passCtl.text;
    answerCtl.dispose();
    passCtl.dispose();
    if (ok != true) return;

    if (AuthValidator.password(newPass) != null) {
      setState(() => _errorCode = 'weak-password');
      return;
    }
    try {
      store.resetPassword(email: email, answer: ans, newPassword: newPass);
    } on AccountError catch (e) {
      setState(() => _errorCode = e.code);
      return;
    } catch (_) {
      setState(() => _errorCode = 'store');
      return;
    }
    if (!mounted) return;
    setState(() {
      _accMode = _AccountMode.signIn;
      _errorCode = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.authResetDone)));
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(l10nProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Stack(
        children: [
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
                    _logo(),
                    const SizedBox(height: 18),
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
                    const SizedBox(height: 20),
                    _modeToggle(t),
                    const SizedBox(height: 20),
                    if (_mode == _Mode.guest)
                      _guestForm(t, scheme)
                    else
                      _accountForm(t, scheme),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo() => Container(
    width: 76,
    height: 76,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.accent.withValues(alpha: 0.16),
      shape: BoxShape.circle,
    ),
    child: const Icon(Icons.auto_awesome, color: AppColors.accent, size: 38),
  );

  Widget _modeToggle(L10n t) {
    return SegmentedButton<_Mode>(
      segments: [
        ButtonSegment(value: _Mode.guest, label: Text(t.authTabGuest)),
        ButtonSegment(value: _Mode.account, label: Text(t.authTabAccount)),
      ],
      selected: {_mode},
      onSelectionChanged: (s) => setState(() {
        _mode = s.first;
        _errorCode = null;
      }),
    );
  }

  Widget _guestForm(L10n t, ColorScheme scheme) {
    return Column(
      children: [
        Text(
          t.authSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _field(
          _name,
          t.authNameOptional,
          scheme,
          onSubmit: (_) => _continueGuest(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _continueGuest,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                _name.text.trim().isEmpty ? t.authGuestButton : t.authContinue,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _note(t.authNote, scheme),
      ],
    );
  }

  Widget _accountForm(L10n t, ColorScheme scheme) {
    final isSignUp = _accMode == _AccountMode.signUp;
    return Column(
      children: [
        _field(
          _email,
          t.authEmail,
          scheme,
          keyboard: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _field(
          _password,
          t.authPassword,
          scheme,
          obscure: true,
          helper: isSignUp ? t.authPasswordHint : null,
        ),
        if (isSignUp) ...[
          const SizedBox(height: 12),
          _field(_name, t.authOptionalName, scheme),
          const SizedBox(height: 12),
          _field(
            _question,
            t.authSecurityQuestion,
            scheme,
            helper: t.authSecurityQuestionHint,
          ),
          const SizedBox(height: 12),
          _field(_answer, t.authSecurityAnswer, scheme),
        ],
        if (_errorCode != null) ...[
          const SizedBox(height: 12),
          Text(
            _msg(t, _errorCode!),
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.error, fontSize: 13),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitAccount,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(isSignUp ? t.authSignUp : t.authSignIn),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (!isSignUp)
          TextButton(onPressed: _forgotFlow, child: Text(t.authForgot)),
        TextButton(
          onPressed: () => setState(() {
            _accMode = isSignUp ? _AccountMode.signIn : _AccountMode.signUp;
            _errorCode = null;
          }),
          child: Text(isSignUp ? t.authToSignIn : t.authToSignUp),
        ),
        const SizedBox(height: 8),
        _note(t.authAccountNote, scheme),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String hint,
    ColorScheme scheme, {
    bool obscure = false,
    String? helper,
    TextInputType? keyboard,
    void Function(String)? onSubmit,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      textAlign: TextAlign.center,
      onSubmitted: onSubmit,
      decoration: InputDecoration(
        hintText: hint,
        helperText: helper,
        helperMaxLines: 2,
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _note(String text, ColorScheme scheme) => Row(
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
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ),
    ],
  );
}
