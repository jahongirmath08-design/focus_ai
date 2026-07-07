import 'package:flutter_test/flutter_test.dart';
import 'package:focus_ai/features/auth/domain/auth_validator.dart';

void main() {
  group('AuthValidator.email', () {
    test("to'g'ri email null qaytaradi", () {
      expect(AuthValidator.email('a@b.com'), isNull);
      expect(AuthValidator.email('  user@mail.uz '), isNull);
    });
    test("xato email 'invalid-email' qaytaradi", () {
      expect(AuthValidator.email('abc'), 'invalid-email');
      expect(AuthValidator.email('a@b'), 'invalid-email');
      expect(AuthValidator.email(''), 'invalid-email');
    });
  });

  group('AuthValidator.password', () {
    test('6+ belgi to\'g\'ri', () {
      expect(AuthValidator.password('123456'), isNull);
    });
    test('qisqa parol xato', () {
      expect(AuthValidator.password('123'), 'weak-password');
    });
  });

  group('AuthValidator.signUp', () {
    test("to'liq to'g'ri forma null", () {
      expect(
        AuthValidator.signUp(
          email: 'u@mail.com',
          password: 'secret1',
          question: 'Birinchi maktabingiz?',
          answer: '5-maktab',
        ),
        isNull,
      );
    });
    test("bo'sh savol 'empty-question'", () {
      expect(
        AuthValidator.signUp(
          email: 'u@mail.com',
          password: 'secret1',
          question: '   ',
          answer: 'x',
        ),
        'empty-question',
      );
    });
    test('xato email birinchi ushlanadi', () {
      expect(
        AuthValidator.signUp(
          email: 'bad',
          password: '123',
          question: '',
          answer: '',
        ),
        'invalid-email',
      );
    });
  });
}
