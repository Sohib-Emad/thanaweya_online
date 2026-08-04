import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_payments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_payments_cubit.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class StudentTransactionsScreen extends StatefulWidget {
  final bool showBackButton;

  const StudentTransactionsScreen({super.key, this.showBackButton = false});

  @override
  State<StudentTransactionsScreen> createState() =>
      _StudentTransactionsScreenState();
}

class _StudentTransactionsScreenState extends State<StudentTransactionsScreen> {
  final _cubit = StudentPaymentsCubit(repo: StudentPaymentsRepo());

  static const List<Color> _palette = [
    Color(0xFF0FA37F),
    Color(0xFF2563EB),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFF059669),
  ];

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _loadPayments() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadPayments(userId);
    }
  }

  String _formatAmount(dynamic amount) {
    final n = double.tryParse(amount?.toString() ?? '') ?? 0;
    final s = n == n.roundToDouble()
        ? n.toInt().toString()
        : n.toStringAsFixed(2);
    return '$s ج.م';
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  ({String label, Color bg, Color border, Color fg}) _statusStyle(
    String? status,
  ) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('pending') || s.contains('waiting') || s.contains('قيد')) {
      return (
        label: 'قيد الانتظار • Pending',
        bg: const Color(0xFFFEF3C7),
        border: const Color(0xFFFDE68A),
        fg: const Color(0xFFB45309),
      );
    }
    if (s.contains('failed') ||
        s.contains('refunded') ||
        s.contains('فشل') ||
        s.contains('ملغي')) {
      return (
        label: 'فشل • Failed',
        bg: const Color(0xFFFEE2E2),
        border: const Color(0xFFFECACA),
        fg: const Color(0xFFDC2626),
      );
    }
    return (
      label: 'مدفوع • Paid',
      bg: const Color(0xFFECFDF5),
      border: const Color(0xFFA7F3D0),
      fg: const Color(0xFF0FA37F),
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
          leading: widget.showBackButton
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: const Color(0xFF0F172A),
                    size: 20.r,
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          centerTitle: false,
          title: Text(
            'المعاملات المالية (Transactions)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: const Color(0xFF0F172A),
                size: 22.r,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == StudentPaymentsStatus.loading &&
                state.payments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == StudentPaymentsStatus.error &&
                state.payments.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text(
                    state.errorMessage ?? 'حدث خطأ في تحميل المعاملات',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              );
            }
            if (state.payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: const Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد معاملات بعد',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'ستظهر هنا مدفوعاتك عند اشتراكك في الكورسات',
                      style: GoogleFonts.cairo(
                        fontSize: 12.sp,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadPayments,
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
                physics: const BouncingScrollPhysics(),
                itemCount: state.payments.length,
                itemBuilder: (context, index) {
                  final payment = state.payments[index];
                  final plan =
                      payment['subscription_plans'] as Map<String, dynamic>? ??
                      {};
                  final title =
                      plan['name'] as String? ?? 'اشتراك (Subscription)';
                  final gateway =
                      payment['payment_gateway'] as String? ?? 'دفع إلكتروني';
                  final amount = _formatAmount(payment['amount']);
                  final date = _formatDate(payment['created_at'] as String?);
                  final statusStyle = _statusStyle(
                    payment['status'] as String?,
                  );
                  final color = _palette[index % _palette.length];
                  final user = Supabase.instance.client.auth.currentUser;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final receiptArgs = <String, dynamic>{
                        'id':
                            payment['gateway_transaction_id'] ??
                            payment['id'] ??
                            '',
                        'title': title,
                        'category': gateway,
                        'price': amount,
                        'date': date,
                        'status': statusStyle.label,
                      };
                      final email = user?.email;
                      if (email != null && email.isNotEmpty) {
                        receiptArgs['email'] = email;
                      }
                      Navigator.pushNamed(
                        context,
                        AppRouter.studentEReceipt,
                        arguments: receiptArgs,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 14.h),
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x060F172A),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Course Thumbnail
                          Container(
                            width: 64.r,
                            height: 64.r,
                            decoration: BoxDecoration(
                              color: color.withAlpha(20),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.receipt_long_rounded,
                                color: color,
                                size: 30.r,
                              ),
                            ),
                          ),

                          SizedBox(width: 14.w),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  gateway,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                                SizedBox(height: 6.h),

                                // Status Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusStyle.bg,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: statusStyle.border,
                                    ),
                                  ),
                                  child: Text(
                                    statusStyle.label,
                                    style: GoogleFonts.cairo(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w800,
                                      color: statusStyle.fg,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 8.w),

                          // Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                amount,
                                style: GoogleFonts.cairo(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.studentPrimary,
                                ),
                              ),
                              Icon(
                                Icons.chevron_left_rounded,
                                color: const Color(0xFF94A3B8),
                                size: 20.r,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
