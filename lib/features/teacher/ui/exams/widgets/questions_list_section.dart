import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Displays the list of existing questions with delete actions,
/// separated by a divider line.
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
      return DeskEmptyNote(
        message: 'لا توجد أسئلة بعد',
        subMessage: 'اكتب أول سؤال من النموذج بالأسفل',
        icon: Icons.help_outline_rounded,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الأسئلة المكتوبة (${questions.length})',
            style: DeskText.heading(15.sp)),
        SizedBox(height: 12.h),
        for (final q in questions) ...[
          DeskCard(
            padding: EdgeInsets.all(12.r),
            accent: _typeColor(q['type'] as String),
            label: '${_typeLabel(q['type'] as String)} · ${q['points']} نقطة',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(q['text'] as String,
                      style: DeskText.body(13.sp),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 8.w),
                DeskIconAction(
                  icon: Icons.delete_outline_rounded,
                  color: DeskColors.danger,
                  tooltip: 'حذف السؤال',
                  onTap: () => onDeleteQuestion(q['id'] as String),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],
        SizedBox(height: 8.h),
        Container(height: 1, color: DeskColors.line),
        SizedBox(height: 24.h),
      ],
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'mcq':
        return DeskColors.primary;
      case 'tf':
      case 'true_false':
        return DeskColors.info;
      default:
        return DeskColors.accent;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'mcq':
        return 'اختيار من متعدد';
      case 'tf':
      case 'true_false':
        return 'صح أو خطأ';
      default:
        return 'سؤال مقالي';
    }
  }
}
