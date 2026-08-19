import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// List of the most challenging exams with failure rates
/// and average scores.
class ChallengingExamsList extends StatelessWidget {
  const ChallengingExamsList({super.key});

  static const _exams = [
    {
      'title': 'امتحان الفصل الثاني - قوانين كيرشوف والدوائر',
      'avg': '68%',
      'failRate': '22%',
      'color': 0xFFE11D48,
    },
    {
      'title': 'اختبار التفاضل والتكامل المتقدم',
      'avg': '72%',
      'failRate': '18%',
      'color': 0xFFEA580C,
    },
    {
      'title': 'امتحان تجربة فاراداي والحث الكهرومغناطيسي',
      'avg': '76%',
      'failRate': '14%',
      'color': 0xFFD97706,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 18.r, color: const Color(0xFFD97706)),
              SizedBox(width: 6.w),
              Text('أكثر الامتحانات صعوبة',
                  style: DeskText.heading(13.sp)),
            ],
          ),
          SizedBox(height: 12.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _exams.length,
            separatorBuilder: (_, _) => const Divider(height: 14),
            itemBuilder: (context, i) {
              final ex = _exams[i];
              final exColor = Color(ex['color'] as int);
              return Row(
                children: [
                  CircleAvatar(
                    radius: 12.r,
                    backgroundColor: exColor.withAlpha(20),
                    child: Text('${i + 1}',
                        style: TextStyle(
                            color: exColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800)),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex['title'] as String,
                            style: DeskText.strong(11.5.sp),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('نسبة عدم الاجتياز: ${ex['failRate']}',
                            style: DeskText.note(10.sp)),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text('متوسط: ${ex['avg']}',
                        style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF334155))),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
