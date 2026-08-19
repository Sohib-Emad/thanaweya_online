import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

/// Displays the list of recently joined teachers.
class RecentTeachersList extends StatelessWidget {
  final List<Map<String, dynamic>> teachers;

  const RecentTeachersList({super.key, required this.teachers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'آخر المعلمين المنضمين',
            style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: teachers.isEmpty
              ? Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      'لا يوجد معلمين مسجلين حديثاً',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textTertiary),
                    ),
                  ),
                )
              : Column(
                  children: teachers.map((teacher) {
                    final users =
                        teacher['users'] as Map<String, dynamic>? ?? {};
                    final name = users['full_name'] as String? ?? '';
                    final initials = name.isNotEmpty ? name[0] : 'م';
                    final subjects =
                        teacher['subjects'] as Map<String, dynamic>? ?? {};
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: AppCard(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.warning.withAlpha(25),
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTextStyles.h3.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    subjects['name_ar'] as String? ?? '',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
