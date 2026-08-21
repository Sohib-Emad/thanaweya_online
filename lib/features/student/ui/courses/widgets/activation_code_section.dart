import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Activation code input section with QR Scanner, paste button, and info hint.
class ActivationCodeSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPaste;
  final VoidCallback onScanQr;
  final ValueChanged<String?> onChanged;

  const ActivationCodeSection({
    super.key,
    required this.controller,
    required this.onPaste,
    required this.onScanQr,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotebookHighlightNote(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: NotebookColors.green,
                size: 20.r,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'أدخل كود التفعيل المستلم من مدرسك أو امسح كود الـ QR من الكارت المطبوع لتفعيل الكورس فوراً.',
                  style: NotebookText.strong(12.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),

        // Quick Input Options (Scan QR & Paste)
        Row(
          children: [
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: onScanQr,
                icon: Icon(
                  Icons.qr_code_scanner_rounded,
                  size: 18.r,
                  color: Colors.white,
                ),
                label: Text(
                  'مسح كود QR من الكارت',
                  style: NotebookText.strong(12.sp, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NotebookColors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 1,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: onPaste,
                icon: Icon(
                  Icons.content_paste_rounded,
                  size: 16.r,
                  color: NotebookColors.ink,
                ),
                label: Text(
                  'لصق الكود',
                  style: NotebookText.strong(12.sp, color: NotebookColors.ink),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: NotebookColors.ink.withAlpha(50)),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        Text(
          'رمز أو كود الاشتراك (Code)',
          style: NotebookText.heading(13.sp),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: NotebookText.heading(18.sp).copyWith(
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
          textCapitalization: TextCapitalization.characters,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'مثال: TH-GQDY-SCSW',
            hintStyle: NotebookText.note(13.sp).copyWith(letterSpacing: 1.0),
            filled: true,
            fillColor: NotebookColors.surfaceBright,
            contentPadding: EdgeInsets.symmetric(
              vertical: 18.h,
              horizontal: 16.w,
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 20.r,
                      color: NotebookColors.ink.withAlpha(120),
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged(null);
                    },
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: NotebookColors.ink.withAlpha(40),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide(
                color: NotebookColors.green,
                width: 2,
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 14.r,
              color: NotebookColors.ink.withAlpha(120),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                'الكود صالح للاستخدام مرة واحدة فقط بحساب طالب واحد.',
                style: NotebookText.note(11.sp),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
