import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_teachers_cubit.dart';
import 'widgets/teacher_card_item.dart';
import 'widgets/teacher_ban_dialog.dart';

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

  void _onToggleBan(BuildContext context, Map<String, dynamic> teacher) {
    final teacherId = teacher['id'] as String? ?? '';
    final users = teacher['users'] as Map<String, dynamic>? ?? {};
    final name = users['full_name'] as String? ?? 'معلم';
    final isBanned = teacher['approval_status'] == 'banned';

    showTeacherBanDialog(
      context: context,
      teacherName: name,
      isCurrentlyBanned: isBanned,
      onConfirm: (reason) {
        _cubit.toggleBanTeacher(teacherId, !isBanned, reason: reason);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isBanned ? 'تم فك الحظر عن المعلم بنجاح ✅' : 'تم حظر حساب المعلم بنجاح 🚫'),
          backgroundColor: isBanned ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('إدارة المعلمين والتجديد'),
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'تحديث', onPressed: () => _cubit.loadAllTeachers())],
        ),
        body: BlocBuilder<AdminTeachersCubit, AdminTeachersState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminTeachersStatus.loading) return const Center(child: CircularProgressIndicator());
            if (state.allTeachers.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.people_outline_rounded, size: 64.r, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text('لا يوجد معلمين مسجلين حالياً', style: AppTextStyles.h3),
              ]));
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadAllTeachers(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
                itemCount: state.allTeachers.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final t = state.allTeachers[index];
                  return TeacherCardItem(
                    teacher: t,
                    onToggleRenewal: (val) => _cubit.toggleRenewalAlert(t['id'] as String? ?? '', val),
                    onToggleBan: () => _onToggleBan(context, t),
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
