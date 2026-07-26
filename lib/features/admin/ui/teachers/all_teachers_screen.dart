import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

class AllTeachersScreen extends StatelessWidget {
  const AllTeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allTeachers = MockData.mockAllTeachers;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('جميع المعلمين')),
        body: allTeachers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline,
                        size: 56.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text('لا يوجد معلمين', style: AppTextStyles.body2),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: allTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = allTeachers[index];
                  final status = teacher['approval_status'] as String;
                  final users = teacher['users'] as Map<String, dynamic>;
                  final name = users['full_name'] as String;
                  final initials = name[0];
                  return AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: AppColors.teacherPrimaryLight,
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: AppColors.teacherPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.h3),
                              SizedBox(height: 2.h),
                              Text(
                                (teacher['subjects'] as Map<String, dynamic>)['name_ar'] as String,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: status == 'approved'
                                ? AppColors.success.withValues(alpha: 0.1)
                                : status == 'rejected'
                                    ? AppColors.error.withValues(alpha: 0.1)
                                    : AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            status == 'approved'
                                ? 'معتمد'
                                : status == 'rejected'
                                    ? 'مرفوض'
                                    : 'قيد المراجعة',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: status == 'approved'
                                  ? AppColors.success
                                  : status == 'rejected'
                                      ? AppColors.error
                                      : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
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
