import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/theme/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';
import 'package:thanaweya_online/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'widgets/widgets.dart';

/// Screen for subscribing to a course directly via student wallet or free enrollment.
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
  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());
  final _walletRepo = WalletRepositoryImpl();
  double _walletBalance = 0.0;
  bool _isLoadingWallet = true;
  late String _teacherId;
  late String _courseTitle;
  double? _price;

  bool get _isFree => _price == null || _price! <= 0;
  bool get _hasSufficientBalance => _walletBalance >= (_price ?? 0);

  @override
  void initState() {
    super.initState();
    _teacherId = widget.teacherId;
    _courseTitle = widget.courseTitle;
    _price = widget.price;
    if (_teacherId.isEmpty && widget.courseId.isNotEmpty) {
      _fetchCourseDetails();
    }
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    final uid = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    if (uid == null) {
      if (mounted) setState(() => _isLoadingWallet = false);
      return;
    }
    try {
      final wallet = await _walletRepo.getWalletData(uid);
      if (mounted) {
        setState(() {
          _walletBalance = wallet.currentBalance;
          _isLoadingWallet = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingWallet = false);
    }
  }

  Future<void> _fetchCourseDetails() async {
    try {
      final res = await Supabase.instance.client
          .from('courses')
          .select('id, title, price, teacher_id')
          .eq('id', widget.courseId)
          .maybeSingle();
      if (res != null && mounted) {
        setState(() {
          if (_teacherId.isEmpty) _teacherId = res['teacher_id'] as String? ?? '';
          if (_courseTitle.isEmpty) _courseTitle = res['title'] as String? ?? '';
          _price ??= (res['price'] as num?)?.toDouble();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _showSnack(String msg, {bool ok = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: ok ? NotebookColors.green : NotebookColors.marginRed,
      content: Text(msg, style: NotebookText.strong(12.sp)),
    ));
  }

  void _openCourseLessons() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(context, AppRouter.studentCourseLessons, arguments: widget.courseId);
  }

  void _onSuccess(String msg) {
    showPaymentSuccessDialog(context: context, message: msg, onOpenLessons: _openCourseLessons);
  }

  Future<void> _enrollFree() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    if (userId == null) {
      _showSnack('يرجى تسجيل الدخول أولاً');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);
    final ok = await _cubit.subscribeFree(
      studentId: userId,
      teacherId: _teacherId,
      courseId: widget.courseId,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ok ? _onSuccess('تم تفعيل الكورس المجاني بنجاح!') : _showSnack('فشل التسجيل في الكورس، يرجى المحاولة مرة أخرى');
  }

  Future<void> _purchaseWithWallet() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    if (userId == null) {
      _showSnack('يرجى تسجيل الدخول أولاً');
      return;
    }
    final price = _price ?? 0.0;
    if (!_hasSufficientBalance) {
      _showSnack('رصيدك في الخزنة غير كافٍ لإتمام عملية الشراء');
      return;
    }

    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);
    try {
      await _walletRepo.purchaseCourse(
        userId: userId,
        courseId: widget.courseId,
        teacherId: _teacherId,
        price: price,
        courseTitle: _courseTitle,
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _onSuccess('تم شراء الكورس بنجاح وخصم المبلغ من خزنتك!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showSnack(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _openWalletToRecharge() {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, AppRouter.studentWallet)
        .then((_) => _fetchWalletBalance());
  }

  @override
  Widget build(BuildContext context) {
    final price = _price ?? 0.0;
    final remainingAfter = _walletBalance - price;
    final neededAmount = price - _walletBalance;

    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: _isFree ? 'تسجيل الكورس المجاني' : 'الاشتراك في الكورس',
        subtitle: _isFree ? 'انضم للكورس وابدأ التعلم الآن' : 'الدفع المباشر من رصيد خزنة الطالب الرقمية',
      ),
      body: Stack(
        children: [
          NotebookPaper(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 140.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CourseSummaryCard(courseTitle: widget.courseTitle, price: widget.price),
                  SizedBox(height: 20.h),
                  if (!_isFree) ...[
                    // بطاقة الدفع المباشر من الخزنة
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: _hasSufficientBalance
                              ? NotebookColors.green
                              : const Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(9.r),
                                decoration: BoxDecoration(
                                  color: NotebookColors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: NotebookColors.green,
                                  size: 22.r,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الدفع من رصيد الخزنة',
                                      style: NotebookText.strong(13.sp, color: NotebookColors.ink),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_isLoadingWallet)
                                      Text('جاري فحص الرصيد...', style: TextStyle(fontSize: 10.5.sp, color: NotebookColors.pencil))
                                    else
                                      Text(
                                        'رصيدك المتاح: ${_walletBalance.toStringAsFixed(2)} ج.م',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.w800,
                                          color: _hasSufficientBalance
                                              ? const Color(0xFF10B981)
                                              : NotebookColors.marginRed,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              TextButton(
                                onPressed: _openWalletToRecharge,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  backgroundColor: NotebookColors.green.withValues(alpha: 0.08),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 15.r, color: NotebookColors.green),
                                    SizedBox(width: 2.w),
                                    Text(
                                      _hasSufficientBalance ? 'الخزنة' : 'شحن ⚡',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: NotebookColors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),
                          Divider(color: NotebookColors.rulerCard, height: 1),
                          SizedBox(height: 14.h),

                          // تفاصيل الحساب المالي
                          _buildDetailRow(
                            title: 'سعر الكورس المطلوب:',
                            value: '${price.toStringAsFixed(2)} ج.م',
                            isBold: true,
                          ),
                          SizedBox(height: 8.h),
                          _buildDetailRow(
                            title: 'رصيد خزنتك الحالي:',
                            value: '${_walletBalance.toStringAsFixed(2)} ج.م',
                            valueColor: _hasSufficientBalance ? const Color(0xFF10B981) : NotebookColors.marginRed,
                          ),
                          SizedBox(height: 8.h),

                          if (_hasSufficientBalance) ...[
                            _buildDetailRow(
                              title: 'الرصيد المتبقي بعد الاشتراك:',
                              value: '${remainingAfter.toStringAsFixed(2)} ج.م',
                              valueColor: NotebookColors.ink,
                            ),
                          ] else ...[
                            _buildDetailRow(
                              title: 'المبلغ المطلوب شحنه:',
                              value: '${neededAmount.toStringAsFixed(2)} ج.م',
                              valueColor: NotebookColors.marginRed,
                              isBold: true,
                            ),
                          ],

                          SizedBox(height: 16.h),

                          // رسالة التنبيه
                          if (_hasSufficientBalance)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 18),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'رصيدك كافٍ! اضغط على الزر بالأسفل لإتمام الاشتراك فورياً.',
                                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF15803D), fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, color: NotebookColors.marginRed, size: 18.r),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      'رصيدك غير كافٍ. اضغط على «شحن الخزنة» لإدخال كارت شحن السنتر ثم ارجع للدفع.',
                                      style: TextStyle(fontSize: 11.sp, color: NotebookColors.marginRed, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // إرشادات الشحن
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, color: NotebookColors.pencil, size: 18.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              '💡 يتم شحن الرصيد من خلال كروت شحن المنصة المتوفرة في السنتر، عبر مسح أو كتابة كود الكارت داخل تبويب «الخزنة».',
                              style: TextStyle(fontSize: 10.5.sp, color: NotebookColors.pencil, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const FreeCourseBanner(),
                ],
              ),
            ),
          ),

          // زر الدفع السفلي
          PaymentActionButton(
            isFree: _isFree,
            isProcessing: _isProcessing,
            label: _isFree
                ? 'التسجيل وبدء المشاهدة الآن'
                : (_hasSufficientBalance
                    ? 'تأكيد الدفع من الخزنة (${price.toStringAsFixed(2)} ج.م)'
                    : 'شحن الخزنة (${neededAmount.toStringAsFixed(2)} ج.م مطلوبة)'),
            icon: _isFree
                ? Icons.play_circle_fill_rounded
                : (_hasSufficientBalance ? Icons.account_balance_wallet_rounded : Icons.bolt_rounded),
            onPressed: _isProcessing
                ? null
                : (_isFree
                    ? _enrollFree
                    : (_hasSufficientBalance ? _purchaseWithWallet : _openWalletToRecharge)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: NotebookColors.pencil,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? NotebookColors.ink,
          ),
        ),
      ],
    );
  }
}
