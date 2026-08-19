import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Floating action button at the bottom of the payment screen.
class PaymentActionButton extends StatelessWidget {
  final bool isFree;
  final bool isProcessing;
  final VoidCallback? onPressed;

  const PaymentActionButton({
    super.key,
    required this.isFree,
    required this.isProcessing,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: SafeArea(
        child: isFree
            ? NotebookPrimaryButton(
                label: isProcessing
                    ? 'جاري التسجيل...'
                    : 'التسجيل وبدء المشاهدة الآن',
                icon: Icons.play_circle_fill_rounded,
                onPressed: onPressed,
              )
            : NotebookPrimaryButton(
                label: isProcessing
                    ? 'جاري تفعيل الكود...'
                    : 'تفعيل الكورس والبدء فوراً',
                icon: Icons.vpn_key_rounded,
                onPressed: onPressed,
              ),
      ),
    );
  }
}
