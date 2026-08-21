import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_plans_repo.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';

class EditPlanScreen extends StatefulWidget {
  final Map<String, dynamic>? plan;

  const EditPlanScreen({super.key, this.plan});

  @override
  State<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AdminPlansRepo();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _orderController;
  late String _selectedPeriod;
  late bool _isActive;
  bool _isLoading = false;

  bool get _isEditing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan?['name'] as String? ?? '');
    _priceController = TextEditingController(
        text: widget.plan != null ? (widget.plan!['price']?.toString() ?? '') : '');
    _orderController = TextEditingController(
        text: widget.plan != null ? (widget.plan!['display_order']?.toString() ?? '1') : '1');
    _selectedPeriod = widget.plan?['billing_period'] as String? ?? 'monthly';
    _isActive = widget.plan?['is_active'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final order = int.tryParse(_orderController.text.trim()) ?? 1;

    if (_isEditing) {
      final planId = widget.plan!['id'] as String;
      final res = await _repo.updatePlan(
        planId: planId,
        name: name,
        billingPeriod: _selectedPeriod,
        price: price,
        displayOrder: order,
        isActive: _isActive,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      res.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تحديث الباقة بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        },
        failure: (msg, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    } else {
      final res = await _repo.addPlan(
        name: name,
        billingPeriod: _selectedPeriod,
        price: price,
        displayOrder: order,
        isActive: _isActive,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      res.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تمت إضافة الباقة بنجاح'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        },
        failure: (msg, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(_isEditing ? 'تعديل الباقة' : 'إضافة باقة جديدة'),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _nameController,
                    labelText: 'اسم الباقة (مثال: باقة الترم)',
                    prefixIcon: Icons.card_membership_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? AppStrings.fieldRequired : null,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _priceController,
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
                    initialValue: _selectedPeriod,
                    decoration: InputDecoration(
                      labelText: 'دورة الفوترة',
                      prefixIcon: const Icon(Icons.calendar_month_outlined),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'monthly', child: Text('شهري (Monthly)')),
                      DropdownMenuItem(value: 'term', child: Text('ترم دراسي (Term)')),
                      DropdownMenuItem(value: 'yearly', child: Text('سنوي (Yearly)')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedPeriod = v);
                    },
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    controller: _orderController,
                    labelText: 'ترتيب العرض (رقم)',
                    prefixIcon: Icons.sort_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isActive ? Icons.check_circle_rounded : Icons.pause_circle_rounded,
                              color: _isActive ? AppColors.success : AppColors.textTertiary,
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              _isActive ? 'الباقة مفعلة ومتاحة للمعلمين' : 'الباقة معطلة مؤقتاً',
                              style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeThumbColor: AppColors.adminPrimary,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 36.h),
                  AppButton(
                    text: _isEditing ? 'حفظ التعديلات' : 'إضافة الباقة',
                    isLoading: _isLoading,
                    icon: Icons.save_rounded,
                    onPressed: _isLoading ? null : _onSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
