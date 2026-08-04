import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/student/data/repos/student_reviews_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_reviews_cubit.dart';

import '../../../../core/router/app_router.dart';

class CourseReviewsScreen extends StatefulWidget {
  final String courseId;

  const CourseReviewsScreen({super.key, required this.courseId});

  @override
  State<CourseReviewsScreen> createState() => _CourseReviewsScreenState();
}

class _CourseReviewsScreenState extends State<CourseReviewsScreen> {
  int _selectedFilterIndex = 0;

  final _cubit = StudentReviewsCubit(repo: StudentReviewsRepo());

  final List<String> _filters = [
    'الكل (Excellent)',
    'ممتاز',
    'جيد جداً',
    'متوسط',
  ];

  static const List<Color> _avatarColors = [
    Color(0xFF0FA37F),
    Color(0xFF2563EB),
    Color(0xFFD97706),
    Color(0xFFEF4444),
  ];

  @override
  void initState() {
    super.initState();
    _cubit.loadReviews(widget.courseId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

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
            BlocBuilder<StudentReviewsCubit, StudentReviewsState>(
              bloc: _cubit,
              builder: (context, state) {
                final ratings = state.reviews
                    .map((r) => (r['rating'] as num?)?.toDouble() ?? 0)
                    .toList();
                final average = ratings.isEmpty
                    ? 0.0
                    : ratings.reduce((a, b) => a + b) / ratings.length;
                final averageStr = average.toStringAsFixed(1);
                return SingleChildScrollView(
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
                              averageStr,
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
                                  index < average.round()
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: const Color(0xFFFBBF24),
                                  size: 24.r,
                                ),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              'بناءً على ${state.reviews.length} تقييم من الطلاب',
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
                      if (state.status == StudentReviewsStatus.loading &&
                          state.reviews.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.reviews.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 64,
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'لا توجد تقييمات بعد',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'كن أول من يقيّم هذا الكورس!',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...state.reviews.asMap().entries.map((entry) {
                          final index = entry.key;
                          final rev = entry.value;
                          final user =
                              rev['users'] as Map<String, dynamic>? ?? {};
                          final name = user['full_name'] as String? ?? 'طالب';
                          final rating = (rev['rating'] as num?)?.toInt() ?? 0;
                          final comment = rev['text'] as String? ?? '';
                          final avatarColor =
                              _avatarColors[index % _avatarColors.length];
                          final avatarChar = name.isNotEmpty
                              ? name.substring(0, 1)
                              : 'ط';

                          return Container(
                            margin: EdgeInsets.only(bottom: 14.h),
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(
                                color: const Color(0xFFF1F5F9),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18.r,
                                          backgroundColor: avatarColor,
                                          child: Text(
                                            avatarChar,
                                            style: GoogleFonts.cairo(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          name,
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
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          ...List.generate(
                                            5,
                                            (i) => Icon(
                                              i < rating
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              color: const Color(0xFFD97706),
                                              size: 12.r,
                                            ),
                                          ),
                                          SizedBox(width: 3.w),
                                          Text(
                                            '$rating',
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
                                  comment,
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
                                      Icons.calendar_today_rounded,
                                      color: const Color(0xFF94A3B8),
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      _formatDate(rev['created_at'] as String?),
                                      style: GoogleFonts.cairo(
                                        fontSize: 11.sp,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
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
                    onPressed: () async {
                      HapticFeedback.selectionClick();
                      final result = await Navigator.pushNamed(
                        context,
                        AppRouter.studentWriteReview,
                        arguments: widget.courseId,
                      );
                      if (result == true) {
                        _cubit.loadReviews(widget.courseId);
                      }
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
