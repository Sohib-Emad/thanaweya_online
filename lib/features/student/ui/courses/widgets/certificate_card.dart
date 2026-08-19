import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// The main certificate card showing badge, student name, course, and signatures.
class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.studentName,
    required this.courseTitle,
    required this.issueDate,
    required this.certificateId,
  });

  final String studentName;
  final String courseTitle;
  final String issueDate;
  final String certificateId;

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true, ruledStartY: 150, marginTab: true, borderRadius: 14,
      padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 26.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            NotebookStamp(label: context.l10n.certificateTitle, color: NotebookColors.green),
          ]),
          SizedBox(height: 10.h),
          _Badge(),
          SizedBox(height: 14.h),
          Text(context.l10n.courseCompleted, style: NotebookText.heading(21.sp)),
          SizedBox(height: 8.h),
          Text(context.l10n.certWitness, textAlign: TextAlign.center, style: NotebookText.note(12.sp)),
          SizedBox(height: 18.h),
          Text(studentName, textAlign: TextAlign.center, style: NotebookText.heading(22.sp)),
          SizedBox(height: 6.h),
          Container(width: 160.w, height: 2, color: NotebookColors.marginRed),
          SizedBox(height: 18.h),
          Text(context.l10n.certCompleted, textAlign: TextAlign.center, style: NotebookText.note(12.sp)),
          SizedBox(height: 12.h),
          if (courseTitle.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: NotebookColors.surfaceBright, borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: NotebookColors.ink.withAlpha(40)),
              ),
              child: Text(courseTitle, textAlign: TextAlign.center, style: NotebookText.strong(14.sp)),
            ),
            SizedBox(height: 16.h),
          ],
          _DateRow(issueDate: issueDate, certificateId: certificateId),
          SizedBox(height: 20.h),
          Container(height: 1, color: NotebookColors.ink.withAlpha(50)),
          SizedBox(height: 16.h),
          _SignatureRow(),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64.r, height: 64.r,
      decoration: BoxDecoration(
        color: NotebookColors.green.withAlpha(20), shape: BoxShape.circle,
        border: Border.all(color: NotebookColors.green.withAlpha(90), width: 1.4),
      ),
      child: Icon(Icons.workspace_premium_rounded, color: NotebookColors.green, size: 32.r),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.issueDate, required this.certificateId});
  final String issueDate;
  final String certificateId;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(context.l10n.issueDateLabel(issueDate), style: NotebookText.note(11.sp)),
      if (certificateId.isNotEmpty) ...[
        SizedBox(width: 14.w),
        Container(width: 4, height: 4, decoration: const BoxDecoration(color: NotebookColors.pencil, shape: BoxShape.circle)),
        SizedBox(width: 14.w),
        Text(certificateId, style: NotebookText.note(11.sp)),
      ],
    ]);
  }
}

class _SignatureRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(context.l10n.studentSignature, style: NotebookText.note(10.sp)),
          SizedBox(height: 4.h),
          Container(width: 90.w, height: 2, color: NotebookColors.marginRed),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(context.l10n.platformManager, style: NotebookText.strong(12.sp)),
          SizedBox(height: 4.h),
          Container(width: 90.w, height: 2, color: NotebookColors.marginRed),
          SizedBox(height: 4.h),
          Text(context.l10n.platformName, style: NotebookText.note(10.sp)),
        ]),
      ],
    );
  }
}
