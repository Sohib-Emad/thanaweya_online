import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/mcq_options_section.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/tf_options_section.dart';

/// The new question form with type selector, question text input,
/// answer options (MCQ or TF), points input, and submit button.
class NewQuestionForm extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final TextEditingController questionController;
  final TextEditingController pointsController;
  final int correctAnswer;
  final List<TextEditingController> optionControllers;
  final ValueChanged<int> onCorrectAnswerChanged;
  final String tfAnswer;
  final ValueChanged<String> onTfAnswerChanged;
  final bool isSaving;
  final VoidCallback onSave;

  const NewQuestionForm({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.questionController,
    required this.pointsController,
    required this.correctAnswer,
    required this.optionControllers,
    required this.onCorrectAnswerChanged,
    required this.tfAnswer,
    required this.onTfAnswerChanged,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('كتابة سؤال جديد', style: DeskText.heading(15.sp)),
        SizedBox(height: 16.h),
        DeskSegmentedControl(
          options: const ['اختيارات', 'صح أو خطأ', 'مقالي'],
          index: selectedType == 'mcq'
              ? 0
              : (selectedType == 'tf' ? 1 : 2),
          onChanged: (i) {
            HapticFeedback.selectionClick();
            onTypeChanged(
                i == 0 ? 'mcq' : (i == 1 ? 'tf' : 'essay'));
          },
        ),
        SizedBox(height: 20.h),
        DeskInputField(
          label: 'نص السؤال',
          controller: questionController,
          icon: Icons.help_outline_rounded,
          hint: 'اكتب نص السؤال بوضوح هنا...',
          maxLines: 3,
        ),
        if (selectedType == 'mcq')
          McqOptionsSection(
            correctAnswer: correctAnswer,
            optionControllers: optionControllers,
            onCorrectAnswerChanged: onCorrectAnswerChanged,
          ),
        if (selectedType == 'tf')
          TfOptionsSection(
            selectedAnswer: tfAnswer,
            onAnswerChanged: onTfAnswerChanged,
          ),
        SizedBox(height: 20.h),
        DeskInputField(
          label: 'درجة السؤال (النقاط)',
          controller: pointsController,
          icon: Icons.stars_outlined,
          hint: '1',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 24.h),
        DeskPrimaryButton(
          label: 'إضافة السؤال',
          icon: Icons.add_rounded,
          loading: isSaving,
          onPressed: isSaving ? null : onSave,
        ),
      ],
    );
  }
}
