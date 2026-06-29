import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../features/history/data/history_repository.dart';
import '../l10n/l10n.dart';

/// Tanlangan til — Hive 'settings' box'ida saqlanadi (qayta ochilganda esda qoladi).
final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() {
    try {
      final code =
          Hive.box('settings').get('language', defaultValue: 'uz') as String;
      return AppLanguageX.fromCode(code);
    } catch (_) {
      return AppLanguage.uz;
    }
  }

  void setLanguage(AppLanguage lang) {
    state = lang;
    try {
      Hive.box('settings').put('language', lang.code);
    } catch (_) {}
  }
}

/// Joriy tilga mos L10n (watch qilinsa, til o'zgarganda UI yangilanadi).
final l10nProvider = Provider<L10n>((ref) => L10n(ref.watch(languageProvider)));

/// Foydalanuvchi ismi — salomlashishda ishlatiladi (ixtiyoriy, lokal).
final userNameProvider = NotifierProvider<UserNameNotifier, String>(
  UserNameNotifier.new,
);

class UserNameNotifier extends Notifier<String> {
  @override
  String build() {
    try {
      return Hive.box('settings').get('user_name', defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  void setName(String name) {
    state = name;
    try {
      Hive.box('settings').put('user_name', name);
    } catch (_) {}
  }
}

/// Foydalanuvchi belgisi (emoji avatar) — lokal, maxfiylikka mos.
final userEmojiProvider = NotifierProvider<UserEmojiNotifier, String>(
  UserEmojiNotifier.new,
);

class UserEmojiNotifier extends Notifier<String> {
  @override
  String build() {
    try {
      return Hive.box('settings').get('user_emoji', defaultValue: '✨')
          as String;
    } catch (_) {
      return '✨';
    }
  }

  void setEmoji(String emoji) {
    state = emoji;
    try {
      Hive.box('settings').put('user_emoji', emoji);
    } catch (_) {}
  }
}

/// Focus-tarix ombori (Hive 'history' box). Ochilmagan bo'lsa null.
final historyProvider = Provider<HistoryRepository?>((ref) {
  try {
    return HistoryRepository(Hive.box('history'));
  } catch (_) {
    return null;
  }
});

/// Kirildimi (mehmon rejimi ham hisoblanadi) — Hive 'settings' 'auth_done'.
/// RootGate shunga qarab auth ekranини yoki home'ni ko'rsatadi.
final authDoneProvider = NotifierProvider<AuthDoneNotifier, bool>(
  AuthDoneNotifier.new,
);

class AuthDoneNotifier extends Notifier<bool> {
  @override
  bool build() {
    try {
      return Hive.box('settings').get('auth_done', defaultValue: false) as bool;
    } catch (_) {
      return false;
    }
  }

  void signIn() {
    state = true;
    try {
      Hive.box('settings').put('auth_done', true);
    } catch (_) {}
  }

  void logout() {
    state = false;
    try {
      Hive.box('settings').put('auth_done', false);
    } catch (_) {}
  }
}

/// Gemini API kaliti — foydalanuvchi o'zi kiritadi (online jonli AI uchun).
/// FAQAT shu qurilmada (Hive 'settings') saqlanadi — hech qayerga yuborilmaydi.
final geminiKeyProvider = NotifierProvider<GeminiKeyNotifier, String>(
  GeminiKeyNotifier.new,
);

class GeminiKeyNotifier extends Notifier<String> {
  /// Ixtiyoriy: bu yerga bepul Gemini kalitini qo'ysang, ilova HAMMAGA
  /// kalitsiz ishlaydi (sudyalar hech narsa kiritmaydi). Bo'sh qolsa —
  /// har bir foydalanuvchi o'z kalitini ilova ichida kiritadi.
  static const _embeddedKey = '';

  @override
  String build() {
    try {
      final saved =
          Hive.box('settings').get('gemini_key', defaultValue: '') as String;
      return saved.isNotEmpty ? saved : _embeddedKey;
    } catch (_) {
      return _embeddedKey;
    }
  }

  void setKey(String key) {
    final k = key.trim();
    state = k;
    try {
      Hive.box('settings').put('gemini_key', k);
    } catch (_) {}
  }
}
