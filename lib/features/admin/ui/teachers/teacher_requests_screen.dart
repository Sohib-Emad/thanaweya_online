import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_teachers_cubit.dart';

class TeacherRequestsScreen extends StatefulWidget {
  const TeacherRequestsScreen({super.key});

  @override
  State<TeacherRequestsScreen> createState() => _TeacherRequestsScreenState();
}

class _TeacherRequestsScreenState extends State<TeacherRequestsScreen> {
  final _cubit = AdminTeachersCubit(repo: AdminTeachersRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadPendingTeachers();
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
        appBar: AppBar(title: const Text(AppStrings.pendingRequests)),
        body: BlocBuilder<AdminTeachersCubit, AdminTeachersState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminTeachersStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == AdminTeachersStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 56.r, color: AppColors.error),
                    SizedBox(height: 16.h),
                    Text(state.errorMessage ?? 'حدث خطأ', style: AppTextStyles.body2),
                  ],
                ),
              );
            }
            if (state.pendingTeachers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 56.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text(AppStrings.noData, style: AppTextStyles.body2),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadPendingTeachers(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.pendingTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = state.pendingTeachers[index];
                  final users = teacher['users'] as Map<String, dynamic>? ?? {};
                  final name = users['full_name'] as String? ?? '';
                  final initials = name.isNotEmpty ? name[0] : 'م';
                  final subjects = teacher['subjects'] as Map<String, dynamic>? ?? {};
                  final teacherId = teacher['id'] as String? ?? '';

                  return AppCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22.r,
                          backgroundColor: AppColors.warning.withValues(alpha: 0.1),
                          child: Text(initials,
                              style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionIconButton(
                              icon: Icons.check_circle_outline,
                              color: AppColors.success,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _cubit.approveTeacher(teacherId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('تم قبول $name'), behavior: SnackBarBehavior.floating),
                                );
                              },
                            ),
                            SizedBox(width: 4.w),
                            _ActionIconButton(
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _showRejectDialog(context, teacherId, name);
                              },
                            ),
                          ],
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

  void _showRejectDialog(BuildContext context, String teacherId, String name) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'اكتب سبب الرفض...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              _cubit.rejectTeacher(teacherId, reasonController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم رفض $name'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: color, size: 20.r),
      ),
    );
  }
}
