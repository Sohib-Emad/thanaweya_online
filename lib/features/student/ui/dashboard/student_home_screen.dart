import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/student/ui/exams/exams_list_screen.dart';
import 'package:thanaweya_online/features/student/ui/courses/student_my_courses_list_screen.dart';
import 'package:thanaweya_online/features/student/ui/transactions/student_transactions_screen.dart';
import 'package:thanaweya_online/features/student/ui/profile/student_profile_tab.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  late final PageController _adPageController;
  int _activeAdIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _studentEnrolledCourses = [
    {
      'title': 'مراجعة الفيزياء الكهربية والشحنات',
      'teacher': 'أ. محمد علي',
      'subject': 'الفيزياء ⚡',
      'progress': 0.75,
      'progressPercent': '75%',
      'completedLessons': '15 من أصل 20 درس',
      'isActivated': true,
      'color': const Color(0xFF0FA37F),
    },
    {
      'title': 'شرح الرياضيات العامة والبحثة',
      'teacher': 'أ. سارة أحمد',
      'subject': 'الرياضيات 📐',
      'progress': 0.40,
      'progressPercent': '40%',
      'completedLessons': '8 من أصل 20 درس',
      'isActivated': true,
      'color': const Color(0xFF2563EB),
    },
  ];

  final List<Map<String, dynamic>> _popularTeachersList = [
    {
      'name': 'أ. كاسي فالديز',
      'subject': 'الأحياء والعلوم الحيوية',
      'bgColor': const Color(0xFFFEE2E2),
      'initials': 'ك',
    },
    {
      'name': 'أ. بول سايمونز',
      'subject': 'الكيمياء العامة',
      'bgColor': const Color(0xFF334155),
      'initials': 'ب',
      'textColor': Colors.white,
    },
    {
      'name': 'أ. جراهام أوسبورن',
      'subject': 'الفيزياء الكهربية',
      'bgColor': const Color(0xFFFEF3C7),
      'initials': 'ج',
    },
    {
      'name': 'أ. سارة أحمد',
      'subject': 'الرياضيات والهندسة',
      'bgColor': const Color(0xFFE0F2FE),
      'initials': 'س',
    },
  ];

  final List<Map<String, dynamic>> _subjectCategories = [
    {
      'title': 'الرياضيات',
      'coursesCount': '25 كورس',
      'icon': Icons.calculate_rounded,
      'color': const Color(0xFFEFF6FF),
      'iconColor': const Color(0xFF2563EB),
    },
    {
      'title': 'الأحياء',
      'coursesCount': '15 كورس',
      'icon': Icons.biotech_rounded,
      'color': const Color(0xFFECFDF5),
      'iconColor': const Color(0xFF0FA37F),
    },
    {
      'title': 'الفيزياء',
      'coursesCount': '25 كورس',
      'icon': Icons.electric_bolt_rounded,
      'color': const Color(0xFFFEE2E2),
      'iconColor': const Color(0xFFEF4444),
    },
    {
      'title': 'الكيمياء',
      'coursesCount': '20 كورس',
      'icon': Icons.science_rounded,
      'color': const Color(0xFFFEF3C7),
      'iconColor': const Color(0xFFD97706),
    },
    {
      'title': 'اللغة العربية',
      'coursesCount': '18 كورس',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFF3E8FF),
      'iconColor': const Color(0xFF9333EA),
    },
    {
      'title': 'اللغة الإنجليزية',
      'coursesCount': '22 كورس',
      'icon': Icons.language_rounded,
      'color': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
    },
  ];

  @override
  void initState() {
    super.initState();
    _adPageController = PageController(viewportFraction: 0.94);
  }

  @override
  void dispose() {
    _adPageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildHomeDashboardTab(context),
              const StudentMyCoursesListScreen(),
              const StudentTransactionsScreen(),
              const StudentExamsListScreen(),
              const StudentProfileTab(isTabMode: true),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  // ─── TAB 0: HOME DASHBOARD ───
  Widget _buildHomeDashboardTab(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Header ──
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك، طالب 👋',
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'ما الذي تريد تعلمه اليوم؟',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.notifications),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0FA37F).withAlpha(60),
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: const Color(0xFF0FA37F),
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // ── 2. Search Bar (Unified Container) ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  SizedBox(width: 14.w),
                  Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 22.r,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        color: const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مادة أو دورة أو مدرس...',
                        hintStyle: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, AppRouter.studentFilter);
                    },
                    child: Container(
                      margin: EdgeInsets.all(4.r),
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0FA37F),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── 3. Promo Banner ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0FA37F), Color(0xFF047857)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  child: Stack(
                    children: [
                      // decorative circles
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(20),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 30,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(15),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(40),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                'خصم 25% على جميع الكورسات',
                                style: GoogleFonts.cairo(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'عرض اليوم الخاص!',
                              style: GoogleFonts.cairo(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'اشترك الآن واحصل على خصم على\nأي كورس لمدة محدودة',
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                color: Colors.white.withAlpha(210),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFBBF24),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // ── 4. Categories ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المواد الدراسية',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'الكل',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF0FA37F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: const Color(0xFF0FA37F),
                          size: 16.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _subjectCategories.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final cat = _subjectCategories[index];
                  final isFirst = index == 0;
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: isFirst
                            ? const Color(0xFF0FA37F)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isFirst
                              ? const Color(0xFF0FA37F)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          cat['title'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: isFirst
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 24.h),

            // ── 5. Popular Courses ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الكورسات الشائعة',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'الكل',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF0FA37F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: const Color(0xFF0FA37F),
                          size: 16.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            // Filter chips
            SizedBox(
              height: 34.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                children:
                    [
                      'الكل',
                      'الفيزياء',
                      'الرياضيات',
                      'الأحياء',
                      'الكيمياء',
                    ].asMap().entries.map((e) {
                      final selected = e.key == 0;
                      return Container(
                        margin: EdgeInsets.only(left: 8.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF0FA37F)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF0FA37F)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            e.value,
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            SizedBox(height: 14.h),
            // Course cards (horizontal scroll)
            SizedBox(
              height: 210.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _studentEnrolledCourses.length,
                separatorBuilder: (_, __) => SizedBox(width: 14.w),
                itemBuilder: (context, index) {
                  final course = _studentEnrolledCourses[index];
                  final title = course['title'] as String;
                  final teacher = course['teacher'] as String;
                  final subject = (course['subject'] as String)
                      .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
                      .trim();
                  final color = course['color'] as Color;
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.studentCourseDetails,
                    ),
                    child: Container(
                      width: 170.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail
                          Container(
                            height: 100.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16.r),
                              ),
                              color: color.withAlpha(30),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                color: color,
                                size: 40.r,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      subject,
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRouter.studentBookmarks,
                                      ),
                                      child: Icon(
                                        Icons.bookmark_border_rounded,
                                        size: 16.r,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Text(
                                      '150 جنيه',
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Icon(
                                      Icons.star_rounded,
                                      color: const Color(0xFFFBBF24),
                                      size: 13.r,
                                    ),
                                    Text(
                                      ' 4.8',
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      '| ${teacher.split('.').last.trim()}',
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      overflow: TextOverflow.ellipsis,
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

            SizedBox(height: 24.h),

            // ── 6. Top Mentors ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'أفضل المدرسين',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'الكل',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF0FA37F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Icon(
                          Icons.chevron_left_rounded,
                          color: const Color(0xFF0FA37F),
                          size: 16.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 110.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _popularTeachersList.length,
                separatorBuilder: (_, __) => SizedBox(width: 16.w),
                itemBuilder: (context, index) {
                  final teacher = _popularTeachersList[index];
                  final name = teacher['name'] as String;
                  final initials = teacher['initials'] as String;
                  final bgColor = teacher['bgColor'] as Color;
                  final textColor =
                      teacher['textColor'] as Color? ?? const Color(0xFF0F172A);
                  final firstName = name.replaceAll('أ. ', '').split(' ').first;
                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.studentTeacherPage,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 62.r,
                          height: 62.r,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: GoogleFonts.cairo(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          firstName,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEnrolledCoursesProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'الكورسات الحالية',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Text(
              '${_studentEnrolledCourses.length} دورات نشطة',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0FA37F),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _studentEnrolledCourses.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final course = _studentEnrolledCourses[index];
            final title = course['title'] as String;
            final teacher = course['teacher'] as String;
            final subject = (course['subject'] as String)
                .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
                .trim();
            final progress = course['progress'] as double;
            final progressPercent = course['progressPercent'] as String;
            final completedLessons = course['completedLessons'] as String;
            final color = course['color'] as Color;

            return Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x040F172A),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: color.withAlpha(20),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          subject,
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                      Text(
                        teacher,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Progress Bar & Percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تم إنهاء $completedLessons',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        progressPercent,
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6.h,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Continue Learning Button
                  SizedBox(
                    width: double.infinity,
                    height: 40.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(
                          context,
                          AppRouter.studentVideoPlayer,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      icon: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20.r,
                      ),
                      label: Text(
                        'متابعة الدراسة',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── LINKEDIN LEARNING STYLE HELPER WIDGETS ───

  // Featured Hero Card (Like LinkedIn Featured Card in screenshot)
  Widget _buildLinkedInFeaturedCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRouter.studentVideoPlayer);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x040F172A),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail graphic box with Featured pill badge
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'دورة مميزة • FEATURED',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0FA37F),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: Colors.white.withAlpha(200),
                      size: 48.r,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفيزياء الكهربية وتطبيقات كيرشوف في الثانوية العامة',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'أستاذ محمد علي • مجهّزة وفق نظام البوكليت الحديث',
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
      ),
    );
  }

  // Recommended Courses Section (Trending for your grade)
  Widget _buildLinkedInRecommendedSection() {
    final List<Map<String, dynamic>> recommended = [
      {
        'title': 'التفاضل والتكامل والشحنات التفاضلية',
        'teacher': 'أستاذة سارة أحمد',
        'badge': 'شائع • POPULAR',
        'duration': '14 درس • 4.5 ساعة',
        'color': const Color(0xFF2563EB),
      },
      {
        'title': 'الكيمياء العضوية ومجموعات الألكان',
        'teacher': 'أستاذ بول سايمونز',
        'badge': 'جديد • NEW',
        'duration': '10 دروس • 3 ساعات',
        'color': const Color(0xFF7C3AED),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'موصى به لصفك الدراسي (Recommended)',
              style: GoogleFonts.cairo(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _currentIndex = 1);
              },
              child: Text(
                'عرض الكل',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0FA37F),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 175.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recommended.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = recommended[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, AppRouter.studentVideoPlayer);
                },
                child: Container(
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color).withAlpha(30),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10.r),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.movie_creation_outlined,
                            color: item['color'] as Color,
                            size: 32.r,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['badge'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: item['color'] as Color,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item['title'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item['duration'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 10.sp,
                                color: const Color(0xFF64748B),
                              ),
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
    );
  }

  // Experts / Popular Teachers Section (Content by Experts)
  Widget _buildLinkedInExpertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'خبراء ومدرسو المادة (Content by Experts)',
          style: GoogleFonts.cairo(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _popularTeachersList.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final t = _popularTeachersList[index];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, AppRouter.studentTeacherPage);
                },
                child: Container(
                  width: 100.w,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: t['bgColor'] as Color,
                        child: Text(
                          t['initials'] as String,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color:
                                (t['textColor'] as Color?) ??
                                const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        t['name'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        t['subject'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 9.sp,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── TAB 1: EXPLORE LESSONS & CATEGORIES (03 Lesson Design) ───
  Widget _buildExploreLessonsTab(BuildContext context) {
    return Column(
      children: [
        // Colored Top Header with Search Bar
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: AppColors.studentPrimary,
                        size: 22.r,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            hintText: 'ابحث عن درس أو مادة أو معلم...',
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 48.r,
                height: 48.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.studentPrimary,
                  size: 22.r,
                ),
              ),
            ],
          ),
        ),

        // White Curved Sheet Container
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 100.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'المواد الدراسية 📖',
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'عرض الكل',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.studentPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),

                    // Grid 2x3 Categories
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14.w,
                        mainAxisSpacing: 14.h,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _subjectCategories.length,
                      itemBuilder: (context, index) {
                        final cat = _subjectCategories[index];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(
                              context,
                              AppRouter.studentCourseLessons,
                              arguments: 'c1',
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x060F172A),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48.r,
                                  height: 48.r,
                                  decoration: BoxDecoration(
                                    color: cat['color'] as Color,
                                    borderRadius: BorderRadius.circular(16.r),
                                  ),
                                  child: Icon(
                                    cat['icon'] as IconData,
                                    color: cat['iconColor'] as Color,
                                    size: 26.r,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  cat['title'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  cat['coursesCount'] as String,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF94A3B8),
                                  ),
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
          ),
        ),
      ],
    );
  }

  // ─── TAB 3: PROFILE & SETTINGS (05 Profile Design) ───
  Widget _buildProfileTab(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الملف الشخصي 👤',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF0F172A),
                    size: 20.r,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // User Info Header Card with Edit Button
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
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
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppColors.studentPrimaryLight,
                    child: Icon(
                      Icons.person_rounded,
                      size: 32.r,
                      color: AppColors.studentPrimary,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سارة أحمد',
                          style: GoogleFonts.cairo(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'طالبة • الصف الثالث الثانوي',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.studentPrimary,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      'تعديل',
                      style: GoogleFonts.cairo(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // 2 Metric Stat Cards Side-by-Side (80 Lessons / 12 Subjects)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    decoration: BoxDecoration(
                      color: AppColors.studentPrimary,
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x200FA37F),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '80',
                          style: GoogleFonts.cairo(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'درساً مكتمل',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    decoration: BoxDecoration(
                      color: AppColors.studentPrimary,
                      borderRadius: BorderRadius.circular(22.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x200FA37F),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '12',
                          style: GoogleFonts.cairo(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'مادة دراسية',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Account Settings Section (إعدادات الحساب)
            Text(
              'إعدادات الحساب (Account Settings)',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 10.h),

            _SettingsOptionRow(
              icon: Icons.person_outline_rounded,
              title: 'تعديل الملف الشخصي',
              onTap: () {},
            ),
            SizedBox(height: 10.h),
            _SettingsOptionRow(
              icon: Icons.email_outlined,
              title: 'تغيير البريد الإلكتروني',
              onTap: () {},
            ),
            SizedBox(height: 10.h),
            _SettingsOptionRow(
              icon: Icons.lock_outline_rounded,
              title: 'تغيير كلمة المرور',
              onTap: () {},
            ),

            SizedBox(height: 24.h),

            // Other Section (أخرى)
            Text(
              'أخرى (Other)',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 10.h),

            _SettingsOptionRow(
              icon: Icons.notifications_none_rounded,
              title: 'الإشعارات والتنبيهات',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.notifications);
              },
            ),
            SizedBox(height: 10.h),
            _SettingsOptionRow(
              icon: Icons.history_edu_rounded,
              title: 'سجل الدرجات والامتحانات',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.studentGradeHistory);
              },
            ),

            SizedBox(height: 28.h),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRouter.roleSelection,
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
                  side: const BorderSide(color: Color(0xFFFCA5A5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                icon: Icon(Icons.logout_rounded, size: 20.r),
                label: Text(
                  'تسجيل الخروج',
                  style: GoogleFonts.cairo(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TEACHER AD CAROUSEL WIDGET ───
  Widget _buildTeacherAdCarousel() {
    final adImagePaths = [
      '/Users/sohibemad/.gemini/antigravity-ide/brain/d86763e5-7ec8-4674-8af8-67124dfdd647/teacher_ad_math_1784853258532.png',
      '/Users/sohibemad/.gemini/antigravity-ide/brain/d86763e5-7ec8-4674-8af8-67124dfdd647/teacher_ad_physics_1784853280105.png',
      '/Users/sohibemad/.gemini/antigravity-ide/brain/d86763e5-7ec8-4674-8af8-67124dfdd647/teacher_ad_science_1784853304564.png',
    ];

    return Column(
      children: [
        SizedBox(
          height: 165.h,
          child: PageView.builder(
            controller: _adPageController,
            itemCount: MockData.mockTeachers.length,
            onPageChanged: (index) {
              setState(() => _activeAdIndex = index);
            },
            itemBuilder: (context, index) {
              final teacher = MockData.mockTeachers[index];
              final user = teacher['users'] as Map<String, dynamic>;
              final name = user['full_name'] as String;
              final subject = teacher['subject_id'] as String;
              final imageFile = File(adImagePaths[index % adImagePaths.length]);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, AppRouter.studentTeacherPage);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22.r),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x180F172A),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22.r),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: imageFile.existsSync()
                              ? Image.file(imageFile, fit: BoxFit.cover)
                              : Container(color: AppColors.studentPrimary),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withAlpha(210),
                                  Colors.black.withAlpha(80),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 16.w,
                          bottom: 16.h,
                          left: 16.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 3.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.studentPrimary,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Text(
                                      'إعلان معلم • $subject',
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 17.sp,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'عرض التفاصيل 👈',
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.studentPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            MockData.mockTeachers.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _activeAdIndex == index ? 20.w : 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                color: _activeAdIndex == index
                    ? AppColors.studentPrimary
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── INBOX TAB ───
  Widget _buildInboxTab(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            color: const Color(0xFF0F172A),
            child: Row(
              children: [
                Text(
                  'الرسائل',
                  style: GoogleFonts.cairo(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64.r,
                    color: const Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'لا توجد رسائل حتى الآن',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM NAVIGATION BAR (5 Tabs - Matching User Image) ───
  Widget _buildBottomNavBar(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 60 + bottomPad,
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8EDF2), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'HOME',
            isSelected: _currentIndex == 0,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 0);
            },
          ),
          _NavBarItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: 'MY COURSES',
            isSelected: _currentIndex == 1,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 1);
            },
          ),
          _NavBarItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            label: 'TRANSACTION',
            isSelected: _currentIndex == 2,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 2);
            },
          ),
          _NavBarItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'EXAMS',
            isSelected: _currentIndex == 3,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 3);
            },
          ),
          _NavBarItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'PROFILE',
            isSelected: _currentIndex == 4,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 4);
            },
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF0FA37F);
    const inactiveColor = Color(0xFF1E2D3D);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 8,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : inactiveColor,
                height: 1.2,
                package: 'google_fonts',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsOptionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              color: const Color(0xFF94A3B8),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}
