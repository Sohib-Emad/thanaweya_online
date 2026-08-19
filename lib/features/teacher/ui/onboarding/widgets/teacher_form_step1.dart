import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/onboarding/widgets/field_label.dart';

/// Step 1: specialty, subjects, baccalaureate tracks, and stages.
class TeacherFormStep1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final int teacherSystemIndex;
  final ValueChanged<int> onSystemIndexChanged;
  final List<Map<String, dynamic>> subjects;
  final Set<String> selectedSubjectIds, selectedTrackIds, selectedStages;
  final ValueChanged<String> onSubjectToggled, onTrackToggled, onStageToggled;
  final List<Map<String, dynamic>> stages;
  final TextEditingController bioController;

  const TeacherFormStep1({
    super.key, required this.formKey,
    required this.teacherSystemIndex, required this.onSystemIndexChanged,
    required this.subjects, required this.selectedSubjectIds,
    required this.onSubjectToggled, required this.selectedTrackIds,
    required this.onTrackToggled, required this.stages,
    required this.selectedStages, required this.onStageToggled,
    required this.bioController,
  });

  static final _tracks = [
    {'id': 'track_med', 'name_ar': 'مسار الطب وعلوم الحياة',
      'qualifying': 'يؤهل لكليات: الطب البشري، الصيدلة، الأسنان، العلاج الطبيعي، والتمريض.',
      'color': DeskColors.success},
    {'id': 'track_eng', 'name_ar': 'مسار الهندسة وعلوم الحاسب',
      'qualifying': 'يؤهل لكليات: الهندسة، الحاسبات والمعلومات، والتكنولوجيا الحيوية.',
      'color': DeskColors.info},
    {'id': 'track_biz', 'name_ar': 'مسار الأعمال والاقتصاد',
      'qualifying': 'يؤهل لكليات: التجارة، الاقتصاد والعلوم السياسية، الإعلام، والحقوق.',
      'color': DeskColors.accent},
    {'id': 'track_arts', 'name_ar': 'مسار الآداب والفنون',
      'qualifying': 'يؤهل لكليات: الآداب، الألسن، الفنون الجميلة، ودار العلوم.',
      'color': DeskColors.danger},
  ];

  static IconData _trackIcon(String id) => switch (id) {
    'track_med' => Icons.medical_services_rounded,
    'track_eng' => Icons.computer_rounded,
    'track_biz' => Icons.business_center_rounded,
    'track_arts' => Icons.palette_rounded,
    _ => Icons.school_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final showGen = teacherSystemIndex == 0 || teacherSystemIndex == 2;
    final showBacc = teacherSystemIndex == 1 || teacherSystemIndex == 2;
    return Form(
      key: formKey,
      child: Column(
        key: const ValueKey(1),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DeskSectionHeader(title: 'بيانات التخصص والمادة'),
          SizedBox(height: 18.h),
          const FieldLabel(label: 'النظام التعليمي المتاح لديك للتدريس*'),
          SizedBox(height: 8.h),
          DeskSegmentedControl(
            options: const ['عامة (قديم)', 'البكالوريا (IB)', 'كلا النظامين'],
            index: teacherSystemIndex,
            onChanged: (i) { HapticFeedback.selectionClick(); onSystemIndexChanged(i); }),
          SizedBox(height: 20.h),
          if (showGen) ..._buildGeneralSection(),
          if (showBacc) ..._buildBaccSection(),
          const FieldLabel(label: 'نبذة عن خبرتك وأسلوب الشرح'),
          SizedBox(height: 6.h),
          DeskInputField(label: '', controller: bioController,
            hint: 'اكتب نبذة مختصرة عن مؤهلاتك وتجاربك السابقة...', maxLines: 4),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  List<Widget> _buildGeneralSection() => [
    const FieldLabel(label: 'المادة الدراسية (النظام العام)*'),
    SizedBox(height: 8.h),
    if (subjects.isEmpty)
      const DeskEmptyNote(message: 'جارٍ تحميل قائمة المواد...')
    else
      Wrap(spacing: 8.w, runSpacing: 10.h, children: subjects.map((s) {
        final id = s['id'] as String? ?? '';
        return DeskChip(label: s['name_ar'] as String? ?? '',
          selected: selectedSubjectIds.contains(id),
          onTap: () { HapticFeedback.selectionClick(); onSubjectToggled(id); });
      }).toList()),
    SizedBox(height: 20.h),
    const FieldLabel(label: 'المراحل الدراسية المتاح تدرسها*'),
    SizedBox(height: 8.h),
    Wrap(spacing: 8.w, runSpacing: 8.h, children: stages.map((st) {
      final val = st['value'] as String;
      return DeskChip(label: st['name']!, selected: selectedStages.contains(val),
        onTap: () { HapticFeedback.selectionClick(); onStageToggled(val); });
    }).toList()),
    SizedBox(height: 20.h),
  ];

  List<Widget> _buildBaccSection() => [
    const FieldLabel(label: 'مسارات البكالوريا المتاح تدريسها (IB)*'),
    SizedBox(height: 10.h),
    ListView.separated(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      itemCount: _tracks.length,
      separatorBuilder: (_, _) => SizedBox(height: 10.h),
      itemBuilder: (context, i) {
        final t = _tracks[i];
        final id = t['id'] as String;
        final color = t['color'] as Color;
        final sel = selectedTrackIds.contains(id);
        return GestureDetector(
          onTap: () { HapticFeedback.selectionClick(); onTrackToggled(id); },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200), padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: sel ? color.withAlpha(24) : DeskColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: sel ? color.withAlpha(200) : DeskColors.line, width: sel ? 1.8 : 1)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(color: color.withAlpha(26), borderRadius: BorderRadius.circular(10.r)),
                  child: Icon(_trackIcon(id), color: color, size: 18.r)),
                SizedBox(width: 10.w),
                Expanded(child: Text((t['name_ar'] as String).trim(),
                  style: DeskText.strong(14.sp, color: sel ? color : DeskColors.ink))),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200), width: 22.r, height: 22.r,
                  decoration: BoxDecoration(
                    color: sel ? color : Colors.transparent, shape: BoxShape.circle,
                    border: Border.all(color: sel ? color : DeskColors.faint, width: 1.5)),
                  child: sel ? Icon(Icons.check_rounded, color: DeskColors.onPrimary, size: 14.r) : null),
              ]),
              SizedBox(height: 4.h),
              Text(t['qualifying'] as String, style: DeskText.note(11.sp)),
            ])),
        );
      },
    ),
    SizedBox(height: 20.h),
  ];
}
