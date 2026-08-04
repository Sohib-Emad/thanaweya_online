import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';
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
        return 'شهري';
      case 'term':
        return 'فترة';
      case 'yearly':
        return 'سنوي';
      default:
        return period;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.subscriptionPlans),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/admin/edit-plan'),
            ),
          ],
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
                    Icon(Icons.card_membership, size: 56.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text(AppStrings.noData, style: AppTextStyles.body2),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _cubit.loadPlans(),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: state.plans.length,
                itemBuilder: (context, index) {
                  final plan = state.plans[index];
                  final planId = plan['id'] as String? ?? '';
                  final isActive = plan['is_active'] == true;
                  final name = plan['name'] as String? ?? '';
                  final price = plan['price'] ?? 0;
                  final period = _periodText(plan['billing_period'] as String? ?? '');

                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.card_membership,
                            color: isActive ? AppColors.success : AppColors.textTertiary,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.h3),
                              SizedBox(height: 2.h),
                              Text('$price ج.م - $period', style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Switch(
                          value: isActive,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            _cubit.togglePlanStatus(planId, v);
                          },
                          activeThumbColor: AppColors.success,
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
