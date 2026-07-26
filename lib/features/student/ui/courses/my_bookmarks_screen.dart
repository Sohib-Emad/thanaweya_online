import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';

class MyBookmarksScreen extends StatefulWidget {
  const MyBookmarksScreen({super.key});

  @override
  State<MyBookmarksScreen> createState() => _MyBookmarksScreenState();
}

class _MyBookmarksScreenState extends State<MyBookmarksScreen> {
  int _selectedCategoryIndex = 1;

  final List<String> _categories = [
    'الكل',
    'الفيزياء',
    'الرياضيات',
    'الأحياء',
    'الكيمياء',
  ];

  final List<Map<String, dynamic>> _bookmarkedCourses = [
    {
      'subject': 'الفيزياء الكهربية',
      'title': 'مبادئ وتطبيقات الفيزياء الكهربية والدوائر',
      'price': '700 ج.م',
      'rating': '4.8',
      'studentsCount': '7830 طالب',
      'bgColor': const Color(0xFF0FA37F),
    },
    {
      'subject': 'الرياضيات البحرية',
      'title': 'شرح التفاضل والتكامل بالتفصيل وحل المسائل',
      'price': '400 ج.م',
      'rating': '4.9',
      'studentsCount': '12550 طالب',
      'bgColor': const Color(0xFF2563EB),
    },
    {
      'subject': 'الأحياء والوراثة',
      'title': 'علم الجينات والتكاثر في الكائنات الحية',
      'price': '550 ج.م',
      'rating': '4.7',
      'studentsCount': '3240 طالب',
      'bgColor': const Color(0xFFEF4444),
    },
    {
      'subject': 'الكيمياء العضوية',
      'title': 'تفاعلات المركبات العضوية والهيدروكربونات',
      'price': '850 ج.م',
      'rating': '4.8',
      'studentsCount': '14500 طالب',
      'bgColor': const Color(0xFFD97706),
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
            'محفوظاتي (My Bookmarks)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 14.h),

            // Horizontal Filter Chips
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategoryIndex = index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF0FA37F) : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF0FA37F) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index],
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Bookmarked Course Cards List
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                physics: const BouncingScrollPhysics(),
                itemCount: _bookmarkedCourses.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final course = _bookmarkedCourses[index];
                  final subject = course['subject'] as String;
                  final title = course['title'] as String;
                  final price = course['price'] as String;
                  final rating = course['rating'] as String;
                  final studentsCount = course['studentsCount'] as String;
                  final bgColor = course['bgColor'] as Color;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, AppRouter.studentCourseDetails);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Course Thumbnail Box
                          Container(
                            width: 100.r,
                            height: 100.r,
                            decoration: BoxDecoration(
                              color: bgColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: bgColor,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      subject,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: bgColor,
                                      ),
                                    ),
                                    Icon(
                                      Icons.bookmark_rounded,
                                      color: const Color(0xFF0FA37F),
                                      size: 20.r,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Text(
                                      price,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w900,
                                        color: const Color(0xFF2563EB),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Icon(Icons.star_rounded, color: const Color(0xFFFBBF24), size: 14.r),
                                    SizedBox(width: 2.w),
                                    Text(
                                      rating,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '| $studentsCount',
                                      style: GoogleFonts.cairo(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF94A3B8),
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
