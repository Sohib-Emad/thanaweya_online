import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chalk_colors.dart';

/// A chalk-ringed avatar showing an initial.
class ChalkAvatar extends StatelessWidget {
  const ChalkAvatar({
    super.key,
    required this.initial,
    this.radius = 24,
    this.color = ChalkboardColors.accent,
  });

  final String initial;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final name = initial.trim();
    final letter = name.isEmpty ? 'م' : name[0];
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color.withAlpha(34),
        shape: BoxShape.circle,
        border: Border.all(color: color.withAlpha(150), width: 1.6),
      ),
      child: Center(
        child: Text(
          letter,
          style: GoogleFonts.cairo(
            fontSize: radius * 0.9,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }
}
