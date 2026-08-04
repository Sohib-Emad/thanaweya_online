import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

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
      failure: (_, __) => setState(() => _subjectsLoading = false),
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'تصفية النتائج',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _clearAll,
              child: Text(
                'إعادة ضبط',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('المواد الدراسية:'),
                  SizedBox(height: 10.h),
                  if (_subjectsLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFF0FA37F),
                        ),
                      ),
                    )
                  else if (_subjects.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Text(
                        'لا توجد مواد متاحة حالياً',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    )
                  else
                    ..._subjects.map(
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
                    ),

                  SizedBox(height: 24.h),

                  _buildSectionTitle('المرحلة الدراسية:'),
                  SizedBox(height: 10.h),
                  ..._stageLabels.entries.map(
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
                  ),
                ],
              ),
            ),

            // Floating Apply Button at bottom
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      elevation: 4,
                      shadowColor: const Color(0x330FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Text(
                          _selectedSubjectIds.isEmpty &&
                                  _selectedStages.isEmpty
                              ? 'عرض كل الدورات'
                              : 'تطبيق الفلترة'
                                  ' (${_selectedSubjectIds.length + _selectedStages.length})',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: const Color(0xFF0FA37F),
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 15.sp,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF0F172A),
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
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24.r,
              height: 24.r,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0FA37F) : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0FA37F)
                      : const Color(0xFFCBD5E1),
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
