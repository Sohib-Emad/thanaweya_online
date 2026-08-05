// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// COURSES BOARD: the teacher's courses live on a chalkboard list. Each
//   course is a chalk-framed card stamped منشور (mint) or مسودة (yellow),
//   with its lesson count written in chalk and edit/delete/publish actions
//   drawn at the foot of the frame. Adding or editing a course happens in a
//   chalk modal (title + description + publish stamp).
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/supabase/storage_helper.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';

class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> {
  final _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadCourses(userId);
      _cubit.loadCourseLessonCounts(userId);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        appBar: ChalkTopBar(
          title: 'الكورسات',
          subtitle: 'دوراتك على السبورة',
          automaticallyImplyBack: true,
        ),
        body: ChalkboardSurface(
          child: BlocBuilder<TeacherCoursesCubit, TeacherCoursesState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.status == TeacherCoursesStatus.loading &&
                  state.courses.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ChalkboardColors.accent,
                  ),
                );
              }
              if (state.status == TeacherCoursesStatus.error &&
                  state.courses.isEmpty) {
                return Center(
                  child: ChalkEmptyNote(
                    message: state.errorMessage ?? 'حدث خطأ أثناء تحميل الدورات',
                    icon: Icons.error_outline_rounded,
                    actionLabel: 'إعادة المحاولة',
                    onAction: _loadCourses,
                  ),
                );
              }
              if (state.courses.isEmpty) {
                return ChalkEmptyNote(
                  message: 'لا توجد دورات بعد',
                  subMessage: 'استخدم زر + لكتابة أول دورة على السبورة',
                  icon: Icons.menu_book_outlined,
                  actionLabel: 'إنشاء دورة',
                  onAction: () => _showCourseSheet(context, null),
                );
              }
              return RefreshIndicator(
                onRefresh: _loadCourses,
                color: ChalkboardColors.accent,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  itemCount: state.courses.length,
                  separatorBuilder: (_, _) => SizedBox(height: 14.h),
                  itemBuilder: (context, index) {
                    final course = state.courses[index];
                    final lessonCount =
                        state.courseLessonCounts[course.id] ?? 0;
                    return _CourseCard(
                      course: course,
                      lessonCount: lessonCount,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(
                          context,
                          AppRouter.teacherLessons,
                          arguments: course.id,
                        );
                      },
                      onEdit: () => _showCourseSheet(context, course),
                      onDelete: () => _confirmDeleteCourse(context, course),
                      onTogglePublish: () => _cubit.updateCourse(
                        courseId: course.id,
                        title: course.title,
                        description: course.description,
                        isPublished: !course.isPublished,
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
            _showCourseSheet(context, null);
          },
          backgroundColor: ChalkboardColors.accent,
          foregroundColor: ChalkboardColors.onAccent,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            'إنشاء دورة',
            style: ChalkboardText.strong(13.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 18.r,
            color: ChalkboardColors.chalkSoft,
          ),
          SizedBox(width: 6.w),
          Text(
            'إضافة صورة غلاف للدورة',
            style: ChalkboardText.note(11.sp),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteCourse(
      BuildContext context, CourseModel course) async {
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
            title: Text(
              'حذف الدورة؟',
              style: ChalkboardText.heading(16.sp),
            ),
            content: Text(
              'سيتم حذف «${course.title}» مع كل دروسها، ولا يمكن التراجع.',
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
      _cubit.deleteCourse(course.id);
    }
  }

  void _showCourseSheet(BuildContext context, CourseModel? course) {
    final titleController = TextEditingController(text: course?.title ?? '');
    final descController =
        TextEditingController(text: course?.description ?? '');
    var isPublished = course?.isPublished ?? false;
    XFile? coverFile;

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
                    Text(
                      course == null ? 'إنشاء دورة جديدة' : 'تعديل الدورة',
                      style: ChalkboardText.heading(17.sp),
                    ),
                    SizedBox(height: 20.h),
                    ChalkInputField(
                      label: 'عنوان الدورة',
                      controller: titleController,
                      icon: Icons.menu_book_outlined,
                      hint: 'مثال: مراجعة الفيزياء للثانوية العامة',
                    ),
                    SizedBox(height: 18.h),
                    ChalkInputField(
                      label: 'وصف الدورة',
                      controller: descController,
                      icon: Icons.notes_rounded,
                      hint: 'اكتب وصفاً موجزاً لما تتضمنه الدورة',
                      maxLines: 2,
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'صورة الغلاف (اختياري)',
                      style: ChalkboardText.strong(12.sp),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () async {
                        HapticFeedback.lightImpact();
                        try {
                          final file = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (file != null) {
                            setSheetState(() => coverFile = file);
                          }
                        } catch (_) {
                          if (sheetContext.mounted) {
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(
                                backgroundColor: ChalkboardColors.accentDeep,
                                content: Text(
                                  'تعذر اختيار الصورة من جهازك',
                                  style: ChalkboardText.strong(12.sp),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: coverFile != null
                            ? 110.h
                            : course?.coverImageUrl?.isNotEmpty == true
                                ? 110.h
                                : 56.h,
                        decoration: BoxDecoration(
                          color: ChalkboardColors.surfaceBright.withAlpha(120),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: coverFile != null
                                ? ChalkboardColors.accent.withAlpha(190)
                                : ChalkboardColors.ink.withAlpha(60),
                            width: coverFile != null ? 1.6 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: coverFile != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(coverFile!.path),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    top: 6.r,
                                    left: 6.r,
                                    child: GestureDetector(
                                      onTap: () =>
                                          setSheetState(() => coverFile = null),
                                      child: Container(
                                        padding: EdgeInsets.all(5.r),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16.r,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : course?.coverImageUrl?.isNotEmpty == true
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        course!.coverImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _buildCoverPlaceholder(context),
                                      ),
                                      Positioned(
                                        top: 6.r,
                                        left: 6.r,
                                        child: GestureDetector(
                                          onTap: () => setSheetState(() {}),
                                          child: Container(
                                            padding: EdgeInsets.all(5.r),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 16.r,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : _buildCoverPlaceholder(context),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setSheetState(() => isPublished = !isPublished);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 20.r,
                            height: 20.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPublished
                                  ? ChalkboardColors.accent
                                  : Colors.transparent,
                              border: Border.all(
                                color: isPublished
                                    ? ChalkboardColors.accent
                                    : ChalkboardColors.ink.withAlpha(90),
                                width: 1.4,
                              ),
                            ),
                            child: isPublished
                                ? Icon(
                                    Icons.check_rounded,
                                    size: 14.r,
                                    color: ChalkboardColors.onAccent,
                                  )
                                : null,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            isPublished ? 'منشورة الآن' : 'تُحفظ كمسودة',
                            style: ChalkboardText.strong(12.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ChalkPrimaryButton(
                      label: course == null ? 'حفظ الدورة' : 'حفظ التعديلات',
                      icon: Icons.check_rounded,
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final description = descController.text.trim();
                        if (title.isEmpty) return;

                        final userId =
                            Supabase.instance.client.auth.currentUser?.id;
                        if (userId == null) return;

                        String? coverImageUrl;
                        if (coverFile != null) {
                          final coverKey =
                              '${DateTime.now().millisecondsSinceEpoch}';
                          coverImageUrl = await StorageHelper.uploadCourseCover(
                            teacherId: userId,
                            courseId: course?.id ?? coverKey,
                            file: coverFile!,
                          );
                          if (coverImageUrl == null) {
                            if (sheetContext.mounted) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                SnackBar(
                                  backgroundColor:
                                      ChalkboardColors.accentDeep,
                                  content: Text(
                                    'فشل رفع صورة الغلاف، حاول مرة أخرى',
                                    style: ChalkboardText.strong(12.sp),
                                  ),
                                ),
                              );
                            }
                            return;
                          }
                        }

                        if (course == null) {
                          _cubit.createCourse(
                            teacherId: userId,
                            title: title,
                            description:
                                description.isNotEmpty ? description : null,
                            coverImageUrl: coverImageUrl,
                            isPublished: isPublished,
                          );
                        } else {
                          _cubit.updateCourse(
                            courseId: course.id,
                            title: title,
                            description:
                                description.isNotEmpty ? description : null,
                            coverImageUrl: coverImageUrl,
                            isPublished: isPublished,
                          );
                        }
                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: ChalkboardColors.accentDeep,
                            content: Text(
                              course == null
                                  ? 'تمت إضافة الدورة إلى السبورة'
                                  : 'تم حفظ تعديلات الدورة',
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
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final int lessonCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublish;

  const _CourseCard({
    required this.course,
    required this.lessonCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final published = course.isPublished;
    final accent =
        published ? ChalkboardColors.accent : ChalkboardColors.chalkYellow;
    return ChalkCard(
      onTap: onTap,
      accent: accent,
      accentLabel: published ? 'منشورة' : 'مسودة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CourseCover(
                coverUrl: course.coverImageUrl,
                accent: accent,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: ChalkboardText.strong(15.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      course.description?.isNotEmpty == true
                          ? course.description!
                          : 'دورة بدون وصف',
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
              Icon(
                Icons.play_circle_outline_rounded,
                size: 15.r,
                color: ChalkboardColors.chalkSoft,
              ),
              SizedBox(width: 6.w),
              Text(
                '$lessonCount درس',
                style: ChalkboardText.note(11.sp),
              ),
              const Spacer(),
              _IconAction(
                icon: Icons.publish_rounded,
                color: published
                    ? ChalkboardColors.chalkYellow
                    : ChalkboardColors.accent,
                tooltip: published ? 'إلغاء النشر' : 'نشر الدورة',
                onTap: onTogglePublish,
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
}

class _CourseCover extends StatelessWidget {
  final String? coverUrl;
  final Color accent;

  const _CourseCover({required this.coverUrl, required this.accent});

  @override
  Widget build(BuildContext context) {
    final hasCover = coverUrl?.isNotEmpty == true;
    return Container(
      width: 46.r,
      height: 46.r,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accent.withAlpha(30),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: accent.withAlpha(120), width: 1.2),
      ),
      child: hasCover ? _network() : _icon(),
    );
  }

  Widget _network() {
    return Image.network(
      coverUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _icon(),
    );
  }

  Widget _icon() {
    return Icon(
      Icons.menu_book_outlined,
      color: accent,
      size: 24.r,
    );
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
