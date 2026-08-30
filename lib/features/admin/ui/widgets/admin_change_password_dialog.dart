import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

void showAdminChangePasswordDialog({
  required BuildContext context,
  required String userName,
  required String currentPassword,
  required Future<bool> Function(String newPassword) onPasswordChanged,
  required void Function(String newPassword) onSuccess,
}) {
  final controller = TextEditingController(text: currentPassword);
  bool obscure = false;
  bool isSaving = false;

  showDialog(
    context: context,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppColors.adminPrimary),
            SizedBox(width: 8.w),
            Text('تعيين كلمة مرور جديدة', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المستخدم: $userName', style: GoogleFonts.cairo(fontSize: 12.5.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
            SizedBox(height: 14.h),
            TextField(
              controller: controller,
              obscureText: obscure,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: 'كلمة المرور الجديدة',
                hintText: 'أدخل كلمة مرور لا تقل عن 6 أحرف',
                prefixIcon: const Icon(Icons.key_rounded),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setDialogState(() => obscure = !obscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: isSaving ? null : () => Navigator.pop(dialogCtx), child: Text('إلغاء', style: GoogleFonts.cairo())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
            onPressed: isSaving
                ? null
                : () async {
                    final newPass = controller.text.trim();
                    if (newPass.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب أن تكون كلمة المرور 6 أحرف على الأقل'), backgroundColor: AppColors.error));
                      return;
                    }
                    setDialogState(() => isSaving = true);
                    final ok = await onPasswordChanged(newPass);
                    if (ok) onSuccess(newPass);
                    if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                  },
            child: isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('حفظ التغيير', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
