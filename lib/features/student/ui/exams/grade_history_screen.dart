import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

class GradeHistoryScreen extends StatelessWidget {
  const GradeHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.gradesTab)),
        body: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: MockData.mockSubmissions.length,
          itemBuilder: (context, index) {
            final sub = MockData.mockSubmissions[index];
            final exam = sub['exams'] as Map<String, dynamic>;
            final score = sub['score'] as int;
            final total = sub['total_points'] as int;
            final percent = (score / total * 100).toInt();
            final isPass = percent >= 50;

            return AppCard(
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: isPass
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        '$percent%',
                        style: TextStyle(
                          color: isPass ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exam['title'] as String, style: AppTextStyles.h3),
                        SizedBox(height: 2.h),
                        Text('$score / $total', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
