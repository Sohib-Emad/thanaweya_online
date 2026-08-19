import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A single exam attempt row showing the attempt number, score, and date.
class AttemptRow extends StatelessWidget {
  final Map<String, dynamic> attempt;
  final int index;
  final double maxScore;

  const AttemptRow({
    super.key,
    required this.attempt,
    required this.index,
    required this.maxScore,
  });

  @override
  Widget build(BuildContext context) {
    final score = (attempt['score'] as num?)?.toDouble() ?? 0;
    final total = (attempt['total_points'] as num?)?.toDouble() ?? maxScore;
    final percent = total > 0 ? ((score / total) * 100).round() : 0;
    final submitted = attempt['submitted_at'] as String?;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DeskColors.line.withAlpha(140))),
      ),
      child: Row(
        children: [
          Icon(Icons.history_rounded, size: 16.r, color: DeskColors.muted),
          SizedBox(width: 8.w),
          Text('المحاولة #$index', style: DeskText.body(12.sp)),
          const Spacer(),
          Text(
            '$score / $total ($percent%)',
            style: DeskText.strong(12.5.sp, color: percent >= 50 ? DeskColors.success : DeskColors.danger),
          ),
          if (submitted != null && submitted.isNotEmpty) ...[
            SizedBox(width: 10.w),
            Text(_formatDate(submitted), style: DeskText.note(10.sp)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}
