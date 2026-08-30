import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'admin_quick_action_card.dart';
import 'admin_wide_action_card.dart';

class AdminQuickActionsGrid extends StatelessWidget {
  const AdminQuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.adminPrimary, size: 20.r),
              SizedBox(width: 6.w),
              Text(
                'الوصول السريع للتحكم',
                style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: AdminQuickActionCard(
                  title: 'طلاب المعلمين',
                  subtitle: 'إدارة الكورسات والاشتراكات',
                  icon: Icons.school_rounded,
                  color: AppColors.studentPrimary,
                  bgColor: AppColors.studentPrimaryLight,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, AppRouter.adminStudents);
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AdminQuickActionCard(
                  title: 'الأكواد النشطة',
                  subtitle: 'استعراض وتوليد الأكواد',
                  icon: Icons.vpn_key_rounded,
                  color: const Color(0xFF16A34A),
                  bgColor: const Color(0xFFDCFCE7),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(context, AppRouter.adminActiveCodes);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AdminWideActionCard(
            title: 'أجهزة وتوكنز الإشعارات (FCM Tokens)',
            subtitle: 'استعراض توكنز كل الطلاب والمعلمين وإرسال إشعارات فورية مخصصة',
            icon: Icons.campaign_rounded,
            color: const Color(0xFF6366F1),
            bgColor: const Color(0xFFEEF2FF),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, AppRouter.adminPushTokens);
            },
          ),
        ],
      ),
    );
  }
}
