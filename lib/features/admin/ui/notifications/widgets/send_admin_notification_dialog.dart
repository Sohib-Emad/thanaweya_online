import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/logic/admin_push_tokens_cubit.dart';

class SendAdminNotificationDialog extends StatefulWidget {
  final AdminPushTokensCubit cubit;
  final String? initialTargetType; // 'all', 'students', 'teachers', 'specific'
  final String? specificUserId;
  final String? specificUserName;

  const SendAdminNotificationDialog({
    super.key,
    required this.cubit,
    this.initialTargetType,
    this.specificUserId,
    this.specificUserName,
  });

  @override
  State<SendAdminNotificationDialog> createState() =>
      _SendAdminNotificationDialogState();
}

class _SendAdminNotificationDialogState
    extends State<SendAdminNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  late String _targetType;
  String _category = 'admin_broadcast';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _targetType = widget.specificUserId != null
        ? 'specific'
        : (widget.initialTargetType ?? 'all');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    final success = await widget.cubit.sendNotification(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      targetType: _targetType,
      specificUserId: widget.specificUserId,
      category: _category,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                Text(
                  'تم إرسال الإشعار بنجاح لـ ${widget.cubit.state.sentCount} مستخدم!',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A34A),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.cubit.state.errorMessage ?? 'فشل إرسال الإشعار',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20.r),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: AppColors.adminPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.campaign_rounded,
                      color: AppColors.adminPrimary,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إرسال إشعار فوري',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.specificUserName != null
                              ? 'إشعار خاص بـ: ${widget.specificUserName}'
                              : 'بث إشعار للأجهزة والتطبيق',
                          style: GoogleFonts.cairo(
                            fontSize: 11.5.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const Divider(height: 24),

              // Target Audience Selector (if not specific)
              if (widget.specificUserId == null) ...[
                Text(
                  'الجمهور المستهدف:',
                  style: GoogleFonts.cairo(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildTargetChoice('all', '📢 جميع المستخدمين'),
                    _buildTargetChoice('students', '🎓 الطلاب فقط'),
                    _buildTargetChoice('teachers', '👨‍🏫 المعلمين فقط'),
                  ],
                ),
                SizedBox(height: 16.h),
              ],

              // Category Selector
              Text(
                'نوع الإشعار:',
                style: GoogleFonts.cairo(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _buildCategoryChoice('admin_broadcast', 'إعلان عام'),
                  _buildCategoryChoice('system', 'تنبيه نظام'),
                  _buildCategoryChoice('offer', 'عرض خاص'),
                  _buildCategoryChoice('important', 'هام وعاجل'),
                ],
              ),
              SizedBox(height: 16.h),

              // Notification Title Field
              Text(
                'عنوان الإشعار:',
                style: GoogleFonts.cairo(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.cairo(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'مثال: تحديث هام في المنصة / خصم خاص...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'يرجى كتابة عنوان الإشعار'
                    : null,
              ),
              SizedBox(height: 14.h),

              // Notification Body Field
              Text(
                'نص الرسالة:',
                style: GoogleFonts.cairo(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _bodyController,
                maxLines: 4,
                style: GoogleFonts.cairo(fontSize: 13.sp),
                decoration: InputDecoration(
                  hintText: 'اكتب نص الإشعار هنا بالتفصيل...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  contentPadding: EdgeInsets.all(14.r),
                ),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'يرجى كتابة نص الرسالة'
                    : null,
              ),
              SizedBox(height: 20.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isSending
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18.r),
                            SizedBox(width: 8.w),
                            Text(
                              'إرسال الإشعار الآن',
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChoice(String type, String label) {
    final isSelected = _targetType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _targetType = type),
      selectedColor: AppColors.adminPrimary,
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: GoogleFonts.cairo(
        fontSize: 11.5.sp,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: BorderSide(
          color: isSelected ? AppColors.adminPrimary : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }

  Widget _buildCategoryChoice(String cat, String label) {
    final isSelected = _category == cat;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _category = cat),
      selectedColor: const Color(0xFF334155),
      backgroundColor: const Color(0xFFF1F5F9),
      labelStyle: GoogleFonts.cairo(
        fontSize: 11.sp,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: isSelected ? const Color(0xFF334155) : Colors.transparent,
        ),
      ),
      showCheckmark: false,
    );
  }
}
