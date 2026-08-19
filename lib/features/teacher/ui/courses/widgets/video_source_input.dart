import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/video_file_picker.dart';

/// Conditional input that shows a URL field or a file picker
/// based on the selected video source index.
class VideoSourceInput extends StatelessWidget {
  final int sourceIndex;
  final TextEditingController urlController;
  final dynamic videoFile;
  final VoidCallback onPickVideo;
  final VoidCallback onClearVideo;

  const VideoSourceInput({
    super.key,
    required this.sourceIndex,
    required this.urlController,
    required this.videoFile,
    required this.onPickVideo,
    required this.onClearVideo,
  });

  @override
  Widget build(BuildContext context) {
    if (sourceIndex == 0) {
      return DeskInputField(
        label: 'رابط فيديو ديليموشن (Dailymotion)',
        controller: urlController,
        icon: Icons.video_collection_outlined,
        hint: 'https://dailymotion.com/video/x8... أو الكود',
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
      );
    }
    if (sourceIndex == 1) {
      return DeskInputField(
        label: 'رابط فيديو يوتيوب (YouTube)',
        controller: urlController,
        icon: Icons.link_rounded,
        hint: 'https://youtube.com/watch?v=...',
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'الحقل مطلوب' : null,
      );
    }
    return VideoFilePicker(
      videoFile: videoFile,
      onPick: onPickVideo,
      onClear: onClearVideo,
    );
  }
}
