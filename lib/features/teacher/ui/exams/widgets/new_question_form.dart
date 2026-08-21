import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/mcq_options_section.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/tf_options_section.dart';

/// The new question form with type selector, question text input,
/// optional image attachment, answer options (MCQ or TF), points input, and submit button.
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
  final File? pickedImage;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;
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
    this.pickedImage,
    required this.onPickImage,
    required this.onClearImage,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('كتابة سؤال جديد', style: DeskText.heading(15.sp)),
        SizedBox(height: 14.h),
        DeskSegmentedControl(
          options: const ['اختيارات', 'صح أو خطأ', 'مقالي'],
          index: selectedType == 'mcq'
              ? 0
              : (selectedType == 'tf' || selectedType == 'true_false' ? 1 : 2),
          onChanged: (i) {
            HapticFeedback.selectionClick();
            onTypeChanged(
                i == 0 ? 'mcq' : (i == 1 ? 'true_false' : 'essay'));
          },
        ),
        SizedBox(height: 18.h),

        // Question Text Input
        DeskInputField(
          label: 'نص السؤال',
          controller: questionController,
          icon: Icons.help_outline_rounded,
          hint: 'اكتب نص السؤال بوضوح هنا...',
          maxLines: 3,
        ),
        SizedBox(height: 12.h),

        // Image Attachment Section
        if (pickedImage != null) ...[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.file(
                    pickedImage!,
                    height: 130.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8.r,
                  left: 8.r,
                  child: GestureDetector(
                    onTap: onClearImage,
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
        ] else ...[
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate_outlined,
                    color: Color(0xFF0284C7),
                    size: 20,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'إرفاق صورة توضيحية للسؤال (اختياري)',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14.h),
        ],

        // Options (MCQ or True/False)
        if (selectedType == 'mcq')
          McqOptionsSection(
            correctAnswer: correctAnswer,
            optionControllers: optionControllers,
            onCorrectAnswerChanged: onCorrectAnswerChanged,
          ),
        if (selectedType == 'tf' || selectedType == 'true_false')
          TfOptionsSection(
            selectedAnswer: tfAnswer,
            onAnswerChanged: onTfAnswerChanged,
          ),
        SizedBox(height: 18.h),

        // Points Input
        DeskInputField(
          label: 'درجة السؤال (النقاط)',
          controller: pointsController,
          icon: Icons.stars_outlined,
          hint: '5',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 22.h),

        // Submit Button
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
