import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Activation code input box with promo code field
/// and apply button.
class ActivationCodeBox extends StatelessWidget {
  final TextEditingController controller;
  final bool isApplied;
  final VoidCallback onApply;

  const ActivationCodeBox({
    super.key,
    required this.controller,
    required this.isApplied,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: DeskColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.vpn_key_outlined,
                  size: 18.r, color: DeskColors.primary),
              SizedBox(width: 6.w),
              Text('هل لديك كود خصم أو كارت تفعيل؟',
                  style: DeskText.strong(13.sp)),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: DeskText.body(13.sp),
                  decoration: InputDecoration(
                    hintText: 'أدخل كود الخصم أو الشحن...',
                    hintStyle: DeskText.note(12.sp),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 10.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide:
                          const BorderSide(color: DeskColors.line),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                      borderSide:
                          BorderSide(color: DeskColors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeskColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(80.w, 44.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  isApplied ? 'تم التفعيل' : 'تطبيق',
                  style: TextStyle(
                      fontSize: 12.sp, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
