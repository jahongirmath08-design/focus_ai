import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive_ce.dart';

/// Lokal hisob ombori — Hive `accounts` box.
///
/// Parol HECH QACHON ochiq saqlanmaydi: har hisob uchun tasodifiy `salt`
/// hosil qilinadi va faqat cho'zilgan (key-stretched) hash saqlanadi. Parolni
/// tiklash email backendisiz — xavfsizlik savoli (javob ham hash'lanadi).
///
/// Bulutli backend (Firebase/Supabase) keyin, startup mahsuloti uchun,
/// aynan shu interfeys ustiga ulanadi — UI o'zgarmaydi.
class AccountStore {
  AccountStore(this._box);
  final Box _box;

  /// Kalitni "cho'zish" (key stretching) rounds soni — brute-force narxini
  /// oshiradi. Lokal oflayn ilova uchun yetarli; ishlab chiqarishда haqiqiy
  /// KDF (PBKDF2/argon2) yoki Firebase. Login/register — bir martalik amal.
  static const int _rounds = 10000;

  /// Bu email bilan hisob bormi.
  bool exists(String email) => _box.containsKey(_key(email));

  /// Barcha hisoblarni o'chiradi ("Chiqish va o'chirish" uchun).
  void clearAll() => _box.clear();

  /// Yangi hisob yaratadi. Email band bo'lsa `AccountError('email-taken')`.
  void register({
    required String email,
    required String password,
    required String name,
    required String question,
    required String answer,
  }) {
    final k = _key(email);
    if (_box.containsKey(k)) throw const AccountError('email-taken');
    final salt = _newSalt();
    final aSalt = _newSalt();
    _box.put(k, <String, dynamic>{
      'email': email.trim(),
      'name': name.trim(),
      'salt': salt,
      'hash': _hash(password, salt),
      'question': question.trim(),
      'aSalt': aSalt,
      'aHash': _hash(_norm(answer), aSalt),
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Kirish. Muvaffaqiyatli bo'lsa (email, name) qaytaradi; aks holda
  /// `AccountError('not-found' | 'wrong-password')`.
  ({String email, String name}) verify(String email, String password) {
    final rec = _rec(email);
    final salt = rec['salt'] as String;
    if (_hash(password, salt) != rec['hash']) {
      throw const AccountError('wrong-password');
    }
    return (email: rec['email'] as String, name: (rec['name'] as String?) ?? '');
  }

  /// Parolni tiklash uchun saqlangan xavfsizlik savoli.
  String questionFor(String email) => _rec(email)['question'] as String;

  /// Xavfsizlik savoli javobi to'g'ri bo'lsa parolni yangilaydi.
  void resetPassword({
    required String email,
    required String answer,
    required String newPassword,
  }) {
    final rec = _rec(email);
    final aSalt = rec['aSalt'] as String;
    if (_hash(_norm(answer), aSalt) != rec['aHash']) {
      throw const AccountError('wrong-answer');
    }
    final salt = _newSalt();
    rec['salt'] = salt;
    rec['hash'] = _hash(newPassword, salt);
    _box.put(_key(email), rec);
  }

  Map _rec(String email) {
    final rec = _box.get(_key(email));
    if (rec == null) throw const AccountError('not-found');
    return Map.from(rec as Map);
  }

  String _key(String email) => 'acc:${_norm(email)}';
  String _norm(String s) => s.trim().toLowerCase();

  String _newSalt() {
    final r = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  /// Salt + cho'zilgan SHA-256 (10k rounds).
  String _hash(String value, String salt) {
    var digest = sha256.convert(utf8.encode('$salt::$value'));
    for (var i = 1; i < _rounds; i++) {
      digest = sha256.convert(digest.bytes);
    }
    return digest.toString();
  }
}

/// Auth omboridagi kutilgan xatolar (kod UI'da o'zbekchaga o'giriladi).
class AccountError implements Exception {
  const AccountError(this.code);
  final String code;
}
