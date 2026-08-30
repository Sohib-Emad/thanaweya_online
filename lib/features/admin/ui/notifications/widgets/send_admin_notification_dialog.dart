import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/logic/admin_push_tokens_cubit.dart';
import 'send_notification_selectors.dart';

class SendAdminNotificationDialog extends StatefulWidget {
  final AdminPushTokensCubit cubit;
  final String? initialTargetType, specificUserId, specificUserName;
  const SendAdminNotificationDialog({super.key, required this.cubit, this.initialTargetType, this.specificUserId, this.specificUserName});

  @override
  State<SendAdminNotificationDialog> createState() => _SendAdminNotificationDialogState();
}

class _SendAdminNotificationDialogState extends State<SendAdminNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(), _bodyController = TextEditingController();
  late String _targetType;
  String _category = 'admin_broadcast';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _targetType = widget.specificUserId != null ? 'specific' : (widget.initialTargetType ?? 'all');
  }

  @override
  void dispose() {
    _titleController.dispose(); _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();
    final ok = await widget.cubit.sendNotification(
      title: _titleController.text.trim(), body: _bodyController.text.trim(),
      targetType: _targetType, specificUserId: widget.specificUserId, category: _category,
    );
    if (!mounted) return;
    setState(() => _isSending = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال الإشعار بنجاح لـ ${widget.cubit.state.sentCount} مستخدم!'), backgroundColor: const Color(0xFF16A34A)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.cubit.state.errorMessage ?? 'فشل إرسال الإشعار'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)), backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: AppColors.adminPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.campaign_rounded, color: AppColors.adminPrimary, size: 24.r)),
                SizedBox(width: 12.w),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('إرسال إشعار فوري', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  Text(widget.specificUserName != null ? 'إشعار خاص بـ: ${widget.specificUserName}' : 'بث إشعار للأجهزة والتطبيق', style: GoogleFonts.cairo(fontSize: 11.5.sp, color: AppColors.textSecondary)),
                ])),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: AppColors.textSecondary),
              ]),
              const Divider(height: 24),
              SendNotificationSelectors(isSpecificUser: widget.specificUserId != null, targetType: _targetType, category: _category, onSelectTargetType: (v) => setState(() => _targetType = v), onSelectCategory: (v) => setState(() => _category = v)),
              SizedBox(height: 16.h),
              Text('عنوان الإشعار:', style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              TextFormField(controller: _titleController, decoration: InputDecoration(hintText: 'عنوان الإشعار...', filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))), validator: (v) => v?.trim().isEmpty == true ? 'يرجى كتابة عنوان' : null),
              SizedBox(height: 14.h),
              Text('نص الرسالة:', style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w700)),
              SizedBox(height: 6.h),
              TextFormField(controller: _bodyController, maxLines: 4, decoration: InputDecoration(hintText: 'اكتب نص الإشعار هنا...', filled: true, fillColor: const Color(0xFFF8FAFC), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))), validator: (v) => v?.trim().isEmpty == true ? 'يرجى كتابة نص الرسالة' : null),
              SizedBox(height: 20.h),
              SizedBox(width: double.infinity, height: 48.h, child: ElevatedButton(onPressed: _isSending ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))), child: _isSending ? const Center(child: CircularProgressIndicator(color: Colors.white)) : Text('إرسال الإشعار الآن', style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800)))),
            ],
          ),
        ),
      ),
    );
  }
}
