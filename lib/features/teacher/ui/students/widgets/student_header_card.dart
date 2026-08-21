import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/students_list_screen.dart'
    show gradeLabelOf;
import 'package:thanaweya_online/features/teacher/ui/students/widgets/contact_chip.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/parent_report_sheet.dart';

/// Header card showing the student avatar, name, grade badge, report button,
/// and contact action chips for calling or messaging the student / parent.
class StudentHeaderCard extends StatelessWidget {
  final String effectiveName;
  final String avatarUrl;
  final String studentPhone;
  final String parentPhone;
  final String effectiveGrade;
  final List<Map<String, dynamic>> grades;
  final List<Map<String, dynamic>> lessons;
  final List<Map<String, dynamic>> subscriptions;
  final List<Map<String, dynamic>> courses;
  final String fallbackEmail;

  const StudentHeaderCard({
    super.key,
    required this.effectiveName,
    required this.avatarUrl,
    required this.studentPhone,
    required this.parentPhone,
    required this.effectiveGrade,
    required this.grades,
    required this.lessons,
    required this.subscriptions,
    this.courses = const [],
    required this.fallbackEmail,
  });

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _avatar(), SizedBox(width: 14.w),
          Expanded(child: _nameGrade()), _reportBtn(context),
        ]),
        if (studentPhone.isNotEmpty || parentPhone.isNotEmpty) ...[
          SizedBox(height: 16.h),
          Container(height: 1, color: DeskColors.line.withAlpha(120)),
          SizedBox(height: 12.h), _chips(),
        ],
      ]),
    );
  }

  Widget _avatar() {
    final i = effectiveName.trim().isNotEmpty ? effectiveName.trim().substring(0, 1) : 'ط';
    return Container(
      width: 54.r, height: 54.r,
      decoration: BoxDecoration(shape: BoxShape.circle,
        gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        boxShadow: [BoxShadow(color: const Color(0xFF0284C7).withAlpha(40), blurRadius: 8, offset: const Offset(0, 3))]),
      child: avatarUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
                errorWidget: (_, _, _) => _fb(i),
              ),
            )
          : _fb(i),
    );
  }

  Widget _fb(String i) => Center(child: Text(i, style: GoogleFonts.cairo(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white)));

  Widget _nameGrade() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(effectiveName, style: GoogleFonts.cairo(fontSize: 16.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
      SizedBox(height: 3.h),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        decoration: BoxDecoration(color: const Color(0xFF0284C7).withAlpha(18), borderRadius: BorderRadius.circular(10.r), border: Border.all(color: const Color(0xFF0284C7).withAlpha(40))),
        child: Text(effectiveGrade.isNotEmpty ? gradeLabelOf(effectiveGrade) : 'المرحلة غير محددة',
            style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7))),
      ),
    ]);
  }

  Widget _reportBtn(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => ParentReportSheet.show(
        context,
        studentName: effectiveName,
        gradeLevel: effectiveGrade.isNotEmpty ? gradeLabelOf(effectiveGrade) : '',
        parentPhone: parentPhone,
        grades: grades,
        progress: lessons,
        subscriptions: subscriptions,
        courses: courses,
      ),
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), elevation: 0),
      icon: Icon(Icons.analytics_rounded, size: 16.r),
      label: Text('تقرير', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800)),
    );
  }

  Widget _chips() {
    return Wrap(spacing: 8.w, runSpacing: 8.h, children: [
      if (studentPhone.isNotEmpty) ...[
        ContactChip(icon: Icons.phone_rounded, label: 'طالب', color: const Color(0xFF0284C7), onTap: () => _launch('tel:${studentPhone.trim()}')),
        ContactChip(icon: Icons.chat_rounded, label: 'واتساب', color: const Color(0xFF059669),
            onTap: () => _wa(studentPhone, 'السلام عليكم يا $effectiveName، نتابع معك دراستك عبر منصة ثانوية أونلاين.')),
      ],
      if (parentPhone.isNotEmpty)
        ContactChip(icon: Icons.family_restroom_rounded, label: 'ولي أمر', color: const Color(0xFF7C3AED),
            onTap: () => _wa(parentPhone, 'السلام عليكم ورحمة الله، تقرير ومتابعة الطالب $effectiveName عبر منصة ثانوية أونلاين.')),
    ]);
  }

  Future<void> _launch(String u) async {
    final uri = Uri.parse(u);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _wa(String phone, String text) {
    var c = phone.trim().replaceAll('+', '').replaceAll(' ', '');
    if (c.isEmpty) return;
    if (!c.startsWith('20') && c.startsWith('01')) c = '2$c';
    HapticFeedback.lightImpact();
    _launch('https://wa.me/$c?text=${Uri.encodeComponent(text)}');
  }
}
