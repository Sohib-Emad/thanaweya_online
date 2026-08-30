import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Floating action button at the bottom of the payment screen.
class PaymentActionButton extends StatelessWidget {
  final bool isFree;
  final bool isProcessing;
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const PaymentActionButton({
    super.key,
    required this.isFree,
    required this.isProcessing,
    this.label,
    this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final defaultLabel = isFree ? 'التسجيل وبدء المشاهدة الآن' : 'الدفع من الخزنة والبدء فوراً';
    final defaultIcon = isFree ? Icons.play_circle_fill_rounded : Icons.account_balance_wallet_rounded;

    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: SafeArea(
        child: NotebookPrimaryButton(
          label: isProcessing
              ? (isFree ? 'جاري التسجيل...' : 'جاري إتمام الدفع...')
              : (label ?? defaultLabel),
          icon: icon ?? defaultIcon,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
