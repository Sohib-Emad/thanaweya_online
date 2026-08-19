import 'package:flutter/material.dart';

/// Very subtle dot-grid desk background.
class DeskSurfacePainter extends CustomPainter {
  const DeskSurfacePainter({this.dotColor = const Color(0x0F0284C7)});

  final Color dotColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const gap = 26.0;
    for (double x = 12; x < size.width; x += gap) {
      for (double y = 12; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DeskSurfacePainter oldDelegate) =>
      oldDelegate.dotColor != dotColor;
}

/// Wraps a child with the desk ground + faint dot wash.
class DeskSurface extends StatelessWidget {
  const DeskSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const DeskSurfacePainter(),
      child: child,
    );
  }
}
