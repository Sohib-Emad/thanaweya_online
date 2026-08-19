import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/show_image_source_picker.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/widgets.dart';

/// Subscription plans screen for teachers to choose a plan,
/// view InstaPay details, upload payment receipt, and contact via WhatsApp.
class TeacherSubscriptionPlansScreen extends StatefulWidget {
  const TeacherSubscriptionPlansScreen({super.key});
  @override
  State<TeacherSubscriptionPlansScreen> createState() =>
      _TeacherSubscriptionPlansScreenState();
}

class _TeacherSubscriptionPlansScreenState
    extends State<TeacherSubscriptionPlansScreen> {
  int _selectedPlanIndex = 2; // Default to Annual (Best Value)
  final _promoCodeController = TextEditingController();
  bool _isCodeApplied = false;
  bool _isSaving = false;
  XFile? _paymentReceipt;
  final _picker = ImagePicker();
  static const _planKeys = ['monthly', 'term', 'annual'];
  static const _planAmounts = [1000.0, 5000.0, 10000.0];

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  void _applyPromoCode() {
    if (_promoCodeController.text.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() => _isCodeApplied = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تطبيق كود الخصم بنجاح!',
              style: TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: DeskColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _pickReceipt() {
    showImageSourcePicker(
      context: context,
      picker: _picker,
      title: 'إرفاق صورة إيصال التحويل (InstaPay)',
      onImageSelected: (file) => setState(() => _paymentReceipt = file),
      onError: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: DeskText.body(13, color: DeskColors.ink)),
            backgroundColor: DeskColors.surface,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _submitSubscription() async {
    if (_paymentReceipt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'برجاء إرفاق صورة إيصال التحويل (InstaPay) أولاً',
            style: DeskText.body(13, color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) {
      try {
        final url = await StorageHelper.uploadTeacherDocument(
          userId: uid,
          subfolder: 'receipt',
          file: _paymentReceipt!,
        );
        final payload = <String, dynamic>{
          'selected_plan': _planKeys[_selectedPlanIndex],
          'payment_method': 'instapay',
          'subscription_amount': _planAmounts[_selectedPlanIndex],
          'payment_receipt_url': url,
        };
        try {
          await Supabase.instance.client.from('teachers').update(payload).eq('id', uid);
        } catch (_) {}
      } catch (e) {
        debugPrint('[Plans] upload receipt failed: $e');
      }
    }

    setState(() => _isSaving = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال طلب الاشتراك وإيصال التحويل بنجاح!'),
        backgroundColor: DeskColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: const DeskTopBar(
          title: 'باقات اشتراك المعلمين',
          subtitle: 'اختر الباقة وبيانات الدفع',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: Column(
            children: [
              Expanded(
                child: PlanListView(
                  selectedIndex: _selectedPlanIndex,
                  onPlanSelected: (i) =>
                      setState(() => _selectedPlanIndex = i),
                  receiptFile: _paymentReceipt,
                  onPickReceipt: _pickReceipt,
                  onRemoveReceipt: () => setState(() => _paymentReceipt = null),
                  activationCodeBox: ActivationCodeBox(
                    controller: _promoCodeController,
                    isApplied: _isCodeApplied,
                    onApply: _applyPromoCode,
                  ),
                ),
              ),
              BottomActionNav(
                onSubmitPressed: _submitSubscription,
                isLoading: _isSaving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
