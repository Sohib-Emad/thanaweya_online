import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
import 'package:thanaweya_online/features/shared/widgets/app_text_field.dart';

class EditPlanScreen extends StatefulWidget {
  const EditPlanScreen({super.key});

  @override
  State<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedPeriod = 'monthly';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إضافة باقة')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.h),
                  AppTextField(
                    controller: _nameController,
                    labelText: 'اسم الباقة',
                    prefixIcon: Icons.card_membership,
                    validator: (v) =>
                        v!.isEmpty ? AppStrings.fieldRequired : null,
                  ),
                  SizedBox(height: 14.h),
                  AppTextField(
                    controller: _priceController,
                    labelText: 'السعر (ج.م)',
                    prefixIcon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v!.isEmpty ? AppStrings.fieldRequired : null,
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'فترة الفوترة',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'monthly', child: Text('شهري')),
                      DropdownMenuItem(value: 'term', child: Text('فترة')),
                      DropdownMenuItem(value: 'yearly', child: Text('سنوي')),
                    ],
                    onChanged: (v) => setState(() => _selectedPeriod = v!),
                  ),
                  SizedBox(height: 32.h),
                  AppButton(
                    text: AppStrings.save,
                    onPressed: _onSave,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الباقة بنجاح'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}
