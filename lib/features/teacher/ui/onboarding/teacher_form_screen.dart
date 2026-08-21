import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/auth/data/repos/auth_repo.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';
import 'package:thanaweya_online/features/auth/logic/auth_state.dart' as local;
import 'package:thanaweya_online/features/shared/models/subscription_plan_item.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/teacher_data_upsert.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/teacher_form_header.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/teacher_form_step_view.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/widgets.dart';

/// Multi-step enrollment form for teacher desk registration.
class TeacherFormScreen extends StatefulWidget {
  const TeacherFormScreen({super.key});
  @override
  State<TeacherFormScreen> createState() => _TeacherFormScreenState();
}

class _TeacherFormScreenState extends State<TeacherFormScreen> {
  final _s0Key = GlobalKey<FormState>(),
      _s1Key = GlobalKey<FormState>(),
      _s2Key = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(),
      _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(),
      _passCtrl = TextEditingController(),
      _bioCtrl = TextEditingController();
  int _sysIdx = 0;
  final _subIds = <String>{}, _trackIds = <String>{};
  List<Map<String, dynamic>> _subjects = [];
  final _stageVals = <String>{};
  String _mode = 'online';
  String? _gov = 'البحيرة';
  bool _terms = true;
  XFile? _avatar, _idFront, _idBack, _proof;
  XFile? _paymentReceipt;
  List<SubscriptionPlanItem> _plans = [];
  int _selectedPlanIndex = 0;
  int _step = 0;
  final _picker = ImagePicker();
  late final AuthCubit _authCubit;
  static const _sysKeys = ['general', 'baccalaureate', 'both'];

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(authRepo: AuthRepo());
    _loadSubjects();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      final data = await Supabase.instance.client
          .from('subscription_plans')
          .select()
          .eq('is_active', true)
          .order('display_order', ascending: true);
      if (mounted && data.isNotEmpty) {
        setState(() {
          _plans = data
              .asMap()
              .entries
              .map((e) => SubscriptionPlanItem.fromMap(e.value, e.key))
              .toList();
          // Select last (usually annual) or first
          if (_selectedPlanIndex >= _plans.length) {
            _selectedPlanIndex = 0;
          }
        });
      }
    } catch (e) {
      debugPrint('[TeacherForm] load plans failed: $e');
    }
  }

  @override
  void dispose() {
    _authCubit.close();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    try {
      final data = await Supabase.instance.client
          .from('subjects')
          .select('id, name_ar')
          .eq('is_active', true)
          .order('display_order');
      if (mounted) {
        setState(() => _subjects = List<Map<String, dynamic>>.from(data));
      }
    } catch (e) {
      debugPrint('[TeacherForm] load subjects failed: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: DeskText.body(13.sp, color: DeskColors.ink)),
        backgroundColor: DeskColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Future<void> _pick({
    required String title,
    required Function(XFile?) onImageSelected,
  }) => showImageSourcePicker(
    context: context,
    picker: _picker,
    title: title,
    onImageSelected: onImageSelected,
    onError: _snack,
  );

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_step == 0) {
      if (!_s0Key.currentState!.validate()) return;
      if (_idFront == null || _proof == null) {
        _snack('برجاء إرفاق جميع الملفات المطلوبة');
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      if (_sysIdx == 0 && _subIds.isEmpty) {
        _snack('برجاء اختيار مادة واحدة على الأقل');
        return;
      }
      if (_sysIdx == 1 && _trackIds.isEmpty) {
        _snack('برجاء اختيار مسار أكاديمي واحد على الأقل');
        return;
      }
      if (_sysIdx == 2 && _subIds.isEmpty && _trackIds.isEmpty) {
        _snack('برجاء اختيار مادة أو مسار أكاديمي واحد على الأقل');
        return;
      }
      if (_stageVals.isEmpty && _sysIdx != 1) {
        _snack('اختر مرحلة واحدة على الأقل');
        return;
      }
      setState(() => _step = 2);
    } else if (_step == 2) {
      if (!_terms) {
        _snack('برجاء الموافقة على الشروط والأحكام');
        return;
      }
      setState(() => _step = 3);
    } else if (_step == 3) {
      setState(() => _step = 4);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    HapticFeedback.lightImpact();
    if (_step > 0) setState(() => _step--);
  }

  void _submit() {
    if (!_terms) {
      _snack('برجاء الموافقة على الشروط والأحكام');
      return;
    }
    if (_paymentReceipt == null) {
      _snack('برجاء إرفاق صورة إيصال التحويل (InstaPay) لإتمام التسجيل');
      return;
    }
    HapticFeedback.mediumImpact();
    _authCubit.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      role: 'teacher',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: DeskColors.ground,
          body: SafeArea(
            bottom: false,
            child: DeskSurface(
              child: Column(
                children: [
                  TeacherFormHeader(
                    currentStep: _step,
                    onBack: () => Navigator.pop(context),
                    onPrev: _prevStep,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: buildTeacherFormStep(
                          step: _step,
                          s0Key: _s0Key,
                          s1Key: _s1Key,
                          s2Key: _s2Key,
                          nameCtrl: _nameCtrl,
                          phoneCtrl: _phoneCtrl,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          bioCtrl: _bioCtrl,
                          sysIdx: _sysIdx,
                          subIds: _subIds,
                          trackIds: _trackIds,
                          subjects: _subjects,
                          stageVals: _stageVals,
                          mode: _mode,
                          gov: _gov,
                          terms: _terms,
                          avatar: _avatar,
                          idFront: _idFront,
                          idBack: _idBack,
                          proof: _proof,
                          paymentReceipt: _paymentReceipt,
                          selectedPlanIndex: _selectedPlanIndex,
                          plans: _plans,
                          pick: _pick,
                          onAvatar: (f) => setState(() => _avatar = f),
                          onIdFront: (f) => setState(() => _idFront = f),
                          onIdBack: (f) => setState(() => _idBack = f),
                          onProof: (f) => setState(() => _proof = f),
                          onPaymentReceipt: (f) =>
                              setState(() => _paymentReceipt = f),
                          onPlanChanged: (i) =>
                              setState(() => _selectedPlanIndex = i),
                          onChangePlan: () => setState(() => _step = 3),
                          onSysIdx: (i) => setState(() => _sysIdx = i),
                          onSubToggle: (id) => setState(
                            () => _subIds.contains(id)
                                ? _subIds.remove(id)
                                : _subIds.add(id),
                          ),
                          onTrackToggle: (id) => setState(
                            () => _trackIds.contains(id)
                                ? _trackIds.remove(id)
                                : _trackIds.add(id),
                          ),
                          onStageToggle: (v) => setState(
                            () => _stageVals.contains(v)
                                ? _stageVals.remove(v)
                                : _stageVals.add(v),
                          ),
                          onGov: (v) => setState(() => _gov = v),
                          onMode: (v) => setState(() => _mode = v),
                          onTermsToggle: () => setState(() => _terms = !_terms),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
                    child: _buildBottomBar(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_step == 4) {
      return BlocConsumer<AuthCubit, local.AuthState>(
        listener: (ctx, state) {
          if (state.status == local.AuthStatus.authenticated) {
            final activePlans = _plans.isNotEmpty ? _plans : SubscriptionPlanItem.defaultPlans;
            final plan = (_selectedPlanIndex >= 0 && _selectedPlanIndex < activePlans.length)
                ? activePlans[_selectedPlanIndex]
                : activePlans.first;

            upsertTeacherData(
              avatar: _avatar,
              idFront: _idFront,
              idBack: _idBack,
              proof: _proof,
              paymentReceipt: _paymentReceipt,
              subjectId: _subIds.isNotEmpty ? _subIds.first : null,
              stage: _stageVals.isNotEmpty ? _stageVals.first : null,
              teachingSystem: _sysKeys[_sysIdx],
              stages: _stageVals.toList(),
              baccalaureateTracks: _trackIds.toList(),
              governorate: _gov,
              teachingMode: _mode,
              selectedPlan: plan.billingPeriod,
              paymentMethod: 'instapay',
              subscriptionAmount: plan.price,
              bio: _bioCtrl.text.trim(),
            );
            Navigator.pushNamedAndRemoveUntil(
              ctx,
              AppRouter.teacherPending,
              (r) => false,
            );
          } else if (state.status == local.AuthStatus.error &&
              state.errorMessage != null) {
            _snack(state.errorMessage!);
          }
        },
        builder: (_, state) => TeacherFormBottomBar(
          currentStep: _step,
          onNext: _nextStep,
          onPrev: _prevStep,
          onSubmit: _submit,
          isLoading: state.status == local.AuthStatus.loading,
        ),
      );
    }
    return TeacherFormBottomBar(
      currentStep: _step,
      onNext: _nextStep,
      onPrev: _prevStep,
    );
  }
}
