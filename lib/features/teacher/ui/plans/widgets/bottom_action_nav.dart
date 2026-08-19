import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Bottom action bar with WhatsApp contact button
/// and skip navigation link.
class BottomActionNav extends StatelessWidget {
  final VoidCallback onSubmitPressed;
  final bool isLoading;

  const BottomActionNav({
    super.key,
    required this.onSubmitPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 16.r),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: DeskColors.line)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : onSubmitPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: DeskColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          icon: isLoading
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.check_circle_rounded, size: 20.r),
          label: Text(
            isLoading ? 'جاري الإرسال...' : 'تأكيد الاشتراك وإرسال إيصال الدفع',
            style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
