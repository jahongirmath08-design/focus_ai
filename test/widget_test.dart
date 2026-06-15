import 'package:flutter_test/flutter_test.dart';
import 'package:focus_ai/main.dart';

void main() {
  testWidgets('Taymer ekrani ochiladi: Boshlash va Qayta tugmalari bor',
      (tester) async {
    await tester.pumpWidget(const FocusAiApp());
    expect(find.text('Boshlash'), findsOneWidget);
    expect(find.text('Qayta'), findsOneWidget);
  });
}
