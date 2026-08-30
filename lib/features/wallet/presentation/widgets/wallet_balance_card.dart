import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_colors.dart';

class WalletBalanceCard extends StatelessWidget {
  final double balance;
  final double totalRecharged;
  final double totalSpent;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const WalletBalanceCard({
    super.key,
    required this.balance,
    required this.totalRecharged,
    required this.totalSpent,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Safe / Wallet Label + Visibility Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: NotebookColors.green.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: NotebookColors.green,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'رصيد الخزنة المتاح',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.white.withValues(alpha: 0.75),
                  size: 20.r,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onToggleVisibility();
                },
                tooltip: isVisible ? 'إخفاء الرصيد' : 'إظهار الرصيد',
              ),
            ],
          ),
          SizedBox(height: 14.h),

          // Main Balance Display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                isVisible ? balance.toStringAsFixed(2) : '••••••',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: isVisible ? 0.5 : 2.0,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'ج.م',
                style: TextStyle(
                  color: NotebookColors.green,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          SizedBox(height: 16.h),

          // Two Sub-stats: Total Recharged & Total Spent
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  title: 'إجمالي المشحون',
                  amount: isVisible ? '+${totalRecharged.toStringAsFixed(2)} ج.م' : '••••',
                  icon: Icons.arrow_downward_rounded,
                  accentColor: const Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatBox(
                  title: 'إجمالي المصروفات',
                  amount: isVisible ? '-${totalSpent.toStringAsFixed(2)} ج.م' : '••••',
                  icon: Icons.arrow_upward_rounded,
                  accentColor: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color accentColor;

  const _StatBox({
    required this.title,
    required this.amount,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 14.r,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  amount,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
