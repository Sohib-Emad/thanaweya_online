import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// A compact text field used inside MCQ option rows.
class LessonBodyContent extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool isEmpty;
  final List<LessonModel> lessons;
  final VoidCallback onRetry;
  final VoidCallback onAddFirst;
  final RefreshCallback onRefresh;
  final Widget Function(BuildContext, int) itemBuilder;

  const LessonBodyContent({
    super.key,
    required this.isLoading,
    required this.hasError,
    this.errorMessage,
    required this.isEmpty,
    required this.lessons,
    required this.onRetry,
    required this.onAddFirst,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && lessons.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: DeskColors.primary),
      );
    }
    if (hasError && lessons.isEmpty) {
      return Center(
        child: DeskEmptyNote(
          message: errorMessage ?? 'حدث خطأ أثناء تحميل الدروس',
          icon: Icons.error_outline_rounded,
          actionLabel: 'إعادة المحاولة',
          onAction: onRetry,
        ),
      );
    }
    if (isEmpty) {
      return DeskEmptyNote(
        message: 'لا توجد دروس بعد',
        subMessage: 'استخدم زر + لإضافة أول درس',
        icon: Icons.video_library_outlined,
        actionLabel: 'إضافة درس',
        onAction: onAddFirst,
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: DeskColors.primary,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding:
            EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        itemCount: lessons.length,
        separatorBuilder: (_, _) => SizedBox(height: 14.h),
        itemBuilder: itemBuilder,
      ),
    );
  }
}
