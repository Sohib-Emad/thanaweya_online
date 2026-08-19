import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';
import 'widgets/widgets.dart';

/// Screen for activating a course via code or enrolling in a free course.
class PaymentMethodsScreen extends StatefulWidget {
  final String courseId;
  final String teacherId;
  final String courseTitle;
  final double? price;

  const PaymentMethodsScreen({
    super.key,
    this.courseId = '',
    this.teacherId = '',
    this.courseTitle = '',
    this.price,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _isProcessing = false;
  final _codeController = TextEditingController();
  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  bool get _isFree => widget.price == null || widget.price! <= 0;

  @override
  void dispose() {
    _codeController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showSnack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ok ? NotebookColors.green : NotebookColors.marginRed,
      content: Text(msg, style: NotebookText.strong(12.sp)),
    ));
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isNotEmpty) {
      HapticFeedback.selectionClick();
      _codeController.text = text.toUpperCase();
      setState(() {});
    }
  }

  void _openCourseLessons() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, AppRouter.studentCourseLessons, arguments: widget.courseId);
  }

  void _onSuccess(String msg) {
    showPaymentSuccessDialog(context: context, message: msg, onOpenLessons: _openCourseLessons);
  }

  Future<void> _redeemCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) { _showSnack('يرجى كتابة أو لصق كود التفعيل أولاً'); return; }
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);
    final error = await _cubit.redeemActivationCode(code, courseId: widget.courseId, teacherId: widget.teacherId);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    error == null ? _onSuccess('تم تفعيل الكورس بنجاح باستخدام كود المدرس!') : _showSnack(error);
  }

  Future<void> _enrollFree() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
    if (userId == null) { _showSnack('يرجى تسجيل الدخول أولاً'); return; }
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);
    final ok = await _cubit.subscribeFree(studentId: userId, teacherId: widget.teacherId);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ok ? _onSuccess('تم تفعيل الكورس المجاني بنجاح!') : _showSnack('فشل التسجيل في الكورس، يرجى المحاولة مرة أخرى');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: _isFree ? 'تسجيل الكورس المجاني' : 'تفعيل الكورس بكود المدرس',
        subtitle: _isFree ? 'انضم للكورس وابدأ التعلم الآن' : 'أدخل كود التفعيل المستلم من مدرسك',
      ),
      body: Stack(children: [
        NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 140.h),
            physics: const BouncingScrollPhysics(),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CourseSummaryCard(courseTitle: widget.courseTitle, price: widget.price),
              SizedBox(height: 22.h),
              if (!_isFree)
                ActivationCodeSection(controller: _codeController, onPaste: _pasteFromClipboard, onChanged: (_) => setState(() {}))
              else
                const FreeCourseBanner(),
            ]),
          ),
        ),
        PaymentActionButton(isFree: _isFree, isProcessing: _isProcessing, onPressed: _isProcessing ? null : (_isFree ? _enrollFree : _redeemCode)),
      ]),
    );
  }
}
