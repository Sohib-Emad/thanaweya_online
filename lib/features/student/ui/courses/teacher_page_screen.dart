import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/router/app_router.dart';

class TeacherPageScreen extends StatefulWidget {
  const TeacherPageScreen({super.key});

  @override
  State<TeacherPageScreen> createState() => _TeacherPageScreenState();
}

class _TeacherPageScreenState extends State<TeacherPageScreen> {
  int _activeTab = 0; // 0 = Lessons, 1 = Quiz

  final List<Map<String, dynamic>> _lessonsList = [
    {
      'id': 'l1',
      'part': 'الجزء 01',
      'title': 'البناء الضوئي والتغذية (Photosynthesis)',
      'duration': '25 دقيقة',
      'icon': Icons.eco_rounded,
    },
    {
      'id': 'l2',
      'part': 'الجزء 02',
      'title': 'النتح والتنفس الخلوي (Transpiration)',
      'duration': '18 دقيقة',
      'icon': Icons.water_drop_rounded,
    },
    {
      'id': 'l3',
      'part': 'الجزء 03',
      'title': 'العوامل المؤثرة في نمو النباتات',
      'duration': '30 دقيقة',
      'icon': Icons.wb_sunny_rounded,
    },
  ];

  final List<Map<String, dynamic>> _quizzesList = [
    {
      'id': 'q1',
      'part': 'اختبار الجزء 01',
      'title': 'كويز على البناء الضوئي',
      'questions': '10 أسئلة • 15 دقيقة',
      'icon': Icons.quiz_rounded,
    },
    {
      'id': 'q2',
      'part': 'اختبار الجزء 02',
      'title': 'كويز على النتح والتنفس الخلوي',
      'questions': '12 سؤالاً • 20 دقيقة',
      'icon': Icons.assignment_rounded,
    },
    {
      'id': 'q3',
      'part': 'اختبار الجزء 03',
      'title': 'الاختبار الشامل للفصل الثاني',
      'questions': '25 سؤالاً • 40 دقيقة',
      'icon': Icons.verified_rounded,
    },
  ];

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
          leading: IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF0F172A),
              size: 30.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'الأحياء - فسيولوجيا النبات 🌿',
            style: GoogleFonts.cairo(
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Illustration Graphic (Plant Physiology Banner)
                    Container(
                      width: double.infinity,
                      height: 160.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(24.r),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?q=80&w=600&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(160),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 18.h),

                    // Topic Title & Subtitle
                    Text(
                      'فسيولوجيا النبات 🌱',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'تعلم كيف تنمو النباتات وامتصاص الماء والغذاء وإنتاج الأكسجين.',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Segmented Tab Switcher (Lesson vs Quiz)
                    Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _activeTab = 0);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: _activeTab == 0
                                      ? AppColors.studentPrimary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.play_circle_outline_rounded,
                                      size: 18.r,
                                      color: _activeTab == 0
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'الدروس (Lesson)',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: _activeTab == 0
                                            ? Colors.white
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _activeTab = 1);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: _activeTab == 1
                                      ? AppColors.studentPrimary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.quiz_outlined,
                                      size: 18.r,
                                      color: _activeTab == 1
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'الامتحانات (Quiz)',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: _activeTab == 1
                                            ? Colors.white
                                            : const Color(0xFF64748B),
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

                    SizedBox(height: 20.h),

                    // Active Tab Content List
                    _activeTab == 0
                        ? _buildLessonsListView(context)
                        : _buildQuizzesListView(context),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Primary Button
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (_activeTab == 0) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.studentVideoPlayer,
                        arguments: {
                          'lessonId': 'l1',
                          'videoUrl': 'demo',
                          'title': 'البناء الضوئي والتغذية',
                        },
                      );
                    } else {
                      Navigator.pushNamed(context, AppRouter.studentExamStart);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.studentPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                  child: Text(
                    _activeTab == 0
                        ? 'ابدأ الدرس (Start Lesson) 🚀'
                        : 'ابدأ الاختبار (Start Quiz) 📝',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 07 Detail Lesson List
  Widget _buildLessonsListView(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _lessonsList.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = _lessonsList[index];

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(
              context,
              AppRouter.studentVideoPlayer,
              arguments: {
                'lessonId': item['id'],
                'videoUrl': 'demo',
                'title': item['title'],
              },
            );
          },
          child: Container(
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
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.studentPrimaryLight,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: AppColors.studentPrimary,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['part']} • ${item['title']}',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'المدة: ${item['duration']}',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.studentPrimary,
                    size: 20.r,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 08 Detail Quiz List
  Widget _buildQuizzesListView(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _quizzesList.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = _quizzesList[index];

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, AppRouter.studentExamStart);
          },
          child: Container(
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
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: const Color(0xFFD97706),
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item['part']} • ${item['title']}',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        item['questions'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: const Color(0xFFD97706),
                    size: 20.r,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
