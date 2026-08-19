import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A single question card displayed in the questions builder step.
///
/// Shows the question number, type badge, points, text, optional image,
/// and a list of answer options.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.onDelete,
  });

  final int index;
  final Map<String, dynamic> question;
  final VoidCallback onDelete;

  String get _typeLabel {
    final rawType = question['type'] as String? ?? 'mcq';
    if (rawType == 'true_false') return 'صح أو خطأ';
    if (rawType == 'essay') return 'سؤال مقالي';
    return 'اختيار من متعدد';
  }

  @override
  Widget build(BuildContext context) {
    final options = (question['options'] as List<dynamic>?) ?? [];
    final points = (question['points'] as int?) ?? 5;
    final imageFile = question['image_file'] as File?;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: DeskColors.primary.withAlpha(20),
                child: Text('${index + 1}',
                    style: TextStyle(
                        color: DeskColors.primary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900)),
              ),
              SizedBox(width: 8.w),
              _Badge(
                  label: _typeLabel,
                  bgColor: const Color(0xFFF1F5F9)),
              const Spacer(),
              _Badge(
                  label: '$points درجات',
                  bgColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFFD97706)),
              SizedBox(width: 6.w),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: DeskColors.danger, size: 18),
                onPressed: onDelete,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(question['question'] as String? ?? '', style: DeskText.strong(13.sp)),
          if (imageFile != null) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(imageFile,
                  height: 120.h, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          SizedBox(height: 10.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((opt) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    const Icon(Icons.radio_button_unchecked,
                        size: 14, color: DeskColors.muted),
                    SizedBox(width: 6.w),
                    Expanded(
                        child: Text(opt.toString(), style: DeskText.note(11.5.sp))),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.bgColor,
    this.textColor,
  });

  final String label;
  final Color bgColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(label,
          style: GoogleFonts.cairo(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: textColor)),
    );
  }
}
