import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/receipt_menu_button.dart';
import 'widgets/receipt_status_badge.dart';
import '../courses/widgets/receipt_barcode.dart';
import '../courses/widgets/receipt_info_row.dart';

class EReceiptScreen extends StatelessWidget {
  final Map<String, dynamic>? transactionData;

  const EReceiptScreen({super.key, this.transactionData});

  @override
  Widget build(BuildContext context) {
    final title = transactionData?['title'] ?? '';
    final category = transactionData?['category'] ?? '';
    final price = transactionData?['price'] ?? '';
    final date = transactionData?['date'] ?? '';
    final studentName = transactionData?['studentName'] ?? '';
    final email = transactionData?['email'] ?? '';
    final transactionId = transactionData?['id'] ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: context.l10n.receiptTitle,
          subtitle: context.l10n.receiptSubtitle,
          actions: [
            ReceiptMenuButton(onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  '${context.l10n.actionExecuted}$value',
                  style: NotebookText.strong(13.sp, color: Colors.white),
                ),
                backgroundColor: NotebookColors.green,
                behavior: SnackBarBehavior.floating,
              ));
            }),
          ],
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                _buildReceiptCard(context, studentName, email, title, category, transactionId, price, date),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(
    BuildContext context, String studentName, String email,
    String title, String category, String transactionId,
    String price, String date,
  ) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 96,
      marginTab: true,
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          ReceiptBarcode(transactionId: transactionId),
          SizedBox(height: 20.h),
          Container(height: 1, color: NotebookColors.ink.withAlpha(35)),
          SizedBox(height: 16.h),
          ReceiptInfoRow(label: context.l10n.studentNameLabel, value: studentName),
          SizedBox(height: 14.h),
          ReceiptInfoRow(label: context.l10n.emailLabel, value: email),
          SizedBox(height: 14.h),
          ReceiptInfoRow(label: context.l10n.courseNameLabel, value: title),
          SizedBox(height: 14.h),
          ReceiptInfoRow(label: context.l10n.categoryLabel, value: category),
          SizedBox(height: 14.h),
          _buildTransactionIdRow(context, transactionId),
          SizedBox(height: 14.h),
          ReceiptInfoRow(label: context.l10n.amountPaidLabel, value: price, isHighlighted: true),
          SizedBox(height: 14.h),
          ReceiptInfoRow(label: context.l10n.transactionDateLabel, value: date),
          SizedBox(height: 14.h),
          ReceiptStatusBadge(label: context.l10n.paidStatus),
        ],
      ),
    );
  }

  Widget _buildTransactionIdRow(BuildContext context, String transactionId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(context.l10n.transactionNumberLabel, style: NotebookText.note(12.sp)),
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  transactionId,
                  style: NotebookText.strong(13.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: transactionId));
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.transactionIdCopied, style: NotebookText.strong(13.sp, color: Colors.white)),
                    duration: const Duration(seconds: 1),
                    backgroundColor: NotebookColors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                child: Icon(Icons.copy_rounded, color: NotebookColors.green, size: 16.r),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
