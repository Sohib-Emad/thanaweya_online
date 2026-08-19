import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/widgets/settings_text_field.dart';

/// Bottom sheet for editing the teacher's personal profile fields.
class EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialAcademy;
  final String initialSubject;
  final VoidCallback onSaved;

  const EditProfileSheet({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialAcademy,
    required this.initialSubject,
    required this.onSaved,
  });

  static Future<void> show(BuildContext context, {
    required String initialName, required String initialEmail,
    required String initialPhone, required String initialAcademy,
    required String initialSubject, required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(context: context, isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EditProfileSheet(
            initialName: initialName, initialEmail: initialEmail,
            initialPhone: initialPhone, initialAcademy: initialAcademy,
            initialSubject: initialSubject, onSaved: onSaved));
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _emailCtl;
  late final TextEditingController _phoneCtl;
  late final TextEditingController _subjectCtl;
  late final TextEditingController _academyCtl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.initialName);
    _emailCtl = TextEditingController(text: widget.initialEmail);
    _phoneCtl = TextEditingController(text: widget.initialPhone);
    _subjectCtl = TextEditingController(text: widget.initialSubject);
    _academyCtl = TextEditingController(text: widget.initialAcademy);
  }

  @override
  void dispose() {
    _nameCtl.dispose(); _emailCtl.dispose(); _phoneCtl.dispose();
    _subjectCtl.dispose(); _academyCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(ctx).viewInsets.bottom + 24.h),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40.w, height: 4.h,
                  decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2.r)))),
              SizedBox(height: 16.h),
              Text('تعديل الملف الشخصي والأكاديمية',
                  style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              SizedBox(height: 16.h),
              SettingsTextField(label: 'اسم المعلم الكامل', controller: _nameCtl, icon: Icons.person_outline_rounded),
              SizedBox(height: 12.h),
              SettingsTextField(label: 'البريد الإلكتروني', controller: _emailCtl, icon: Icons.email_outlined, readOnly: true),
              SizedBox(height: 12.h),
              SettingsTextField(label: 'رقم الهاتف للتواصل', controller: _phoneCtl, icon: Icons.phone_outlined),
              SizedBox(height: 12.h),
              SettingsTextField(label: 'المادة والتخصص', controller: _subjectCtl, icon: Icons.subject_rounded),
              SizedBox(height: 12.h),
              SettingsTextField(label: 'اسم الأكاديمية / المنصة', controller: _academyCtl, icon: Icons.school_outlined),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity, height: 46.h,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : () => _save(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: Text('حفظ التعديلات', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext ctx) async {
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(UserAttributes(data: {
        'full_name': _nameCtl.text.trim(), 'phone': _phoneCtl.text.trim(),
        'academy_name': _academyCtl.text.trim(), 'subject': _subjectCtl.text.trim(),
      }));
      if (!mounted) return;
      Navigator.pop(ctx);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white),
          SizedBox(width: 8.w),
          Text('تم حفظ بيانات الحساب بنجاح', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        ]),
        backgroundColor: const Color(0xFF0284C7), behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('تعذر الحفظ: $e', style: GoogleFonts.cairo()), backgroundColor: DeskColors.danger));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
