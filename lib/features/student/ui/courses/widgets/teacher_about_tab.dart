import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/teacher_info_row.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// About-teacher tab containing bio, teaching mode, and academic details.
class TeacherAboutTab extends StatelessWidget {
  final String bio;
  final String mode;
  final String governorate;
  final String system;
  final List<dynamic>? stages;
  final String subjectName;
  const TeacherAboutTab({
    super.key, required this.bio, required this.mode, required this.governorate,
    required this.system, this.stages, required this.subjectName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NotebookCard(
        ruled: true, ruledStartY: 46,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.info_outline_rounded, color: NotebookColors.green, size: 20.r),
            SizedBox(width: 8.w),
            Text(l10n.bioLabel, style: NotebookText.strong(14.sp)),
          ]),
          SizedBox(height: 12.h),
          Text(bio.isNotEmpty ? bio : l10n.noBio, style: NotebookText.body(12.sp)),
        ]),
      ),
      SizedBox(height: 16.h),
      NotebookCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(_getTeachingModeIcon(mode), color: NotebookColors.green, size: 20.r),
            SizedBox(width: 8.w),
            Text(l10n.teachingPlaceTitle, style: NotebookText.strong(14.sp)),
          ]),
          SizedBox(height: 12.h),
          TeacherInfoRow(icon: Icons.laptop_chromebook_rounded, label: l10n.teachingMethod, value: _fmtMode(mode, l10n)),
          if (mode.toLowerCase() == 'center' || mode.toLowerCase() == 'both')
            TeacherInfoRow(icon: Icons.location_on_outlined, label: l10n.centerLocation,
                value: l10n.locatedInGovernorate(governorate)),
        ]),
      ),
      SizedBox(height: 16.h),
      NotebookCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.school_outlined, color: NotebookColors.green, size: 20.r),
            SizedBox(width: 8.w),
            Text(l10n.academicTitle, style: NotebookText.strong(14.sp)),
          ]),
          SizedBox(height: 12.h),
          TeacherInfoRow(icon: Icons.subject_rounded, label: l10n.subjectField,
              value: subjectName.isNotEmpty ? subjectName : l10n.notSpecified),
          TeacherInfoRow(icon: Icons.layers_rounded, label: l10n.gradeField, value: _fmtStages(stages, l10n)),
          TeacherInfoRow(icon: Icons.settings_outlined, label: l10n.systemField, value: _fmtSystem(system, l10n)),
        ]),
      ),
    ]);
  }

  String _fmtStages(List<dynamic>? s, AppLocalizations l10n) {
    if (s == null || s.isEmpty) return l10n.notSpecified;
    return s.map((v) {
      switch (v.toString().toLowerCase()) {
        case 'first': return l10n.firstStage;
        case 'second': return l10n.secondStage;
        case 'third': return l10n.thirdStage;
        default: return v.toString();
      }
    }).join(' • ');
  }

  String _fmtSystem(String? s, AppLocalizations l10n) {
    if (s == null || s.isEmpty) return l10n.notSpecified;
    switch (s.toLowerCase()) {
      case 'general': return l10n.generalSecondary;
      case 'azhari': return l10n.azhariSecondary;
      case 'stem': return l10n.stemSchools;
      default: return s;
    }
  }

  String _fmtMode(String? m, AppLocalizations l10n) {
    if (m == null) return l10n.modeOnlineShort;
    switch (m.toLowerCase()) {
      case 'online': return l10n.modeOnline;
      case 'center': return l10n.modeCenter;
      case 'both': return l10n.modeBoth;
      default: return m;
    }
  }

  IconData _getTeachingModeIcon(String? m) {
    if (m == null) return Icons.laptop_chromebook_rounded;
    switch (m.toLowerCase()) {
      case 'online': return Icons.laptop_chromebook_rounded;
      case 'center': return Icons.location_city_rounded;
      case 'both': return Icons.business_center_rounded;
      default: return Icons.school_rounded;
    }
  }
}
