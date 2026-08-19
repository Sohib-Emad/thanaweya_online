import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Activation code input section with paste button and info hint.
class ActivationCodeSection extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onPaste;
  final ValueChanged<String?> onChanged;

  const ActivationCodeSection({
    super.key,
    required this.controller,
    required this.onPaste,
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
                  'أدخل كود التفعيل المستلم من مدرسك لتفعيل هذا الكورس والبدء في مشاهدة الحصص والامتحانات فوراً.',
                  style: NotebookText.strong(12.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 22.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'كود تفعيل الكورس من المدرس',
              style: NotebookText.heading(13.sp),
            ),
            TextButton.icon(
              onPressed: onPaste,
              icon: Icon(
                Icons.content_paste_rounded,
                size: 16.r,
                color: NotebookColors.green,
              ),
              label: Text(
                'لصق الكود',
                style: NotebookText.strong(12.sp, color: NotebookColors.green),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
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
            hintText: 'مثال: TH-2026-ABCD',
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
