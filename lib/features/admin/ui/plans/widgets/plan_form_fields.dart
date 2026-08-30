import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';

class PlanFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController orderController;
  final String selectedPeriod;
  final bool isActive;
  final ValueChanged<String> onSelectPeriod;
  final ValueChanged<bool> onToggleActive;

  const PlanFormFields({
    super.key,
    required this.nameController,
    required this.priceController,
    required this.orderController,
    required this.selectedPeriod,
    required this.isActive,
    required this.onSelectPeriod,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: nameController,
          labelText: 'اسم الباقة (مثال: باقة الترم)',
          prefixIcon: Icons.card_membership_rounded,
          validator: (v) => v == null || v.trim().isEmpty ? AppStrings.fieldRequired : null,
        ),
        SizedBox(height: 16.h),
        AppTextField(
          controller: priceController,
          labelText: 'السعر (ج.م)',
          prefixIcon: Icons.payments_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return AppStrings.fieldRequired;
            if (double.tryParse(v.trim()) == null) return 'يرجى إدخال رقم صحيح';
            return null;
          },
        ),
        SizedBox(height: 16.h),
        DropdownButtonFormField<String>(
          initialValue: selectedPeriod,
          decoration: InputDecoration(
            labelText: 'دورة الفوترة',
            prefixIcon: const Icon(Icons.calendar_month_outlined),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: AppColors.cardBorder)),
          ),
          items: const [
            DropdownMenuItem(value: 'monthly', child: Text('شهري (Monthly)')),
            DropdownMenuItem(value: 'term', child: Text('ترم دراسي (Term)')),
            DropdownMenuItem(value: 'yearly', child: Text('سنوي (Yearly)')),
          ],
          onChanged: (v) { if (v != null) onSelectPeriod(v); },
        ),
        SizedBox(height: 16.h),
        AppTextField(controller: orderController, labelText: 'ترتيب العرض (رقم)', prefixIcon: Icons.sort_rounded, keyboardType: TextInputType.number),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14.r), border: Border.all(color: AppColors.cardBorder)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded, color: isActive ? AppColors.success : AppColors.textTertiary),
                  SizedBox(width: 12.w),
                  Text(isActive ? 'الباقة مفعلة ومتاحة للمعلمين' : 'الباقة معطلة مؤقتاً', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              Switch(value: isActive, onChanged: onToggleActive, activeThumbColor: AppColors.adminPrimary),
            ],
          ),
        ),
      ],
    );
  }
}
