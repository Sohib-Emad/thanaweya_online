import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// A card widget displaying a single lesson with title, description,
/// duration, and action footer.
class LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDocuments;
  final VoidCallback onResetViews;
  final VoidCallback onToggleFree;

  const LessonCard({
    super.key,
    required this.lesson,
    required this.onEdit,
    required this.onDelete,
    required this.onDocuments,
    required this.onResetViews,
    required this.onToggleFree,
  });

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest > 0 ? '$hours س و $rest د' : '$hours ساعة';
  }

  @override
  Widget build(BuildContext context) {
    final isFree = lesson.isFreePreview;
    final accent = isFree ? DeskColors.success : DeskColors.accent;
    return DeskCard(
      onTap: onEdit,
      accent: accent,
      label: isFree ? 'معاينة مجانية' : 'خاص بالمشتركين',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: accent.withAlpha(24),
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(color: accent.withAlpha(110), width: 1.2),
                ),
                child: Icon(
                  isFree
                      ? Icons.play_circle_fill_rounded
                      : Icons.lock_outline,
                  color: accent,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: DeskText.strong(15.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      lesson.description?.isNotEmpty == true
                          ? lesson.description!
                          : 'درس بدون وصف',
                      style: DeskText.note(12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (lesson.durationSeconds != null) ...[
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 15.r, color: DeskColors.muted),
                SizedBox(width: 6.w),
                Text(
                  _formatDuration(lesson.durationSeconds!),
                  style: DeskText.note(11.sp),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
          DeskActionFooter(
            actions: [
              DeskLabeledAction(
                label: 'الملازم',
                icon: Icons.description_outlined,
                color: DeskColors.accent,
                onTap: onDocuments,
              ),
              DeskLabeledAction(
                label: 'إعادة فتح',
                icon: Icons.lock_reset_rounded,
                color: DeskColors.info,
                onTap: onResetViews,
              ),
              DeskLabeledAction(
                label: isFree ? 'إلغاء المعاينة' : 'معاينة',
                icon: isFree
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: isFree ? DeskColors.accent : DeskColors.success,
                onTap: onToggleFree,
              ),
              DeskLabeledAction(
                label: 'حذف',
                icon: Icons.delete_outline_rounded,
                color: DeskColors.danger,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
