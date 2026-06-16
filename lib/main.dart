import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'features/timer/ui/timer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive'ni XAVFSIZ ishga tushiramiz: agar web'da sekinlashsa yoki xato bersa ham,
  // ilova baribir ochiladi (oq ekran bo'lmasligi uchun). Saqlash bo'lmasa,
  // ilova vaqtincha xotirada ishlaydi.
  try {
    await Hive.initFlutter().timeout(const Duration(seconds: 15));
    await Hive.openBox('focus_session').timeout(const Duration(seconds: 15));
  } catch (e, st) {
    debugPrint('HIVE INIT muammosi (ilova saqlashsiz davom etadi): $e\n$st');
  }
  runApp(const FocusAiApp());
}

class FocusAiApp extends StatelessWidget {
  const FocusAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aksent rang (#6C5CE7) — strategiya hujjatidagi PLACEHOLDER (Phase 3 da aniqlanadi).
    return MaterialApp(
      title: 'Focus AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
      ),
      home: const TimerScreen(),
    );
  }
}
