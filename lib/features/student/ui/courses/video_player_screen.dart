import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/screen_protection.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/video_player_mixin.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Screen for playing a single lesson video with attachments and progress.
class VideoPlayerScreen extends StatefulWidget {
  final String lessonId;
  final String videoUrl;
  final String title;
  final String courseId;
  final String description;
  final String videoSourceType;

  const VideoPlayerScreen({
    super.key,
    required this.lessonId,
    required this.videoUrl,
    required this.title,
    required this.courseId,
    this.description = '',
    this.videoSourceType = 'dailymotion',
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with VideoPlayerMixin {
  @override
  void initState() {
    super.initState();
    ScreenProtection.enable();
    activeTitle = widget.title;
    activeDescription = widget.description;
    activeLessonId = widget.lessonId;
    if (widget.courseId.isNotEmpty) coursesCubit.loadCourseLessons(widget.courseId);
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid != null) coursesCubit.loadProgress(uid);
    _initSubscription();
  }

  Future<void> _initSubscription() async => checkSubscription(
    courseId: widget.courseId, lessonId: widget.lessonId,
    videoUrl: widget.videoUrl, videoSourceType: widget.videoSourceType,
    title: widget.title, description: widget.description,
    onSubscribed: () => loadLessonContent(widget.lessonId).then((_) {
      if (!mounted || viewLocked) return;
      initPlayer(url: widget.videoUrl, sourceType: widget.videoSourceType,
        title: widget.title, description: widget.description, lessonId: widget.lessonId, notify: false);
    }),
  );

  @override
  void dispose() {
    ScreenProtection.disable();
    disposePlayerControllers();
    coursesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.watchingLesson, subtitle: activeTitle),
      body: NotebookPaper(child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
        children: [
          ViewCountAlertBanner(viewCount: viewCount, maxViews: maxViews),
          VideoArea(
            isCheckingSubscription: isCheckingSubscription, isSubscribed: isSubscribed,
            viewLocked: viewLocked, isDailymotion: isDailymotion, isYoutube: isYoutube,
            activeUrl: activeUrl, activeLessonId: activeLessonId, isUploadLoading: isUploadLoading,
            onViewStarted: () {}, youtubeController: youtubeController,
            videoController: videoController, courseId: widget.courseId,
          ),
          SizedBox(height: 10.h),
          LiveProgressBanner(currentPosition: currentPosition, totalDuration: totalDuration,
            isCompleted: isCompleted, onToggleCompleted: toggleCompleted),
          SizedBox(height: 14.h),
          Text(activeTitle, style: NotebookText.heading(17.sp)),
          if (activeDescription.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(activeDescription, style: NotebookText.body(12.sp)),
          ],
          SizedBox(height: 20.h),
          NotebookSectionHeader(title: l10n.lessonHandout), SizedBox(height: 10.h),
          if (documents.isEmpty)
            Padding(padding: EdgeInsets.symmetric(vertical: 6.h), child: NotebookEmptyNote(icon: Icons.description_outlined, message: l10n.noHandoutYet))
          else ...documents.map((d) => LessonDocumentTile(document: d, onTap: () => _openDocument(d))),
          SizedBox(height: 20.h),
          NotebookSectionHeader(title: l10n.lessonExam), SizedBox(height: 10.h),
          if (lessonExams.isEmpty)
            Padding(padding: EdgeInsets.symmetric(vertical: 6.h), child: NotebookEmptyNote(icon: Icons.quiz_outlined, message: l10n.noLessonExam))
          else ...lessonExams.map((e) => LessonExamTile(exam: e, onTap: () => _openExam(e))),
          SizedBox(height: 20.h),
          NotebookSectionHeader(title: l10n.courseSectionTitle), SizedBox(height: 10.h),
          _buildLessonsList(),
        ],
      )),
    );
  }

  Widget _buildLessonsList() {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      bloc: coursesCubit,
      builder: (context, state) {
        if (state.lessonsStatus == StudentCoursesStatus.loading && state.lessons.isEmpty) {
          return Padding(padding: EdgeInsets.symmetric(vertical: 30.h), child: const Center(child: CircularProgressIndicator()));
        }
        final done = {for (final p in state.progress) if (p.isCompleted) p.lessonId};
        return Column(children: state.lessons.asMap().entries.map((e) {
          final l = e.value;
          final active = l.videoUrlOrId == activeUrl && l.title == activeTitle;
          return LessonListItem(lesson: l, index: e.key, isActive: active,
            isCompleted: done.contains(l.id), onTap: () => openLesson(l, widget.courseId));
        }).toList());
      },
    );
  }

  Future<void> _openDocument(Map<String, dynamic> doc) async {
    final url = doc['file_url'] as String? ?? '';
    if (url.isEmpty) return;
    HapticFeedback.lightImpact();
    final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.couldNotOpenFile, style: NotebookText.strong(12.sp)), backgroundColor: NotebookColors.marginRed));
    }
  }

  void _openExam(Map<String, dynamic> exam) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRouter.studentExamStart, arguments: exam).then((_) => loadLessonContent(activeLessonId));
  }
}
