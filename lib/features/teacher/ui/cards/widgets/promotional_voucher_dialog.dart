import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/teacher/ui/cards/services/pdf_cards_generator.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/widgets/printable_voucher_card.dart';

/// Modal dialog displaying the print-ready card with direct PDF printing & copy actions.
class PromotionalVoucherDialog extends StatelessWidget {
  final String code;
  final String courseTitle;
  final String teacherName;
  final bool isUsed;

  const PromotionalVoucherDialog({
    super.key,
    required this.code,
    required this.courseTitle,
    required this.teacherName,
    required this.isUsed,
  });

  static Future<void> show(
    BuildContext context, {
    required String code,
    required String courseTitle,
    required String teacherName,
    required bool isUsed,
  }) {
    HapticFeedback.mediumImpact();
    return showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(170),
      builder: (_) => PromotionalVoucherDialog(
        code: code,
        courseTitle: courseTitle,
        teacherName: teacherName,
        isUsed: isUsed,
      ),
    );
  }

  void _copy(BuildContext context) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الكود: $code ✅',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF0F172A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  Future<void> _printPdf(BuildContext context) async {
    HapticFeedback.mediumImpact();
    try {
      await PdfCardsGenerator.printSingleCard(
        code: code,
        courseTitle: courseTitle,
        teacherName: teacherName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تصدير الـ PDF: $e', style: GoogleFonts.cairo()),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── The Printable Horizontal Voucher Card ───────────────────
              PrintableVoucherCard(
                code: code,
                courseTitle: courseTitle,
                teacherName: teacherName,
              ),
              SizedBox(height: 14.h),

              // Instructional Note
              Text(
                '🖨️ كارت بمقاس الطباعة الرسمي (85×55 مم) مع كود الـ QR في الواجهة الأمامية.',
                style: GoogleFonts.cairo(
                  fontSize: 11.5.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),

              // Action Buttons (Print PDF & Copy & Close)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () => _printPdf(context),
                      icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'طباعة PDF',
                        style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      onPressed: () => _copy(context),
                      icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'نسخ الكود',
                        style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF94A3B8)),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
