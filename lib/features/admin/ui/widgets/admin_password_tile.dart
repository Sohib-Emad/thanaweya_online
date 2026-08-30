import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'admin_change_password_dialog.dart';

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
      SnackBar(content: Text('تم نسخ كلمة مرور ${widget.userName} 📋'), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)),
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
          Icon(Icons.lock_outline_rounded, size: 15.r, color: const Color(0xFF475569)),
          SizedBox(width: 6.w),
          Text('كلمة المرور: ', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF334155))),
          Expanded(
            child: hasPassword
                ? Text(
                    _isRevealed ? _currentPassword : '••••••••',
                    textDirection: TextDirection.ltr, textAlign: TextAlign.left,
                    style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800, color: _isRevealed ? const Color(0xFF0F172A) : const Color(0xFF64748B), letterSpacing: _isRevealed ? 0.5 : 2.0),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  )
                : Text('غير مسجلة', style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.textTertiary, fontStyle: FontStyle.italic)),
          ),
          if (hasPassword) ...[
            InkWell(onTap: () => setState(() => _isRevealed = !_isRevealed), borderRadius: BorderRadius.circular(4.r), child: Padding(padding: EdgeInsets.all(4.r), child: Icon(_isRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16.r, color: const Color(0xFF0284C7)))),
            SizedBox(width: 4.w),
            InkWell(onTap: _copyPassword, borderRadius: BorderRadius.circular(4.r), child: Padding(padding: EdgeInsets.all(4.r), child: const Icon(Icons.copy_rounded, size: 15, color: Color(0xFF0D9488)))),
            SizedBox(width: 4.w),
          ],
          InkWell(
            onTap: () => showAdminChangePasswordDialog(
              context: context, userName: widget.userName, currentPassword: _currentPassword,
              onPasswordChanged: widget.onPasswordChanged, onSuccess: (p) => setState(() => _currentPassword = p),
            ),
            borderRadius: BorderRadius.circular(4.r),
            child: Padding(padding: EdgeInsets.all(4.r), child: const Icon(Icons.edit_rounded, size: 15, color: AppColors.adminPrimary)),
          ),
        ],
      ),
    );
  }
}
