// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// STUDENT PROGRESS BOARD: this page is the teacher's record of one student's
//   progress. It reads real lesson_progress rows for that student (via
//   TeacherStudentsRepo.getStudentProgressForStudent) and their subscription
//   from subscriptions. The header is the student's chalk frame, then the
//   numbers written in chalk (إجمالي الدروس / المكتمل / النسبة), then their
//   progress grouped by course with a checkmark per completed lesson and the
//   watched time — no fake rows, no invented phones.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/ui/students/students_list_screen.dart'
    show gradeLabelOf;

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
  List<Map<String, dynamic>> _progress = [];
  List<Map<String, dynamic>> _subscriptions = [];

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
    final teacherId = Supabase.instance.client.auth.currentUser?.id;
    if (teacherId == null || widget.studentId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'لا يمكن تحميل بيانات الطالب';
      });
      return;
    }

    final progressResult = await _repo.getStudentProgressForStudent(
      teacherId,
      widget.studentId,
    );
    final subsResult = await _repo.getStudentSubscriptions(
      teacherId,
      widget.studentId,
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      progressResult.when(
        success: (data) => _progress = data,
        failure: (message, _) => _error = message,
      );
      subsResult.when(
        success: (data) => _subscriptions = data,
        failure: (_, _) {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        appBar: ChalkTopBar(
          title: 'تقدم الطالب',
          subtitle: widget.name,
        ),
        body: ChalkboardSurface(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: ChalkboardColors.accent,
                  ),
                )
              : _error != null
                  ? Center(
                      child: ChalkEmptyNote(
                        message: _error!,
                        icon: Icons.error_outline_rounded,
                        actionLabel: 'إعادة المحاولة',
                        onAction: _load,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: ChalkboardColors.accent,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                            20.w, 16.h, 20.w, 28.h),
                        children: [
                          _buildHeaderCard(),
                          SizedBox(height: 16.h),
                          if (_subscriptions.isNotEmpty) ...[
                            _buildSubscriptionCard(),
                            SizedBox(height: 16.h),
                          ],
                          _buildStatsCard(),
                          SizedBox(height: 24.h),
                          ChalkSectionHeader(
                            title: 'الدرس المكتمل',
                            accent: ChalkboardColors.chalkBlue,
                          ),
                          SizedBox(height: 12.h),
                          if (_progress.isEmpty)
                            const ChalkEmptyNote(
                              message: 'لا يوجد تقدم مسجل لهذا الطالب بعد',
                              subMessage: 'عندما يشاهد الطالب دروساً ستظهر هنا',
                              icon: Icons.assignment_outlined,
                            )
                          else
                            _buildProgressList(),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return ChalkCard(
      accent: ChalkboardColors.accent,
      child: Row(
        children: [
          ChalkAvatar(initial: widget.name, radius: 26),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: ChalkboardText.strong(17.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  widget.grade.isNotEmpty
                      ? gradeLabelOf(widget.grade)
                      : 'المرحلة غير محددة',
                  style: ChalkboardText.note(12.sp),
                ),
              ],
            ),
          ),
          if (widget.email.isNotEmpty)
            Icon(
              Icons.mail_outline_rounded,
              size: 18.r,
              color: ChalkboardColors.chalkSoft,
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final sub = _subscriptions.first;
    final status = sub['status'] as String? ?? 'inactive';
    final active = status == 'active';
    final color =
        active ? ChalkboardColors.accent : ChalkboardColors.chalkYellow;
    final expires = sub['expires_at'] as String?;

    return ChalkCard(
      accent: color,
      accentLabel: active ? 'اشتراك نشط' : 'اشتراك غير نشط',
      child: Row(
        children: [
          Icon(
            active
                ? Icons.verified_outlined
                : Icons.event_available_outlined,
            size: 20.r,
            color: color,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              expires != null && expires.isNotEmpty
                  ? 'ينتهي في ${Formatters.formatDate(DateTime.parse(expires))}'
                  : 'لا يوجد تاريخ نهاية مسجل',
              style: ChalkboardText.body(12.5.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    final total = _progress.length;
    final completed = _progress
        .where((p) => p['is_completed'] == true)
        .length;
    final percent = total == 0 ? 0 : (completed * 100 / total).round();

    return ChalkCard(
      child: Row(
        children: [
          _StatCell(
            label: 'إجمالي الدروس',
            value: '$total',
            accent: ChalkboardColors.chalkBlue,
          ),
          Container(
            width: 1,
            height: 30.h,
            color: ChalkboardColors.ink.withAlpha(45),
          ),
          _StatCell(
            label: 'دروس مكتملة',
            value: '$completed',
            accent: ChalkboardColors.accent,
          ),
          Container(
            width: 1,
            height: 30.h,
            color: ChalkboardColors.ink.withAlpha(45),
          ),
          _StatCell(
            label: 'نسبة الإنجاز',
            value: '$percent%',
            accent: ChalkboardColors.chalkYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressList() {
    // Group progress rows by course title.
    final courses = <String, List<Map<String, dynamic>>>{};
    for (final row in _progress) {
      final lesson = row['lessons'] as Map<String, dynamic>? ?? {};
      final course = lesson['courses'] as Map<String, dynamic>? ?? {};
      final courseTitle = course['title'] as String? ?? 'دروس عامة';
      courses.putIfAbsent(courseTitle, () => []).add(row);
    }

    final children = <Widget>[];
    courses.forEach((title, rows) {
      final completedCount = rows
          .where((r) => r['is_completed'] == true)
          .length;
      children.add(
        ChalkCard(
          padding: EdgeInsets.all(12.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: ChalkboardText.strong(14.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ChalkStatusChip(
                    label: '$completedCount/${rows.length}',
                    color: ChalkboardColors.accent,
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              for (final row in rows) _buildProgressRow(row),
            ],
          ),
        ),
      );
      children.add(SizedBox(height: 12.h));
    });

    return Column(children: children);
  }

  Widget _buildProgressRow(Map<String, dynamic> row) {
    final lesson = row['lessons'] as Map<String, dynamic>? ?? {};
    final title = lesson['title'] as String? ?? 'درس';
    final completed = row['is_completed'] == true;
    final watchedSeconds = (row['watched_seconds'] as num?)?.toInt() ?? 0;
    final lastWatched = row['last_watched_at'] as String?;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ChalkboardColors.ink.withAlpha(25)),
        ),
      ),
      child: Row(
        children: [
          completed
              ? Icon(
                  Icons.check_circle_rounded,
                  size: 18.r,
                  color: ChalkboardColors.accent,
                )
              : Icon(
                  Icons.radio_button_unchecked_rounded,
                  size: 18.r,
                  color: ChalkboardColors.chalkFaint,
                ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ChalkboardText.body(12.5.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  watchedSeconds > 0
                      ? 'شاهد ${Formatters.formatDuration(watchedSeconds)}'
                      : 'لم يشاهد بعد',
                  style: ChalkboardText.note(10.5.sp),
                ),
              ],
            ),
          ),
          if (lastWatched != null && lastWatched.isNotEmpty)
            Text(
              Formatters.formatDate(DateTime.parse(lastWatched)),
              style: ChalkboardText.note(10.sp),
            ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _StatCell({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 2.w),
        child: Column(
          children: [
            Text(
              value,
              style: ChalkboardText.heading(18.sp, color: accent),
            ),
            SizedBox(height: 2.h),
            Text(label, style: ChalkboardText.note(10.5.sp)),
          ],
        ),
      ),
    );
  }
}
