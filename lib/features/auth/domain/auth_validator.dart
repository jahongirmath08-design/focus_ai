/// Auth kiritishlarini tekshiruvchi — SOF DART, oflayn, unit-testlanadi.
///
/// Har metod xato KODINI qaytaradi (`null` = to'g'ri). Kod UI qatlamida
/// `l10n` orqali o'zbekchaga (va en/ru) o'giriladi — TIL QOIDASIga muvofiq
/// hech qanday matn shu yerda qattiq yozilmaydi.
class AuthValidator {
  AuthValidator._();

  static final RegExp _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Email formati. `null` = to'g'ri, `'invalid-email'` = xato.
  static String? email(String value) =>
      _emailRe.hasMatch(value.trim()) ? null : 'invalid-email';

  /// Parol — kamida 6 belgi. `null` = to'g'ri, `'weak-password'` = xato.
  static String? password(String value) =>
      value.length >= 6 ? null : 'weak-password';

  /// Bo'sh bo'lmasligi. `null` = to'g'ri, `'empty'` = xato.
  static String? notEmpty(String value) =>
      value.trim().isEmpty ? 'empty' : null;

  /// Ro'yxatdan o'tish formasi — birinchi uchragan xato kodini qaytaradi.
  static String? signUp({
    required String email,
    required String password,
    required String question,
    required String answer,
  }) {
    return AuthValidator.email(email) ??
        AuthValidator.password(password) ??
        (notEmpty(question) != null ? 'empty-question' : null) ??
        (notEmpty(answer) != null ? 'empty-answer' : null);
  }

  /// Kirish formasi.
  static String? signIn({required String email, required String password}) {
    return AuthValidator.email(email) ?? AuthValidator.password(password);
  }
}
