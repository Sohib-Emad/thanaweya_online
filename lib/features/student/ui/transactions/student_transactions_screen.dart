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
import '../../../../core/theme/notebook_theme.dart';

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
        label: 'قيد الانتظار',
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
        label: 'فشل',
        bg: const Color(0xFFFEE2E2),
        border: const Color(0xFFFECACA),
        fg: const Color(0xFFDC2626),
      );
    }
    return (
      label: 'مدفوع',
      bg: const Color(0xFFE6F7F2),
      border: const Color(0xFFA7F3D0),
      fg: const Color(0xFF0FA37F),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'المعاملات المالية',
          subtitle: 'سجل المدفوعات والاشتراكات',
          automaticallyImplyBack: widget.showBackButton,
          actions: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                color: NotebookColors.ink,
                size: 20.r,
              ),
              onPressed: () {},
            ),
            SizedBox(width: 12.w),
          ],
        ),
        body: BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == StudentPaymentsStatus.loading &&
                state.payments.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: NotebookColors.green),
              );
            }
            if (state.status == StudentPaymentsStatus.error &&
                state.payments.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: NotebookEmptyNote(
                    icon: Icons.error_outline_rounded,
                    message: state.errorMessage ?? 'حدث خطأ في تحميل المعاملات',
                  ),
                ),
              );
            }
            if (state.payments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: NotebookEmptyNote(
                  icon: Icons.receipt_long_rounded,
                  message: 'لا توجد معاملات بعد\nستظهر هنا مدفوعاتك عند اشتراكك في الكورسات',
                ),
              );
            }
            return NotebookPaper(
              child: RefreshIndicator(
                onRefresh: _loadPayments,
                color: NotebookColors.green,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 30.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.payments.length,
                  itemBuilder: (context, index) {
                    final payment = state.payments[index];
                    final plan =
                        payment['subscription_plans']
                            as Map<String, dynamic>? ??
                        {};
                    final title =
                        plan['name'] as String? ?? 'اشتراك';
                    final gateway =
                        payment['payment_gateway'] as String? ?? 'دفع إلكتروني';
                    final amount = _formatAmount(payment['amount']);
                    final date = _formatDate(payment['created_at'] as String?);
                    final statusStyle = _statusStyle(
                      payment['status'] as String?,
                    );
                    final color = _palette[index % _palette.length];
                    final user = Supabase.instance.client.auth.currentUser;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: NotebookCard(
                        ruled: true,
                        ruledStartY: 84,
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
                        child: Row(
                          children: [
                            // Receipt index box
                            Container(
                              width: 60.r,
                              height: 60.r,
                              decoration: BoxDecoration(
                                color: color.withAlpha(18),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: color.withAlpha(90),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: color,
                                  size: 28.r,
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
                                    style: NotebookText.heading(13.sp),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    gateway,
                                    style: NotebookText.note(10.sp),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusStyle.bg,
                                          borderRadius:
                                              BorderRadius.circular(5.r),
                                          border: Border.all(
                                            color: statusStyle.border,
                                          ),
                                        ),
                                        child: Text(
                                          statusStyle.label,
                                          style: NotebookText.strong(
                                            10.sp,
                                            color: statusStyle.fg,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        date,
                                        style: NotebookText.note(10.sp),
                                      ),
                                    ],
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
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.studentPrimary,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_left_rounded,
                                  color: NotebookColors.pencil,
                                  size: 18.r,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
