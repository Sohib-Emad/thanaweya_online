import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Displays the exam body or loading/error states based on cubit state.
class ExamContentBuilder extends StatelessWidget {
  final dynamic state;
  final Widget Function(dynamic state) onReady;
  final String loadErrorText;
  final String backLabel;

  const ExamContentBuilder({
    super.key,
    required this.state,
    required this.onReady,
    required this.loadErrorText,
    required this.backLabel,
  });

  @override
  Widget build(BuildContext context) {
    final statusName = state.examStatus.toString();
    if (statusName.contains('loading')) {
      return Center(
        child: CircularProgressIndicator(color: NotebookColors.green),
      );
    }
    if (statusName.contains('error') || state.currentQuestions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NotebookEmptyNote(
                icon: Icons.error_outline_rounded,
                message: state.errorMessage ?? loadErrorText,
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: 200.w,
                child: NotebookPrimaryButton(
                  label: backLabel,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return onReady(state);
  }
}
