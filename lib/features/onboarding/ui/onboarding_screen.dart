import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/state/app_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../active_session/ui/light_arc.dart';

/// Interaktiv onboarding — "diqqatni nurga aylantirish" metaforasini hikoya qiladi.
/// Signature yoy (LightArc / MiniLightArc) qahramon element. Bir marta ko'rinadi.
/// Birinchi ochilishda staggered "entrance" animatsiyasi: yoy sakrab kattalashadi,
/// matn pastdan suzib chiqadi (premium birinchi taassurot).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  /// Onboarding tugaganda (Skip yoki Boshlaymiz) chaqiriladi.
  final VoidCallback onDone;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnbPage {
  const _OnbPage({required this.title, required this.body, required this.color});
  final String title;
  final String body;
  final Color color;
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  late final AnimationController _entrance;
  int _index = 0;

  static const _colors = <Color>[
    Color(0xFFFFD86E), // amber
    Color(0xFF00D2D3), // siyan
    Color(0xFF55EFC4), // yashil
  ];

  List<_OnbPage> _buildPages(L10n t) => [
        _OnbPage(title: t.onb1Title, body: t.onb1Body, color: _colors[0]),
        _OnbPage(title: t.onb2Title, body: t.onb2Body, color: _colors[1]),
        _OnbPage(title: t.onb3Title, body: t.onb3Body, color: _colors[2]),
      ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _colors.length - 1) {
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
    final t = ref.watch(l10nProvider);
    final pages = _buildPages(t);
    final last = _index == pages.length - 1;
    final pageColor = pages[_index].color;

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
                // Yuqori panel: brend wordmark + O'tkazib yuborish.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
                  child: Row(
                    children: [
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _entrance,
                          curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
                        ),
                        child: _Wordmark(color: pageColor),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: last ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: TextButton(
                          onPressed: last ? null : widget.onDone,
                          child: Text(
                            t.onbSkip,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _index = i);
                    },
                    itemCount: pages.length,
                    itemBuilder: (_, i) => _OnbPageView(
                      page: pages[i],
                      index: i,
                      controller: _controller,
                      entrance: _entrance,
                    ),
                  ),
                ),
                _Dots(count: pages.length, index: _index, color: pageColor),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(last ? t.onbStart : t.onbNext),
                          const SizedBox(width: 8),
                          Icon(
                            last
                                ? Icons.auto_awesome
                                : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
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

/// Bitta onboarding sahifasi — qahramon yoy + matn, parallaks + entrance bilan.
class _OnbPageView extends StatelessWidget {
  const _OnbPageView({
    required this.page,
    required this.index,
    required this.controller,
    required this.entrance,
  });

  final _OnbPage page;
  final int index;
  final PageController controller;
  final Animation<double> entrance;

  /// e (0..1) ning [start..end] oralig'ida egri chiziq bo'yicha qiymat.
  double _seg(double e, double start, double end, Curve curve) {
    final v = ((e - start) / (end - start)).clamp(0.0, 1.0);
    return curve.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, entrance]),
      builder: (context, _) {
        final hasDim =
            controller.hasClients && controller.position.haveDimensions;
        final pageVal = hasDim ? (controller.page ?? 0.0) : 0.0;
        final offset = pageVal - index; // 0 = markazda
        final t = offset.clamp(-1.0, 1.0);
        final centered = (1 - t.abs()).clamp(0.0, 1.0);
        final e = entrance.value;
        // Yoy "to'lishi" — sahifa kelganda yoy 0 dan maqsadgacha quyiladi (signature metafora).
        final fill = _seg(e, 0.08, 0.9, Curves.easeOutCubic) * centered;

        // Entrance: yoy pastdan ko'tarilib, sakrab kattalashadi; matn suzib chiqadi.
        final heroScale =
            (0.58 + 0.42 * _seg(e, 0.0, 0.60, Curves.easeOutBack)) *
                (0.92 + 0.08 * centered);
        final heroRise = (1 - _seg(e, 0.0, 0.55, Curves.easeOutCubic)) * 40;
        final heroOpacity =
            _seg(e, 0.0, 0.42, Curves.easeOut) * (0.20 + 0.80 * centered);
        final titleIn = _seg(e, 0.30, 0.80, Curves.easeOut);
        final bodyIn = _seg(e, 0.48, 1.0, Curves.easeOut);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.translate(
                offset: Offset(-t * 60, heroRise),
                child: Transform.scale(
                  scale: heroScale,
                  child: Opacity(
                    opacity: heroOpacity.clamp(0.0, 1.0),
                    child: SizedBox(height: 250, child: Center(child: _hero(fill))),
                  ),
                ),
              ),
              const SizedBox(height: 44),
              Transform.translate(
                offset: Offset(0, (1 - titleIn) * 42),
                child: Opacity(
                  opacity: (titleIn * centered).clamp(0.0, 1.0),
                  child: Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Transform.translate(
                offset: Offset(0, (1 - bodyIn) * 42),
                child: Opacity(
                  opacity: (bodyIn * centered).clamp(0.0, 1.0),
                  child: Text(
                    page.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.5,
                      height: 1.5,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _hero(double fill) {
    final f = fill.clamp(0.0, 1.0);
    // Sahifa 1 (index 1) — ko'p odat: uchta mini yoy (kelganda to'ladi, % sanaydi).
    if (index == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _mini(AppColors.habitColors[1], 0.45 * f, 86),
          const SizedBox(width: 16),
          _mini(AppColors.habitColors[2], 0.72 * f, 116),
          const SizedBox(width: 16),
          _mini(AppColors.habitColors[3], 0.30 * f, 86),
        ],
      );
    }
    // Sahifa 0 va 2 — bitta katta signature yoy (0 dan maqsadgacha quyiladi).
    return LightArc(
      progress: (index == 0 ? 0.68 : 0.9) * f,
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

/// Brend wordmark — porlayotgan nuqta (sahifa rangida) + "FOCUS AI".
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.7),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 9),
        Text(
          "FOCUS AI",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
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
