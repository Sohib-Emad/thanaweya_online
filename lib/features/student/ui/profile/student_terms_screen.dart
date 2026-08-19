import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/l10n/l10n.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

class StudentTermsScreen extends StatelessWidget {
  const StudentTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: context.l10n.termsTitle,
          subtitle: context.l10n.termsSubtitle,
        ),
        body: NotebookPaper(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NotebookSectionHeader(
                    title: context.l10n.attendanceTermsTitle),
                SizedBox(height: 12.h),
                NotebookCard(
                  ruled: true,
                  ruledStartY: 20,
                  borderRadius: 12,
                  child: Text(
                    context.l10n.attendanceTermsBody,
                    style: NotebookText.body(13.sp).copyWith(height: 1.6),
                  ),
                ),

                SizedBox(height: 24.h),

                NotebookSectionHeader(title: context.l10n.usageTermsTitle),
                SizedBox(height: 12.h),
                NotebookCard(
                  ruled: true,
                  ruledStartY: 20,
                  borderRadius: 12,
                  child: Text(
                    context.l10n.usageTermsBody,
                    style: NotebookText.body(13.sp).copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
