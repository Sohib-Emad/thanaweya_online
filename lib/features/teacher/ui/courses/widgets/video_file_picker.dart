import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Animated file picker card for selecting a video from device storage.
class VideoFilePicker extends StatelessWidget {
  final XFile? videoFile;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const VideoFilePicker({
    super.key,
    required this.videoFile,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = videoFile != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ملف الفيديو', style: DeskText.strong(12.sp)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onPick,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: hasFile
                  ? DeskColors.primary.withAlpha(18)
                  : DeskColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: hasFile
                    ? DeskColors.primary.withAlpha(190)
                    : DeskColors.line,
                width: hasFile ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildIcon(hasFile),
                SizedBox(width: 12.w),
                Expanded(child: _buildLabel(hasFile)),
                if (hasFile)
                  GestureDetector(
                    onTap: onClear,
                    child: Icon(
                      Icons.close_rounded,
                      color: DeskColors.danger,
                      size: 20.r,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(bool hasFile) {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: hasFile ? DeskColors.primary : DeskColors.primarySoft,
        shape: BoxShape.circle,
      ),
      child: Icon(
        hasFile ? Icons.check_rounded : Icons.video_file_outlined,
        color: hasFile ? DeskColors.onPrimary : DeskColors.primary,
        size: 22.r,
      ),
    );
  }

  Widget _buildLabel(bool hasFile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasFile ? videoFile!.name : 'اختيار فيديو من جهازك',
          style: DeskText.strong(13.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 3.h),
        Text(
          hasFile ? 'تم اختيار الملف بنجاح' : 'MP4 / MOV · يُرفع إلى خوادم المنصة',
          style: DeskText.note(11.sp),
        ),
      ],
    );
  }
}
