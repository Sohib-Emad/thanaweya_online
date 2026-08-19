import 'package:flutter/material.dart';

import 'chalk_colors.dart';

/// Paints faint horizontal chalk lines behind a page.
class ChalkboardSurfacePainter extends CustomPainter {
  const ChalkboardSurfacePainter({
    this.lineGap = 44,
    this.lineColor = ChalkboardColors.line,
  });

  final double lineGap;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double y = lineGap; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(ChalkboardSurfacePainter oldDelegate) =>
      oldDelegate.lineGap != lineGap || oldDelegate.lineColor != lineColor;
}

/// Paints a rounded dashed border, like a frame drawn with chalk.
class ChalkBorderPainter extends CustomPainter {
  const ChalkBorderPainter({
    this.color = ChalkboardColors.ink,
    this.strokeWidth = 1.4,
    this.radius = 14,
    this.dashLength = 6,
    this.gapLength = 5,
  });

  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final drawTo = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, drawTo), paint);
        distance = drawTo + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(ChalkBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}

/// Wraps a child with the chalkboard ground + faint horizontal chalk lines.
class ChalkboardSurface extends StatelessWidget {
  const ChalkboardSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const ChalkboardSurfacePainter(),
      child: child,
    );
  }
}
