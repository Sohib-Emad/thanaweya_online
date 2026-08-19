import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/widgets.dart';

/// Weekly schedule screen showing lecture slots per day
/// with day-tab filtering and hall/time details.
class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  int _selectedDayIndex = 0;

  static const _days = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  static const _schedule = [
    {
      'title': 'محاضرة الفيزياء - الصف الثالث الثانوي أ',
      'time': '10:30 ص - 11:30 ص',
      'hall': 'قاعة الأمل 1',
      'status': 'نشطة الآن',
    },
    {
      'title': 'محاضرة الكيمياء - الصف الثاني الثانوي ب',
      'time': '11:30 ص - 12:30 م',
      'hall': 'قاعة التفوق 3',
      'status': 'قادمة',
    },
    {
      'title': 'حل مراجعة الشامل - الصف الثالث الثانوي',
      'time': '01:15 م - 02:15 م',
      'hall': 'أونلاين (بث مباشر)',
      'status': 'قادمة',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'الجدول الدراسي الأسبوعي',
          subtitle: 'مواعيد الحصص والمجموعات والقاعات الدراسية',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: Column(
            children: [
              SizedBox(height: 14.h),
              DayTabs(
                days: _days,
                selectedIndex: _selectedDayIndex,
                onSelected: (i) => setState(() => _selectedDayIndex = i),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  itemCount: _schedule.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) =>
                      ScheduleSlotCard(item: _schedule[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
