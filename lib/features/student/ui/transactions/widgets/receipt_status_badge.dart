import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Green "Paid" status badge shown on the receipt.
class ReceiptStatusBadge extends StatelessWidget {
  const ReceiptStatusBadge({super.key, required this.label});

  /// Status text to display.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.paymentStatusLabel, style: NotebookText.note(12.sp)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: NotebookColors.green.withAlpha(24),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: NotebookColors.green.withAlpha(90)),
          ),
          child: Text(
            label,
            style: NotebookText.strong(11.sp, color: NotebookColors.green),
          ),
        ),
      ],
    );
  }
}
