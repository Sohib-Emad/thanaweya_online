import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_onboarding_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_onboarding_cubit.dart';
import 'package:thanaweya_online/features/student/ui/onboarding/widgets/baccalaureate_tracks_list.dart';
import 'package:thanaweya_online/features/student/ui/onboarding/widgets/general_subjects_list.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen for selecting subjects, supporting both general and
/// baccalaureate systems.
class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() =>
      _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  late final StudentOnboardingCubit _cubit;
  int _selectedSystemIndex = 0;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _cubit = StudentOnboardingCubit(repo: StudentOnboardingRepo());
    _cubit.loadSubjects();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _toggleId(String id) {
    setState(() {
      _selectedIds.contains(id)
          ? _selectedIds.remove(id)
          : _selectedIds.add(id);
    });
  }

  void _goNext() {
    HapticFeedback.lightImpact();
    for (final id in _selectedIds) {
      _cubit.selectSubject(id);
    }
    Navigator.pushNamed(context, AppRouter.studentTeachers);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: l10n.selectSubjects,
          subtitle: l10n.selectSubjectsSubtitle,
        ),
        body: SafeArea(
          top: false,
          child: NotebookPaper(
            child: Column(
              children: [
                SizedBox(height: 12.h),
                _buildSegmentSwitcher(l10n),
                SizedBox(height: 14.h),
                Expanded(child: _buildContent(l10n)),
                _buildNextButton(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentSwitcher(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: NotebookSegmentControl(
        options: [l10n.generalSystem, l10n.baccalaureateSystem],
        index: _selectedSystemIndex,
        onChanged: (i) {
          if (i != _selectedSystemIndex) {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedSystemIndex = i;
              _selectedIds.clear();
            });
          }
        },
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    if (_selectedSystemIndex != 0) {
      return BaccalaureateTracksList(
        selectedIds: _selectedIds,
        onToggle: _toggleId,
      );
    }
    return GeneralSubjectsContent(
      selectedIds: _selectedIds,
      onToggle: _toggleId,
      onRetry: () => _cubit.loadSubjects(),
    );
  }

  Widget _buildNextButton(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 20.h),
      child: NotebookPrimaryButton(
        label: l10n.nextWithCount(_selectedIds.length),
        onPressed: _selectedIds.isEmpty ? null : _goNext,
      ),
    );
  }
}
