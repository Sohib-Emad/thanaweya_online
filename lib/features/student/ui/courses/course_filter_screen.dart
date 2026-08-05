import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';

/// Selections returned to the caller when the user taps "تطبيق الفلترة".
class CourseFilters {
  const CourseFilters({
    this.subjectIds = const {},
    this.stages = const {},
  });

  final Set<String> subjectIds;
  final Set<String> stages;

  bool get isActive => subjectIds.isNotEmpty || stages.isNotEmpty;

  /// Whether a course map (with `subject_id` and `stage` keys) passes the filter.
  bool matches(Map<String, dynamic> course) {
    if (subjectIds.isNotEmpty) {
      final subjectId = course['subject_id'] as String?;
      if (subjectId == null || !subjectIds.contains(subjectId)) return false;
    }
    if (stages.isNotEmpty) {
      final stage = course['stage'] as String?;
      if (stage == null || !stages.contains(stage)) return false;
    }
    return true;
  }
}

class CourseFilterScreen extends StatefulWidget {
  const CourseFilterScreen({super.key});

  @override
  State<CourseFilterScreen> createState() => _CourseFilterScreenState();
}

class _CourseFilterScreenState extends State<CourseFilterScreen> {
  static const Map<String, String> _stageLabels = {
    'first': 'الصف الأول الثانوي',
    'second': 'الصف الثاني الثانوي',
    'third': 'الصف الثالث الثانوي',
  };

  final StudentCoursesRepo _repo = StudentCoursesRepo();

  final Set<String> _selectedSubjectIds = {};
  final Set<String> _selectedStages = {};

  List<Map<String, dynamic>> _subjects = [];
  bool _subjectsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final result = await _repo.getSubjects();
    if (!mounted) return;
    result.when(
      success: (subjects) => setState(() {
        _subjects = subjects;
        _subjectsLoading = false;
      }),
      failure: (_, _) => setState(() => _subjectsLoading = false),
    );
  }

  void _clearAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedSubjectIds.clear();
      _selectedStages.clear();
    });
  }

  void _apply() {
    HapticFeedback.selectionClick();
    Navigator.pop(
      context,
      CourseFilters(
        subjectIds: _selectedSubjectIds,
        stages: _selectedStages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _selectedSubjectIds.length + _selectedStages.length;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'تصفية النتائج',
          subtitle: 'حدد مادة أو مرحلة من صفحات الدفتر',
          actions: [
            TextButton(
              onPressed: _clearAll,
              child: Text(
                'إعادة ضبط',
                style: NotebookText.strong(13.sp, color: NotebookColors.marginRed),
              ),
            ),
            SizedBox(width: 12.w),
          ],
        ),
        body: Stack(
          children: [
            NotebookPaper(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(0, 16.h, 0, 110.h),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NotebookSectionHeader(title: 'المواد الدراسية'),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _subjectsLoading
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: NotebookColors.green,
                                ),
                              ),
                            )
                          : _subjects.isEmpty
                          ? Text(
                              'لا توجد مواد متاحة حالياً',
                              style: NotebookText.note(13.sp),
                            )
                          : Column(
                              children: _subjects.map(
                                (subject) => _buildCustomCheckboxTile(
                                  label: subject['name_ar'] as String? ?? '',
                                  isSelected: _selectedSubjectIds
                                      .contains(subject['id'] as String),
                                  onChanged: (val) {
                                    setState(() {
                                      final id = subject['id'] as String;
                                      if (val) {
                                        _selectedSubjectIds.add(id);
                                      } else {
                                        _selectedSubjectIds.remove(id);
                                      }
                                    });
                                  },
                                ),
                              ).toList(),
                            ),
                    ),

                    SizedBox(height: 22.h),

                    const NotebookSectionHeader(title: 'المرحلة الدراسية'),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: _stageLabels.entries.map(
                          (entry) => _buildCustomCheckboxTile(
                            label: entry.value,
                            isSelected: _selectedStages.contains(entry.key),
                            onChanged: (val) {
                              setState(() {
                                if (val) {
                                  _selectedStages.add(entry.key);
                                } else {
                                  _selectedStages.remove(entry.key);
                                }
                              });
                            },
                          ),
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Apply Button at bottom
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: NotebookPrimaryButton(
                  label: count == 0
                      ? 'عرض كل الدورات'
                      : 'تطبيق الفلترة ($count)',
                  onPressed: _apply,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCheckboxTile({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(!isSelected);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: isSelected
                    ? NotebookColors.green
                    : NotebookColors.surfaceBright,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected
                      ? NotebookColors.green
                      : NotebookColors.ink.withAlpha(50),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Icon(Icons.check_rounded, size: 16.r, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13.5.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? NotebookColors.ink
                      : NotebookColors.pencil,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.push_pin_rounded,
                color: NotebookColors.marginRed.withAlpha(160),
                size: 15.r,
              ),
          ],
        ),
      ),
    );
  }
}
