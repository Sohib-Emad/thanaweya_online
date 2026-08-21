import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Interactive InstaPay payment information card displaying
/// account number with copy action, dynamic plan fee, and quick steps.
class InstaPayInfoCard extends StatelessWidget {
  final String amount;
  final String planName;
  static const String instapayNumber = '01096462825';

  const InstaPayInfoCard({
    super.key,
    required this.amount,
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with InstaPay badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFF9333EA)],
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, color: Colors.amber, size: 16.r),
                    SizedBox(width: 4.w),
                    Text(
                      'InstaPay / إنستاباي',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: DeskColors.primarySoft,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'المطلوب: $amount',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: DeskColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Transfer number row with Copy Button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_iphone_rounded,
                    size: 20.r, color: DeskColors.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'رقم التحويل (إنستاباي فقط):',
                        style: DeskText.note(11.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        instapayNumber,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 16.5.sp,
                          fontWeight: FontWeight.w900,
                          color: DeskColors.ink,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(
                        const ClipboardData(text: instapayNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white),
                            SizedBox(width: 8.w),
                            Text('تم نسخ الرقم: $instapayNumber'),
                          ],
                        ),
                        backgroundColor: DeskColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DeskColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.copy_rounded, size: 15.r),
                  label: Text('نسخ',
                      style: TextStyle(
                          fontSize: 12.sp, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          // Steps list
          _buildStepRow('1', 'افتح تطبيق إنستاباي (InstaPay).'),
          _buildStepRow('2', 'حوّل مبلغ $amount لـ $planName إلى الرقم $instapayNumber.'),
          _buildStepRow('3', 'التقط صورة/لقطة شاشة لإيصال التحويل وأرفقها بالأسفل.'),
        ],
      ),
    );
  }

  Widget _buildStepRow(String num, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18.r,
            height: 18.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DeskColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: DeskColors.primary,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: DeskText.body(11.5.sp, color: DeskColors.ink).copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
