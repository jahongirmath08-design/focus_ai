import 'dart:math' as math;

import 'package:flutter/material.dart';

/// SIGNATURE VIZUAL — "Quyma yorug'lik yoyi".
/// Progress bilan cho'g'dek yoy "quyiladi": sovigan iz + qizigan ember uch + uchqunlar.
/// 100% da bir martalik PORTLASH: zarba to'lqini + radial uchqunlar + to'liq yongan halqa.
/// Faqat uch/portlash yorqin render bo'ladi — zaif qurilmada silliq.
class LightArc extends StatefulWidget {
  const LightArc({
    super.key,
    required this.progress,
    required this.color,
    required this.running,
    required this.complete,
    this.size = 300,
    this.center,
  });

  final double progress; // 0..1
  final Color color;
  final bool running;
  final bool complete;
  final double size;
  final Widget? center;

  @override
  State<LightArc> createState() => _LightArcState();
}

class _LightArcState extends State<LightArc> with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _burst;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.complete)
      _burst.value = 1.0; // ochilganda allaqachon tugagan bo'lsa — portlashsiz
  }

  @override
  void didUpdateWidget(LightArc old) {
    super.didUpdateWidget(old);
    if (!old.complete && widget.complete) {
      _burst.forward(from: 0.0); // hozir tugadi -> portlash
    } else if (old.complete && !widget.complete) {
      _burst.value = 0.0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _burst.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulse, _burst]),
              builder: (_, __) => CustomPaint(
                size: Size.square(widget.size),
                painter: _LightArcPainter(
                  progress: widget.progress.clamp(0.0, 1.0),
                  color: widget.color,
                  running: widget.running,
                  complete: widget.complete,
                  t: _pulse.value,
                  burst: _burst.value,
                ),
              ),
            ),
          ),
          if (widget.center != null) widget.center!,
        ],
      ),
    );
  }
}

class _LightArcPainter extends CustomPainter {
  _LightArcPainter({
    required this.progress,
    required this.color,
    required this.running,
    required this.complete,
    required this.t,
    required this.burst,
  });

  final double progress;
  final Color color;
  final bool running;
  final bool complete;
  final double t; // 0..1 davriy
  final double burst; // 0..1 bir martalik

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.width * 0.05;
    final radius = (size.width - stroke) / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;

    final hot = Color.lerp(color, Colors.white, 0.75)!;
    final cooled = Color.lerp(color, Colors.black, 0.45)!;
    final breath = (math.sin(t * 2 * math.pi) + 1) / 2;

    // 1) Xira halqa
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.06),
    );

    final sweep = (complete ? 1.0 : progress) * 2 * math.pi;
    if (sweep <= 0.0001) return;

    // 2) Gradient yoy (sovigan -> qizigan)
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: sweep,
      transform: const GradientRotation(start),
      colors: [complete ? color : cooled, color, hot],
      stops: const [0.0, 0.55, 1.0],
      tileMode: TileMode.clamp,
    ).createShader(rect);
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );

    // 3) Ember uch (faqat tugamaganda asosiy uch)
    final tipAngle = start + sweep;
    final radial = Offset(math.cos(tipAngle), math.sin(tipAngle));
    final tangent = Offset(-math.sin(tipAngle), math.cos(tipAngle));
    final tip = center + radial * radius;

    if (!complete) {
      final glow = running ? (0.55 + 0.45 * breath) : 0.28;
      canvas.drawCircle(
        tip,
        stroke * (1.7 + 0.6 * breath) * (running ? 1.0 : 0.6),
        Paint()
          ..color = color.withValues(alpha: 0.22 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 2.4),
      );
      canvas.drawCircle(
        tip,
        stroke * (0.85 + 0.3 * breath),
        Paint()
          ..color = hot.withValues(alpha: 0.7 * glow)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 1.1),
      );
      canvas.drawCircle(
        tip,
        stroke * 0.42,
        Paint()..color = Color.lerp(hot, Colors.white, 0.7)!,
      );

      // uchqunlar (ishlayotganda)
      if (running) {
        for (int i = 0; i < 6; i++) {
          final ph = i * 1.7;
          final life = (t + i / 6.0) % 1.0;
          final dist = stroke * (0.4 + 3.0 * life);
          final side = stroke * 1.1 * math.sin(ph + i * 2.1) * life;
          final p = tip + tangent * dist + radial * (side * 0.4);
          canvas.drawCircle(
            p,
            stroke * (0.16 * (1 - life) + 0.03),
            Paint()..color = hot.withValues(alpha: (1 - life) * 0.85),
          );
        }
      }
    }

    // 4) 100% — to'liq yongan halqa + doimiy korona + bir martalik portlash
    if (complete) {
      // doimiy korona (sovib turgan metall kabi nafas oladi)
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = hot.withValues(alpha: 0.16 + 0.14 * breath)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 2.0),
      );

      // bir martalik PORTLASH (burst 0->1) — kuchaytirilgan
      if (burst > 0.0 && burst < 1.0) {
        final b = Curves.easeOut.transform(burst);

        // (a) markaziy yorug'lik chaqnashi — boshida kuchli, tez so'nadi
        canvas.drawCircle(
          center,
          radius * (0.5 + 0.6 * b),
          Paint()
            ..color = hot.withValues(alpha: (1 - b) * (1 - b) * 0.55)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 4.0),
        );

        // (b) ikki qatlamli zarba to'lqini (ketma-ket)
        for (final off in <double>[0.0, 0.18]) {
          final double bb = ((b - off).clamp(0.0, 1.0)) / (1 - off);
          if (bb <= 0) continue;
          canvas.drawCircle(
            center,
            radius * (1 + 0.85 * bb),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = stroke * 1.3 * (1 - bb)
              ..color = hot.withValues(alpha: (1 - bb) * 0.6)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 1.6),
          );
        }

        // (c) radial uchqun portlashi — 20 ta, uzoqroq otiladi
        for (int i = 0; i < 20; i++) {
          final ang = (i / 20) * 2 * math.pi + b * 0.3;
          final dist = radius + b * radius * 1.1;
          final p = center + Offset(math.cos(ang), math.sin(ang)) * dist;
          canvas.drawCircle(
            p,
            stroke * 0.34 * (1 - b),
            Paint()
              ..color = Color.lerp(
                hot,
                Colors.white,
                0.5,
              )!.withValues(alpha: (1 - b) * 0.95),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LightArcPainter o) =>
      o.progress != progress ||
      o.t != t ||
      o.burst != burst ||
      o.running != running ||
      o.complete != complete ||
      o.color != color;
}

/// Yengil "mini yoy" — dashboard kartalari uchun.
/// AnimationController YO'Q (ro'yxatda ko'p karta bo'lsa ham silliq) —
/// progress bilan statik chiziladi, ember uchi xira porlaydi.
class MiniLightArc extends StatelessWidget {
  const MiniLightArc({
    super.key,
    required this.progress,
    required this.color,
    required this.complete,
    this.size = 64,
    this.child,
  });

  final double progress; // 0..1
  final Color color;
  final bool complete;
  final double size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _MiniArcPainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              complete: complete,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _MiniArcPainter extends CustomPainter {
  _MiniArcPainter({
    required this.progress,
    required this.color,
    required this.complete,
  });

  final double progress;
  final Color color;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final stroke = size.width * 0.10;
    final radius = (size.width - stroke) / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;

    final hot = Color.lerp(color, Colors.white, 0.7)!;
    final cooled = Color.lerp(color, Colors.black, 0.45)!;

    // xira iz
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.07),
    );

    final sweep = (complete ? 1.0 : progress) * 2 * math.pi;
    if (sweep <= 0.0001) return;

    // gradient yoy (sovigan -> qizigan)
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: sweep,
      transform: const GradientRotation(start),
      colors: [complete ? color : cooled, color, hot],
      stops: const [0.0, 0.55, 1.0],
      tileMode: TileMode.clamp,
    ).createShader(rect);
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = shader,
    );

    if (!complete) {
      // ember uch (statik porlash)
      final tipAngle = start + sweep;
      final tip =
          center + Offset(math.cos(tipAngle), math.sin(tipAngle)) * radius;
      canvas.drawCircle(
        tip,
        stroke * 1.1,
        Paint()
          ..color = color.withValues(alpha: 0.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 1.2),
      );
      canvas.drawCircle(
        tip,
        stroke * 0.5,
        Paint()..color = Color.lerp(hot, Colors.white, 0.6)!,
      );
    } else {
      // tugadi: yumshoq to'liq halqa porlashi
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = hot.withValues(alpha: 0.18)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 1.3),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniArcPainter o) =>
      o.progress != progress || o.complete != complete || o.color != color;
}

/// Hero parvozida ko'rsatiladigan toza halqa — matnsiz, berilgan o'lchamga
/// to'liq moslashadi (kichik yoydan katta yoyga silliq o'sadi).
class ArcRing extends StatelessWidget {
  const ArcRing({
    super.key,
    required this.progress,
    required this.color,
    required this.complete,
  });

  final double progress;
  final Color color;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _MiniArcPainter(
        progress: progress.clamp(0.0, 1.0),
        color: color,
        complete: complete,
      ),
    );
  }
}

/// Dashboard mini-yoyi va Active session katta yoyi o'rtasidagi Hero
/// parvozi uchun umumiy "shuttle" — ikkala uchda ham shu builder ishlatiladi.
HeroFlightShuttleBuilder arcFlightShuttleBuilder({
  required double progress,
  required Color color,
  required bool complete,
}) {
  return (flightContext, animation, direction, fromContext, toContext) {
    return ArcRing(progress: progress, color: color, complete: complete);
  };
}
