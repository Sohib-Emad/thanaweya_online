import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';

class ExamStartScreen extends StatelessWidget {
  final Map<String, dynamic>? examData;

  const ExamStartScreen({super.key, this.examData});

  @override
  Widget build(BuildContext context) {
    final title = examData?['title'] as String? ?? 'امتحان شامل';
    final durationMinutes = examData?['duration_minutes'] as int? ?? 0;
    final duration = '$durationMinutes دقيقة';
    final questions = examData?['questions'];
    final questionsCount =
        (questions is List && questions.isNotEmpty
                ? (questions.first['count'] as int?) ?? 0
                : 0)
            .toString();
    final totalMarks = '${examData?['max_score'] ?? 0} درجة';
    final teachers = examData?['teachers'];
    final users = teachers is Map ? teachers['users'] : null;
    final instructor =
        users is Map ? (users['full_name'] as String? ?? '') : '';
    final examId = examData?['id'] as String? ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'تعليمات وضوابط الامتحان',
          subtitle: 'اقرأ القواعد قبل بدء التقييم',
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exam Header Card
                NotebookCard(
                  ruled: true,
                  ruledStartY: 104,
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      Container(
                        width: 60.r,
                        height: 60.r,
                        decoration: BoxDecoration(
                          color: NotebookColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.quiz_rounded,
                          color: Colors.white,
                          size: 28.r,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: NotebookText.heading(17.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'المدرس المسؤول: ${instructor.isEmpty ? 'المدرس' : instructor}',
                        style: NotebookText.note(11.sp),
                      ),

                      SizedBox(height: 16.h),
                      Container(
                        height: 1,
                        color: NotebookColors.ink.withAlpha(35),
                      ),
                      SizedBox(height: 12.h),

                      // Quick Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'المدة الزمنية',
                            duration,
                            Icons.timer_outlined,
                          ),
                          _buildStatItem(
                            'عدد الأسئلة',
                            questionsCount,
                            Icons.help_outline_rounded,
                          ),
                          _buildStatItem(
                            'الدرجة الكلية',
                            totalMarks,
                            Icons.stars_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Strict Rules & Anti-Cheat Regulations Warning
                NotebookSectionHeader(title: 'قواعد وضوابط الامتحان'),
                SizedBox(height: 8.h),
                NotebookHighlightNote(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.gavel_rounded,
                            color: NotebookColors.marginRed,
                            size: 18.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'ضوابط حازمة، قراءتها إلزامية قبل البدء',
                            style: NotebookText.strong(
                              12.sp,
                              color: NotebookColors.marginRed,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      _buildRuleItem(
                        'توقيت دقيق محدد',
                        'يبدأ التوقيت فور دخول الامتحان، وسيتم تسليم الإجابات تلقائياً فور انتهاء الوقت.',
                      ),
                      SizedBox(height: 8.h),
                      _buildRuleItem(
                        'حظر الخروج من الشاشة (تسليم تلقائي)',
                        'في حالة الخروج من التطبيق، تصغير الشاشة، أو الانتقال لتطبيق آخر، سيتم تسليم الامتحان فوراً وحساب الدرجة على ما تم حله فقط!',
                      ),
                      SizedBox(height: 8.h),
                      _buildRuleItem(
                        'الحفاظ على استقرار الاتصال',
                        'تأكد من شحن الهاتف واستقرار شبكة الإنترنت قبل البدء.',
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 28.h),

                // Start Exam Primary Button
                NotebookPrimaryButton(
                  label: 'بدء الامتحان الآن',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _showStartConfirmationDialog(context, examId);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: NotebookColors.green, size: 20.r),
        SizedBox(height: 6.h),
        Text(value, style: NotebookText.strong(13.sp)),
        SizedBox(height: 2.h),
        Text(label, style: NotebookText.note(10.sp)),
      ],
    );
  }

  Widget _buildRuleItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: NotebookText.strong(12.sp, color: NotebookColors.marginRed),
        ),
        SizedBox(height: 2.h),
        Text(
          desc,
          style: NotebookText.body(11.sp).copyWith(height: 1.4),
        ),
      ],
    );
  }

  void _showStartConfirmationDialog(BuildContext context, String examId) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: NotebookColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: NotebookColors.marginRed,
                size: 26.r,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'تأكيد بدء الامتحان',
                  style: NotebookText.heading(16.sp),
                ),
              ),
            ],
          ),
          content: Text(
            'بمجرد الضغط على "بدء"، سيبدأ التوقيت ولا يمكن إيقافه، وسيتم حظر مغادرة الشاشة وإلا سيتم تسليم إجاباتك فوراً. هل أنت جاهز؟',
            style: NotebookText.body(13.sp,
                    color: NotebookColors.pencil)
                .copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: NotebookText.strong(
                  13.sp,
                  color: NotebookColors.pencil,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacementNamed(
                  context,
                  AppRouter.studentExamTaking,
                  arguments: {'examId': examId},
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NotebookColors.marginRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'بدء الامتحان الآن',
                style: NotebookText.strong(13.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
