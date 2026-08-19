import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/attendance_save_button.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/attendance_tile.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/grade_selector.dart';

/// Screen for recording student attendance per class session.
class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() =>
      _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String _selectedGrade = 'الصف الثالث الثانوي';
  final List<Map<String, dynamic>> _students = [
    {'id': '1', 'name': 'أحمد محمد علي', 'status': 'present'},
    {'id': '2', 'name': 'سارة إبراهيم محمود', 'status': 'present'},
    {'id': '3', 'name': 'محمود حسن الخولي', 'status': 'absent'},
    {'id': '4', 'name': 'ريم عبد الله الزهراني', 'status': 'late'},
    {'id': '5', 'name': 'عمر خالد فاروق', 'status': 'present'},
  ];

  void _setStatus(int index, String status) {
    HapticFeedback.selectionClick();
    setState(() => _students[index]['status'] = status);
  }

  void _saveAttendance() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ كشف الحضور بنجاح'),
        backgroundColor: DeskColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'تسجيل الحضور والغياب',
          subtitle: 'متابعة حضور الطلاب للحصص والمجموعات',
          automaticallyImplyBack: true,
          actions: [
            IconButton(
              icon: Icon(Icons.check_circle_outline_rounded,
                  color: DeskColors.primary, size: 22.r),
              onPressed: _saveAttendance,
              tooltip: 'حفظ الكشف',
            ),
          ],
        ),
        body: DeskSurface(
          child: Column(
            children: [
              SizedBox(height: 14.h),
              GradeSelector(
                selectedGrade: _selectedGrade,
                onGradeChanged: (g) => setState(() => _selectedGrade = g),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  itemCount: _students.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final item = _students[index];
                    return AttendanceTile(
                      name: item['name'] as String,
                      status: item['status'] as String,
                      onStatusChanged: (s) => _setStatus(index, s),
                    );
                  },
                ),
              ),
              AttendanceSaveButton(onPressed: _saveAttendance),
            ],
          ),
        ),
      ),
    );
  }
}
