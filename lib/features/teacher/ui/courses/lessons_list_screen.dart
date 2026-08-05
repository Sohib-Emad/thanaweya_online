// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// LESSONS BOARD: the lessons of a course are chalk frames stacked on the
//   board. Each frame shows the lesson title, its chalk note, a معاينة
//   (mint) or خاص (dim) stamp, and edit/delete chalk actions. Editing opens
//   a chalk modal that rewrites the same frame (title, note, video link,
//   free-preview stamp) through the shared courses cubit.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';

class LessonsListScreen extends StatefulWidget {
  final String courseId;

  const LessonsListScreen({super.key, required this.courseId});

  @override
  State<LessonsListScreen> createState() => _LessonsListScreenState();
}

class _LessonsListScreenState extends State<LessonsListScreen> {
  final _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());

  @override
  void initState() {
    super.initState();
    _cubit.loadLessons(widget.courseId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _confirmDeleteLesson(LessonModel lesson) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: ChalkboardColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: ChalkboardColors.ink.withAlpha(60)),
            ),
            title: Text('حذف الدرس؟', style: ChalkboardText.heading(16.sp)),
            content: Text(
              'سيتم حذف «${lesson.title}» من هذه الدورة.',
              style: ChalkboardText.body(12.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'إلغاء',
                  style: ChalkboardText.strong(12.sp,
                      color: ChalkboardColors.chalkSoft),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'حذف',
                  style: ChalkboardText.strong(12.sp,
                      color: ChalkboardColors.chalkRed),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed == true) {
      await _cubit.deleteLesson(lesson.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ChalkboardColors.accentDeep,
            content: Text(
              'تم حذف الدرس',
              style: ChalkboardText.strong(12.sp),
            ),
          ),
        );
      }
    }
  }

  void _showEditLessonSheet(LessonModel lesson) {
    final titleController = TextEditingController(text: lesson.title);
    final descriptionController =
        TextEditingController(text: lesson.description ?? '');
    final videoController = TextEditingController(text: lesson.videoUrlOrId);
    var isFree = lesson.isFreePreview;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: ChalkboardColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        side: BorderSide(color: ChalkboardColors.ink.withAlpha(60)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (sheetContext, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 24.h,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تعديل الدرس', style: ChalkboardText.heading(17.sp)),
                    SizedBox(height: 20.h),
                    ChalkInputField(
                      label: 'عنوان الدرس',
                      controller: titleController,
                      icon: Icons.play_circle_outline_rounded,
                      hint: 'أدخل اسم أو عنوان الدرس',
                    ),
                    SizedBox(height: 18.h),
                    ChalkInputField(
                      label: 'وصف الدرس والتفاصيل',
                      controller: descriptionController,
                      icon: Icons.notes_rounded,
                      hint: 'اكتب الشرح المباشر والنقاط الهامة بالدرس',
                      maxLines: 3,
                    ),
                    SizedBox(height: 18.h),
                    ChalkInputField(
                      label: 'رابط الفيديو أو اليوتيوب',
                      controller: videoController,
                      icon: Icons.link_rounded,
                      hint: 'https://youtube.com/watch?v=...',
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setSheetState(() => isFree = !isFree);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 20.r,
                            height: 20.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFree
                                  ? ChalkboardColors.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: isFree
                                    ? ChalkboardColors.accent
                                    : ChalkboardColors.ink.withAlpha(90),
                                width: 1.4,
                              ),
                            ),
                            child: isFree
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 14.r,
                                    color: ChalkboardColors.onAccent,
                                  )
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'معاينة مجانية للطلاب غير المشتركين',
                            style: ChalkboardText.strong(12.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ChalkPrimaryButton(
                      label: 'حفظ التعديلات',
                      icon: Icons.check_rounded,
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;
                        _cubit.updateLesson(
                          lessonId: lesson.id,
                          title: title,
                          description: descriptionController.text
                                  .trim()
                                  .isNotEmpty
                              ? descriptionController.text.trim()
                              : null,
                          videoUrlOrId: videoController.text.trim(),
                          isFreePreview: isFree,
                        );
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: ChalkboardColors.accentDeep,
                            content: Text(
                              'تم حفظ تعديلات الدرس',
                              style: ChalkboardText.strong(12.sp),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        appBar: ChalkTopBar(
          title: 'دروس الدورة',
          subtitle: 'أضف الدروس ورتبها على السبورة',
        ),
        body: ChalkboardSurface(
          child: BlocBuilder<TeacherCoursesCubit, TeacherCoursesState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.lessonsStatus == TeacherCoursesStatus.loading &&
                  state.lessons.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ChalkboardColors.accent,
                  ),
                );
              }
              if (state.lessonsStatus == TeacherCoursesStatus.error &&
                  state.lessons.isEmpty) {
                return Center(
                  child: ChalkEmptyNote(
                    message: state.errorMessage ?? 'حدث خطأ أثناء تحميل الدروس',
                    icon: Icons.error_outline_rounded,
                    actionLabel: 'إعادة المحاولة',
                    onAction: () => _cubit.loadLessons(widget.courseId),
                  ),
                );
              }
              if (state.lessons.isEmpty) {
                return ChalkEmptyNote(
                  message: 'لا توجد دروس بعد',
                  subMessage: 'استخدم زر + لإضافة أول درس',
                  icon: Icons.video_library_outlined,
                  actionLabel: 'إضافة درس',
                  onAction: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.teacherAddLesson,
                      arguments: widget.courseId,
                    );
                  },
                );
              }
              return RefreshIndicator(
                onRefresh: () => _cubit.loadLessons(widget.courseId),
                color: ChalkboardColors.accent,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  itemCount: state.lessons.length,
                  separatorBuilder: (_, _) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final lesson = state.lessons[index];
                    return _LessonCard(
                      lesson: lesson,
                      onEdit: () => _showEditLessonSheet(lesson),
                      onDelete: () => _confirmDeleteLesson(lesson),
                      onToggleFree: () => _cubit.updateLesson(
                        lessonId: lesson.id,
                        title: lesson.title,
                        description: lesson.description,
                        videoUrlOrId: lesson.videoUrlOrId,
                        isFreePreview: !lesson.isFreePreview,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(
              context,
              AppRouter.teacherAddLesson,
              arguments: widget.courseId,
            );
          },
          backgroundColor: ChalkboardColors.accent,
          foregroundColor: ChalkboardColors.onAccent,
          elevation: 4,
          icon: const Icon(Icons.video_call_rounded, size: 22),
          label: Text(
            'إضافة درس جديد',
            style: ChalkboardText.strong(13.sp),
          ),
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonModel lesson;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFree;

  const _LessonCard({
    required this.lesson,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFree,
  });

  @override
  Widget build(BuildContext context) {
    final isFree = lesson.isFreePreview;
    final accent =
        isFree ? ChalkboardColors.accent : ChalkboardColors.chalkYellow;
    return ChalkCard(
      accent: accent,
      accentLabel: isFree ? 'معاينة مجانية' : 'خاص بالمشتركين',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42.r,
                height: 42.r,
                decoration: BoxDecoration(
                  color: accent.withAlpha(28),
                  borderRadius: BorderRadius.circular(13.r),
                  border: Border.all(color: accent.withAlpha(120), width: 1.2),
                ),
                child: Icon(
                  isFree ? Icons.play_circle_fill_rounded : Icons.lock_outline,
                  color: accent,
                  size: 22.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: ChalkboardText.strong(15.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      lesson.description?.isNotEmpty == true
                          ? lesson.description!
                          : 'درس بدون وصف',
                      style: ChalkboardText.note(12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(height: 1, color: ChalkboardColors.ink.withAlpha(35)),
          SizedBox(height: 10.h),
          Row(
            children: [
              if (lesson.durationSeconds != null) ...[
                Icon(
                  Icons.timer_outlined,
                  size: 15.r,
                  color: ChalkboardColors.chalkSoft,
                ),
                SizedBox(width: 6.w),
                Text(
                  _formatDuration(lesson.durationSeconds!),
                  style: ChalkboardText.note(11.sp),
                ),
              ],
              const Spacer(),
              _IconAction(
                icon: Icons.lock_open_outlined,
                color: isFree
                    ? ChalkboardColors.chalkYellow
                    : ChalkboardColors.accent,
                tooltip: isFree ? 'إزالة المعاينة المجانية' : 'جعلها معاينة مجانية',
                onTap: onToggleFree,
              ),
              SizedBox(width: 4.w),
              _IconAction(
                icon: Icons.edit_outlined,
                color: ChalkboardColors.chalkBlue,
                tooltip: 'تعديل',
                onTap: onEdit,
              ),
              SizedBox(width: 4.w),
              _IconAction(
                icon: Icons.delete_outline_rounded,
                color: ChalkboardColors.chalkRed,
                tooltip: 'حذف',
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).round();
    if (minutes < 60) return '$minutes دقيقة';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest > 0 ? '$hours س و $rest د' : '$hours ساعة';
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: color.withAlpha(22),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withAlpha(110), width: 1.1),
          ),
          child: Icon(icon, size: 17.r, color: color),
        ),
      ),
    );
  }
}
