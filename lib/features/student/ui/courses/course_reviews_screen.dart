import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/features/student/data/repos/student_reviews_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_reviews_cubit.dart';

import '../../../../core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/review_filter_bar.dart';
import 'widgets/review_item_card.dart';
import 'widgets/review_overall_card.dart';

class CourseReviewsScreen extends StatefulWidget {
  final String courseId;

  const CourseReviewsScreen({super.key, required this.courseId});

  @override
  State<CourseReviewsScreen> createState() => _CourseReviewsScreenState();
}

class _CourseReviewsScreenState extends State<CourseReviewsScreen> {
  int _selectedFilterIndex = 0;
  final _cubit = StudentReviewsCubit(repo: StudentReviewsRepo());

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [l10n.all, l10n.excellent, l10n.veryGood, l10n.average];

    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.studentReviewsTitle, subtitle: l10n.reviewsSubtitle),
      body: Stack(
        children: [
          NotebookPaper(
            child: BlocBuilder<StudentReviewsCubit, StudentReviewsState>(
              bloc: _cubit,
              builder: (context, state) {
                final ratings = state.reviews
                    .map((r) => (r['rating'] as num?)?.toDouble() ?? 0)
                    .toList();
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ReviewOverallCard.fromRatings(ratings, countLabel: ''),
                      SizedBox(height: 20.h),
                      ReviewFilterBar(
                        labels: filters,
                        selectedIndex: _selectedFilterIndex,
                        onSelected: (i) => setState(() => _selectedFilterIndex = i),
                      ),
                      SizedBox(height: 20.h),
                      _buildReviewsList(state, l10n),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildAddReviewButton(l10n),
        ],
      ),
    );
  }

  Widget _buildReviewsList(StudentReviewsState state, AppLocalizations l10n) {
    if (state.status == StudentReviewsStatus.loading && state.reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 48.h),
        child: Center(child: CircularProgressIndicator(color: NotebookColors.green)),
      );
    }
    if (state.reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: NotebookEmptyNote(icon: Icons.rate_review_outlined, message: l10n.noReviewsYet),
      );
    }
    return Column(
      children: state.reviews.asMap().entries.map((entry) {
        final rev = entry.value;
        final user = rev['users'] as Map<String, dynamic>? ?? {};
        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: ReviewItemCard(
            name: user['full_name'] as String? ?? 'طالب',
            rating: (rev['rating'] as num?)?.toInt() ?? 0,
            comment: rev['text'] as String? ?? '',
            date: rev['created_at'] as String?,
            index: entry.key,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddReviewButton(AppLocalizations l10n) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: SafeArea(
        child: NotebookPrimaryButton(
          label: l10n.addYourReview,
          icon: Icons.edit_rounded,
          onPressed: () async {
            HapticFeedback.selectionClick();
            final result = await Navigator.pushNamed(
              context, AppRouter.studentWriteReview, arguments: widget.courseId,
            );
            if (result == true) _cubit.loadReviews(widget.courseId);
          },
        ),
      ),
    );
  }
}
