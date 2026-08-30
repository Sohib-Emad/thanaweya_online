import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_teachers_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_teachers_cubit.dart';
import 'widgets/widgets.dart';

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
            if (state.status == AdminTeachersStatus.loading) return const Center(child: CircularProgressIndicator());
            if (state.status == AdminTeachersStatus.error) {
              return EmptyStateView(icon: Icons.error_outline, iconColor: AppColors.error, message: state.errorMessage ?? 'حدث خطأ');
            }
            if (state.pendingTeachers.isEmpty) {
              return const EmptyStateView(icon: Icons.check_circle_outline, iconColor: AppColors.textTertiary, message: AppStrings.noData);
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
                  final teacherId = teacher['id'] as String? ?? '';
                  return TeacherRequestCard(
                    name: name,
                    initials: name.isNotEmpty ? name[0] : 'م',
                    subject: (teacher['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '',
                    phone: users['phone'] as String? ?? '',
                    plan: teacher['selected_plan'] as String?,
                    amount: teacher['subscription_amount'] as num?,
                    receiptUrl: teacher['payment_receipt_url'] as String?,
                    idFrontUrl: teacher['id_card_front_url'] as String?,
                    idBackUrl: teacher['id_card_back_url'] as String?,
                    proofUrl: teacher['teacher_proof_url'] as String?,
                    onApprove: () {
                      HapticFeedback.lightImpact();
                      _cubit.approveTeacher(teacherId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم قبول وتفعيل حساب $name'), behavior: SnackBarBehavior.floating),
                      );
                    },
                    onReject: () => showRejectTeacherDialog(
                      context: context,
                      teacherName: name,
                      onReject: (reason) => _cubit.rejectTeacher(teacherId, reason),
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
