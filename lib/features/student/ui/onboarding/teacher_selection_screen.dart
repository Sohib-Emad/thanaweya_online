import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_onboarding_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_onboarding_cubit.dart';
import 'package:thanaweya_online/features/student/ui/onboarding/widgets/teacher_card.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen for selecting teachers from the available list.
class TeacherSelectionScreen extends StatefulWidget {
  const TeacherSelectionScreen({super.key});

  @override
  State<TeacherSelectionScreen> createState() =>
      _TeacherSelectionScreenState();
}

class _TeacherSelectionScreenState extends State<TeacherSelectionScreen> {
  final _cubit = StudentOnboardingCubit(repo: StudentOnboardingRepo());
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _cubit.loadTeachers();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _toggleTeacher(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.selectTeachers,
        subtitle: l10n.selectTeachersSubtitle,
      ),
      body: BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.teachersStatus == StudentOnboardingStatus.loading) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: NotebookColors.green,
              ),
            );
          }
          if (state.teachersStatus == StudentOnboardingStatus.error) {
            return _buildSafeNote(l10n.error);
          }
          if (state.teachers.isEmpty) {
            return _buildSafeNote(l10n.noTeachersAvailable);
          }
          return _buildTeacherList(l10n, state.teachers);
        },
      ),
    );
  }

  Widget _buildSafeNote(String message) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Center(child: NotebookEmptyNote(message: message)),
      ),
    );
  }

  Widget _buildTeacherList(
    AppLocalizations l10n,
    List<Map<String, dynamic>> teachers,
  ) {
    return SafeArea(
      top: false,
      child: NotebookPaper(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                physics: const BouncingScrollPhysics(),
                itemCount: teachers.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final teacher = teachers[index];
                  final user =
                      teacher['users'] as Map<String, dynamic>? ?? {};
                  final name = user['full_name'] as String? ?? '';
                  return TeacherCard(
                    name: name,
                    avatarUrl: user['avatar_url'] as String?,
                    subjectName:
                        (teacher['subjects'] as Map<String, dynamic>?)?[
                                'name_ar']
                            as String? ??
                            '',
                    isSelected: _selectedIds.contains(teacher['id']),
                    onTap: () =>
                        _toggleTeacher(teacher['id'] as String),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: NotebookPrimaryButton(
                label: l10n.nextWithCount(_selectedIds.length),
                onPressed: _selectedIds.isEmpty
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          AppRouter.studentForm,
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
