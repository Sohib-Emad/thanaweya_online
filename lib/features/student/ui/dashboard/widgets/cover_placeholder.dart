import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A ruled-paper placeholder displayed when a course cover image is unavailable.
class CoverPlaceholder extends StatelessWidget {
  /// Creates a [CoverPlaceholder] with the given accent [color].
  const CoverPlaceholder({super.key, required this.color});

  /// The accent color used for the play-button circle.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(
          painter: RuledLinesPainter(lineGap: 22, color: Color(0x33FFFFFF)),
        ),
        Center(
          child: Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18.r,
            ),
          ),
        ),
      ],
    );
  }
}
