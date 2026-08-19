import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/certificate_card.dart';

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
    final metadataName = user?.userMetadata?['full_name']?.toString().trim() ?? '';
    return metadataName.isNotEmpty ? metadataName : 'Student';
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

    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: context.l10n.certificateTitle,
        subtitle: context.l10n.certificateSubtitle,
      ),
      body: NotebookPaper(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 110.h),
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: CertificateCard(
                  studentName: name,
                  courseTitle: courseTitle,
                  issueDate: date,
                  certificateId: certId,
                ),
              ),
            ),
            _buildDownloadButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: SafeArea(
        child: NotebookPrimaryButton(
          label: context.l10n.downloadCertificate,
          icon: Icons.download_rounded,
          onPressed: () {
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                context.l10n.certificateDownloaded,
                style: NotebookText.strong(13.sp, color: Colors.white),
              ),
              backgroundColor: NotebookColors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ));
          },
        ),
      ),
    );
  }
}
