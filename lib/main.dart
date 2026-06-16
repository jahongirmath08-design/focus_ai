import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/theme/app_colors.dart';
import 'features/dashboard/ui/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive'ni xavfsiz ishga tushiramiz (sekin telefon cold start uchun 15s).
  try {
    await Hive.initFlutter().timeout(const Duration(seconds: 15));
    await Hive.openBox('habits').timeout(const Duration(seconds: 15));
  } catch (e, st) {
    debugPrint('HIVE INIT muammosi (ilova saqlashsiz davom etadi): $e\n$st');
  }
  runApp(const FocusAiApp());
}

class FocusAiApp extends StatelessWidget {
  const FocusAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aksent rang (#6C5CE7) — PLACEHOLDER (Phase 3 da brending bo'yicha aniqlanadi).
    return ProviderScope(
      child: MaterialApp(
        title: 'Focus AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.accent,
            brightness: Brightness.dark,
          ),
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
