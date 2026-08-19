import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Dialog form for adding a new teacher note.
class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  static Future<Map<String, String>?> show(BuildContext context) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddNoteDialog(),
    );
  }

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.isNotEmpty) {
      Navigator.pop(context, {
        'title': _titleController.text,
        'content': _contentController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text('إضافة ملاحظة جديدة', style: DeskText.heading(15.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DeskInputField(
              label: 'عنوان الملاحظة',
              controller: _titleController,
              hint: 'مثال: مراجعة الحصة القادمة',
            ),
            SizedBox(height: 12.h),
            DeskInputField(
              label: 'نص الملاحظة',
              controller: _contentController,
              hint: 'اكتب الملاحظات والتفاصيل هنا...',
              keyboardType: TextInputType.multiline,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: DeskText.note(13.sp)),
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: DeskColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'حفظ الملاحظة',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
