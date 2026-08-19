import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';
import '../../../../student/logic/student_payments_cubit.dart';
import '../../../../../l10n/l10n.dart';

/// Body widget that renders transaction list states (loading, error, empty, data).
class TransactionListBody extends StatelessWidget {
  final StudentPaymentsCubit cubit;
  final Future<void> Function() onRefresh;
  final Widget Function(Map<String, dynamic> payment, int index) cardBuilder;

  const TransactionListBody({
    super.key,
    required this.cubit,
    required this.onRefresh,
    required this.cardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentPaymentsCubit, StudentPaymentsState>(
      bloc: cubit,
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
                message: state.errorMessage ??
                    context.l10n.transactionsLoadError,
              ),
            ),
          );
        }
        if (state.payments.isEmpty) {
          return RefreshIndicator(
            onRefresh: onRefresh,
            color: NotebookColors.green,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 100.h,
                  ),
                  child: NotebookEmptyNote(
                    icon: Icons.receipt_long_rounded,
                    message: context.l10n.transactionsEmpty,
                  ),
                ),
              ],
            ),
          );
        }
        return NotebookPaper(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: NotebookColors.green,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 30.h),
              physics: const BouncingScrollPhysics(),
              itemCount: state.payments.length,
              itemBuilder: (context, index) =>
                  cardBuilder(state.payments[index], index),
            ),
          ),
        );
      },
    );
  }
}
