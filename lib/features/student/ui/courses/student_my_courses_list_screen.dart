import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class StudentMyCoursesListScreen extends StatefulWidget {
  const StudentMyCoursesListScreen({super.key});

  @override
  State<StudentMyCoursesListScreen> createState() =>
      _StudentMyCoursesListScreenState();
}

class _StudentMyCoursesListScreenState
    extends State<StudentMyCoursesListScreen> {
  int _selectedTab = 1; // 0 = Completed, 1 = Ongoing

  final List<Map<String, dynamic>> _ongoingCourses = [
    {
      'subject': 'الفيزياء الكهربية',
      'title': 'مبادئ الفيزياء والتطبيق للثانوية',
      'progress': 0.75,
      'completedCount': 75,
      'totalCount': 100,
      'rating': '4.8',
      'enrolledCount': '7830 طالب',
      'color': const Color(0xFF0FA37F),
    },
    {
      'subject': 'البرمجة وتطوير الويب',
      'title': 'دورة تصميم المواقع الإلكترونية بالكامل',
      'progress': 0.50,
      'completedCount': 50,
      'totalCount': 100,
      'rating': '4.9',
      'enrolledCount': '12400 طالب',
      'color': const Color(0xFFEA580C),
    },
    {
      'subject': 'الرياضيات والـ UI/UX',
      'title': 'تصميم الواجهات 3D Blender والهندسة',
      'progress': 0.20,
      'completedCount': 4,
      'totalCount': 20,
      'rating': '4.7',
      'enrolledCount': '3200 طالب',
      'color': const Color(0xFF2563EB),
    },
    {
      'subject': 'علم النفس والإنسان',
      'title': 'دراسة دراسات تجربة المستخدم UX Personas',
      'progress': 0.10,
      'completedCount': 1,
      'totalCount': 10,
      'rating': '4.8',
      'enrolledCount': '5100 طالب',
      'color': const Color(0xFF7C3AED),
    },
  ];

  final List<Map<String, dynamic>> _completedCourses = [
    {
      'subject': 'الكيمياء العضوية',
      'title': 'تفاعلات المركبات العضوية والهيدروكربونات',
      'progress': 1.0,
      'completedCount': 100,
      'totalCount': 100,
      'rating': '4.9',
      'enrolledCount': '15200 طالب',
      'color': const Color(0xFF0FA37F),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentList =
        _selectedTab == 1 ? _ongoingCourses : _completedCourses;

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
            'دوراتي التعليمية (My Courses)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          children: [
            // Search Bar + Filter Icon
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'ابحث في دوراتك...',
                          hintStyle: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: const Color(0xFF94A3B8),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFF94A3B8),
                            size: 20.r,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, AppRouter.studentFilter);
                    },
                    child: Container(
                      width: 48.r,
                      height: 48.r,
                      decoration: BoxDecoration(
                        color: AppColors.studentPrimary,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x200FA37F),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 22.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pills Tab Switcher (Completed / Ongoing)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? AppColors.studentPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(26.r),
                          ),
                          child: Text(
                            'المكتملة (Completed)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? AppColors.studentPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(26.r),
                          ),
                          child: Text(
                            'مستمر (Ongoing)',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Courses List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
                physics: const BouncingScrollPhysics(),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final course = currentList[index];
                  final color = course['color'] as Color;
                  final double progress = course['progress'];
                  final int done = course['completedCount'];
                  final int total = course['totalCount'];

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (_selectedTab == 0) {
                        Navigator.pushNamed(context, AppRouter.studentCertificate);
                      } else {
                        Navigator.pushNamed(context, AppRouter.studentCurriculum);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x080F172A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Thumbnail Box
                          Container(
                            width: 86.r,
                            height: 86.r,
                            decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: color,
                                size: 36.r,
                              ),
                            ),
                          ),

                          SizedBox(width: 14.w),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course['subject'],
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  course['title'],
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),

                                // Progress Line + Ratio
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6.h,
                                          backgroundColor:
                                              const Color(0xFFE2E8F0),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            color,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      '$done/$total',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 6.h),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: const Color(0xFFF59E0B),
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      course['rating'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Icon(
                                      Icons.people_outline_rounded,
                                      color: const Color(0xFF94A3B8),
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      course['enrolledCount'],
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
