import 'package:flutter/material.dart';

import 'notebook_colors.dart';

/// Paints the ruled paper + red margin behind a whole notebook page.
class NotebookPaperPainter extends CustomPainter {
  const NotebookPaperPainter({
    this.lineGap = 30,
    this.marginWidth = 22,
    this.lineColor = NotebookColors.ruler,
    this.marginColor = NotebookColors.marginRed,
  });

  final double lineGap;
  final double marginWidth;
  final Color lineColor;
  final Color marginColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (double y = lineGap; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final marginX = size.width - marginWidth;
    canvas.drawRect(
      Rect.fromLTWH(marginX, 0, marginWidth, size.height),
      Paint()..color = marginColor.withAlpha(14),
    );
    canvas.drawLine(
      Offset(marginX, 0),
      Offset(marginX, size.height),
      Paint()
        ..color = marginColor
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(NotebookPaperPainter oldDelegate) =>
      oldDelegate.lineGap != lineGap ||
      oldDelegate.marginWidth != marginWidth ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.marginColor != marginColor;
}

/// Paints the faint horizontal ruling inside a card.
class RuledLinesPainter extends CustomPainter {
  const RuledLinesPainter({
    required this.lineGap,
    this.startY = 0,
    this.color = NotebookColors.rulerCard,
  });

  final double lineGap;
  final double startY;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double y = startY; y < size.height; y += lineGap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(RuledLinesPainter oldDelegate) =>
      oldDelegate.lineGap != lineGap ||
      oldDelegate.startY != startY ||
      oldDelegate.color != color;
}

/// Wraps a child with the notebook's ruled-paper background + red margin.
///
/// Drop it inside a scroll view (or a fixed area) and the painter covers the
/// child's own bounds, so the lines scroll like real paper.
class NotebookPaper extends StatelessWidget {
  const NotebookPaper({
    super.key,
    required this.child,
    this.lineGap = 30,
    this.marginWidth = 22,
  });

  final Widget child;
  final double lineGap;
  final double marginWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: NotebookPaperPainter(
        lineGap: lineGap,
        marginWidth: marginWidth,
      ),
      child: child,
    );
  }
}
