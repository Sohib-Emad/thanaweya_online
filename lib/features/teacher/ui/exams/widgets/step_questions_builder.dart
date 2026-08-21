import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/add_question_sheet.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/question_card.dart';

/// Step 2 of the exam builder wizard: add and manage questions.
///
/// Displays a list of question cards with add/remove actions.
class StepQuestionsBuilder extends StatelessWidget {
  const StepQuestionsBuilder({
    super.key,
    required this.questions,
    required this.onAddQuestion,
    required this.onRemoveQuestion,
  });

  final List<Map<String, dynamic>> questions;
  final VoidCallback onAddQuestion;
  final ValueChanged<int> onRemoveQuestion;

  /// Shows the add-question bottom sheet.
  static void showAddQuestionSheet(
    BuildContext context, {
    required ValueChanged<Map<String, dynamic>> onAdded,
  }) {
    AddQuestionSheet.show(context, onAdded: onAdded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'الخطوة 2: إضافة وتنسيق الأسئلة (${questions.length})',
                style: DeskText.heading(14.sp),
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton.icon(
              onPressed: onAddQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: DeskColors.primary,
                foregroundColor: Colors.white,
                minimumSize: Size.zero,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text('+ إضافة سؤال',
                  style: GoogleFonts.cairo(
                      fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (questions.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.quiz_outlined,
                    color: Color(0xFF0284C7),
                    size: 28,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'لا توجد أسئلة مضافة بعد',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'اضغط على زر "+ إضافة سؤال" للبدء في إضافة أسئلة الامتحان',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, i) => QuestionCard(
              index: i,
              question: questions[i],
              onDelete: () => onRemoveQuestion(i),
            ),
          ),
      ],
    );
  }
}
