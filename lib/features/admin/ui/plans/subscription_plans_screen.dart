import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  late List<Map<String, dynamic>> _plans;

  @override
  void initState() {
    super.initState();
    _plans = List<Map<String, dynamic>>.from(MockData.mockPlans);
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
        body: _plans.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.card_membership,
                        size: 56.r, color: AppColors.textTertiary),
                    SizedBox(height: 16.h),
                    Text(AppStrings.noData, style: AppTextStyles.body2),
                  ],
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  final isActive = plan['is_active'] == true;
                  final period = plan['billing_period'] == 'monthly'
                      ? 'شهري'
                      : plan['billing_period'] == 'term'
                          ? 'فترة'
                          : 'سنوي';
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.card_membership,
                            color: isActive
                                ? AppColors.success
                                : AppColors.textTertiary,
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan['name'] ?? '', style: AppTextStyles.h3),
                              SizedBox(height: 2.h),
                              Text(
                                '${plan['price']} ج.م - $period',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isActive,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _plans[index] = {...plan, 'is_active': v};
                            });
                          },
                          activeThumbColor: AppColors.success,
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
