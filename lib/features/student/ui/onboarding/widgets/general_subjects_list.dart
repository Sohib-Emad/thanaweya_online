import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/logic/student_onboarding_cubit.dart';
import 'package:thanaweya_online/features/student/ui/onboarding/widgets/selection_widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Bloc-driven content that loads general subjects and displays them
/// with loading, error, and empty states.
class GeneralSubjectsContent extends StatelessWidget {
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;
  final VoidCallback onRetry;

  const GeneralSubjectsContent({
    super.key,
    required this.selectedIds,
    required this.onToggle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        if (state.status == StudentOnboardingStatus.loading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: NotebookColors.green,
            ),
          );
        }
        if (state.status == StudentOnboardingStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: NotebookEmptyNote(
                    message: state.errorMessage ?? l10n.loadSubjectsError,
                  ),
                ),
                SizedBox(height: 16.h),
                NotebookPrimaryButton(
                  label: l10n.retry,
                  onPressed: onRetry,
                  expanded: false,
                ),
              ],
            ),
          );
        }
        if (state.subjects.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: NotebookEmptyNote(message: l10n.noSubjectsAvailable),
          );
        }
        return GeneralSubjectsList(
          subjects: state.subjects,
          selectedIds: selectedIds,
          onToggle: onToggle,
        );
      },
    );
  }
}

/// Scrollable list of general-system subjects with multi-select.
class GeneralSubjectsList extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const GeneralSubjectsList({
    super.key,
    required this.subjects,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: subjects.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final subjectId = subject['id'] as String;
        final subjectName = subject['name_ar'] as String? ?? '';
        final isSelected = selectedIds.contains(subjectId);

        return NotebookCard(
          ruled: true,
          ruledStartY: 30,
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle(subjectId);
          },
          child: SelectionRow(label: subjectName, isSelected: isSelected),
        );
      },
    );
  }
}
