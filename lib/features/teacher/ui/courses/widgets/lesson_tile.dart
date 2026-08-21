import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/core/utils/dailymotion_utils.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// Individual lesson row displayed inside the lessons list.
class LessonTile extends StatelessWidget {
  final LessonModel lesson;
  final int number;
  final ExamModel? exam;
  final VoidCallback onAttachments;
  final VoidCallback onDelete;
  final VoidCallback? onExam;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.number,
    this.exam,
    required this.onAttachments,
    required this.onDelete,
    this.onExam,
  });

  @override
  Widget build(BuildContext context) {
    final isDirectUpload = lesson.videoSourceType == VideoSourceType.upload;
    final isDm = lesson.videoSourceType == VideoSourceType.dailymotion ||
        DailymotionUtils.isDailymotionUrl(lesson.videoUrlOrId);
    final sourceIcon = isDirectUpload
        ? Icons.cloud_upload_outlined
        : (isDm
            ? Icons.video_collection_outlined
            : Icons.ondemand_video_rounded);
    final sourceText = isDirectUpload
        ? 'فيديو مرفوع'
        : (isDm ? 'ديليموشن Dailymotion' : 'يوتيوب YouTube');

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: DeskColors.primarySoft,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: DeskColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: DeskText.strong(13.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lesson.isFreePreview) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: DeskColors.success.withAlpha(20),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'معاينة مجانية',
                              style: GoogleFonts.cairo(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w800,
                                color: DeskColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Icon(sourceIcon, size: 13.r, color: DeskColors.muted),
                        SizedBox(width: 4.w),
                        Text(sourceText, style: DeskText.note(10.5.sp)),
                        if (lesson.durationSeconds != null &&
                            lesson.durationSeconds! > 0) ...[
                          SizedBox(width: 10.w),
                          Icon(Icons.timer_outlined,
                              size: 12.r, color: DeskColors.muted),
                          SizedBox(width: 3.w),
                          Text(
                            '${(lesson.durationSeconds! / 60).round()} دقيقة',
                            style: DeskText.note(10.5.sp),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded,
                    color: DeskColors.muted, size: 20.r),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onSelected: (val) {
                  if (val == 'attachments') {
                    onAttachments();
                  } else if (val == 'delete') {
                    onDelete();
                  } else if (val == 'exam') {
                    onExam?.call();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'exam',
                    child: Row(
                      children: [
                        Icon(
                          Icons.quiz_outlined,
                          size: 18.r,
                          color: const Color(0xFF9333EA),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          exam != null
                              ? 'إدارة امتحان الحصة'
                              : '+ إضافة امتحان للحصة',
                          style: GoogleFonts.cairo(fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'attachments',
                    child: Row(
                      children: [
                        Icon(Icons.picture_as_pdf_outlined,
                            size: 18.r, color: DeskColors.primary),
                        SizedBox(width: 8.w),
                        Text('الملازم والملفات',
                            style: GoogleFonts.cairo(fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 18.r, color: DeskColors.danger),
                        SizedBox(width: 8.w),
                        Text('حذف المحاضرة',
                            style: GoogleFonts.cairo(
                                fontSize: 12.sp, color: DeskColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Exam action bar
          if (exam != null)
            InkWell(
              onTap: onExam,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF9333EA).withAlpha(15),
                  borderRadius: BorderRadius.circular(8.r),
                  border:
                      Border.all(color: const Color(0xFF9333EA).withAlpha(50)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.quiz_rounded,
                        size: 15.r, color: const Color(0xFF9333EA)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'امتحان الحصة: ${exam!.title} (${exam!.durationMinutes} دقيقة)',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9333EA),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.edit_outlined,
                        size: 13.r, color: const Color(0xFF9333EA)),
                  ],
                ),
              ),
            )
          else
            InkWell(
              onTap: onExam,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 14.r, color: const Color(0xFF64748B)),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        '+ إضافة امتحان للحصة (شرط لفتح الفيديو التالي)',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 11.r, color: const Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
