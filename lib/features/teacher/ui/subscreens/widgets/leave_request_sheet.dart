import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Bottom sheet form for submitting a new leave or absence request.
class LeaveRequestSheet extends StatelessWidget {
  const LeaveRequestSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => const LeaveRequestSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeController = TextEditingController();
    final reasonController = TextEditingController();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('تقديم طلب إجازة جديد', style: DeskText.heading(16.sp)),
            SizedBox(height: 16.h),
            DeskInputField(
              label: 'نوع الطلب',
              controller: typeController,
              hint: 'إجازة اعتيادية / مرضية / استئذان',
            ),
            SizedBox(height: 12.h),
            DeskInputField(
              label: 'سبب الطلب',
              controller: reasonController,
              hint: 'اكتب سبب الإجازة هنا...',
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم إرسال طلب الإجازة للمراجعة بنجاح',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: DeskColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeskColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'إرسال الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
