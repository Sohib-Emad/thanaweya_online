import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';

class SubscriptionPlanCardItem extends StatelessWidget {
  final Map<String, dynamic> plan;
  final ValueChanged<bool> onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SubscriptionPlanCardItem({
    super.key, required this.plan, required this.onToggleStatus,
    required this.onEdit, required this.onDelete,
  });

  String _periodText(String p) => switch (p) { 'monthly' => 'شهرياً', 'term' => 'لكل ترم دراسي', 'yearly' => 'سنوياً', _ => p };
  Color _periodColor(String p) => switch (p) { 'monthly' => AppColors.info, 'term' => AppColors.warning, 'yearly' => AppColors.adminPrimary, _ => AppColors.primary };

  @override
  Widget build(BuildContext context) {
    final isActive = plan['is_active'] == true, name = plan['name'] as String? ?? '', price = plan['price'] ?? 0;
    final billingPeriod = plan['billing_period'] as String? ?? 'monthly', periodLabel = _periodText(billingPeriod), color = _periodColor(billingPeriod);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: isActive ? color.withValues(alpha: 0.35) : AppColors.cardBorder, width: isActive ? 1.5 : 1),
        boxShadow: [BoxShadow(color: color.withValues(alpha: isActive ? 0.08 : 0.02), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r), onTap: onEdit,
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.workspace_premium_rounded, color: color, size: 24.r)),
                    SizedBox(width: 14.w),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800)),
                      SizedBox(height: 4.h),
                      Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6.r)), child: Text(periodLabel, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color))),
                    ])),
                    Switch(value: isActive, onChanged: (v) { HapticFeedback.selectionClick(); onToggleStatus(v); }, activeThumbColor: AppColors.adminPrimary),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(height: 1),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text('$price', style: AppTextStyles.h2.copyWith(color: AppColors.adminPrimary, fontWeight: FontWeight.w900)),
                      SizedBox(width: 4.w),
                      Text('ج.م', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                    ]),
                    Row(children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, color: AppColors.adminPrimary), tooltip: 'تعديل', onPressed: onEdit),
                      IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error), tooltip: 'حذف', onPressed: onDelete),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
