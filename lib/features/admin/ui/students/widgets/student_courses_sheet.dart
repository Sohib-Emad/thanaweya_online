import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';
import 'student_course_item.dart';
import 'student_courses_teacher_filter.dart';
import 'student_courses_sheet_top_bar.dart';

class StudentCoursesSheet extends StatefulWidget {
  final Map<String, dynamic> student;
  final List<Map<String, dynamic>> teachers;
  final String? initialTeacherId;
  const StudentCoursesSheet({super.key, required this.student, required this.teachers, this.initialTeacherId});

  @override
  State<StudentCoursesSheet> createState() => _StudentCoursesSheetState();
}

class _StudentCoursesSheetState extends State<StudentCoursesSheet> {
  final _repo = AdminStudentsRepo();
  String? _selectedTeacherId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _courses = [];
  final Set<String> _processing = {};

  @override
  void initState() {
    super.initState();
    _selectedTeacherId = widget.initialTeacherId?.isNotEmpty == true
        ? widget.initialTeacherId
        : (widget.teachers.isNotEmpty ? widget.teachers.first['id'] as String? : null);
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final tid = _selectedTeacherId, sid = widget.student['student_id'] as String? ?? widget.student['id'] as String? ?? '';
    if (tid == null || sid.isEmpty) { setState(() { _isLoading = false; _courses = []; }); return; }
    setState(() => _isLoading = true);
    final res = await _repo.getStudentCoursesWithStatus(studentId: sid, teacherId: tid);
    if (mounted) res.when(success: (c) => setState(() { _courses = c; _isLoading = false; }), failure: (_, __) => setState(() { _courses = []; _isLoading = false; }));
  }

  Future<void> _toggleAccess(Map<String, dynamic> course) async {
    final cid = course['id'] as String? ?? '', isUnlocked = course['is_unlocked'] == true;
    final sid = widget.student['student_id'] as String? ?? widget.student['id'] as String? ?? '';
    if (cid.isEmpty || sid.isEmpty || _selectedTeacherId == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _processing.add(cid));
    final res = isUnlocked ? await _repo.lockCourse(studentId: sid, teacherId: _selectedTeacherId!, courseId: cid) : await _repo.unlockCourse(studentId: sid, teacherId: _selectedTeacherId!, courseId: cid);
    if (!mounted) return;
    setState(() => _processing.remove(cid));
    res.when(
      success: (_) {
        setState(() => course['is_unlocked'] = !isUnlocked);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isUnlocked ? 'تم قفل الكورس 🔒' : 'تم فتح الكورس ✅'), backgroundColor: isUnlocked ? const Color(0xFFDC2626) : const Color(0xFF16A34A)));
      },
      failure: (msg, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $msg'), backgroundColor: AppColors.error)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (widget.student['users'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'الطالب';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 0.85.sh, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
        child: Column(
          children: [
            StudentCoursesSheetTopBar(studentName: name),
            SizedBox(height: 10.h),
            StudentCoursesTeacherFilter(teachers: widget.teachers, selectedTeacherId: _selectedTeacherId, onSelectTeacher: (tid) { setState(() => _selectedTeacherId = tid); _loadCourses(); }),
            SizedBox(height: 10.h),
            const Divider(height: 1),
            Expanded(
              child: _isLoading ? const Center(child: CircularProgressIndicator()) : _courses.isEmpty
                  ? Center(child: Text('لا توجد كورسات مضافة لهذا المعلم', style: AppTextStyles.body2))
                  : ListView.separated(
                      padding: EdgeInsets.all(20.r), itemCount: _courses.length, separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (_, i) => StudentCourseItem(course: _courses[i], isProcessing: _processing.contains(_courses[i]['id']), onToggleAccess: () => _toggleAccess(_courses[i])),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
