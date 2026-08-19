import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_reviews_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_reviews_cubit.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/review_hint_banner.dart';
import 'widgets/star_rating_selector.dart';

class WriteReviewScreen extends StatefulWidget {
  final String courseId;

  const WriteReviewScreen({super.key, required this.courseId});

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _ratingStars = 5;
  final _reviewTextController = TextEditingController();
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
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.writeReviewTitle, subtitle: l10n.writeReviewSubtitle),
      body: Stack(
        children: [
          NotebookPaper(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 120.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReviewHintBanner(message: l10n.reviewHelpsOthers),
                  SizedBox(height: 22.h),
                  NotebookSectionHeader(title: l10n.yourRatingQuestion),
                  SizedBox(height: 16.h),
                  StarRatingSelector(rating: _ratingStars, onChanged: (v) => setState(() => _ratingStars = v)),
                  SizedBox(height: 28.h),
                  NotebookSectionHeader(title: l10n.detailedReviewTitle),
                  SizedBox(height: 12.h),
                  _buildTextArea(l10n),
                ],
              ),
            ),
          ),
          _buildSubmitButton(l10n),
        ],
      ),
    );
  }

  Widget _buildTextArea(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(38)),
      ),
      child: TextField(
        controller: _reviewTextController,
        maxLines: 5,
        style: NotebookText.body(13.sp),
        decoration: InputDecoration(
          hintText: l10n.reviewHint,
          hintStyle: NotebookText.note(12.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(14.r),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: SafeArea(
        child: NotebookPrimaryButton(
          label: l10n.submitReview,
          icon: Icons.send_rounded,
          onPressed: () async {
            HapticFeedback.heavyImpact();
            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);
            final userId = Supabase.instance.client.auth.currentUser?.id;
            if (userId == null || widget.courseId.isEmpty) {
              _showSnackBar(messenger, l10n.mustLoginFirst);
              return;
            }
            final saved = await _cubit.saveMyReview(
              studentId: userId,
              courseId: widget.courseId,
              rating: _ratingStars,
              text: _reviewTextController.text.trim(),
            );
            if (!mounted) return;
            _showSnackBar(messenger, saved ? l10n.reviewSubmitted : l10n.reviewSubmitError, success: saved);
            if (saved) navigator.pop(true);
          },
        ),
      ),
    );
  }

  void _showSnackBar(ScaffoldMessengerState messenger, String msg, {bool success = false}) {
    messenger.showSnackBar(SnackBar(
      content: Text(msg, style: NotebookText.strong(13.sp, color: Colors.white)),
      backgroundColor: success ? NotebookColors.green : const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
