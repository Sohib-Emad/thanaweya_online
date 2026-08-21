import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';

/// An interactive tile for Administrators to view, copy, or reset a user's password.
class AdminPasswordTile extends StatefulWidget {
  const AdminPasswordTile({
    super.key,
    required this.userId,
    required this.userName,
    required this.initialPassword,
    required this.onPasswordChanged,
  });

  final String userId;
  final String userName;
  final String initialPassword;
  final Future<bool> Function(String newPassword) onPasswordChanged;

  @override
  State<AdminPasswordTile> createState() => _AdminPasswordTileState();
}

class _AdminPasswordTileState extends State<AdminPasswordTile> {
  bool _isRevealed = false;
  late String _currentPassword;

  @override
  void initState() {
    super.initState();
    _currentPassword = widget.initialPassword.trim();
  }

  @override
  void didUpdateWidget(covariant AdminPasswordTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialPassword != widget.initialPassword) {
      _currentPassword = widget.initialPassword.trim();
    }
  }

  void _copyPassword() {
    if (_currentPassword.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _currentPassword));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ كلمة مرور ${widget.userName} 📋'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final controller = TextEditingController(text: _currentPassword);
    bool obscure = false;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Row(
              children: [
                const Icon(Icons.lock_reset_rounded, color: AppColors.adminPrimary),
                SizedBox(width: 8.w),
                Text(
                  'تعيين كلمة مرور جديدة',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المستخدم: ${widget.userName}',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
                      icon: Icon(
                        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogCtx),
                child: Text('إلغاء', style: GoogleFonts.cairo()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.adminPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                onPressed: isSaving
                    ? null
                    : () async {
                        final newPass = controller.text.trim();
                        if (newPass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يجب أن تكون كلمة المرور 6 أحرف على الأقل'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        setDialogState(() => isSaving = true);
                        final ok = await widget.onPasswordChanged(newPass);
                        if (mounted) {
                          setState(() {
                            if (ok) _currentPassword = newPass;
                          });
                        }
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      },
                child: isSaving
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'حفظ التغيير',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPassword = _currentPassword.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 15.r,
            color: const Color(0xFF475569),
          ),
          SizedBox(width: 6.w),
          Text(
            'كلمة المرور: ',
            style: GoogleFonts.cairo(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
          Expanded(
            child: hasPassword
                ? Text(
                    _isRevealed ? _currentPassword : '••••••••',
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: _isRevealed
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF64748B),
                      letterSpacing: _isRevealed ? 0.5 : 2.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    'غير مسجلة',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      color: AppColors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          if (hasPassword) ...[
            // Toggle visibility
            InkWell(
              onTap: () => setState(() => _isRevealed = !_isRevealed),
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(
                  _isRevealed
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 16.r,
                  color: const Color(0xFF0284C7),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Copy
            InkWell(
              onTap: _copyPassword,
              borderRadius: BorderRadius.circular(4.r),
              child: Padding(
                padding: EdgeInsets.all(4.r),
                child: Icon(
                  Icons.copy_rounded,
                  size: 15.r,
                  color: const Color(0xFF0D9488),
                ),
              ),
            ),
            SizedBox(width: 4.w),
          ],
          // Edit / Reset password button
          InkWell(
            onTap: _showChangePasswordDialog,
            borderRadius: BorderRadius.circular(4.r),
            child: Padding(
              padding: EdgeInsets.all(4.r),
              child: Icon(
                Icons.edit_rounded,
                size: 15.r,
                color: AppColors.adminPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
