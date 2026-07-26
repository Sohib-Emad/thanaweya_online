import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.studentDetails),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.h),
              CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.person, size: 40.r),
              ),
              SizedBox(height: 16.h),
              Text('طالب أحمد', style: AppTextStyles.h3),
              SizedBox(height: 4.h),
              Text('student@example.com', style: AppTextStyles.caption),
              SizedBox(height: 24.h),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تقدم الحصص', style: AppTextStyles.subtitle2),
                    SizedBox(height: 12.h),
                    LinearProgressIndicator(
                      value: 0.65,
                      backgroundColor: Colors.grey[200],
                    ),
                    SizedBox(height: 8.h),
                    Text('65%', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
