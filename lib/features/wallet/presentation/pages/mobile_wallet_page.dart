import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_colors.dart';
import 'package:thanaweya_online/core/theme/notebook_text.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../widgets/wallet_balance_card.dart';
import '../widgets/wallet_recharge_card_form.dart';
import '../widgets/wallet_transactions_list.dart';

class MobileWalletPage extends StatelessWidget {
  const MobileWalletPage({super.key, this.isTabMode = false});

  final bool isTabMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletCubit()..loadWallet(),
      child: _MobileWalletPageView(isTabMode: isTabMode),
    );
  }
}

class _MobileWalletPageView extends StatelessWidget {
  const _MobileWalletPageView({this.isTabMode = false});

  final bool isTabMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !isTabMode,
        title: Text(
          'خزنة الطالب (المحفظة)',
          style: NotebookText.strong(16.sp, color: NotebookColors.ink),
        ),
        leading: isTabMode
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: NotebookColors.ink, size: 18.r),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: NotebookText.strong(12.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: NotebookColors.marginRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<WalletCubit>().clearMessages();
          }

          if (state.successMessage != null && state.successMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: NotebookText.strong(12.sp, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<WalletCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          final cubit = context.read<WalletCubit>();

          return RefreshIndicator(
            color: NotebookColors.green,
            onRefresh: () async {
              HapticFeedback.lightImpact();
              await cubit.loadWallet();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. بطاقة الرصيد والإحصائيات
                  WalletBalanceCard(
                    balance: state.wallet.currentBalance,
                    totalRecharged: state.wallet.totalRecharged,
                    totalSpent: state.wallet.totalSpent,
                    isVisible: state.isBalanceVisible,
                    onToggleVisibility: cubit.toggleBalanceVisibility,
                  ),
                  SizedBox(height: 20.h),

                  // 2. نموذج شحن الكارت
                  WalletRechargeCardForm(
                    isRecharging: state.isRecharging,
                    onRecharge: (code) => cubit.rechargeWithCard(code),
                  ),
                  SizedBox(height: 24.h),

                  // 3. قسم سجل العمليات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            size: 20.r,
                            color: NotebookColors.ink,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'سجل العمليات المالية',
                            style: NotebookText.strong(14.sp, color: NotebookColors.ink),
                          ),
                        ],
                      ),
                      if (state.wallet.transactions.isNotEmpty)
                        Text(
                          '${state.wallet.transactions.length} حركة',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: NotebookColors.pencil,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // قائمة الحركات
                  if (state.status == WalletStatus.loading && state.wallet.transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: CircularProgressIndicator(color: NotebookColors.green),
                      ),
                    )
                  else
                    WalletTransactionsList(
                      transactions: state.wallet.transactions,
                    ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
