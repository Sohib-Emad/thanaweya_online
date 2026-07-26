import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/core/router/app_router.dart';

class StudentExamsListScreen extends StatefulWidget {
  const StudentExamsListScreen({super.key});

  @override
  State<StudentExamsListScreen> createState() => _StudentExamsListScreenState();
}

class _StudentExamsListScreenState extends State<StudentExamsListScreen> {
  final List<Map<String, dynamic>> _dailyStreak = [
    {'day': 'الأحد', 'isDone': true},
    {'day': 'الإثنين', 'isDone': true},
    {'day': 'الثلاثاء', 'isDone': true},
    {'day': 'الأربعاء', 'isDone': true},
    {'day': 'الخميس', 'isDone': false, 'count': '5'},
    {'day': 'الجمعة', 'isDone': false, 'count': '6'},
    {'day': 'السبت', 'isDone': false, 'count': '7'},
  ];

  final List<double> _weeklyHours = [2.5, 4.0, 3.0, 1.5, 3.5, 2.0, 4.5];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'التقدم والامتحانات 📊',
            style: GoogleFonts.cairo(
              fontSize: 19.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                size: 22.r,
                color: const Color(0xFF0F172A),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.bookmark_outline_rounded,
                size: 22.r,
                color: const Color(0xFF0F172A),
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.tune_rounded,
                size: 22.r,
                color: const Color(0xFF0F172A),
              ),
              onPressed: () {},
            ),
            SizedBox(width: 6.w),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: MockData.mockExams.length,
                itemBuilder: (context, index) {
                  final exam = MockData.mockExams[index];
                  final title = exam['title'] as String;
                  final duration = '${exam['duration_minutes']} دقيقة';

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(
                        context,
                        AppRouter.studentExamStart,
                        arguments: {
                          'title': title,
                          'duration': duration,
                          'questionsCount': '30 سؤال',
                          'totalMarks': '${exam['max_score']} درجة',
                        },
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x060F172A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Icon(
                                  Icons.quiz_rounded,
                                  color: const Color(0xFF2563EB),
                                  size: 22.r,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'المدرس: أ. محمد علي • مادة الفيزياء',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          SizedBox(height: 12.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    size: 14.r,
                                    color: const Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    duration,
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Icon(
                                    Icons.help_outline_rounded,
                                    size: 14.r,
                                    color: const Color(0xFF64748B),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '30 سؤال',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'دخول الامتحان',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 12.r,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MasteryLegendItem extends StatelessWidget {
  final String title;
  final Color color;

  const _MasteryLegendItem({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
