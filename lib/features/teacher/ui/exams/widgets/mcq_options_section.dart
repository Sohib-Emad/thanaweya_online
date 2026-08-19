import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/desk_mini_field.dart';

/// MCQ answer options section with letter selectors
/// and text fields for each option.
class McqOptionsSection extends StatelessWidget {
  final int correctAnswer;
  final List<TextEditingController> optionControllers;
  final ValueChanged<int> onCorrectAnswerChanged;

  const McqOptionsSection({
    super.key,
    required this.correctAnswer,
    required this.optionControllers,
    required this.onCorrectAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    const letters = ['أ', 'ب', 'ج', 'د'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Text('خيارات الإجابة (حدد الإجابة الصحيحة)',
            style: DeskText.strong(13.sp)),
        SizedBox(height: 12.h),
        ...List.generate(4, (index) {
          final isCorrect = correctAnswer == index;
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onCorrectAnswerChanged(index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? DeskColors.primary
                          : DeskColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCorrect
                            ? DeskColors.primary
                            : DeskColors.line,
                        width: isCorrect ? 1.6 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(letters[index],
                          style: DeskText.strong(13.sp,
                              color: isCorrect
                                  ? DeskColors.onPrimary
                                  : DeskColors.muted)),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: DeskMiniField(
                    controller: optionControllers[index],
                    hint: 'الخيار (${letters[index]})',
                    isCorrect: isCorrect,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
