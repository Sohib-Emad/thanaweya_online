import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/notebook_theme.dart';
import '../../../../student/logic/student_courses_cubit.dart';
import '../../../../../l10n/l10n.dart';

/// Floating bottom bar with certificate and continue/restart buttons.
class CurriculumBottomBar extends StatelessWidget {
  final bool isCompleted;
  final StudentCoursesCubit coursesCubit;

  const CurriculumBottomBar({
    super.key,
    required this.isCompleted,
    required this.coursesCubit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
        decoration: BoxDecoration(
          color: NotebookColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(
            top: BorderSide(
              color: NotebookColors.ink.withAlpha(38),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: NotebookColors.ink.withAlpha(24),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              if (isCompleted) ...[
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pushNamed(context, AppRouter.studentCertificate);
                  },
                  child: Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: BoxDecoration(
                      color: NotebookColors.surfaceBright,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: NotebookColors.marginRed.withAlpha(140),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: NotebookColors.marginRed,
                      size: 26.r,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                  bloc: coursesCubit,
                  builder: (context, state) {
                    final firstLesson =
                        state.lessons.isNotEmpty ? state.lessons.first : null;
                    return NotebookPrimaryButton(
                      label: isCompleted
                          ? l10n.restartCourse
                          : l10n.continueLearning,
                      icon: isCompleted
                          ? Icons.refresh_rounded
                          : Icons.play_arrow_rounded,
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushNamed(
                          context,
                          AppRouter.studentVideoPlayer,
                          arguments: {
                            'lessonId': firstLesson?.id ?? '',
                            'videoUrl': firstLesson?.videoUrlOrId ?? '',
                            'title':
                                firstLesson?.title ?? l10n.lessonGeneric,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
