import 'package:flutter/material.dart';

import 'features/timer/ui/timer_screen.dart';

void main() {
  runApp(const FocusAiApp());
}

class FocusAiApp extends StatelessWidget {
  const FocusAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Eslatma: aksent rang (#6C5CE7) — strategiya hujjatidagi PLACEHOLDER.
    // Brending javobi kelganda BITTA shu joydan o'zgartiramiz (Phase 3).
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
