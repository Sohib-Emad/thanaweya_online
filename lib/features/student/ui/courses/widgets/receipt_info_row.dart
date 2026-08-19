import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A single row in the receipt info table with label and value.
class ReceiptInfoRow extends StatelessWidget {
  const ReceiptInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  /// Row label text.
  final String label;

  /// Row value text.
  final String value;

  /// Whether to render the value in green heading style.
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: NotebookText.note(12.sp)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: isHighlighted
                ? NotebookText.heading(15.sp, color: NotebookColors.green)
                : NotebookText.strong(12.sp),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
