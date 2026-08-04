import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_teachers_cubit.dart';

class AllTeachersScreen extends StatefulWidget {
  const AllTeachersScreen({super.key});

  @override
  State<AllTeachersScreen> createState() => _AllTeachersScreenState();
}

class _AllTeachersScreenState extends State<AllTeachersScreen> {
  final _cubit = AdminTeachersCubit(repo: AdminTeachersRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadAllTeachers();
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
        appBar: AppBar(title: const Text('جميع المعلمين')),
        body: BlocBuilder<AdminTeachersCubit, AdminTeachersState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminTeachersStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.allTeachers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 56.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text('لا يوجد معلمين', style: AppTextStyles.body2),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadAllTeachers(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.allTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = state.allTeachers[index];
                  final status = teacher['approval_status'] as String? ?? '';
                  final users = teacher['users'] as Map<String, dynamic>? ?? {};
                  final name = users['full_name'] as String? ?? '';
                  final initials = name.isNotEmpty ? name[0] : 'م';
                  final subjects = teacher['subjects'] as Map<String, dynamic>? ?? {};

                  Color statusColor;
                  String statusText;
                  switch (status) {
                    case 'approved':
                      statusColor = AppColors.success;
                      statusText = 'معتمد';
                      break;
                    case 'rejected':
                      statusColor = AppColors.error;
                      statusText = 'مرفوض';
                      break;
                    default:
                      statusColor = AppColors.warning;
                      statusText = 'قيد المراجعة';
                  }

                  return AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: AppColors.teacherPrimaryLight,
                          child: Text(initials,
                              style: TextStyle(color: AppColors.teacherPrimary, fontWeight: FontWeight.w600)),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.h3),
                              SizedBox(height: 2.h),
                              Text(subjects['name_ar'] as String? ?? '', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(fontSize: 12.sp, color: statusColor, fontWeight: FontWeight.w600),
                          ),
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
}
