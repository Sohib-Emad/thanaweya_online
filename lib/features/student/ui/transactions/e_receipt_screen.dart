import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

class EReceiptScreen extends StatelessWidget {
  final Map<String, dynamic>? transactionData;

  const EReceiptScreen({
    super.key,
    this.transactionData,
  });

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
          title: 'إيصال الدفع الإلكتروني',
          subtitle: 'نسخة من الإيصال على صفحة دفترك',
          actions: [
            PopupMenuButton<String>(
              icon: Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: NotebookColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NotebookColors.ink.withAlpha(50),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: NotebookColors.ink,
                  size: 20.r,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 6,
              onSelected: (value) {
                HapticFeedback.mediumImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تنفيذ الأمر: $value',
                      style: NotebookText.strong(13.sp, color: Colors.white),
                    ),
                    backgroundColor: NotebookColors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'مشاركة الإيصال',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مشاركة',
                        style: NotebookText.strong(13.sp),
                      ),
                      Icon(
                        Icons.send_rounded,
                        size: 18.r,
                        color: NotebookColors.green,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'تحميل PDF',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تحميل',
                        style: NotebookText.strong(13.sp),
                      ),
                      Icon(
                        Icons.download_rounded,
                        size: 18.r,
                        color: NotebookColors.green,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'طباعة الإيصال',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'طباعة',
                        style: NotebookText.strong(13.sp),
                      ),
                      Icon(
                        Icons.print_rounded,
                        size: 18.r,
                        color: NotebookColors.pencil,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Ruled Receipt Page Card
                NotebookCard(
                  ruled: true,
                  ruledStartY: 96,
                  marginTab: true,
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      // Verified Check Illustration
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
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: NotebookColors.green,
                            size: 44.r,
                          ),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      // Barcode graphic
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          32,
                          (index) => Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: (index % 4 == 0) ? 2.w : 1.w,
                            ),
                            width: (index % 3 == 0)
                                ? 3.w
                                : (index % 2 == 0)
                                    ? 2.w
                                    : 1.w,
                            height: 48.h,
                            color: NotebookColors.ink,
                          ),
                        ),
                      ),

                      SizedBox(height: 8.h),

                      // Barcode Numbers (real transaction id)
                      Text(
                        transactionId,
                        style: NotebookText.body(12.sp)
                            .copyWith(letterSpacing: 2),
                      ),

                      SizedBox(height: 20.h),
                      Container(
                        height: 1,
                        color: NotebookColors.ink.withAlpha(35),
                      ),
                      SizedBox(height: 16.h),

                      // Receipt Info Table
                      _buildReceiptRow('اسم الطالب', studentName),
                      SizedBox(height: 14.h),
                      _buildReceiptRow('البريد الإلكتروني', email),
                      SizedBox(height: 14.h),
                      _buildReceiptRow('اسم الكورس', title),
                      SizedBox(height: 14.h),
                      _buildReceiptRow('التصنيف', category),
                      SizedBox(height: 14.h),

                      // Transaction ID with copy button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'رقم المعاملة',
                            style: NotebookText.note(12.sp),
                          ),
                          Row(
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
                                  Clipboard.setData(
                                    ClipboardData(text: transactionId),
                                  );
                                  HapticFeedback.lightImpact();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم نسخ رقم المعاملة',
                                        style: NotebookText.strong(
                                          13.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: NotebookColors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.copy_rounded,
                                  color: NotebookColors.green,
                                  size: 16.r,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      _buildReceiptRow(
                        'المبلغ المدفوع',
                        price,
                        isBoldPrice: true,
                      ),
                      SizedBox(height: 14.h),
                      _buildReceiptRow('تاريخ المعاملة', date),
                      SizedBox(height: 14.h),

                      // Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حالة الدفع',
                            style: NotebookText.note(12.sp),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: NotebookColors.green.withAlpha(24),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: NotebookColors.green.withAlpha(90),
                              ),
                            ),
                            child: Text(
                              'مدفوع',
                              style: NotebookText.strong(
                                11.sp,
                                color: NotebookColors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBoldPrice = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: NotebookText.note(12.sp)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: isBoldPrice
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
