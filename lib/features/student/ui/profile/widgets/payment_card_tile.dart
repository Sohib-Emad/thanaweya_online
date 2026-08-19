import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A tile widget displaying a saved payment card with holder name and last-4.
class PaymentCardTile extends StatelessWidget {
  /// Creates a [PaymentCardTile].
  const PaymentCardTile({
    super.key,
    required this.cardHolder,
    required this.cardLast4,
    required this.isDefault,
    this.defaultLabel = 'Default',
    this.connectedLabel = 'Connected',
  });

  /// The name of the card holder.
  final String cardHolder;

  /// The last four digits of the card number.
  final String cardLast4;

  /// Whether this is the default payment method.
  final bool isDefault;

  /// Label shown when the card is the default.
  final String defaultLabel;

  /// Label shown when the card is not the default.
  final String connectedLabel;

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 40,
      marginTab: isDefault,
      borderRadius: 12,
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          _buildIcon(),
          SizedBox(width: 14.w),
          Expanded(child: _buildInfo()),
          _buildBadge(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: NotebookColors.surfaceBright,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: NotebookColors.ink.withAlpha(28),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.credit_card_rounded,
        color: NotebookColors.ink,
        size: 24.r,
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(cardHolder, style: NotebookText.strong(13.sp)),
        Text('•••• •••• •••• $cardLast4', style: NotebookText.note(12.sp)),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDefault ? NotebookColors.green : NotebookColors.surfaceBright,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDefault
              ? NotebookColors.green
              : NotebookColors.ink.withAlpha(40),
        ),
      ),
      child: Text(
        isDefault ? defaultLabel : connectedLabel,
        style: GoogleFonts.cairo(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: isDefault ? Colors.white : NotebookColors.pencil,
        ),
      ),
    );
  }
}
