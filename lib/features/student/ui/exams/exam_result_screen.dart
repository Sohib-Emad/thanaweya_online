import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';

class ExamResultScreen extends StatelessWidget {
  final Map<String, dynamic>? resultData;

  const ExamResultScreen({super.key, this.resultData});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        resultData ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {});

    final int score = args['score'] ?? 4;
    final int total = args['total'] ?? 5;
    final bool autoSubmitted = args['autoSubmitted'] ?? false;
    final bool isTimeOut = args['isTimeOut'] ?? false;
    final double percent = (score / total) * 100;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            'نتيجة الامتحان',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 30.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Auto Submitted Alert Warning Banner
                if (autoSubmitted) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: const Color(0xFFE11D48),
                          size: 24.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'تنبيه: تم تسليم الامتحان تلقائياً بسبب مغادرة الشاشة أو تصغير التطبيق أثناء التقييم.',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF9F1239),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                if (isTimeOut) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_off_rounded,
                          color: const Color(0xFFD97706),
                          size: 24.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'تم تسليم الامتحان تلقائياً بانتهاء الوقت المخصص للحل.',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Result Circle Badge
                Container(
                  width: 110.r,
                  height: 110.r,
                  decoration: BoxDecoration(
                    color: percent >= 50
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFF1F2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: percent >= 50
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11D48),
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      percent >= 50
                          ? Icons.emoji_events_rounded
                          : Icons.sentiment_dissatisfied_rounded,
                      size: 54.r,
                      color: percent >= 50
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11D48),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                Text(
                  percent >= 50
                      ? 'مبارك! أتممت الامتحان بنجاح 🏆'
                      : 'للأسف، لم تتجاوز النسبة المطلوبة ⚠️',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),

                SizedBox(height: 12.h),

                Text(
                  '$score / $total',
                  style: GoogleFonts.cairo(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w900,
                    color: percent >= 50
                        ? AppColors.studentPrimary
                        : const Color(0xFFE11D48),
                  ),
                ),

                SizedBox(height: 6.h),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: percent >= 50
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'النسبة المئوية: ${percent.toStringAsFixed(0)}%',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: percent >= 50
                          ? const Color(0xFF10B981)
                          : const Color(0xFFE11D48),
                    ),
                  ),
                ),

                SizedBox(height: 36.h),

                // Return Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Text(
                      'العودة لقائمة الامتحانات',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
