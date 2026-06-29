import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Milliy o'zbek naqsh turlari — har biri toza geometriya (matematik aniq):
/// - [star8]   : 8 qirrali yulduz (Samarqand "shamsa" koshini)
/// - [lattice] : panjara (an'anaviy yog'och romb-to'r)
/// - [chevron] : atlas/ikat zigzagi (milliy mato naqshi)
/// - [rosette] : suzani quyosh-guli (palak)
enum MotifType { star8, lattice, chevron, rosette }

/// Naqshni past shaffoflikda butun yuza bo'ylab koshin (tile) qilib chizadi.
/// Pure Dart CustomPaint — qo'shimcha paket yoki rasm kerak emas.
class UzbekMotif extends StatelessWidget {
  const UzbekMotif({
    super.key,
    required this.color,
    this.type = MotifType.star8,
    this.opacity = 0.1,
    this.tile = 62,
    this.strokeWidth = 1.4,
  });

  final Color color;
  final MotifType type;
  final double opacity;
  final double tile;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _MotifPainter(
          color: color.withValues(alpha: opacity),
          type: type,
          tile: tile,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _MotifPainter extends CustomPainter {
  _MotifPainter({
    required this.color,
    required this.type,
    required this.tile,
    required this.strokeWidth,
  });

  final Color color;
  final MotifType type;
  final double tile;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;
    switch (type) {
      case MotifType.star8:
        _grid(size, (c) => _star8(canvas, c, p));
      case MotifType.lattice:
        _grid(size, (c) => _diamond(canvas, c, p));
      case MotifType.rosette:
        _grid(size, (c) => _rosette(canvas, c, p));
      case MotifType.chevron:
        _chevrons(canvas, size, p);
    }
  }

  /// Koshin (diaper) to'ri — toq qatorlar yarim koshinga suriladi.
  void _grid(Size size, void Function(Offset center) cell) {
    var row = 0;
    for (double y = -tile; y < size.height + tile; y += tile) {
      final dx = row.isEven ? 0.0 : tile / 2;
      for (double x = -tile; x < size.width + tile; x += tile) {
        cell(Offset(x + dx, y));
      }
      row++;
    }
  }

  void _star8(Canvas canvas, Offset c, Paint p) {
    final r0 = tile * 0.40;
    final r1 = r0 * 0.46;
    final path = Path();
    for (var k = 0; k < 16; k++) {
      final a = -math.pi / 2 + k * (math.pi / 8);
      final rad = k.isEven ? r0 : r1;
      final pt = Offset(c.dx + rad * math.cos(a), c.dy + rad * math.sin(a));
      k == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _diamond(Canvas canvas, Offset c, Paint p) {
    final h = tile * 0.5;
    final path = Path()
      ..moveTo(c.dx, c.dy - h)
      ..lineTo(c.dx + h, c.dy)
      ..lineTo(c.dx, c.dy + h)
      ..lineTo(c.dx - h, c.dy)
      ..close();
    canvas.drawPath(path, p);
    // ichki kichik romb — panjara hissi
    final h2 = tile * 0.22;
    final inner = Path()
      ..moveTo(c.dx, c.dy - h2)
      ..lineTo(c.dx + h2, c.dy)
      ..lineTo(c.dx, c.dy + h2)
      ..lineTo(c.dx - h2, c.dy)
      ..close();
    canvas.drawPath(inner, p);
  }

  void _rosette(Canvas canvas, Offset c, Paint p) {
    final r = tile * 0.16;
    canvas.drawCircle(c, r, p);
    // quyosh nurlari (8 ta)
    for (var k = 0; k < 8; k++) {
      final a = k * (math.pi / 4);
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * (r + 2), c + dir * (r + tile * 0.16), p);
    }
  }

  void _chevrons(Canvas canvas, Size size, Paint p) {
    final amp = tile * 0.28;
    final step = tile * 0.5;
    for (double y = 0; y < size.height + tile; y += tile * 0.8) {
      final path = Path()..moveTo(-step, y);
      var up = true;
      for (double x = -step; x < size.width + step; x += step) {
        path.lineTo(x, up ? y - amp : y);
        up = !up;
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _MotifPainter old) =>
      old.color != color ||
      old.type != type ||
      old.tile != tile ||
      old.strokeWidth != strokeWidth;
}
