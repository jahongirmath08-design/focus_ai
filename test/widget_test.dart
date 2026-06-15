import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:focus_ai/main.dart';

void main() {
  setUpAll(() async {
    // Test uchun Hive'ni vaqtinchalik papkada ishga tushiramiz.
    final dir = Directory.systemTemp.createTempSync('focusai_test');
    Hive.init(dir.path);
    await Hive.openBox('focus_session');
  });

  testWidgets('Taymer ekrani ochiladi: Boshlash va Qayta tugmalari bor',
      (tester) async {
    await tester.pumpWidget(const FocusAiApp());
    expect(find.text('Boshlash'), findsOneWidget);
    expect(find.text('Qayta'), findsOneWidget);
  });
}
