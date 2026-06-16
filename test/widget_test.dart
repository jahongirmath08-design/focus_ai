import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:focus_ai/main.dart';

void main() {
  setUpAll(() async {
    // Test uchun Hive'ni vaqtinchalik papkada ishga tushiramiz.
    Hive.init(Directory.systemTemp.createTempSync('focusai_test').path);
    await Hive.openBox('habits');
  });

  testWidgets('Dashboard ochiladi: sarlavha va "Odat qo\'shish" tugmasi bor',
      (tester) async {
    await tester.pumpWidget(const FocusAiApp());
    await tester.pump();
    expect(find.text('Focus AI'), findsOneWidget);
    expect(find.text("Odat qo'shish"), findsOneWidget);
  });
}
