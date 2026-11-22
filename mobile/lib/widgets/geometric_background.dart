import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Tunisian-inspired geometric background (zellige / star pattern).
class GeometricBackground extends StatelessWidget {
  final Widget child;
  final Color? patternColor;
  final Color? backgroundColor;

  const GeometricBackground({
    super.key,
    required this.child,
    this.patternColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: backgroundColor ?? AppColors.cream),
        CustomPaint(
          painter: _ZelligePainter(
            color: patternColor ?? AppColors.black.withAlpha(18),
          ),
        ),
        child,
      ],
    );
  }
}

class _ZelligePainter extends CustomPainter {
  final Color color;

  _ZelligePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const spacing = 56.0;
    const r = 14.0; // radius of star

    for (double x = spacing / 2; x < size.width + spacing; x += spacing) {
      for (double y = spacing / 2; y < size.height + spacing; y += spacing) {
        _drawStar8(canvas, Offset(x, y), r, paint);
      }
    }
    // Dots at grid intersections
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 2.5, dotPaint);
      }
    }
  }

  void _drawStar8(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    final inner = r * 0.42;
    for (int i = 0; i < 8; i++) {
      final outerAngle = (i * 2 * math.pi / 8) - math.pi / 2;
      final innerAngle = outerAngle + math.pi / 8;
      final ox = center.dx + r * math.cos(outerAngle);
      final oy = center.dy + r * math.sin(outerAngle);
      final ix = center.dx + inner * math.cos(innerAngle);
      final iy = center.dy + inner * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ZelligePainter old) => old.color != color;
}
