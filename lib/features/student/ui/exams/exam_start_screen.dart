import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';

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
            'تعليمات وضوابط الامتحان',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exam Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.quiz_rounded,
                        color: const Color(0xFF2563EB),
                        size: 32.r,
                      ),
                    ),

                    SizedBox(height: 14.h),

                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'المدرس المسؤول: ${instructor.isEmpty ? 'المدرس' : instructor}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),

                    SizedBox(height: 16.h),
                    const Divider(color: Color(0xFFF1F5F9)),
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

              // Strict Rules & Anti-Cheat Regulations Warning Card (Matching User Request)
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.gavel_rounded,
                          color: const Color(0xFFE11D48),
                          size: 22.r,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'قواعد وضوابط الامتحان الحازمة (مهم جداً):',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF9F1239),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),

                    _buildRuleItem(
                      '⏱️ توقيت دقيق محدد',
                      'يبدأ التوقيت فور دخول الامتحان، وسيتم تسليم الإجابات تلقائياً فور انتهاء الوقت.',
                    ),
                    SizedBox(height: 8.h),
                    _buildRuleItem(
                      '🚨 حظر الخروج من الشاشة (تسليم تلقائي)',
                      'في حالة الخروج من التطبيق، تصغير الشاشة، أو الانتقال لتطبيق آخر، سيتم تسليم الامتحان فوراً وحساب الدرجة على ما تم حله فقط!',
                    ),
                    SizedBox(height: 8.h),
                    _buildRuleItem(
                      '📱 الحفاظ على استقرار الاتصال',
                      'تأكد من شحن الهاتف واستقرار شبكة الإنترنت قبل البدء.',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // Start Exam Primary Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _showStartConfirmationDialog(context, examId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    elevation: 4,
                    shadowColor: const Color(0x33E11D48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'بدء الامتحان الآن (Start Exam Now)',
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: const Color(0xFFE11D48),
                          size: 20.r,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2563EB), size: 20.r),
        SizedBox(height: 4.h),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10.sp,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF881337),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          desc,
          style: GoogleFonts.cairo(
            fontSize: 11.sp,
            color: const Color(0xFF9F1239),
            height: 1.4,
          ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFE11D48),
                size: 26.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'تأكيد بدء الامتحان',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            'بمجرد الضغط على "بدء"، سيبدأ التوقيت ولا يمكن إيقافه، وسيتم حظر مغادرة الشاشة وإلا سيتم تسليم إجاباتك فوراً. هل أنت جاهز؟',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
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
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'بدء الامتحان الآن 🚀',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
