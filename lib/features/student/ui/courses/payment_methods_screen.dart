import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

import '../../../../core/router/app_router.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _userId = '';
  String _selectedMethodId = '';

  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_userId.isNotEmpty) {
      _cubit.loadPaymentMethods(_userId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  String _formatExpiry(int? month, int? year) {
    if (month == null || year == null) return '';
    final y = year > 99 ? year % 100 : year;
    return '${month.toString().padLeft(2, '0')}/${y.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteMethod(String methodId) async {
    if (_userId.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف وسيلة الدفع',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'هل تريد حذف هذه البطاقة؟',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'حذف',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) {
      await _cubit.deletePaymentMethod(_userId, methodId);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon Graphic Container
                Container(
                  width: 72.r,
                  height: 72.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    color: const Color(0xFF0FA37F),
                    size: 44.r,
                  ),
                ),
                SizedBox(height: 12.h),

                // Stars row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFFBBF24),
                      size: 24.r,
                    ),
                  ),
                ),

                SizedBox(height: 12.h),
                Text(
                  'تهانينا! 🎉 (Congratulations)',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'تم عملية الاشتراك وشراء الكورس بنجاح.\nيمكنك الآن البدء في دراسة المحاضرات!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 20.h),

                // Watch Course Button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.studentVideoPlayer,
                    );
                  },
                  child: Text(
                    'مشاهدة المحاضرات الآن 🎬',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0FA37F),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // E-Receipt Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.studentHome,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إيصال الدفع الإلكتروني (E-Receipt)',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 18.r,
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'وسائل الدفع (Payment Methods)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Stack(
          children: [
            BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
              bloc: _cubit,
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Summary Header Box
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60.r,
                              height: 60.r,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0FA37F).withAlpha(30),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.play_circle_fill_rounded,
                                color: const Color(0xFF0FA37F),
                                size: 32.r,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الفيزياء الكهربية ⚡',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0FA37F),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'مبادئ وتطبيقات الفيزياء الكهربية والدوائر',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'الإجمالي: 499 ج.م',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24.h),

                      Text(
                        'اختر طريقة الدفع المناسبة لك:',
                        style: GoogleFonts.cairo(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 14.h),

                      if (state.methodsStatus ==
                              StudentPaymentsStatus.loading &&
                          state.paymentMethods.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.h),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (state.paymentMethods.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 48.h),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card_off_rounded,
                                size: 64,
                                color: const Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                'لا توجد وسائل دفع محفوظة',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                'أضف بطاقة جديدة من صفحة خيارات الدفع',
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...state.paymentMethods.map((method) {
                          final id = method['id'] as String? ?? '';
                          final cardHolder =
                              method['card_holder'] as String? ??
                              'بطاقة مصرفية';
                          final cardLast4 =
                              method['card_last4'] as String? ?? '••••';
                          final brand =
                              method['card_brand'] as String? ?? 'Card';
                          final isDefault =
                              method['is_default'] as bool? ?? false;
                          final expiry = _formatExpiry(
                            method['expiry_month'] as int?,
                            method['expiry_year'] as int?,
                          );
                          final subtitle = [
                            '•••• $cardLast4',
                            brand,
                            if (expiry.isNotEmpty) expiry,
                          ].join(' • ');
                          final isSelected =
                              _selectedMethodId == id ||
                              (isDefault && _selectedMethodId.isEmpty);

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedMethodId = id);
                              _cubit.setDefault(_userId, id);
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 12.h),
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0FA37F)
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 42.r,
                                    height: 42.r,
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2563EB,
                                      ).withAlpha(20),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.credit_card_rounded,
                                      color: const Color(0xFF2563EB),
                                      size: 22.r,
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cardHolder,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          subtitle,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11.sp,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _deleteMethod(id),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      child: Icon(
                                        Icons.delete_outline_rounded,
                                        color: const Color(0xFF94A3B8),
                                        size: 20.r,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 22.r,
                                    height: 22.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF0FA37F)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF0FA37F)
                                            : const Color(0xFFCBD5E1),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 14.r,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                );
              },
            ),

            // Floating Bottom Action Button
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      _showSuccessDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      elevation: 4,
                      shadowColor: const Color(0x330FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Text(
                          'تأكيد ودفع 499 ج.م (Enroll Course)',
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: const Color(0xFF0FA37F),
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
