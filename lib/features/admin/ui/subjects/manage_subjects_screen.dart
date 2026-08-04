import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_subjects_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_subjects_cubit.dart';

class ManageSubjectsScreen extends StatefulWidget {
  const ManageSubjectsScreen({super.key});

  @override
  State<ManageSubjectsScreen> createState() => _ManageSubjectsScreenState();
}

class _ManageSubjectsScreenState extends State<ManageSubjectsScreen> {
  final _cubit = AdminSubjectsCubit(repo: AdminSubjectsRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadSubjects();
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
        appBar: AppBar(
          title: const Text(AppStrings.manageSubjects),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddDialog,
            ),
          ],
        ),
        body: BlocBuilder<AdminSubjectsCubit, AdminSubjectsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminSubjectsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.subjects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_outlined, size: 56.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text('لا توجد مواد', style: AppTextStyles.body2),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadSubjects(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.subjects.length,
                itemBuilder: (context, index) {
                  final subject = state.subjects[index];
                  final subjectId = subject['id'] as String? ?? '';
                  final nameAr = subject['name_ar'] as String? ?? '';

                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: AppColors.studentPrimaryLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.menu_book_outlined, color: AppColors.studentPrimary, size: 20.r),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Text(nameAr, style: AppTextStyles.h3),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 20.r, color: AppColors.error),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _cubit.deleteSubject(subjectId);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddDialog() {
    final nameArController = TextEditingController();
    final nameEnController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة مادة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: nameArController, labelText: 'الاسم بالعربي'),
            SizedBox(height: 12.h),
            AppTextField(controller: nameEnController, labelText: 'الاسم بالإنجليزي'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.cancel)),
          TextButton(
            onPressed: () {
              if (nameArController.text.isNotEmpty && nameEnController.text.isNotEmpty) {
                HapticFeedback.lightImpact();
                _cubit.addSubject(
                  nameAr: nameArController.text.trim(),
                  nameEn: nameEnController.text.trim(),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}
