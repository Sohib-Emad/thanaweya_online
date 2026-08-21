import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/teacher/ui/settings/widgets/settings_text_field.dart';

/// Bottom sheet for editing the teacher's personal profile fields.
class EditProfileSheet extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final VoidCallback onSaved;

  const EditProfileSheet({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String initialName,
    required String initialEmail,
    required String initialPhone,
    required VoidCallback onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditProfileSheet(
        initialName: initialName,
        initialEmail: initialEmail,
        initialPhone: initialPhone,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameCtl;
  late final TextEditingController _emailCtl;
  late final TextEditingController _phoneCtl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.initialName);
    _emailCtl = TextEditingController(text: widget.initialEmail);
    _phoneCtl = TextEditingController(text: widget.initialPhone);
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _phoneCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(
            20.w,
            16.h,
            20.w,
            MediaQuery.of(ctx).viewInsets.bottom + 24.h,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'تعديل الملف الشخصي',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 16.h),
                SettingsTextField(
                  label: 'اسم المعلم الكامل',
                  controller: _nameCtl,
                  icon: Icons.person_outline_rounded,
                ),
                SizedBox(height: 12.h),
                SettingsTextField(
                  label: 'البريد الإلكتروني',
                  controller: _emailCtl,
                  icon: Icons.email_outlined,
                  readOnly: true,
                ),
                SizedBox(height: 12.h),
                SettingsTextField(
                  label: 'رقم الهاتف للتواصل',
                  controller: _phoneCtl,
                  icon: Icons.phone_outlined,
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : () => _save(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    icon: _saving
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      _saving ? 'جاري الحفظ...' : 'حفظ التعديلات',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w800,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(BuildContext ctx) async {
    setState(() => _saving = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      final newName = _nameCtl.text.trim();
      final newPhone = _phoneCtl.text.trim();

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {
          'full_name': newName,
          'phone': newPhone,
        }),
      );

      if (uid != null) {
        await Supabase.instance.client
            .from('users')
            .update({
              'full_name': newName,
              'phone': newPhone,
            })
            .eq('id', uid);
      }

      if (!mounted) return;
      Navigator.pop(ctx);
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                'تم حفظ بيانات الحساب بنجاح',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0FA37F),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الحفظ: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
