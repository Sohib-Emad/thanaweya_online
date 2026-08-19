import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/course_filters.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/filter_checkbox_tile.dart';

export 'widgets/course_filters.dart';

class CourseFilterScreen extends StatefulWidget {
  const CourseFilterScreen({super.key});

  @override
  State<CourseFilterScreen> createState() => _CourseFilterScreenState();
}

class _CourseFilterScreenState extends State<CourseFilterScreen> {
  final _repo = StudentCoursesRepo();
  final _selectedSubjectIds = <String>{};
  final _selectedStages = <String>{};
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
      success: (s) => setState(() { _subjects = s; _subjectsLoading = false; }),
      failure: (_, __) => setState(() => _subjectsLoading = false),
    );
  }

  void _clearAll() {
    HapticFeedback.mediumImpact();
    setState(() { _selectedSubjectIds.clear(); _selectedStages.clear(); });
  }

  void _apply() {
    HapticFeedback.selectionClick();
    Navigator.pop(context, CourseFilters(subjectIds: _selectedSubjectIds, stages: _selectedStages));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final count = _selectedSubjectIds.length + _selectedStages.length;

    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.filterResults,
        subtitle: l10n.filterSubtitle,
        actions: [
          TextButton(onPressed: _clearAll, child: Text(l10n.reset, style: NotebookText.strong(13.sp, color: NotebookColors.marginRed))),
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
                  NotebookSectionHeader(title: l10n.studySubjects),
                  SizedBox(height: 8.h),
                  _buildSubjectsSection(l10n),
                  SizedBox(height: 22.h),
                  NotebookSectionHeader(title: l10n.studyStage),
                  SizedBox(height: 8.h),
                  _buildStagesSection(l10n),
                ],
              ),
            ),
          ),
          _buildApplyButton(l10n, count),
        ],
      ),
    );
  }

  Widget _buildSubjectsSection(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: _subjectsLoading
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.5, color: NotebookColors.green)),
            )
          : _subjects.isEmpty
              ? Text(l10n.noSubjectsNow, style: NotebookText.note(13.sp))
              : Column(
                  children: _subjects.map((s) => FilterCheckboxTile(
                    label: s['name_ar'] as String? ?? '',
                    isSelected: _selectedSubjectIds.contains(s['id'] as String),
                    onChanged: (val) {
                      setState(() {
                        final id = s['id'] as String;
                        val ? _selectedSubjectIds.add(id) : _selectedSubjectIds.remove(id);
                      });
                    },
                  )).toList(),
                ),
    );
  }

  Widget _buildStagesSection(AppLocalizations l10n) {
    final stages = {'first': l10n.firstStage, 'second': l10n.secondStage, 'third': l10n.thirdStage};
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: stages.entries.map((e) => FilterCheckboxTile(
          label: e.value,
          isSelected: _selectedStages.contains(e.key),
          onChanged: (val) {
            setState(() { val ? _selectedStages.add(e.key) : _selectedStages.remove(e.key); });
          },
        )).toList(),
      ),
    );
  }

  Widget _buildApplyButton(AppLocalizations l10n, int count) {
    return Positioned(
      left: 20.w,
      right: 20.w,
      bottom: 20.h,
      child: SafeArea(
        child: NotebookPrimaryButton(
          label: count == 0 ? l10n.showAllCourses : l10n.applyFilter(count),
          onPressed: _apply,
        ),
      ),
    );
  }
}
