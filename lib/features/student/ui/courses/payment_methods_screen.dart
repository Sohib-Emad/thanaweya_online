import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';

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
            style: NotebookText.strong(15.sp),
          ),
          content: Text(
            'هل تريد حذف هذه البطاقة؟',
            style: NotebookText.body(13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'إلغاء',
                style: NotebookText.strong(13.sp),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'حذف',
                style: NotebookText.strong(
                  13.sp,
                  color: NotebookColors.marginRed,
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
            borderRadius: BorderRadius.circular(18.r),
          ),
          backgroundColor: NotebookColors.surface,
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Celebration Icon Graphic Container
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

                // Stars row
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
                Text(
                  'تهانينا',
                  style: NotebookText.heading(20.sp),
                ),
                SizedBox(height: 6.h),
                Text(
                  'تم الاشتراك في الكورس بنجاح.\nيمكنك الآن البدء في دراسة المحاضرات',
                  textAlign: TextAlign.center,
                  style: NotebookText.body(13.sp),
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
                    'مشاهدة المحاضرات الآن',
                    style: NotebookText.strong(
                      14.sp,
                      color: NotebookColors.green,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // E-Receipt action
                NotebookPrimaryButton(
                  label: 'إيصال الدفع الإلكتروني',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(
                      context,
                      AppRouter.studentHome,
                    );
                  },
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
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'وسائل الدفع',
          subtitle: 'اختر وسيلة الدفع المناسبة',
        ),
        body: Stack(
          children: [
            NotebookPaper(
              child: BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
                bloc: _cubit,
                builder: (context, state) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 120.h),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NotebookHighlightNote(
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                color: NotebookColors.ink,
                                size: 16.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'اختر وسيلة الدفع ثم أكد اشتراكك',
                                  style: NotebookText.strong(12.sp),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 22.h),

                        const NotebookSectionHeader(
                          title: 'وسائل الدفع المحفوظة',
                        ),
                        SizedBox(height: 14.h),

                        if (state.methodsStatus ==
                                StudentPaymentsStatus.loading &&
                            state.paymentMethods.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.h),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: NotebookColors.green,
                              ),
                            ),
                          )
                        else if (state.paymentMethods.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24.h),
                            child: NotebookEmptyNote(
                              icon: Icons.credit_card_off_rounded,
                              message:
                                  'لا توجد وسائل دفع محفوظة بعد — أضف بطاقة من صفحة خيارات الدفع',
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
                                    (isDefault &&
                                        _selectedMethodId.isEmpty);

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: NotebookCard(
                                ruled: true,
                                ruledStartY: 84,
                                marginTab: isSelected,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedMethodId = id);
                                  _cubit.setDefault(_userId, id);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40.r,
                                      height: 40.r,
                                      decoration: BoxDecoration(
                                        color: NotebookColors.surfaceBright,
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        border: Border.all(
                                          color: isSelected
                                              ? NotebookColors.green
                                                  .withAlpha(90)
                                              : NotebookColors.ink
                                                  .withAlpha(30),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.credit_card_rounded,
                                        color: isSelected
                                            ? NotebookColors.green
                                            : NotebookColors.pencil,
                                        size: 22.r,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cardHolder,
                                            style:
                                                NotebookText.heading(13.sp),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 2.h),
                                          Text(
                                            subtitle,
                                            style: NotebookText.note(10.sp),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                                          color: NotebookColors.pencil,
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
                                            ? NotebookColors.green
                                            : NotebookColors.surfaceBright,
                                        border: Border.all(
                                          color: isSelected
                                              ? NotebookColors.green
                                              : NotebookColors.ink
                                                  .withAlpha(60),
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
            ),

            // Floating Bottom Action Button
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: NotebookPrimaryButton(
                  label: 'تأكيد الاشتراك',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    _showSuccessDialog();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
