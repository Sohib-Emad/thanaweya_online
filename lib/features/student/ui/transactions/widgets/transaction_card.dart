import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/theme/notebook_theme.dart';
import 'transaction_status_helper.dart';

/// A single transaction receipt card with title, gateway, status, and price.
class TransactionCard extends StatelessWidget {
  final Color color;
  final String title;
  final String gateway;
  final String amount;
  final String date;
  final TransactionStatusStyle statusStyle;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.color,
    required this.title,
    required this.gateway,
    required this.amount,
    required this.date,
    required this.statusStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: NotebookCard(
        ruled: true,
        ruledStartY: 84,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Row(
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                color: color.withAlpha(18),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: color.withAlpha(90),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: color,
                  size: 28.r,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: NotebookText.heading(13.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    gateway,
                    style: NotebookText.note(10.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusStyle.bg,
                          borderRadius: BorderRadius.circular(5.r),
                          border: Border.all(color: statusStyle.border),
                        ),
                        child: Text(
                          statusStyle.label,
                          style: NotebookText.strong(
                            10.sp,
                            color: statusStyle.fg,
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(date, style: NotebookText.note(10.sp)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.studentPrimary,
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: NotebookColors.pencil,
                  size: 18.r,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
