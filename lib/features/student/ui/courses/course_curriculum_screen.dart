import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import '../../../student/data/repos/student_courses_repo.dart';
import '../../../student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/curriculum_bottom_bar.dart';
import 'widgets/curriculum_sections_builder.dart';

/// Screen listing all lessons in a course curriculum.
class CourseCurriculumScreen extends StatefulWidget {
  final String courseId;
  final bool isCompleted;

  const CourseCurriculumScreen({
    super.key,
    required this.courseId,
    this.isCompleted = false,
  });

  @override
  State<CourseCurriculumScreen> createState() => _CourseCurriculumScreenState();
}

class _CourseCurriculumScreenState extends State<CourseCurriculumScreen> {
  late final StudentCoursesCubit _coursesCubit;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _coursesCubit.loadCourseLessons(widget.courseId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _coursesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.curriculumTitle, subtitle: l10n.curriculumSubtitle),
      body: Stack(children: [
        NotebookPaper(
          child: Column(children: [
            SizedBox(height: 14.h),
            NotebookSearchField(
              controller: _searchController,
              hint: l10n.searchLessonHint,
              onFilter: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, AppRouter.studentFilter);
              },
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: CurriculumSectionsBuilder(
                coursesCubit: _coursesCubit,
                courseId: widget.courseId,
              ),
            ),
          ]),
        ),
        CurriculumBottomBar(isCompleted: widget.isCompleted, coursesCubit: _coursesCubit),
      ]),
    );
  }
}
