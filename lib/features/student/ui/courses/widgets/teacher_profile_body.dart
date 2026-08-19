import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/teacher_about_tab.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/teacher_cover_card.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/whatsapp_contact_card.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen displaying a teacher's profile, bio, and contact info.
class TeacherProfileBody extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String displayName;
  final Map<String, dynamic>? profile;

  const TeacherProfileBody({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.displayName,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final bio = profile?['bio'] as String? ?? '';
    final mode = profile?['teaching_mode'] as String? ?? 'online';
    final governorate = profile?['governorate'] as String? ?? '';
    final system = profile?['teaching_system'] as String? ?? '';
    final stages = profile?['stages'] as List<dynamic>?;
    final subjectName =
        (profile?['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '';
    final usersMap = profile?['users'] as Map<String, dynamic>?;
    final phone = usersMap?['phone'] as String? ?? '';
    final teacherName = usersMap?['full_name'] as String? ?? name;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TeacherCoverCard(
            avatarUrl: avatarUrl,
            name: name,
            displayName: displayName,
            verifiedLabel: context.l10n.verifiedTeacher,
          ),
          SizedBox(height: 20.h),
          if (phone.isNotEmpty) ...[
            WhatsAppContactCard(
              phone: phone,
              teacherName: teacherName,
              onPressed: () => _launchWhatsApp(context, phone, teacherName),
            ),
            SizedBox(height: 16.h),
          ],
          TeacherAboutTab(
            bio: bio,
            mode: mode,
            governorate: governorate,
            system: system,
            stages: stages,
            subjectName: subjectName,
          ),
        ],
      ),
    );
  }

  String _cleanPhoneNumber(String phone) {
    var cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '20${cleaned.substring(1)}';
    } else if (!cleaned.startsWith('20') && cleaned.length == 10) {
      cleaned = '20$cleaned';
    }
    return cleaned;
  }

  Future<void> _launchWhatsApp(
      BuildContext context, String phone, String teacherName) async {
    final cleanedPhone = _cleanPhoneNumber(phone);
    final message = context.l10n.whatsappMessage(teacherName);
    final url = Uri.parse(
        'https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.whatsappOpenFailed),
        backgroundColor: NotebookColors.marginRed,
      ));
    }
  }
}
