import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/teacher_profile_body.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen displaying a teacher's full profile page.
class TeacherPageScreen extends StatefulWidget {
  final String teacherId;
  final String title;
  final String? avatarUrl;

  const TeacherPageScreen({
    super.key,
    this.teacherId = '',
    this.title = '',
    this.avatarUrl,
  });

  @override
  State<TeacherPageScreen> createState() => _TeacherPageScreenState();
}

class _TeacherPageScreenState extends State<TeacherPageScreen> {
  late final StudentCoursesCubit _coursesCubit;

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    if (widget.teacherId.isNotEmpty) {
      _coursesCubit.loadTeacherProfile(widget.teacherId);
    }
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
  }

  String _teacherDisplayName(AppLocalizations l10n) {
    final raw = widget.title.trim();
    if (raw.isEmpty) return l10n.teacherPageFallback;
    return raw.startsWith('أ.') ? raw : 'أ. $raw';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: _teacherDisplayName(context.l10n),
        subtitle: context.l10n.teacherPageSubtitle,
      ),
      body: NotebookPaper(
        child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
          bloc: _coursesCubit,
          builder: (context, state) {
            if (state.teacherProfileStatus == StudentCoursesStatus.loading &&
                state.teacherProfile == null) {
              return Center(
                child: CircularProgressIndicator(color: NotebookColors.green),
              );
            }
            if (state.teacherProfile == null) {
              return NotebookEmptyNote(
                icon: Icons.info_outline_rounded,
                message: context.l10n.teacherInfoLoadError,
              );
            }
            return TeacherProfileBody(
              avatarUrl: widget.avatarUrl ?? '',
              name: widget.title.trim().replaceFirst('أ. ', ''),
              displayName: _teacherDisplayName(context.l10n),
              profile: state.teacherProfile,
            );
          },
        ),
      ),
    );
  }
}
