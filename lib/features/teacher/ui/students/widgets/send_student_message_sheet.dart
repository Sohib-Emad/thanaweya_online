import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';

/// Dialog for composing and sending a notification to all students.
class SendStudentMessageSheet extends StatefulWidget {
  const SendStudentMessageSheet({super.key});

  /// Shows the dialog; returns true if the message was sent successfully.
  static Future<bool> show(BuildContext context) async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => const SendStudentMessageSheet(),
    );
    return sent ?? false;
  }

  @override
  State<SendStudentMessageSheet> createState() => _SendStudentMessageSheetState();
}

class _SendStudentMessageSheetState extends State<SendStudentMessageSheet> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() { _titleController.dispose(); _bodyController.dispose(); super.dispose(); }

  Future<void> _send() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    setState(() => _sending = true);

    final result = await TeacherStudentsRepo().communications.sendMessageToStudents(
      title: title, body: _bodyController.text.trim(),
    );

    if (!mounted) return;
    result.when(
      success: (_) { HapticFeedback.mediumImpact(); Navigator.pop(context, true); },
      failure: (message, _) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل إرسال الرسالة: $message'),
          backgroundColor: const Color(0xFFE11D48),
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withAlpha(16),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.campaign_rounded, color: const Color(0xFF0284C7), size: 22.r),
          ),
          SizedBox(width: 10.w),
          Expanded(child: Text('إرسال إشعار للطلاب',
            style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          )),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          DeskInputField(label: 'عنوان الرسالة', controller: _titleController, icon: Icons.title_rounded, hint: 'مثال: موعد الامتحان القادم'),
          SizedBox(height: 12.h),
          DeskInputField(label: 'نص الرسالة', controller: _bodyController, icon: Icons.subject_rounded, hint: 'اكتب نص التنبيه هنا...', maxLines: 3),
        ]),
        actions: [
          TextButton(
            onPressed: _sending ? null : () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
          ),
          SizedBox(width: 8.w),
          if (_sending)
            const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF0284C7))))
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: _send,
              child: Text('إرسال الآن', style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}
