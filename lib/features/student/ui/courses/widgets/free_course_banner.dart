import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Banner shown when a course is free to enroll.
class FreeCourseBanner extends StatelessWidget {
  const FreeCourseBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return NotebookHighlightNote(
      child: Row(
        children: [
          Icon(
            Icons.celebration_rounded,
            color: NotebookColors.green,
            size: 22.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'هذا الكورس متاح مجاناً لجميع الطلاب! اضغط بالأسفل للبدء فوراً.',
              style: NotebookText.strong(13.sp),
            ),
          ),
        ],
      ),
    );
  }
}
