import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/enrolled_courses_list.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/grades_section.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/progress_section.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/student_header_card.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/student_stats_card.dart';

/// Detail screen showing a student's profile, enrolled courses, exam grades,
/// and per-lesson progress. Loads all data in parallel on init / pull-to-refresh.
class StudentDetailScreen extends StatefulWidget {
  final String studentId;
  final String name;
  final String grade;
  final String email;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.name,
    required this.grade,
    required this.email,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  final _repo = TeacherStudentsRepo();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _lessons = [];
  int _total = 0, _completed = 0, _pct = 0;
  List<Map<String, dynamic>> _subs = [], _grades = [], _courses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final tid = Supabase.instance.client.auth.currentUser?.id;
    if (tid == null || widget.studentId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'لا يمكن تحميل بيانات الطالب';
      });
      return;
    }
    final r = await Future.wait([
      _repo.communications.getStudentProfile(widget.studentId),
      _repo.progress.detail.getStudentProgressForStudent(tid, widget.studentId),
      _repo.communications.getStudentSubscriptions(tid, widget.studentId),
      _repo.communications.examGrades.getStudentExamGrades(
        teacherId: tid,
        studentId: widget.studentId,
      ),
      _repo.progress.detail.getStudentEnrolledCourses(
        teacherId: tid,
        studentId: widget.studentId,
      ),
    ]);
    if (!mounted) return;
    setState(() {
      _loading = false;
      (r[0] as ApiResult<Map<String, dynamic>>).when(
        success: (d) => _profile = d,
        failure: (_, _) {},
      );
      (r[1] as ApiResult<Map<String, dynamic>>).when(
        success: (d) {
          _total = d['total'] as int? ?? 0;
          _completed = d['completed'] as int? ?? 0;
          _pct = d['percent'] as int? ?? 0;
          _lessons =
              (d['lessons'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
              [];
        },
        failure: (m, _) => _error = m,
      );
      (r[2] as ApiResult<List<Map<String, dynamic>>>).when(
        success: (d) => _subs = d,
        failure: (_, _) {},
      );
      (r[3] as ApiResult<List<Map<String, dynamic>>>).when(
        success: (d) => _grades = d,
        failure: (_, _) {},
      );
      (r[4] as ApiResult<List<Map<String, dynamic>>>).when(
        success: (d) => _courses = d,
        failure: (_, _) {},
      );
    });
  }

  String get _name {
    final n = (_profile?['full_name'] as String?)?.trim();
    return (n != null && n.isNotEmpty) ? n : widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(title: 'ملف الطالب وتقدمه', subtitle: _name),
        body: DeskSurface(child: _body()),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: DeskColors.primary),
      );
    }
    if (_error != null) {
      return Center(
        child: DeskEmptyNote(
          message: _error!,
          icon: Icons.error_outline_rounded,
          actionLabel: 'إعادة المحاولة',
          onAction: _load,
        ),
      );
    }
    final p = _profile ?? {};
    return RefreshIndicator(
      onRefresh: _load,
      color: DeskColors.primary,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
        children: [
          StudentHeaderCard(
            effectiveName: _name,
            avatarUrl: p['avatar_url'] as String? ?? '',
            studentPhone: p['phone'] as String? ?? '',
            parentPhone: p['parent_phone'] as String? ?? '',
            effectiveGrade: (p['grade_level'] as String?) ?? widget.grade,
            grades: _grades,
            lessons: _lessons,
            subscriptions: _subs,
            courses: _courses,
            fallbackEmail: widget.email,
          ),
          SizedBox(height: 16.h),
          StudentStatsCard(
            coursesCount: _courses.isNotEmpty ? _courses.length : 1,
            totalLessons: _total,
            completedLessons: _completed,
            completionPercent: _pct,
          ),
          SizedBox(height: 22.h),
          if (_courses.isNotEmpty) ...[
            DeskSectionHeader(
              title: 'الكورسات المشترك بها (${_courses.length})',
            ),
            SizedBox(height: 10.h),
            EnrolledCoursesList(courses: _courses, lessons: _lessons),
            SizedBox(height: 22.h),
          ],
          const DeskSectionHeader(title: 'درجات الامتحانات'),
          SizedBox(height: 10.h),
          GradesSection(grades: _grades),
          SizedBox(height: 22.h),
          const DeskSectionHeader(title: 'متابعة المحاضرات والدروس'),
          SizedBox(height: 10.h),
          ProgressSection(
            lessons: _lessons,
            studentId: widget.studentId,
            onRefresh: _load,
          ),
        ],
      ),
    );
  }
}
