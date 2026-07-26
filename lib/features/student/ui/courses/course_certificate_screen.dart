import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class CourseCertificateScreen extends StatelessWidget {
  final String courseTitle;
  final String studentName;
  final String issueDate;
  final String certificateId;

  const CourseCertificateScreen({
    super.key,
    this.courseTitle = 'شرح مبادئ الفيزياء والتطبيق (3D Design)',
    this.studentName = 'أحمد محمد علي',
    this.issueDate = '24 نوفمبر 2024',
    this.certificateId = 'ID: SKH06900R',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            courseTitle,
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(left: 16.w),
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: AppColors.studentPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: AppColors.studentPrimary,
                size: 18.r,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.r),
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F0F172A),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: Stack(
                          children: [
                            // Top Right Organic Decorative Shape
                            Positioned(
                              top: -40,
                              right: -40,
                              child: Container(
                                width: 160.r,
                                height: 160.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A).withAlpha(180),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -20,
                              right: -10,
                              child: Container(
                                width: 120.r,
                                height: 120.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withAlpha(200),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                            // Bottom Left Decorative Shape
                            Positioned(
                              bottom: -30,
                              left: -30,
                              child: Container(
                                width: 140.r,
                                height: 140.r,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316).withAlpha(220),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),

                            // Main Certificate Contents
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 36.h,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Badge Icon
                                  Container(
                                    width: 72.r,
                                    height: 72.r,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF3B82F6),
                                        width: 2,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x203B82F6),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.workspace_premium_rounded,
                                        color: const Color(0xFF1D4ED8),
                                        size: 38.r,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 20.h),

                                  Text(
                                    'شهادة إتمام كورس',
                                    style: GoogleFonts.cairo(
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),

                                  SizedBox(height: 6.h),

                                  Text(
                                    'تشهد إدارة منصة الثانوية أونلاين بأن الطالب',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  SizedBox(height: 14.h),

                                  // Student Name
                                  Text(
                                    studentName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1D4ED8),
                                    ),
                                  ),

                                  SizedBox(height: 12.h),

                                  Text(
                                    'قد أتم بنجاح كافة متطلبات وااختبارات الكورس التعليمي:',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.sp,
                                      color: const Color(0xFF475569),
                                      height: 1.4,
                                    ),
                                  ),

                                  SizedBox(height: 10.h),

                                  // Course Title Box
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 10.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14.r),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Text(
                                      courseTitle,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.cairo(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16.h),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'تاريخ الإصدار: $issueDate',
                                        style: GoogleFonts.cairo(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Container(
                                        width: 4,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFCBD5E1),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Text(
                                        certificateId,
                                        style: GoogleFonts.cairo(
                                          fontSize: 11.sp,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 24.h),

                                  const Divider(color: Color(0xFFF1F5F9)),

                                  SizedBox(height: 12.h),

                                  // Signatures Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'أ. د. أسامة الإبرشي',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          Text(
                                            'مدرس الكورس المعتمد',
                                            style: GoogleFonts.cairo(
                                              fontSize: 10.sp,
                                              color: const Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'مدير المنصة  ',
                                            style: GoogleFonts.cairo(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.studentPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            'م. صهيب عماد',
                                            style: GoogleFonts.cairo(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                              color: const Color.fromARGB(
                                                255,
                                                0,
                                                0,
                                                0,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Download Button
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 20.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تحميل الشهادة بنجاح بصيغة PDF 🎓',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          backgroundColor: const Color(0xFF0FA37F),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      elevation: 4,
                      shadowColor: const Color(0x332563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'تحميل الشهادة (Download Certificate)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 34.r,
                          height: 34.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            color: const Color(0xFF2563EB),
                            size: 18.r,
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
      ),
    );
  }
}
