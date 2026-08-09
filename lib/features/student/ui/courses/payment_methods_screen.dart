import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

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
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  int _selectedTab = 0; // 0 = Activation Code, 1 = Electronic Payment
  String _selectedGateway = 'paymob'; // 'paymob' or 'fawry'

  bool get _isFree => widget.price == null || widget.price! <= 0;

  @override
  void dispose() {
    _codeController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NotebookColors.marginRed,
        content: Text(message, style: NotebookText.strong(12.sp)),
      ),
    );
  }

  Future<void> _redeemCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showSnack('أدخل كود التفعيل أولاً');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);
    final error = await _cubit.redeemActivationCode(code);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (error == null) {
      _showSuccessDialog();
    } else {
      _showSnack(error);
    }
  }

  void _openCourseLessons() {
    Navigator.pop(context);
    Navigator.pushReplacementNamed(
      context,
      AppRouter.studentCourseLessons,
      arguments: widget.courseId,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          backgroundColor: NotebookColors.surface,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: BoxDecoration(
                    color: NotebookColors.green.withAlpha(18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: NotebookColors.green.withAlpha(90),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    color: NotebookColors.green,
                    size: 40.r,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 22.r,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text('تهانينا', style: NotebookText.heading(20.sp)),
                SizedBox(height: 6.h),
                Text(
                  'تم تفعيل اشتراكك بنجاح.\nيمكنك الآن البدء في دراسة المحاضرات',
                  textAlign: TextAlign.center,
                  style: NotebookText.body(13.sp),
                ),
                SizedBox(height: 20.h),
                NotebookPrimaryButton(
                  label: 'مشاهدة المحاضرات الآن',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _openCourseLessons,
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.studentHome,
                    );
                  },
                  child: Text(
                    'العودة للرئيسية',
                    style: NotebookText.strong(
                      13.sp,
                      color: NotebookColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseSummary() {
    return NotebookCard(
      ruled: true,
      ruledStartY: 64,
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: NotebookColors.surfaceBright,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: NotebookColors.green.withAlpha(90),
                width: 1.2,
              ),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: NotebookColors.green,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseTitle.isEmpty
                      ? 'الاشتراك في الكورس'
                      : widget.courseTitle,
                  style: NotebookText.heading(13.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  _isFree ? 'كورس مجاني' : Formatters.formatEgp(widget.price),
                  style: NotebookText.strong(
                    12.sp,
                    color: _isFree
                        ? NotebookColors.green
                        : NotebookColors.marginRed,
                  ),
                ),
              ],
            ),
          ),
          if (!_isFree)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: NotebookColors.marginRed.withAlpha(14),
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: NotebookColors.marginRed.withAlpha(90),
                ),
              ),
              child: Text(
                'اشتراك كورس',
                style: NotebookText.strong(
                  11.sp,
                  color: NotebookColors.marginRed,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivationCodeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotebookHighlightNote(
          child: Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: NotebookColors.ink,
                size: 16.r,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'أدخل كود التفعيل الذي حصلت عليه من مدرسك',
                  style: NotebookText.strong(12.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Text('كود التفعيل', style: NotebookText.heading(13.sp)),
        SizedBox(height: 8.h),
        TextField(
          controller: _codeController,
          textAlign: TextAlign.center,
          style: NotebookText.heading(16.sp),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'مثال: TH-8921-X90',
            hintStyle: NotebookText.note(13.sp),
            filled: true,
            fillColor: NotebookColors.surfaceBright,
            contentPadding: EdgeInsets.symmetric(vertical: 16.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: NotebookColors.ink.withAlpha(40)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: NotebookColors.green, width: 1.6),
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'بعد التأكيد سيتم تفعيل اشتراكك فوراً في جميع كورسات المدرس',
          style: NotebookText.note(11.sp),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'تفعيل كود الاشتراك',
          subtitle: 'أدخل كود التفعيل للبدء في دراسة الكورس',
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
                    _buildCourseSummary(),
                    SizedBox(height: 18.h),
                    NotebookSegmentControl(
                      options: const ['كود التفعيل', 'الدفع الإلكتروني'],
                      index: _selectedTab,
                      onChanged: (i) => setState(() => _selectedTab = i),
                    ),
                    SizedBox(height: 22.h),
                    _selectedTab == 0
                        ? _buildActivationCodeTab()
                        : _buildElectronicPaymentTab(),
                  ],
                ),
              ),
            ),

            // Floating Bottom Action Button
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: NotebookPrimaryButton(
                  label: _isProcessing
                      ? (_selectedTab == 0 ? 'جارٍ تفعيل الكود...' : 'جارٍ معالجة الدفع...')
                      : (_selectedTab == 0 ? 'تفعيل الكود والاشتراك الآن' : 'تأكيد الدفع والاشتراك الآن'),
                  icon: _selectedTab == 0 ? Icons.card_giftcard_rounded : Icons.payment_rounded,
                  onPressed: _isProcessing ? null : _processPayment,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectronicPaymentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NotebookHighlightNote(
          child: Row(
            children: [
              Icon(
                Icons.credit_card_rounded,
                color: NotebookColors.ink,
                size: 16.r,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'ادفع بأمان وسهولة عبر الدفع الإلكتروني المباشر',
                  style: NotebookText.strong(12.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Gateway select
        Text('طريقة الدفع', style: NotebookText.heading(13.sp)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildGatewayChoice('paymob', 'بطاقة فيزا / ماستر كارد', Icons.credit_card_rounded),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildGatewayChoice('fawry', 'فوري للمدفوعات', Icons.storefront_rounded),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // Simulated credit card form if paymob is selected
        if (_selectedGateway == 'paymob') ...[
          Text('بيانات البطاقة', style: NotebookText.heading(13.sp)),
          SizedBox(height: 10.h),
          _buildTextField(_cardHolderController, 'اسم صاحب البطاقة', 'مثال: أحمد محمد علي'),
          SizedBox(height: 10.h),
          _buildTextField(_cardNumberController, 'رقم البطاقة', '4000 1234 5678 9010', keyboardType: TextInputType.number),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_expiryController, 'تاريخ الانتهاء', 'MM/YY', keyboardType: TextInputType.datetime),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(_cvvController, 'الرمز السري (CVV)', '123', isCvv: true, keyboardType: TextInputType.number),
              ),
            ],
          ),
        ] else ...[
          // Fawry instructions
          Container(
            padding: EdgeInsets.all(16.r),
            width: double.infinity,
            decoration: BoxDecoration(
              color: NotebookColors.surfaceBright,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: NotebookColors.ink.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الدفع عبر فوري',
                  style: NotebookText.strong(13.sp, color: NotebookColors.green),
                ),
                SizedBox(height: 6.h),
                Text(
                  'سيتم إصدار كود دفع فوري مؤقت لإتمام عملية الدفع في أي منفذ فوري.',
                  style: NotebookText.body(11.sp),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGatewayChoice(String val, String label, IconData icon) {
    final active = _selectedGateway == val;
    return GestureDetector(
      onTap: () => setState(() => _selectedGateway = val),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: active ? NotebookColors.green.withAlpha(18) : NotebookColors.surfaceBright,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: active ? NotebookColors.green : NotebookColors.ink.withAlpha(35),
            width: active ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? NotebookColors.green : NotebookColors.pencil, size: 20.r),
            SizedBox(height: 6.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: NotebookText.strong(10.sp, color: active ? NotebookColors.green : NotebookColors.pencil),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isCvv = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NotebookText.note(11.sp)),
        SizedBox(height: 4.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isCvv,
          style: NotebookText.body(13.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: NotebookText.note(12.sp).copyWith(color: NotebookColors.pencil.withAlpha(120)),
            filled: true,
            fillColor: NotebookColors.surfaceBright,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: NotebookColors.ink.withAlpha(35)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: NotebookColors.green, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    if (_selectedTab == 0) {
      _redeemCode();
      return;
    }

    if (_selectedGateway == 'paymob') {
      if (_cardHolderController.text.trim().isEmpty ||
          _cardNumberController.text.trim().isEmpty ||
          _expiryController.text.trim().isEmpty ||
          _cvvController.text.trim().isEmpty) {
        _showSnack('يرجى ملء جميع بيانات البطاقة');
        return;
      }
    }

    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    final success = await _cubit.subscribeWithPayment(
      teacherId: widget.teacherId,
      amount: widget.price ?? 100.0,
      courseId: widget.courseId,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _showSuccessDialog();
    } else {
      _showSnack(_cubit.state.errorMessage ?? 'تعذر إتمام الدفع الإلكتروني، حاول مرة أخرى');
    }
  }
}
