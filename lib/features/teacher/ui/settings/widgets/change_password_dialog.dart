import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Dialog for changing the teacher's account password.
/// Validates minimum length and confirmation match before calling Supabase.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ChangePasswordDialog(),
    );
  }

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  @override
  void dispose() {
    _passCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text('تغيير كلمة المرور',
            style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 16.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_passCtl, 'كلمة المرور الجديدة'),
            SizedBox(height: 12.h),
            _field(_confirmCtl, 'تأكيد كلمة المرور'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: DeskColors.muted)),
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('حفظ التغيير', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController ctl, String label) {
    return TextField(
      controller: ctl,
      obscureText: true,
      style: GoogleFonts.cairo(fontSize: 13.sp),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(fontSize: 12.sp),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_passCtl.text.length < 6) {
      messenger.showSnackBar(
          const SnackBar(content: Text('كلمة المرور يجب أن لا تقل عن 6 أحرف')));
      return;
    }
    if (_passCtl.text != _confirmCtl.text) {
      messenger.showSnackBar(
          const SnackBar(content: Text('كلمات المرور غير متطابقة')));
      return;
    }
    Navigator.pop(context);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passCtl.text),
      );
      if (!mounted) return;
      messenger.showSnackBar(
          const SnackBar(content: Text('تم تحديث كلمة المرور بنجاح!')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }
}
