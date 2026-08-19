import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';

/// Admin dashboard top bar with logo, title and role badge.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة إدارة المنصة',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'مدير النظام',
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.adminPrimaryLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'مسؤول',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.adminPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            IconButton(
              icon: Icon(Icons.logout_rounded, color: AppColors.error, size: 22.r),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
