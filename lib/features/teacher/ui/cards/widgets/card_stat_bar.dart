import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Horizontal statistics bar showing total, available, and used card counts.
class CardStatBar extends StatelessWidget {
  final int totalCount;
  final int availableCount;
  final int usedCount;

  const CardStatBar({
    super.key,
    required this.totalCount,
    required this.availableCount,
    required this.usedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
      child: DeskCard(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        accent: DeskColors.primary,
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'الإجمالي',
                value: totalCount.toString(),
                color: DeskColors.ink,
              ),
            ),
            Container(width: 1, height: 28.h, color: DeskColors.line),
            Expanded(
              child: _StatItem(
                label: 'المتاحة',
                value: availableCount.toString(),
                color: DeskColors.success,
              ),
            ),
            Container(width: 1, height: 28.h, color: DeskColors.line),
            Expanded(
              child: _StatItem(
                label: 'المستعملة',
                value: usedCount.toString(),
                color: DeskColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(label, style: DeskText.note(10.sp)),
      ],
    );
  }
}
