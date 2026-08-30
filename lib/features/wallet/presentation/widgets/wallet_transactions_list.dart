import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:thanaweya_online/core/theme/notebook_colors.dart';
import 'package:thanaweya_online/core/theme/notebook_text.dart';
import '../../domain/entities/wallet_transaction_entity.dart';

class WalletTransactionsList extends StatelessWidget {
  final List<WalletTransactionEntity> transactions;

  const WalletTransactionsList({
    super.key,
    required this.transactions,
  });

  String _formatDate(DateTime dt) {
    return DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: NotebookColors.rulerCard),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: NotebookColors.ground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 32.r,
                color: NotebookColors.pencil.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'لا توجد حركات مالية مسجلة بعد',
              style: NotebookText.strong(13.sp, color: NotebookColors.ink),
            ),
            SizedBox(height: 4.h),
            Text(
              'ستظهر هنا جميع عمليات شحن الكروت وشراء الكورسات فور إتمامها',
              style: NotebookText.note(11.sp, color: NotebookColors.pencil),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final tx = transactions[index];
        final isCredit = tx.isCredit;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: NotebookColors.rulerCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: isCredit
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isCredit
                      ? Icons.add_circle_outline_rounded
                      : Icons.remove_circle_outline_rounded,
                  color: isCredit
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),

              // Title and Subtitle / Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: NotebookText.strong(12.sp, color: NotebookColors.ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tx.subtitle != null && tx.subtitle!.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        tx.subtitle!,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: NotebookColors.pencil,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(tx.createdAt),
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: NotebookColors.pencil.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Amount Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? "+" : "-"}${tx.amount.toStringAsFixed(2)} ج.م',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: isCredit
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? const Color(0xFF10B981).withValues(alpha: 0.08)
                          : const Color(0xFFEF4444).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      isCredit ? 'إيداع' : 'خصم',
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: isCredit
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
