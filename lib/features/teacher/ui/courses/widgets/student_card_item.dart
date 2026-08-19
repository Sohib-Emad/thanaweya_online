import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/parent_report_sheet.dart';

/// Individual student card item showing name, phone, and report action.
class StudentCardItem extends StatelessWidget {
  final String name;
  final String phone;

  const StudentCardItem({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: DeskColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Row(
        children: [
          DeskAvatar(initial: name, radius: 20),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: DeskText.strong(13.sp)),
                SizedBox(height: 2.h),
                Text(
                  phone.isNotEmpty ? phone : 'لا يوجد رقم هاتف',
                  style: DeskText.note(11.sp),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.analytics_rounded,
              color: DeskColors.primary,
              size: 20.r,
            ),
            tooltip: 'إصدار تقرير ولي الأمر',
            onPressed: () {
              ParentReportSheet.show(
                context,
                studentName: name,
                gradeLevel: 'الثالث الثانوي',
                parentPhone: phone,
                grades: const [],
                progress: const [],
                subscriptions: const [],
              );
            },
          ),
        ],
      ),
    );
  }
}
