import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/answer_tile.dart';

/// True/false answer selection section with two selectable tiles.
class TfOptionsSection extends StatelessWidget {
  final String selectedAnswer;
  final ValueChanged<String> onAnswerChanged;

  const TfOptionsSection({
    super.key,
    required this.selectedAnswer,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Row(
          children: [
            Expanded(
              child: AnswerTile(
                label: 'صحيح',
                selected: selectedAnswer == 'true',
                accent: DeskColors.success,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onAnswerChanged('true');
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AnswerTile(
                label: 'خطأ',
                selected: selectedAnswer == 'false',
                accent: DeskColors.danger,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onAnswerChanged('false');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
