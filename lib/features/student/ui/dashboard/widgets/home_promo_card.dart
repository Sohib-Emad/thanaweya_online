import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// A highlighted study note card showing today's offer with a discount stamp.
class HomePromoCard extends StatelessWidget {
  /// Creates a [HomePromoCard].
  const HomePromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: NotebookColors.surfaceBright,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: NotebookColors.ink.withAlpha(35)),
          boxShadow: [
            BoxShadow(
              color: NotebookColors.ink.withAlpha(14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                NotebookStamp(label: l10n.discountStamp),
                SizedBox(width: 12.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  color: NotebookColors.highlighter,
                  child: Text(
                    l10n.todaysOffer,
                    style: NotebookText.heading(15.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.todaysOfferMessage,
              style: NotebookText.note(11.sp),
            ),
          ],
        ),
      ),
    );
  }
}
