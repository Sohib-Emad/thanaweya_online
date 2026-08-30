import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/router/admin_routes.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_plans_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_plans_cubit.dart';
import 'widgets/subscription_plan_card_item.dart';
import 'widgets/delete_plan_dialog.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  final _cubit = AdminPlansCubit(repo: AdminPlansRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadPlans();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _onEditPlan([Map<String, dynamic>? plan]) async {
    final res = await Navigator.pushNamed(context, AdminRoutes.adminEditPlan, arguments: plan);
    if (res == true && mounted) _cubit.loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.subscriptionPlans),
          actions: [IconButton(icon: const Icon(Icons.add_circle_outline_rounded), tooltip: 'إضافة باقة جديدة', onPressed: () => _onEditPlan())],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.adminPrimary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('باقة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () => _onEditPlan(),
        ),
        body: BlocBuilder<AdminPlansCubit, AdminPlansState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminPlansStatus.loading) return const Center(child: CircularProgressIndicator());
            if (state.plans.isEmpty) {
              return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.card_membership_rounded, size: 64.r, color: AppColors.textTertiary),
                SizedBox(height: 16.h),
                Text('لا توجد باقات حالياً', style: AppTextStyles.h3),
                SizedBox(height: 8.h),
                ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary, foregroundColor: Colors.white), icon: const Icon(Icons.add), label: const Text('إضافة باقة'), onPressed: () => _onEditPlan()),
              ]));
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadPlans(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                itemCount: state.plans.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final plan = state.plans[index];
                  final id = plan['id'] as String? ?? '', name = plan['name'] as String? ?? '';
                  return SubscriptionPlanCardItem(
                    plan: plan,
                    onToggleStatus: (v) => _cubit.togglePlanStatus(id, v),
                    onEdit: () => _onEditPlan(plan),
                    onDelete: () => showConfirmDeletePlanDialog(context: context, planName: name, onConfirm: () => _cubit.deletePlan(id)),
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
