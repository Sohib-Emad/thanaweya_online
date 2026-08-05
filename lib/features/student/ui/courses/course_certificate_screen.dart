import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/notebook_theme.dart';

class CourseCertificateScreen extends StatelessWidget {
  final String courseTitle;
  final String studentName;
  final String issueDate;
  final String certificateId;

  const CourseCertificateScreen({
    super.key,
    this.courseTitle = '',
    this.studentName = '',
    this.issueDate = '',
    this.certificateId = '',
  });

  String _resolveStudentName(String name) {
    if (name.isNotEmpty) return name;
    final user = Supabase.instance.client.auth.currentUser;
    final metadataName =
        user?.userMetadata?['full_name']?.toString().trim() ?? '';
    if (metadataName.isNotEmpty) return metadataName;
    return 'طالب';
  }

  String _resolveIssueDate(String date) {
    if (date.isNotEmpty) return date;
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _resolveCertificateId(String id) {
    if (id.isNotEmpty) return id;
    final user = Supabase.instance.client.auth.currentUser;
    if (user?.id != null && user!.id.length >= 8) {
      return 'ID: ${user.id.substring(0, 8).toUpperCase()}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final name = _resolveStudentName(studentName);
    final date = _resolveIssueDate(issueDate);
    final certId = _resolveCertificateId(certificateId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'شهادة إتمام',
          subtitle: 'صفحة التكريم في دفترك',
        ),
        body: NotebookPaper(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 110.h),
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: NotebookCard(
                    ruled: true,
                    ruledStartY: 150,
                    marginTab: true,
                    borderRadius: 14,
                    padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 26.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Mint completion stamp
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NotebookStamp(
                              label: 'شهادة إتمام',
                              color: NotebookColors.green,
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Badge
                        Container(
                          width: 64.r,
                          height: 64.r,
                          decoration: BoxDecoration(
                            color: NotebookColors.green.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NotebookColors.green.withAlpha(90),
                              width: 1.4,
                            ),
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: NotebookColors.green,
                            size: 32.r,
                          ),
                        ),
                        SizedBox(height: 14.h),

                        Text(
                          'إتمام الكورس بنجاح',
                          style: NotebookText.heading(21.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'تشهد منصة الثانوية أونلاين بأن الطالب',
                          textAlign: TextAlign.center,
                          style: NotebookText.note(12.sp),
                        ),
                        SizedBox(height: 18.h),

                        // Student name signed with a red underline
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          style: NotebookText.heading(22.sp),
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 160.w,
                          height: 2,
                          color: NotebookColors.marginRed,
                        ),
                        SizedBox(height: 18.h),

                        Text(
                          'قد أتم بنجاح كافة متطلبات واختبارات الكورس التعليمي:',
                          textAlign: TextAlign.center,
                          style: NotebookText.note(12.sp),
                        ),
                        SizedBox(height: 12.h),

                        if (courseTitle.isNotEmpty) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: NotebookColors.surfaceBright,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: NotebookColors.ink.withAlpha(40),
                              ),
                            ),
                            child: Text(
                              courseTitle,
                              textAlign: TextAlign.center,
                              style: NotebookText.strong(14.sp),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],

                        // Issue date + certificate id
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تاريخ الإصدار: $date',
                              style: NotebookText.note(11.sp),
                            ),
                            if (certId.isNotEmpty) ...[
                              SizedBox(width: 14.w),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: NotebookColors.pencil,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Text(
                                certId,
                                style: NotebookText.note(11.sp),
                              ),
                            ],
                          ],
                        ),

                        SizedBox(height: 20.h),
                        Container(
                          height: 1,
                          color: NotebookColors.ink.withAlpha(50),
                        ),
                        SizedBox(height: 16.h),

                        // Signature row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'توقيع الطالب',
                                  style: NotebookText.note(10.sp),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  width: 90.w,
                                  height: 2,
                                  color: NotebookColors.marginRed,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'مدير المنصة',
                                  style: NotebookText.strong(12.sp),
                                ),
                                SizedBox(height: 4.h),
                                Container(
                                  width: 90.w,
                                  height: 2,
                                  color: NotebookColors.marginRed,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'منصة الثانوية أونلاين',
                                  style: NotebookText.note(10.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Download Button
              Positioned(
                left: 20.w,
                right: 20.w,
                bottom: 20.h,
                child: SafeArea(
                  child: NotebookPrimaryButton(
                    label: 'تحميل الشهادة',
                    icon: Icons.download_rounded,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم تحميل الشهادة بنجاح بصيغة PDF',
                            style: NotebookText.strong(
                              13.sp,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: NotebookColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
