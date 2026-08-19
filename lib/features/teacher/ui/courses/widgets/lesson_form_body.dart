import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/widgets.dart';

/// The scrollable form body for adding a new lesson — source selector,
/// title, description, video source input, preview toggle, and save button.
class LessonFormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController urlController;
  final int sourceIndex;
  final bool isFreePreview;
  final bool isSaving;
  final dynamic videoFile;
  final ValueChanged<int> onSourceChanged;
  final ValueChanged<bool> onPreviewToggled;
  final VoidCallback onPickVideo;
  final VoidCallback onClearVideo;
  final VoidCallback? onSave;

  const LessonFormBody({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.urlController,
    required this.sourceIndex,
    required this.isFreePreview,
    required this.isSaving,
    required this.videoFile,
    required this.onSourceChanged,
    required this.onPreviewToggled,
    required this.onPickVideo,
    required this.onClearVideo,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeskSegmentedControl(
            options: const [
              'ديليموشن Dailymotion',
              'يوتيوب YouTube',
              'رفع مباشر',
            ],
            index: sourceIndex,
            onChanged: (i) {
              HapticFeedback.selectionClick();
              onSourceChanged(i);
            },
          ),
          SizedBox(height: 24.h),
          DeskInputField(
            label: 'عنوان الدرس',
            controller: titleController,
            icon: Icons.play_circle_outline_rounded,
            hint: 'أدخل اسم أو عنوان الدرس...',
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
          ),
          SizedBox(height: 18.h),
          DeskInputField(
            label: 'وصف الدرس والتفاصيل',
            controller: descriptionController,
            icon: Icons.notes_rounded,
            hint: 'اكتب الشرح المباشر والنقاط الهامة بالدرس...',
            maxLines: 3,
          ),
          SizedBox(height: 18.h),
          VideoSourceInput(
            sourceIndex: sourceIndex,
            urlController: urlController,
            videoFile: videoFile,
            onPickVideo: onPickVideo,
            onClearVideo: onClearVideo,
          ),
          SizedBox(height: 20.h),
          FreePreviewToggle(
            value: isFreePreview,
            onChanged: onPreviewToggled,
          ),
          SizedBox(height: 32.h),
          DeskPrimaryButton(
            label: 'حفظ الدرس',
            icon: Icons.check_rounded,
            loading: isSaving,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}
