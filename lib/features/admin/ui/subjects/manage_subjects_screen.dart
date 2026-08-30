import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_subjects_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_subjects_cubit.dart';
import 'widgets/subject_card_item.dart';
import 'widgets/add_subject_dialog.dart';

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
              onPressed: () => showAddSubjectDialog(
                context: context,
                onConfirm: (ar, en) => _cubit.addSubject(nameAr: ar, nameEn: en),
              ),
            ),
          ],
        ),
        body: BlocBuilder<AdminSubjectsCubit, AdminSubjectsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminSubjectsStatus.loading) return const Center(child: CircularProgressIndicator());
            if (state.subjects.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.menu_book_outlined, size: 56.r, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text('لا توجد مواد', style: AppTextStyles.body2),
              ]));
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadSubjects(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.subjects.length,
                itemBuilder: (context, index) {
                  final s = state.subjects[index];
                  return SubjectCardItem(subject: s, onDelete: () => _cubit.deleteSubject(s['id'] as String? ?? ''));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
