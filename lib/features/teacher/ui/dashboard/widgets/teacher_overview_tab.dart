import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/student_report_picker_sheet.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_activity_feed.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_header_card.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_overview_metrics_grid.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/teacher_quick_actions_bar.dart';

/// Overview dashboard tab composing header, metrics, actions, and feed.
class TeacherOverviewTab extends StatelessWidget {
  const TeacherOverviewTab({
    super.key,
    required this.availableCodesCount,
    required this.usedCodesCount,
    required this.recentStudents,
    required this.teacherName,
    required this.greetingLabel,
    required this.teacherIdCode,
    required this.onRefresh,
    required this.onSwitchTab,
  });

  final int availableCodesCount;
  final int usedCodesCount;
  final List<Map<String, dynamic>> recentStudents;
  final String teacherName;
  final String greetingLabel;
  final String teacherIdCode;
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
              SizedBox(height: 18.h),
              const TeacherActivityFeed(),
            ],
          ),
        ),
      ),
    );
  }
}
