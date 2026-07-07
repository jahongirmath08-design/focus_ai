import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:focus_ai/main.dart';

void main() {
  setUpAll(() async {
    // Test uchun Hive'ni vaqtinchalik papkada ishga tushiramiz.
    Hive.init(Directory.systemTemp.createTempSync('focusai_test').path);
    // Ilova ishlatadigan BARCHA box'lar (main.dart bilan bir xil).
    await Hive.openBox('habits');
    await Hive.openBox('history');
    await Hive.openBox('conversations');
    await Hive.openBox('accounts');
    final settings = await Hive.openBox('settings');
    // Onboarding ko'rilgan + kirilgan deb belgilaymiz -> to'g'ridan HomeShell.
    await settings.put('onboarding_seen', true);
    await settings.put('auth_done', true);
  });

  testWidgets('Home ochiladi: navigatsiya va "Odat qo\'shish" tugmasi bor', (
    tester,
  ) async {
    // FocusAiApp Riverpod provayderlarни ishlatadi -> ProviderScope shart.
    await tester.pumpWidget(const ProviderScope(child: FocusAiApp()));
    // AnimatedSwitcher (500ms) o'tishini kutamiz (pumpAndSettle emas —
    // imzo animatsiyalari takrorlanuvchi bo'lishi mumkin).
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Bugun'), findsOneWidget); // pastki navigatsiya
    expect(find.text("Odat qo'shish"), findsOneWidget); // qo'shish tugmasi
  });
}
