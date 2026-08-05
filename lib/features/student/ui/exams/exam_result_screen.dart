import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

class ExamResultScreen extends StatelessWidget {
  final Map<String, dynamic>? resultData;

  const ExamResultScreen({super.key, this.resultData});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        resultData ??
        (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {});

    final int score = args['score'] ?? 0;
    final int total = args['total'] ?? 0;
    final bool autoSubmitted = args['autoSubmitted'] ?? false;
    final bool isTimeOut = args['isTimeOut'] ?? false;
    final double percent = total > 0 ? (score / total) * 100 : 0;
    final isPass = percent >= 50;
    final accent = isPass ? NotebookColors.green : NotebookColors.marginRed;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'نتيجة الامتحان',
          subtitle: isPass ? 'تم التقييم وحفظ الدرجة' : 'جرى التقييم بنجاح',
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Auto Submitted Alert Warning Banner
                if (autoSubmitted) ...[
                  NotebookHighlightNote(
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: NotebookColors.marginRed,
                          size: 20.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'تنبيه: تم تسليم الامتحان تلقائياً بسبب مغادرة الشاشة أو تصغير التطبيق أثناء التقييم.',
                            style: NotebookText.strong(11.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                if (isTimeOut) ...[
                  NotebookHighlightNote(
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_off_rounded,
                          color: NotebookColors.marginRed,
                          size: 20.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'تم تسليم الامتحان تلقائياً بانتهاء الوقت المخصص للحل.',
                            style: NotebookText.strong(11.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],

                // Result Paper Card with a red stamp
                NotebookCard(
                  ruled: true,
                  ruledStartY: 132,
                  padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 26.r),
                  child: Column(
                    children: [
                      NotebookStamp(label: 'نتيجة'),
                      SizedBox(height: 14.h),

                      Text(
                        '$score / $total',
                        style: NotebookText.heading(40.sp, color: accent),
                      ),

                      SizedBox(height: 8.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withAlpha(30),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'النسبة المئوية: ${percent.toStringAsFixed(0)}%',
                          style: NotebookText.strong(13.sp, color: accent),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        isPass
                            ? 'مبارك، اجتزت الامتحان بنجاح'
                            : 'لم تتجاوز النسبة المطلوبة',
                        textAlign: TextAlign.center,
                        style: NotebookText.heading(18.sp),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 36.h),

                // Return Button
                NotebookPrimaryButton(
                  label: 'العودة لقائمة الامتحانات',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
