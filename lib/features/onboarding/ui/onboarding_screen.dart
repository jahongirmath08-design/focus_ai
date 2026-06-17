import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../active_session/ui/light_arc.dart';

/// Interaktiv onboarding — "diqqatni nurga aylantirish" metaforasini hikoya qiladi.
/// Signature yoy (LightArc / MiniLightArc) qahramon element. Bir marta ko'rinadi.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  /// Onboarding tugaganda (Skip yoki Boshlaymiz) chaqiriladi.
  final VoidCallback onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnbPage {
  const _OnbPage({required this.title, required this.body, required this.color});
  final String title;
  final String body;
  final Color color;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _pages = <_OnbPage>[
    _OnbPage(
      title: "Diqqatni nurga aylantir",
      body:
          "Har bir diqqat daqiqasi yoyga quyma cho'g'dek quyiladi. Maqsadingga yetganda — u butunlay yonadi.",
      color: Color(0xFFFFD86E), // amber
    ),
    _OnbPage(
      title: "Har bir odat — o'z olovi",
      body:
          "Bir nechta odatni bir vaqtda yurit. Har biri mustaqil yonadi va biri ikkinchisiga xalal bermaydi.",
      color: Color(0xFF00D2D3), // siyan
    ),
    _OnbPage(
      title: "Vaqting yo'qolmaydi",
      body:
          "Ilovani yopsang ham, taymer aniq vaqt bo'yicha davom etadi. Hech narsa o'chmaydi.",
      color: Color(0xFF55EFC4), // yashil
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      HapticFeedback.lightImpact();
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    } else {
      HapticFeedback.mediumImpact();
      widget.onDone();
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;
    final pageColor = _pages[_index].color;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient fon — joriy sahifa rangiga moslashadi.
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.35),
                radius: 1.1,
                colors: [
                  pageColor.withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // O'tkazib yuborish
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedOpacity(
                    opacity: last ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: TextButton(
                      onPressed: last ? null : widget.onDone,
                      child: Text(
                        "O'tkazib yuborish",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _index = i);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _OnbPageView(
                      page: _pages[i],
                      index: i,
                      controller: _controller,
                    ),
                  ),
                ),
                _Dots(count: _pages.length, index: _index, color: pageColor),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton(
                      onPressed: _next,
                      style: FilledButton.styleFrom(
                        backgroundColor: pageColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(last ? "Boshlaymiz ✨" : "Keyingi"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bitta onboarding sahifasi — qahramon yoy + matn, parallaks bilan.
class _OnbPageView extends StatelessWidget {
  const _OnbPageView({
    required this.page,
    required this.index,
    required this.controller,
  });

  final _OnbPage page;
  final int index;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final hasDim =
            controller.hasClients && controller.position.haveDimensions;
        final pageVal = hasDim ? (controller.page ?? 0.0) : 0.0;
        final offset = pageVal - index; // 0 = markazda
        final t = offset.clamp(-1.0, 1.0);
        final centered = (1 - t.abs()).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Qahramon yoy — parallaks (sekinroq suriladi) + fade/scale.
              Transform.translate(
                offset: Offset(-t * 64, 0),
                child: Transform.scale(
                  scale: 0.86 + 0.14 * centered,
                  child: Opacity(
                    opacity: 0.30 + 0.70 * centered,
                    child: SizedBox(
                      height: 250,
                      child: Center(child: _hero()),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 44),
              Opacity(
                opacity: centered,
                child: Column(
                  children: [
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      page.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hero() {
    // Sahifa 1 (index 1) — ko'p odat: uchta mini yoy.
    if (index == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _mini(AppColors.habitColors[1], 0.45, 86),
          const SizedBox(width: 16),
          _mini(AppColors.habitColors[2], 0.72, 116),
          const SizedBox(width: 16),
          _mini(AppColors.habitColors[3], 0.30, 86),
        ],
      );
    }
    // Sahifa 0 va 2 — bitta katta signature yoy.
    return LightArc(
      progress: index == 0 ? 0.68 : 0.9,
      color: page.color,
      running: true,
      complete: false,
      size: 224,
    );
  }

  Widget _mini(Color c, double p, double size) {
    return MiniLightArc(
      progress: p,
      color: c,
      complete: false,
      size: size,
      child: Text(
        '${(p * 100).round()}%',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Sahifa indikatori — faol nuqta cho'ziladi va sahifa rangida porlaydi.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index, required this.color});

  final int count;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? color : Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
