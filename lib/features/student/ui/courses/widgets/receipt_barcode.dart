import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// Barcode graphic and numeric ID displayed on the receipt.
class ReceiptBarcode extends StatelessWidget {
  const ReceiptBarcode({super.key, required this.transactionId});

  /// The transaction ID to show below the barcode.
  final String transactionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72.r,
          height: 72.r,
          decoration: BoxDecoration(
            color: NotebookColors.green.withAlpha(20),
            shape: BoxShape.circle,
            border: Border.all(
              color: NotebookColors.green.withAlpha(80),
              width: 1.4,
            ),
          ),
          child: Center(
            child: Icon(Icons.check_circle_rounded, color: NotebookColors.green, size: 44.r),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            32,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: (index % 4 == 0) ? 2.w : 1.w),
              width: (index % 3 == 0) ? 3.w : (index % 2 == 0) ? 2.w : 1.w,
              height: 48.h,
              color: NotebookColors.ink,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          transactionId,
          style: NotebookText.body(12.sp).copyWith(letterSpacing: 2),
        ),
      ],
    );
  }
}
