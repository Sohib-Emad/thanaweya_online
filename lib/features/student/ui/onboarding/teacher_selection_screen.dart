import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
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
        appBar: AppBar(title: Text(AppStrings.selectTeachers)),
        body: BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.teachersStatus == StudentOnboardingStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.teachersStatus == StudentOnboardingStatus.error) {
              return Center(
                child: Text(state.errorMessage ?? 'حدث خطأ', style: AppTextStyles.body1),
              );
            }
            if (state.teachers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_rounded, size: 64, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text('لا يوجد معلمون متاحون', style: AppTextStyles.h3),
                  ],
                ),
              );
            }
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: state.teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = state.teachers[index];
                        final user = teacher['users'] as Map<String, dynamic>? ?? {};
                        final isSelected = _selectedIds.contains(teacher['id']);
                        final name = user['full_name'] as String? ?? '';
                        final initials = name.isNotEmpty ? name[0] : 'م';

                        return GestureDetector(
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
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.studentPrimaryLight : AppColors.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: isSelected ? AppColors.studentPrimary : AppColors.borderLight,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44.r,
                                  height: 44.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.studentPrimaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(initials,
                                        style: AppTextStyles.h3.copyWith(color: AppColors.studentPrimary)),
                                  ),
                                ),
                                SizedBox(width: 14.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: AppTextStyles.h3),
                                      SizedBox(height: 2.h),
                                      Text(
                                        (teacher['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '',
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: AppColors.studentPrimary, size: 22.r)
                                else
                                  Icon(Icons.add_circle_outline, color: AppColors.textTertiary, size: 22.r),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: '${AppStrings.next} (${_selectedIds.length})',
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : () => Navigator.pushNamed(context, AppRouter.studentForm),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
