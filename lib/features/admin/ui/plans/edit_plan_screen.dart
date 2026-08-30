import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_plans_repo.dart';
import 'package:thanaweya_online/features/shared/widgets/app_button.dart';
import 'widgets/plan_form_fields.dart';

class EditPlanScreen extends StatefulWidget {
  final Map<String, dynamic>? plan;
  const EditPlanScreen({super.key, this.plan});

  @override
  State<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends State<EditPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AdminPlansRepo();
  late final TextEditingController _nameController, _priceController, _orderController;
  late String _selectedPeriod;
  late bool _isActive;
  bool _isLoading = false;

  bool get _isEditing => widget.plan != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan?['name'] as String? ?? '');
    _priceController = TextEditingController(text: widget.plan?['price']?.toString() ?? '');
    _orderController = TextEditingController(text: widget.plan?['display_order']?.toString() ?? '1');
    _selectedPeriod = widget.plan?['billing_period'] as String? ?? 'monthly';
    _isActive = widget.plan?['is_active'] as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose(); _priceController.dispose(); _orderController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final order = int.tryParse(_orderController.text.trim()) ?? 1;

    final res = _isEditing
        ? await _repo.updatePlan(planId: widget.plan!['id'] as String, name: name, billingPeriod: _selectedPeriod, price: price, displayOrder: order, isActive: _isActive)
        : await _repo.addPlan(name: name, billingPeriod: _selectedPeriod, price: price, displayOrder: order, isActive: _isActive);

    if (!mounted) return;
    setState(() => _isLoading = false);
    res.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditing ? 'تم تحديث الباقة بنجاح' : 'تمت إضافة الباقة بنجاح'), backgroundColor: AppColors.success));
        Navigator.pop(context, true);
      },
      failure: (msg, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(_isEditing ? 'تعديل الباقة' : 'إضافة باقة جديدة'), elevation: 0),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PlanFormFields(
                    nameController: _nameController, priceController: _priceController, orderController: _orderController,
                    selectedPeriod: _selectedPeriod, isActive: _isActive,
                    onSelectPeriod: (v) => setState(() => _selectedPeriod = v), onToggleActive: (v) => setState(() => _isActive = v),
                  ),
                  SizedBox(height: 36.h),
                  AppButton(text: _isEditing ? 'حفظ التعديلات' : 'إضافة الباقة', isLoading: _isLoading, icon: Icons.save_rounded, onPressed: _isLoading ? null : _onSave),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
