import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';

/// Shows a bottom sheet to edit a lesson's title, description,
/// video URL, and free preview toggle.
void showEditLessonSheet({
  required BuildContext context,
  required LessonModel lesson,
  required void Function({
    required String lessonId,
    required String title,
    String? description,
    required String videoUrlOrId,
    required bool isFreePreview,
  }) onUpdate,
}) {
  final titleController = TextEditingController(text: lesson.title);
  final descriptionController =
      TextEditingController(text: lesson.description ?? '');
  final videoController =
      TextEditingController(text: lesson.videoUrlOrId);
  var isFree = lesson.isFreePreview;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: DeskColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 24.h,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تعديل الدرس', style: DeskText.heading(17.sp)),
                  SizedBox(height: 20.h),
                  DeskInputField(
                    label: 'عنوان الدرس',
                    controller: titleController,
                    icon: Icons.play_circle_outline_rounded,
                    hint: 'أدخل اسم أو عنوان الدرس',
                  ),
                  SizedBox(height: 18.h),
                  DeskInputField(
                    label: 'وصف الدرس والتفاصيل',
                    controller: descriptionController,
                    icon: Icons.notes_rounded,
                    hint: 'اكتب الشرح المباشر والنقاط الهامة بالدرس',
                    maxLines: 3,
                  ),
                  SizedBox(height: 18.h),
                  DeskInputField(
                    label: 'رابط الفيديو أو اليوتيوب',
                    controller: videoController,
                    icon: Icons.link_rounded,
                    hint: 'https://youtube.com/watch?v=...',
                  ),
                  SizedBox(height: 14.h),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setSheetState(() => isFree = !isFree);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 20.r,
                          height: 20.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFree
                                ? DeskColors.success
                                : Colors.transparent,
                            border: Border.all(
                              color: isFree
                                  ? DeskColors.success
                                  : DeskColors.faint,
                              width: 1.4,
                            ),
                          ),
                          child: isFree
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 14.r,
                                  color: DeskColors.onPrimary,
                                )
                              : null,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'معاينة مجانية للطلاب غير المشتركين',
                          style: DeskText.strong(12.sp),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  DeskPrimaryButton(
                    label: 'حفظ التعديلات',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;
                      onUpdate(
                        lessonId: lesson.id,
                        title: title,
                        description: descriptionController.text
                                    .trim()
                                    .isNotEmpty
                            ? descriptionController.text.trim()
                            : null,
                        videoUrlOrId: videoController.text.trim(),
                        isFreePreview: isFree,
                      );
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
