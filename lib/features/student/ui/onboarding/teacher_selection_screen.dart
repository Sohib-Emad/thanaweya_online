import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_onboarding_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_onboarding_cubit.dart';

class TeacherSelectionScreen extends StatefulWidget {
  const TeacherSelectionScreen({super.key});

  @override
  State<TeacherSelectionScreen> createState() => _TeacherSelectionScreenState();
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: AppStrings.selectTeachers,
          subtitle: 'اختر المدرسين الذين تريد متابعتهم',
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
              return SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Center(
                    child: NotebookEmptyNote(
                      message: state.errorMessage ?? 'حدث خطأ',
                    ),
                  ),
                ),
              );
            }
            if (state.teachers.isEmpty) {
              return SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Center(
                    child: NotebookEmptyNote(
                      message: 'لا يوجد معلمون متاحون',
                    ),
                  ),
                ),
              );
            }
            return SafeArea(
              top: false,
              child: NotebookPaper(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                        physics: const BouncingScrollPhysics(),
                        itemCount: state.teachers.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final teacher = state.teachers[index];
                          final user =
                              teacher['users'] as Map<String, dynamic>? ?? {};
                          final isSelected =
                              _selectedIds.contains(teacher['id']);
                          final name = user['full_name'] as String? ?? '';

                          return NotebookCard(
                            ruled: true,
                            ruledStartY: 32,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                if (isSelected) {
                                  _selectedIds.remove(teacher['id']);
                                } else {
                                  _selectedIds.add(teacher['id'] as String);
                                }
                              });
                            },
                            child: Row(
                              children: [
                                NotebookTeacherAvatar(
                                  avatarUrl:
                                      user['avatar_url'] as String?,
                                  name: name,
                                  size: 42.r,
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: NotebookText.strong(13.sp),
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        (teacher['subjects']
                                                as Map<String, dynamic>?)?['name_ar']
                                            as String? ??
                                            '',
                                        style: NotebookText.note(11.sp),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  width: 24.r,
                                  height: 24.r,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? NotebookColors.green
                                        : NotebookColors.surfaceBright,
                                    borderRadius: BorderRadius.circular(6.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? NotebookColors.green
                                          : NotebookColors.ink.withAlpha(50),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(Icons.check_rounded,
                                          size: 16.r, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: NotebookPrimaryButton(
                        label: '${AppStrings.next} (${_selectedIds.length})',
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
          },
        ),
      ),
    );
  }
}
