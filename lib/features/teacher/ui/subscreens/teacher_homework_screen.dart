import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/add_homework_sheet.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/homework_card.dart';

/// Screen for managing homework assignments and tracking student submissions.
class TeacherHomeworkScreen extends StatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  State<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends State<TeacherHomeworkScreen> {
  final List<Map<String, dynamic>> _homeworks = [
    {
      'id': '1',
      'title': 'واجب حل مسائل الدينامو',
      'course': 'فيزياء الثانوية العامة',
      'submissions': 38,
      'totalStudents': 42,
    },
    {
      'id': '2',
      'title': 'واجب حل أسئلة كتاب المدرسة - الدرس الثاني',
      'course': 'كيمياء الثانوية العامة',
      'submissions': 25,
      'totalStudents': 30,
    },
  ];

  Future<void> _addHomework() async {
    final title = await AddHomeworkSheet.show(context);
    if (title != null && title.isNotEmpty) {
      setState(() {
        _homeworks.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': title,
          'course': 'فيزياء الثانوية العامة',
          'submissions': 0,
          'totalStudents': 42,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'الواجبات والتسليمات',
          subtitle: 'إسناد الملاحظات ومتابعة حلول الواجبات للطلاب',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(16.r),
            itemCount: _homeworks.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final item = _homeworks[index];
              return HomeworkCard(
                title: item['title'] as String,
                course: item['course'] as String,
                submissions: item['submissions'] as int,
                totalStudents: item['totalStudents'] as int,
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            _addHomework();
          },
          backgroundColor: DeskColors.primary,
          foregroundColor: Colors.white,
          icon: Icon(Icons.add_rounded, size: 20.r),
          label: Text(
            'واجب جديد',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
