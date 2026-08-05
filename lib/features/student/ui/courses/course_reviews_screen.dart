import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/features/student/data/repos/student_reviews_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_reviews_cubit.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';

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
    'الكل',
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
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'تقييمات الطلاب',
          subtitle: 'آراء حقيقية على صفحات الدفتر',
        ),
        body: Stack(
          children: [
            NotebookPaper(
              child: BlocBuilder<StudentReviewsCubit, StudentReviewsState>(
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
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Overall Rating Hero Card
                        NotebookCard(
                          ruled: true,
                          ruledStartY: 110,
                          marginTab: true,
                          padding: EdgeInsets.symmetric(
                            vertical: 18.h,
                            horizontal: 16.w,
                          ),
                          child: Column(
                            children: [
                              Text(
                                averageStr,
                                style: NotebookText.heading(36.sp),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: List.generate(
                                  5,
                                  (index) => Icon(
                                    index < average.round()
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: const Color(0xFFF59E0B),
                                    size: 24.r,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'بناءً على ${state.reviews.length} تقييم من الطلاب',
                                style: NotebookText.note(11.sp),
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
                              final isSelected =
                                  _selectedFilterIndex == index;
                              return NotebookChip(
                                label: _filters[index],
                                selected: isSelected,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(
                                    () => _selectedFilterIndex = index,
                                  );
                                },
                              );
                            },
                          ),
                        ),

                        SizedBox(height: 20.h),

                        // Reviews List
                        if (state.status ==
                                StudentReviewsStatus.loading &&
                            state.reviews.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: NotebookColors.green,
                              ),
                            ),
                          )
                        else if (state.reviews.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: NotebookEmptyNote(
                              icon: Icons.rate_review_outlined,
                              message:
                                  'لا توجد تقييمات بعد — كن أول من يقيّم هذا الكورس',
                            ),
                          )
                        else
                          ...state.reviews.asMap().entries.map((entry) {
                            final index = entry.key;
                            final rev = entry.value;
                            final user =
                                rev['users'] as Map<String, dynamic>? ?? {};
                            final name =
                                user['full_name'] as String? ?? 'طالب';
                            final rating =
                                (rev['rating'] as num?)?.toInt() ?? 0;
                            final comment = rev['text'] as String? ?? '';
                            final avatarColor = _avatarColors[
                                index % _avatarColors.length];
                            final avatarChar = name.isNotEmpty
                                ? name.substring(0, 1)
                                : 'ط';

                            return Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: NotebookCard(
                                ruled: true,
                                ruledStartY: 88,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 36.r,
                                              height: 36.r,
                                              decoration: BoxDecoration(
                                                color: avatarColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  avatarChar,
                                                  style: NotebookText.strong(
                                                    14.sp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              name,
                                              style:
                                                  NotebookText.strong(13.sp),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8.w,
                                            vertical: 3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Row(
                                            children: [
                                              ...List.generate(
                                                5,
                                                (i) => Icon(
                                                  i < rating
                                                      ? Icons.star_rounded
                                                      : Icons
                                                          .star_border_rounded,
                                                  color: const Color(
                                                      0xFFF59E0B,
                                                  ),
                                                  size: 11.r,
                                                ),
                                              ),
                                              SizedBox(width: 3.w),
                                              Text(
                                                '$rating',
                                                style: NotebookText.strong(
                                                  11.sp,
                                                  color: const Color(
                                                      0xFFB45309),
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
                                      style: NotebookText.body(13.sp),
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: NotebookColors.pencil,
                                          size: 13.r,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          _formatDate(
                                            rev['created_at'] as String?,
                                          ),
                                          style: NotebookText.note(11.sp),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Sticky Bottom Add Review Button
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: NotebookPrimaryButton(
                  label: 'أضف تقييمك',
                  icon: Icons.edit_rounded,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
