import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Displays the list of existing questions with clean badges and delete actions,
/// matching the exact styling of Step 2 in the exam wizard.
class QuestionsListSection extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final bool isLoading;
  final void Function(String id) onDeleteQuestion;

  const QuestionsListSection({
    super.key,
    required this.questions,
    required this.isLoading,
    required this.onDeleteQuestion,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(color: DeskColors.primary),
        ),
      );
    }

    if (questions.isEmpty) {
      return Container(
        margin: EdgeInsets.only(bottom: 20.h),
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(Icons.help_outline_rounded, color: Color(0xFF0284C7)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لا توجد أسئلة مضافة بعد',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    'اكتب أول سؤال من النموذج بالأسفل لإضافته للامتحان',
                    style: GoogleFonts.cairo(
                      fontSize: 11.5.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأسئلة المكتوبة (${questions.length})',
              style: DeskText.heading(14.sp),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${questions.length} سؤال مضاف',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0369A1),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        for (int i = 0; i < questions.length; i++) ...[
          _QuestionItemCard(
            index: i,
            question: questions[i],
            onDelete: () => onDeleteQuestion(questions[i]['id'] as String),
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 10.h),
        const Divider(height: 1),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class _QuestionItemCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> question;
  final VoidCallback onDelete;

  const _QuestionItemCard({
    required this.index,
    required this.question,
    required this.onDelete,
  });

  String get _typeLabel {
    final rawType = question['type'] as String? ?? 'mcq';
    if (rawType == 'true_false' || rawType == 'tf') return 'صح أو خطأ';
    if (rawType == 'essay') return 'سؤال مقالي';
    return 'اختيار من متعدد';
  }

  @override
  Widget build(BuildContext context) {
    final points = question['points'] ?? 5;
    final text = question['text'] as String? ?? '';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: const Color(0xFFE0F2FE),
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF0284C7),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  _typeLabel,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '$points درجات',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          if (question['image_url'] != null && (question['image_url'] as String).isNotEmpty) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: CachedNetworkImage(
                imageUrl: question['image_url'] as String,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (_, __) => Container(
                  height: 120.h,
                  color: const Color(0xFFF1F5F9),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0284C7)),
                  ),
                ),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
