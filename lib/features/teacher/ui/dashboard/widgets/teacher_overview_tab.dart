import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/student_report_picker_sheet.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_header_card.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_overview_metrics_grid.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_quick_actions_bar.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_recent_content_section.dart';

/// Overview dashboard tab composing header, warning banner, metrics, actions, and recent content.
class TeacherOverviewTab extends StatelessWidget {
  const TeacherOverviewTab({
    super.key,
    required this.availableCodesCount,
    required this.usedCodesCount,
    required this.recentStudents,
    required this.recentCourses,
    required this.recentExams,
    this.isLoadingContent = false,
    required this.teacherName,
    required this.greetingLabel,
    required this.teacherIdCode,
    this.requiresRenewal = false,
    required this.onRefresh,
    required this.onSwitchTab,
  });

  final int availableCodesCount;
  final int usedCodesCount;
  final List<Map<String, dynamic>> recentStudents;
  final List<CourseModel> recentCourses;
  final List<ExamModel> recentExams;
  final bool isLoadingContent;
  final String teacherName;
  final String greetingLabel;
  final String teacherIdCode;
  final bool requiresRenewal;
  final Future<void> Function() onRefresh;
  final void Function(int index) onSwitchTab;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        color: const Color(0xFF0284C7),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TeacherHeaderCard(
                teacherName: teacherName,
                greetingLabel: greetingLabel,
                teacherIdCode: teacherIdCode,
                onNotificationsTap: () =>
                    Navigator.pushNamed(context, AppRouter.teacherNotifications),
                onSettingsTap: () => onSwitchTab(4),
                onAvatarTap: () => onSwitchTab(4),
              ),

              // ─── Fixed Subscription Renewal Warning Banner ────────────────
              if (requiresRenewal) ...[
                SizedBox(height: 14.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626)),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تنبيه: اقتراب موعد انتهاء الاشتراك ⚠️',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.sp,
                                color: const Color(0xFF991B1B),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'يرجى تجديد باقة الاشتراك لضمان استمرار عمل المنصة وتفعيل حسابك.',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                color: const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pushNamed(context, AppRouter.teacherPlans),
                        child: Text(
                          'تجديد الآن',
                          style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 14.h),
              TeacherOverviewMetricsGrid(
                availableCodesCount: availableCodesCount,
                usedCodesCount: usedCodesCount,
                onTabSwitch: onSwitchTab,
              ),
              SizedBox(height: 16.h),
              TeacherQuickActionsBar(
                onTabSwitch: onSwitchTab,
                onReportTap: () => StudentReportPickerSheet.show(
                  context,
                  recentStudents: recentStudents,
                ),
              ),
              SizedBox(height: 20.h),
              TeacherRecentContentSection(
                recentCourses: recentCourses,
                recentExams: recentExams,
                isLoading: isLoadingContent,
                onSwitchTab: onSwitchTab,
                onRefresh: onRefresh,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
