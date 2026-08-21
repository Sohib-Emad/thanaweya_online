import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/router/admin_routes.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_plans_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_plans_cubit.dart';

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

  String _periodText(String period) {
    switch (period) {
      case 'monthly':
        return 'شهرياً';
      case 'term':
        return 'لكل ترم دراسي';
      case 'yearly':
        return 'سنوياً';
      default:
        return period;
    }
  }

  Color _periodColor(String period) {
    switch (period) {
      case 'monthly':
        return AppColors.info;
      case 'term':
        return AppColors.warning;
      case 'yearly':
        return AppColors.adminPrimary;
      default:
        return AppColors.primary;
    }
  }

  void _onEditPlan(Map<String, dynamic> plan) async {
    final updated = await Navigator.pushNamed(
      context,
      AdminRoutes.adminEditPlan,
      arguments: plan,
    );
    if (updated == true && mounted) {
      _cubit.loadPlans();
    }
  }

  void _onAddPlan() async {
    final added = await Navigator.pushNamed(
      context,
      AdminRoutes.adminEditPlan,
    );
    if (added == true && mounted) {
      _cubit.loadPlans();
    }
  }

  void _confirmDeletePlan(String planId, String planName) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('حذف الباقة'),
          content: Text('هل أنت متأكد من رغبتك في حذف "$planName"؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _cubit.deletePlan(planId);
              },
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(AppStrings.subscriptionPlans),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: 'إضافة باقة جديدة',
              onPressed: _onAddPlan,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.adminPrimary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('باقة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: _onAddPlan,
        ),
        body: BlocBuilder<AdminPlansCubit, AdminPlansState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == AdminPlansStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.plans.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_membership_rounded, size: 64.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text('لا توجد باقات حالياً', style: AppTextStyles.h3),
                    SizedBox(height: 8.h),
                    Text('اضغط على زر الإضافة لإنشاء باقة جديدة', style: AppTextStyles.caption),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('إضافة باقة'),
                      onPressed: _onAddPlan,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _cubit.loadPlans(),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                itemCount: state.plans.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final plan = state.plans[index];
                  final planId = plan['id'] as String? ?? '';
                  final isActive = plan['is_active'] == true;
                  final name = plan['name'] as String? ?? '';
                  final price = plan['price'] ?? 0;
                  final billingPeriod = plan['billing_period'] as String? ?? 'monthly';
                  final periodLabel = _periodText(billingPeriod);
                  final color = _periodColor(billingPeriod);

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: isActive ? color.withValues(alpha: 0.35) : AppColors.cardBorder,
                        width: isActive ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isActive ? 0.08 : 0.02),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18.r),
                        onTap: () => _onEditPlan(plan),
                        child: Padding(
                          padding: EdgeInsets.all(18.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(Icons.workspace_premium_rounded, color: color, size: 24.r),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            periodLabel,
                                            style: TextStyle(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w700,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isActive,
                                    onChanged: (v) {
                                      HapticFeedback.selectionClick();
                                      _cubit.togglePlanStatus(planId, v);
                                    },
                                    activeThumbColor: AppColors.adminPrimary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              const Divider(height: 1),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '$price',
                                        style: AppTextStyles.h2.copyWith(
                                          color: AppColors.adminPrimary,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'ج.م',
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: AppColors.adminPrimary),
                                        tooltip: 'تعديل',
                                        onPressed: () => _onEditPlan(plan),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                        tooltip: 'حذف',
                                        onPressed: () => _confirmDeletePlan(planId, name),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
