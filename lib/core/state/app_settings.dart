import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../l10n/l10n.dart';

/// Tanlangan til — Hive 'settings' box'ida saqlanadi (qayta ochilganda esda qoladi).
final languageProvider =
    NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);

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
final userNameProvider =
    NotifierProvider<UserNameNotifier, String>(UserNameNotifier.new);

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
final userEmojiProvider =
    NotifierProvider<UserEmojiNotifier, String>(UserEmojiNotifier.new);

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
