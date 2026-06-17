import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/theme/app_colors.dart';
import 'features/dashboard/ui/dashboard_screen.dart';
import 'features/onboarding/ui/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Hive'ni xavfsiz ishga tushiramiz (sekin telefon cold start uchun 15s).
  try {
    await Hive.initFlutter().timeout(const Duration(seconds: 15));
    await Hive.openBox('habits').timeout(const Duration(seconds: 15));
    await Hive.openBox('settings').timeout(const Duration(seconds: 15));
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
        home: const RootGate(),
      ),
    );
  }
}

/// Onboarding ko'rilganmi — shunga qarab birinchi ekranni tanlaydi.
/// Ko'rilgani Hive 'settings' box'ida saqlanadi (bir marta chiqadi).
class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  late bool _showOnboarding;

  @override
  void initState() {
    super.initState();
    bool seen = false;
    try {
      seen =
          Hive.box('settings').get('onboarding_seen', defaultValue: false) as bool;
    } catch (_) {
      // Hive ochilmagan bo'lsa — onboarding'da qamab qo'ymaymiz.
      seen = true;
    }
    _showOnboarding = !seen;
  }

  void _completeOnboarding() {
    try {
      Hive.box('settings').put('onboarding_seen', true);
    } catch (_) {}
    setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      child: _showOnboarding
          ? OnboardingScreen(
              key: const ValueKey('onboarding'),
              onDone: _completeOnboarding,
            )
          : const DashboardScreen(key: ValueKey('dashboard')),
    );
  }
}
