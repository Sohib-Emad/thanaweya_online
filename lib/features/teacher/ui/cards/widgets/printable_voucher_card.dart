import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Clean White Printable Card (85x55mm Ratio) with front-face QR code for physical printing.
class PrintableVoucherCard extends StatelessWidget {
  final String code;
  final String courseTitle;
  final String teacherName;

  const PrintableVoucherCard({
    super.key,
    required this.code,
    required this.courseTitle,
    required this.teacherName,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header: Platform Brand ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                      ),
                      child: Image.asset(
                        'assets/icons/icon_Thanaweya_Online.png',
                        width: 22.r,
                        height: 22.r,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.school_rounded,
                          color: const Color(0xFF0284C7),
                          size: 20.r,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'منصة ثانوية أونلاين',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'كارت شحن واشتراك رسمي معتمد',
                          style: GoogleFonts.cairo(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withAlpha(25),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: Text(
                    '★ كارت أصلي',
                    style: GoogleFonts.cairo(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFB45309),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),

            // ─── Center: Main Info + QR Code in Front Face ─────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left Column: The Big QR Code
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: code,
                        version: QrVersions.auto,
                        size: 92.r,
                        backgroundColor: Colors.white,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xFF0F172A),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'امسح بالكاميرا 📷',
                        style: GoogleFonts.cairo(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),

                // Right Column: Teacher, Course, and Activation Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teacher Info
                      Row(
                        children: [
                          Icon(Icons.person_pin_rounded, color: const Color(0xFF0284C7), size: 14.r),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'المعلم: $teacherName',
                              style: GoogleFonts.cairo(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // Course Title
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded, color: const Color(0xFFF59E0B), size: 13.r),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              'الكورس: $courseTitle',
                              style: GoogleFonts.cairo(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF334155),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Highlighted Code Box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFF0284C7), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'كود التفعيل (Activation Code)',
                              style: GoogleFonts.cairo(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0284C7),
                              ),
                            ),
                            SelectableText(
                              code,
                              style: GoogleFonts.robotoMono(
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF0284C7),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // ─── Footer: Website & Support ─────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🌐 thanaweya-online.com',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0284C7),
                    ),
                  ),
                  Text(
                    'الدعم: 01096462825 📞',
                    style: GoogleFonts.cairo(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
