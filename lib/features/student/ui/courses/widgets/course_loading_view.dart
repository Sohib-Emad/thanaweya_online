import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Full-screen loading spinner shown while course data is fetched.
class CourseLoadingView extends StatelessWidget {
  const CourseLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: NotebookColors.green),
            SizedBox(height: 16.h),
            Text(
              'جاري تحميل بيانات الكورس...',
              style: NotebookText.body(14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
