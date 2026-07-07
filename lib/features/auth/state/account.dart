import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../../core/state/app_settings.dart';
import '../data/account_store.dart';

/// Joriy hisob (null = mehmon). Lokal, faqat shu qurilmada.
class Account {
  const Account({required this.email, required this.name});
  final String email;
  final String name;
}

/// Lokal hisob ombori (Hive `accounts`). Box ochilmagan bo'lsa null.
final accountStoreProvider = Provider<AccountStore?>((ref) {
  try {
    return AccountStore(Hive.box('accounts'));
  } catch (_) {
    return null;
  }
});

/// Joriy identifikatsiya — `authDoneProvider`ga bog'liq.
/// Chiqishda (authDone=false) avtomatik `null` (mehmon) bo'ladi.
final accountProvider = Provider<Account?>((ref) {
  final done = ref.watch(authDoneProvider);
  if (!done) return null;
  try {
    final box = Hive.box('settings');
    final email = box.get('account_email', defaultValue: '') as String;
    if (email.isEmpty) return null;
    final name = box.get('account_name', defaultValue: '') as String;
    return Account(email: email, name: name);
  } catch (_) {
    return null;
  }
});

/// Sessiyani boshqaradi — mehmon yoki hisob bilan kirish.
/// Mavjud `authDoneProvider` bilan additiv ishlaydi (RootGate o'zgarmaydi).
class SessionController {
  SessionController(this._ref);
  final Ref _ref;

  /// Mehmon rejimida davom etish (oldingi xulq — buzilmaydi).
  void continueAsGuest(String name) {
    _clearAccountKeys();
    _ref.read(userNameProvider.notifier).setName(name.trim());
    _ref.read(authDoneProvider.notifier).signIn();
  }

  /// Hisob bilan kirish — identifikatsiyani saqlaydi va home'ga o'tkazadi.
  void enterWithAccount(Account a) {
    try {
      Hive.box('settings')
        ..put('account_email', a.email)
        ..put('account_name', a.name);
    } catch (_) {}
    _ref.read(userNameProvider.notifier).setName(a.name);
    _ref.read(authDoneProvider.notifier).signIn();
  }

  void _clearAccountKeys() {
    try {
      Hive.box('settings')
        ..delete('account_email')
        ..delete('account_name');
    } catch (_) {}
  }

  /// "Chiqish va o'chirish" — barcha hisoblar + sessiya kalitlarini tozalaydi.
  void wipeAccounts() {
    try {
      Hive.box('accounts').clear();
    } catch (_) {}
    _clearAccountKeys();
  }
}

final sessionControllerProvider =
    Provider<SessionController>((ref) => SessionController(ref));
