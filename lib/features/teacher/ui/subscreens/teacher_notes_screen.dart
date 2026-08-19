import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/add_note_dialog.dart';
import 'package:thanaweya_online/features/teacher/ui/subscreens/widgets/note_card.dart';

/// Screen for managing teacher notes and reminders.
class TeacherNotesScreen extends StatefulWidget {
  const TeacherNotesScreen({super.key});

  @override
  State<TeacherNotesScreen> createState() => _TeacherNotesScreenState();
}

class _TeacherNotesScreenState extends State<TeacherNotesScreen> {
  final List<Map<String, dynamic>> _notes = [
    {
      'id': '1',
      'title': 'تحضير أسئلة المراجعة الشاملة',
      'content': 'التركيز على مسألة الدينامو وقوانين فاراداي في الحصة القادمة.',
      'date': 'اليوم • 09:30 ص',
      'category': 'خاصة',
      'color': const Color(0xFFDB2777),
    },
    {
      'id': '2',
      'title': 'متابعة الطالب أحمد محمد',
      'content': 'مستوى الطالب ممتاز ولكن يحتاج لزيادة التركيز في أسئلة الاختيارات.',
      'date': 'أمس • 04:15 م',
      'category': 'طالب',
      'color': const Color(0xFF0284C7),
    },
  ];

  Future<void> _addNote() async {
    final result = await AddNoteDialog.show(context);
    if (result != null) {
      setState(() {
        _notes.insert(0, {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': result['title'],
          'content': result['content'],
          'date': 'الآن',
          'category': 'خاصة',
          'color': const Color(0xFFDB2777),
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
          title: 'ملاحظات المعلم',
          subtitle: 'تدوين الملاحظات والتنبيهات الخاصة بالحصول والطلاب',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: _notes.isEmpty
              ? const DeskEmptyNote(
                  message: 'لا توجد ملاحظات مدونة بعد',
                  subMessage: 'اضغط على زر + لتدوين أول ملاحظة',
                  icon: Icons.note_alt_outlined,
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(16.r),
                  itemCount: _notes.length,
                  separatorBuilder: (_, _) => SizedBox(height: 10.h),
                  itemBuilder: (context, index) {
                    final item = _notes[index];
                    return NoteCard(
                      title: item['title'] as String,
                      content: item['content'] as String,
                      date: item['date'] as String,
                      color: item['color'] as Color,
                    );
                  },
                ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            _addNote();
          },
          backgroundColor: DeskColors.primary,
          foregroundColor: Colors.white,
          icon: Icon(Icons.add_rounded, size: 20.r),
          label: Text(
            'ملاحظة جديدة',
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
