import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_reviews_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_reviews_cubit.dart';

import '../../../../core/theme/notebook_theme.dart';

class WriteReviewScreen extends StatefulWidget {
  final String courseId;

  const WriteReviewScreen({super.key, required this.courseId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _ratingStars = 5;
  final TextEditingController _reviewTextController = TextEditingController();
  final _cubit = StudentReviewsCubit(repo: StudentReviewsRepo());

  @override
  void initState() {
    super.initState();
    _prefillMyReview();
  }

  @override
  void dispose() {
    _cubit.close();
    _reviewTextController.dispose();
    super.dispose();
  }

  Future<void> _prefillMyReview() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || widget.courseId.isEmpty) return;
    await _cubit.loadMyReview(userId, widget.courseId);
    if (!mounted) return;
    final state = _cubit.state;
    setState(() {
      if (state.myRating > 0) _ratingStars = state.myRating;
      if (state.myText.isNotEmpty) _reviewTextController.text = state.myText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'كتابة تقييم',
          subtitle: 'اكتب رأيك بخط يدك',
        ),
        body: Stack(
          children: [
            NotebookPaper(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 120.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotebookHighlightNote(
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: NotebookColors.ink,
                            size: 16.r,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'تقييمك يساعد زملاءك على اختيار الكورس المناسب',
                              style: NotebookText.strong(12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 22.h),

                    // Rating Stars Selector
                    const NotebookSectionHeader(title: 'ما هو تقييمك للكورس؟'),
                    SizedBox(height: 16.h),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _ratingStars = index + 1);
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 4.w),
                              child: Icon(
                                index < _ratingStars
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: const Color(0xFFF59E0B),
                                size: 40.r,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Write Review TextArea
                    const NotebookSectionHeader(
                      title: 'اكتب تقييمك بالتفصيل',
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        color: NotebookColors.surface,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: NotebookColors.ink.withAlpha(38),
                        ),
                      ),
                      child: TextField(
                        controller: _reviewTextController,
                        maxLines: 5,
                        style: NotebookText.body(13.sp),
                        decoration: InputDecoration(
                          hintText:
                              'ما هي تجربتك مع هذا الكورس والمدرس؟ شارك برأيك لمساعدة بقية الطلاب...',
                          hintStyle: NotebookText.note(12.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Submit Button at bottom
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: NotebookPrimaryButton(
                  label: 'إرسال التقييم',
                  icon: Icons.send_rounded,
                  onPressed: () async {
                    HapticFeedback.heavyImpact();
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null || widget.courseId.isEmpty) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'يجب تسجيل الدخول أولاً',
                            style: NotebookText.strong(
                              13.sp,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: const Color(0xFFEF4444),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    final saved = await _cubit.saveMyReview(
                      studentId: userId,
                      courseId: widget.courseId,
                      rating: _ratingStars,
                      text: _reviewTextController.text.trim(),
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          saved
                              ? 'تم إرسال تقييمك بنجاح'
                              : 'حدث خطأ أثناء إرسال التقييم، حاول مرة أخرى',
                          style: NotebookText.strong(
                            13.sp,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: saved
                            ? NotebookColors.green
                            : const Color(0xFFEF4444),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    if (saved) {
                      navigator.pop(true);
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
