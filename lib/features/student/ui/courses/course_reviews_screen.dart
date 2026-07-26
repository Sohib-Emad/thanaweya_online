import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';

class CourseReviewsScreen extends StatefulWidget {
  const CourseReviewsScreen({super.key});

  @override
  State<CourseReviewsScreen> createState() => _CourseReviewsScreenState();
}

class _CourseReviewsScreenState extends State<CourseReviewsScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    'الكل (Excellent)',
    'ممتاز',
    'جيد جداً',
    'متوسط',
  ];

  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'هيثم عبد الفتاح',
      'avatar': 'هـ',
      'bgColor': const Color(0xFF0FA37F),
      'rating': '4.8',
      'comment':
          'الكورس مميز جداً وشرح المستر مبسط وسهل الفهم لجميع المستويات. المستر شرح قانون كيرشوف بطريقة أسطورية!',
      'likes': '152',
      'date': 'منذ أسبوعين',
    },
    {
      'name': 'منة الله أحمد',
      'avatar': 'م',
      'bgColor': const Color(0xFF2563EB),
      'rating': '4.5',
      'comment':
          'الشرح رائع ومفيد جداً، والملخصات الـ PDF كانت مساعدة جداً في المراجعة قبل الامتحان.',
      'likes': '98',
      'date': 'منذ أسبوعين',
    },
    {
      'name': 'مصطفى كامل',
      'avatar': 'مـ',
      'bgColor': const Color(0xFFD97706),
      'rating': '4.8',
      'comment': 'أفضل كورس فيزياء على الإطلاق! أتمنى التوفيق للجميع.',
      'likes': '210',
      'date': 'منذ 3 أسابيع',
    },
    {
      'name': 'فريدة السيد',
      'avatar': 'ف',
      'bgColor': const Color(0xFFEF4444),
      'rating': '4.6',
      'comment':
          'طريقة إلقاء المحاضرات ممتازة وحل الأسئلة التطبيقية يعطي ثقة كبيرة للطالب.',
      'likes': '120',
      'date': 'منذ شهر',
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
            'تقييمات وآراء الطلاب (Reviews)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Overall Rating Hero Card
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x06000000),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '4.8',
                          style: GoogleFonts.cairo(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFFBBF24),
                              size: 24.r,
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'بناءً على 468 تقييم من الطلاب',
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Filter Chips
                  SizedBox(
                    height: 38.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFilterIndex == index;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedFilterIndex = index);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF0FA37F)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF0FA37F)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _filters[index],
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
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

                  SizedBox(height: 20.h),

                  // Reviews List
                  ..._reviews.map(
                    (rev) => Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18.r,
                                    backgroundColor: rev['bgColor'] as Color,
                                    child: Text(
                                      rev['avatar'] as String,
                                      style: GoogleFonts.cairo(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    rev['name'] as String,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: const Color(0xFFD97706),
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      rev['rating'] as String,
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            rev['comment'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              color: const Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: Colors.redAccent,
                                size: 16.r,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                rev['likes'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Text(
                                rev['date'] as String,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky Bottom Write a Review Button
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pushNamed(
                        context,
                        AppRouter.studentWriteReview,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      elevation: 4,
                      shadowColor: const Color(0x330FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Text(
                          'أضف تقييمك ورأيك (Write a Review)',
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_rounded,
                            color: const Color(0xFF0FA37F),
                            size: 20.r,
                          ),
                        ),
                      ],
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
}
