import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/subscription_plan_item.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/show_image_source_picker.dart';
import 'package:thanaweya_online/features/teacher/ui/plans/widgets/widgets.dart';

/// Subscription plans screen for teachers to view their current active plan,
/// and only access renewal/upgrade options when an admin renewal alert is active.
class TeacherSubscriptionPlansScreen extends StatefulWidget {
  const TeacherSubscriptionPlansScreen({super.key});
  @override
  State<TeacherSubscriptionPlansScreen> createState() =>
      _TeacherSubscriptionPlansScreenState();
}

class _TeacherSubscriptionPlansScreenState
    extends State<TeacherSubscriptionPlansScreen> {
  int _selectedPlanIndex = 0;
  List<SubscriptionPlanItem> _plans = [];
  String? _currentPlanKey;
  String? _currentApprovalStatus;
  double? _currentSubscriptionAmount;
  bool _requiresRenewal = false;
  final _promoCodeController = TextEditingController();
  bool _isCodeApplied = false;
  bool _isSaving = false;
  bool _isLoading = true;
  XFile? _paymentReceipt;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPlansAndSubscription();
  }

  @override
  void dispose() {
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadPlansAndSubscription() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;

    try {
      // 1. Fetch available plans
      final data = await client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);

      List<SubscriptionPlanItem> loadedPlans = [];
      if (data.isNotEmpty) {
        loadedPlans = data
            .asMap()
            .entries
            .map((e) => SubscriptionPlanItem.fromMap(e.value, e.key))
            .toList();
      } else {
        loadedPlans = SubscriptionPlanItem.defaultPlans;
      }

      // 2. Fetch current teacher subscription & renewal requirement
      String? planKey;
      String? approvalStatus;
      double? amount;
      bool renewalRequired = false;

      if (uid != null) {
        final teacherDoc = await client
            .from('teachers')
            .select('selected_plan, approval_status, subscription_amount, requires_renewal')
            .eq('id', uid)
            .maybeSingle();

        if (teacherDoc != null) {
          planKey = teacherDoc['selected_plan']?.toString();
          approvalStatus = teacherDoc['approval_status']?.toString();
          renewalRequired = teacherDoc['requires_renewal'] == true;
          final rawAmt = teacherDoc['subscription_amount'];
          if (rawAmt is num) {
            amount = rawAmt.toDouble();
          } else if (rawAmt is String) {
            amount = double.tryParse(rawAmt);
          }
        }
      }

      // Find index of current plan or default
      int defaultIdx = 0;
      if (planKey != null) {
        final found = loadedPlans.indexWhere(
          (p) => p.billingPeriod == planKey || (planKey == 'annual' && p.billingPeriod == 'yearly'),
        );
        if (found != -1) {
          defaultIdx = found;
        }
      } else {
        defaultIdx = loadedPlans.isNotEmpty ? loadedPlans.length - 1 : 0;
      }

      if (mounted) {
        setState(() {
          _plans = loadedPlans;
          _currentPlanKey = planKey;
          _currentApprovalStatus = approvalStatus;
          _currentSubscriptionAmount = amount;
          _requiresRenewal = renewalRequired;
          _selectedPlanIndex = defaultIdx;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _plans = SubscriptionPlanItem.defaultPlans;
          _isLoading = false;
        });
      }
    }
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

        final activePlans = _plans.isNotEmpty ? _plans : SubscriptionPlanItem.defaultPlans;
        final selectedPlan = (_selectedPlanIndex >= 0 && _selectedPlanIndex < activePlans.length)
            ? activePlans[_selectedPlanIndex]
            : activePlans.first;

        final payload = <String, dynamic>{
          'selected_plan': selectedPlan.billingPeriod,
          'payment_method': 'instapay',
          'subscription_amount': selectedPlan.price,
          'payment_receipt_url': url,
          'approval_status': 'pending',
          'requires_renewal': false, // Clear renewal alert upon submission
        };

        await Supabase.instance.client
            .from('teachers')
            .update(payload)
            .eq('id', uid);

        if (mounted) {
          setState(() {
            _isSaving = false;
            _currentPlanKey = selectedPlan.billingPeriod;
            _currentApprovalStatus = 'pending';
            _currentSubscriptionAmount = selectedPlan.price;
            _requiresRenewal = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال طلب تجديد الاشتراك بنجاح، جاري مراجعته من الإدارة'),
              backgroundColor: DeskColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل الإرسال: $e'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCurrentPlan = _currentPlanKey != null && _currentPlanKey!.isNotEmpty;
    final bool showBottomBar = _requiresRenewal || !hasCurrentPlan;

    return Scaffold(
      backgroundColor: DeskColors.ground,
      appBar: AppBar(
        title: const Text('باقات واشتراكات المعلم'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PlanListView(
              selectedIndex: _selectedPlanIndex,
              onPlanSelected: (i) => setState(() => _selectedPlanIndex = i),
              plans: _plans,
              currentSubscribedPlanKey: _currentPlanKey,
              currentSubscriptionStatus: _currentApprovalStatus,
              currentSubscriptionAmount: _currentSubscriptionAmount,
              requiresRenewal: _requiresRenewal,
              receiptFile: _paymentReceipt,
              onPickReceipt: _pickReceipt,
              onRemoveReceipt: () => setState(() => _paymentReceipt = null),
              activationCodeBox: ActivationCodeBox(
                controller: _promoCodeController,
                isApplied: _isCodeApplied,
                onApply: _applyPromoCode,
              ),
            ),
      bottomNavigationBar: showBottomBar
          ? BottomActionNav(
              onSubmitPressed: _submitSubscription,
              isLoading: _isSaving,
            )
          : null,
    );
  }
}
