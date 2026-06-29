import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/uzbek_motif.dart';
import '../../dashboard/ui/dashboard_screen.dart';
import '../../pro/ui/pro_screen.dart';
import '../../profile/ui/profile_screen.dart';
import '../../statistics/ui/statistics_screen.dart';

/// Ilovaning asosiy karkasi — pastki navigatsiya (Bugun / Statistika / Profil).
/// IndexedStack: tablar holati saqlanadi (taymerlar yo'qolmaydi).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  /// Har bir bo'limni o'z milliy naqshi bilan o'raydi (fon koshini).
  static Widget _motif(MotifType type, Widget child) => Stack(
    children: [
      Positioned.fill(
        child: UzbekMotif(color: AppColors.accent, type: type, opacity: 0.07),
      ),
      child,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(l10nProvider);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          _motif(MotifType.lattice, const DashboardScreen()),
          _motif(MotifType.chevron, const StatisticsScreen()),
          const ProScreen(),
          _motif(MotifType.rosette, const ProfileScreen()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: t.tabToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart_rounded),
            label: t.tabStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.auto_awesome_outlined),
            selectedIcon: const Icon(Icons.auto_awesome),
            label: t.tabPro,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: t.tabProfile,
          ),
        ],
      ),
    );
  }
}
