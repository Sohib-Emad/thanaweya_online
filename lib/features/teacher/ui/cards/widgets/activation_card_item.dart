import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/teacher/ui/cards/widgets/printable_voucher_card.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/widgets/promotional_voucher_dialog.dart';

/// Single activation card item that directly renders the official Printable Voucher Card
/// with QR Code on the front face, Platform name, and Teacher details.
class ActivationCardItem extends StatelessWidget {
  final String code;
  final bool isUsed;
  final String courseTitle;
  final String? teacherName;
  final String? studentName;
  final VoidCallback onCopy;
  final VoidCallback? onDelete;

  const ActivationCardItem({
    super.key,
    required this.code,
    required this.isUsed,
    required this.courseTitle,
    this.teacherName,
    this.studentName,
    required this.onCopy,
    this.onDelete,
  });

  void _openPrintDialog(BuildContext context) {
    PromotionalVoucherDialog.show(
      context,
      code: code,
      courseTitle: courseTitle,
      teacherName: (teacherName != null && teacherName!.isNotEmpty) ? teacherName! : 'المعلم',
      isUsed: isUsed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = (teacherName != null && teacherName!.isNotEmpty)
        ? teacherName!
        : 'المعلم';

    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── 1. The Real Printable Card (Clean White Print Design) ────────
          GestureDetector(
            onTap: () => _openPrintDialog(context),
            child: Stack(
              children: [
                PrintableVoucherCard(
                  code: code,
                  courseTitle: courseTitle,
                  teacherName: displayName,
                ),
                if (isUsed)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(160),
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_rounded, color: Color(0xFFF87171), size: 16),
                            SizedBox(width: 6.w),
                            Text(
                              studentName != null
                                  ? 'مستخدم بواسطة: $studentName'
                                  : 'تم استخدام الكارت',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),

          // ─── 2. Quick Action Bar Below Card ──────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: onCopy,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.copy_rounded, size: 13.r, color: const Color(0xFF0284C7)),
                            SizedBox(width: 4.w),
                            Text(
                              'نسخ الكود',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () => _openPrintDialog(context),
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withAlpha(12),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFF0284C7).withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fullscreen_rounded, size: 15.r, color: const Color(0xFF0284C7)),
                            SizedBox(width: 3.w),
                            Text(
                              'تكبير وطباعة',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isUsed && onDelete != null)
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.all(5.r),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 15.r, color: const Color(0xFFE11D48)),
                          SizedBox(width: 3.w),
                          Text(
                            'حذف',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
