import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

class TeacherRequestsScreen extends StatelessWidget {
  const TeacherRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingTeachers = MockData.mockPendingTeachers;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.pendingRequests)),
        body: pendingTeachers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 56.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text(AppStrings.noData, style: AppTextStyles.body2),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: pendingTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = pendingTeachers[index];
                  final users = teacher['users'] as Map<String, dynamic>;
                  final name = users['full_name'] as String;
                  final initials = name[0];
                  return AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor:
                              AppColors.warning.withValues(alpha: 0.1),
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: AppColors.warning,
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionIconButton(
                              icon: Icons.check_circle_outline,
                              color: AppColors.success,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم قبول $name'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 4.w),
                            _ActionIconButton(
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم رفض $name'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
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

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 20.r),
      ),
    );
  }
}
