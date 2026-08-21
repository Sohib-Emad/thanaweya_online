import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/services/student_realtime_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/lesson_progression_helper.dart';
import 'package:thanaweya_online/core/utils/screen_protection.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_progress_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/video_player_mixin.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (widget.courseId.isNotEmpty) {
      coursesCubit.loadCourseLessons(widget.courseId, studentId: uid);
    }
    if (uid != null) coursesCubit.loadProgress(uid, courseId: widget.courseId);
    _initSubscription();

    StudentRealtimeService.instance.addExamsListener(_onRealtimeExams);
  }

  void _onRealtimeExams() {
    if (!mounted || activeLessonId.isEmpty) return;
    loadLessonContent(activeLessonId);
  }

  Future<void> _initSubscription() async => checkSubscription(
    courseId: widget.courseId, lessonId: widget.lessonId,
    videoUrl: widget.videoUrl, videoSourceType: widget.videoSourceType,
    title: widget.title, description: widget.description,
    onSubscribed: () => loadLessonContent(widget.lessonId).then((_) async {
      if (!mounted || viewLocked) return;

      // Check progression lock status for initial entry
      if (widget.courseId.isNotEmpty) {
        final uid = Supabase.instance.client.auth.currentUser?.id;
        final res = await StudentCoursesRepo().lessons.getCourseLessonExams(
          courseId: widget.courseId,
          studentId: uid ?? '',
        );
        final exams = res.when(
          success: (d) =>
              (d['exams'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
              [],
          failure: (_, __) => <Map<String, dynamic>>[],
        );
        final submissions = res.when(
          success: (d) =>
              (d['submissions'] as List<dynamic>?)
                  ?.cast<Map<String, dynamic>>() ??
              [],
          failure: (_, __) => <Map<String, dynamic>>[],
        );

        final lessonsRes = await StudentCoursesRepo()
            .lessons
            .getCourseLessons(widget.courseId);
        final lessons = lessonsRes.when(
          success: (l) => l,
          failure: (_, __) => <LessonModel>[],
        );

        final progRes = await StudentCoursesRepo()
            .lessons
            .getStudentProgress(uid ?? '');
        final progress = progRes.when(
          success: (p) => p,
          failure: (_, __) => <LessonProgressModel>[],
        );

        final statusMap = LessonProgressionHelper.evaluateLessons(
          lessons: lessons,
          progress: progress,
          isSubscribed: true,
          courseExams: exams,
          examSubmissions: submissions,
        );

        final lockStatus = statusMap[widget.lessonId];
        if (lockStatus != null && !lockStatus.isUnlocked) {
          setState(() {
            viewLocked = true;
          });
          if (mounted) {
            LessonExamRequiredDialog.show(
              context,
              lessonTitle: widget.title,
              lockStatus: lockStatus,
              courseId: widget.courseId,
              onRefresh: () {
                Navigator.pop(context);
              },
            );
          }
          return;
        }
      }

      initPlayer(
        url: widget.videoUrl,
        sourceType: widget.videoSourceType,
        title: widget.title,
        description: widget.description,
        lessonId: widget.lessonId,
        startAtSeconds: resumeSeconds,
        notify: false,
      );
    }),
  );

  bool _isFullscreen = false;

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }

  @override
  void dispose() {
    StudentRealtimeService.instance.removeExamsListener(_onRealtimeExams);
    ScreenProtection.disable();
    disposePlayerControllers();
    coursesCubit.close();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Fullscreen view for uploaded / generic player
    if (_isFullscreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _toggleFullscreen();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: VideoArea(
              isCheckingSubscription: isCheckingSubscription,
              isSubscribed: isSubscribed,
              viewLocked: viewLocked,
              isDailymotion: isDailymotion,
              isYoutube: isYoutube,
              activeUrl: activeUrl,
              activeLessonId: activeLessonId,
              isUploadLoading: isUploadLoading,
              startSeconds: resumeSeconds,
              maxWatchedPosition: maxWatchedPosition,
              isFullscreen: true,
              onToggleFullscreen: _toggleFullscreen,
              onViewStarted: () => handleViewStarted(activeLessonId),
              youtubeController: youtubeController,
              videoController: videoController,
              courseId: widget.courseId,
            ),
          ),
        ),
      );
    }

    Widget buildBody(Widget? ytPlayer) {
      return Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(title: l10n.watchingLesson, subtitle: activeTitle),
        body: NotebookPaper(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            children: [
              ViewCountAlertBanner(viewCount: viewCount, maxViews: maxViews),
              if (ytPlayer != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: ytPlayer,
                  ),
                )
              else
                VideoArea(
                  isCheckingSubscription: isCheckingSubscription,
                  isSubscribed: isSubscribed,
                  viewLocked: viewLocked,
                  isDailymotion: isDailymotion,
                  isYoutube: isYoutube,
                  activeUrl: activeUrl,
                  activeLessonId: activeLessonId,
                  isUploadLoading: isUploadLoading,
                  startSeconds: resumeSeconds,
                  maxWatchedPosition: maxWatchedPosition,
                  isFullscreen: false,
                  onToggleFullscreen: _toggleFullscreen,
                  onViewStarted: () => handleViewStarted(activeLessonId),
                  onPositionChanged: onPlayerPositionChanged,
                  youtubeController: youtubeController,
                  videoController: videoController,
                  courseId: widget.courseId,
                ),
              SizedBox(height: 10.h),
              LiveProgressBanner(
                currentPosition: currentPosition,
                totalDuration: totalDuration,
                isCompleted: isCompleted,
              ),
              SizedBox(height: 14.h),
              Text(activeTitle, style: NotebookText.heading(17.sp)),
              if (activeDescription.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(activeDescription, style: NotebookText.body(12.sp)),
              ],
              SizedBox(height: 20.h),
              NotebookSectionHeader(title: l10n.lessonHandout),
              SizedBox(height: 10.h),
              if (documents.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: NotebookEmptyNote(
                    icon: Icons.description_outlined,
                    message: l10n.noHandoutYet,
                  ),
                )
              else
                ...documents.map((d) => LessonDocumentTile(
                      document: d,
                      onTap: () => _openDocument(d),
                    )),
              SizedBox(height: 20.h),
              NotebookSectionHeader(title: l10n.lessonExam),
              SizedBox(height: 10.h),
              if (lessonExams.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h),
                  child: NotebookEmptyNote(
                    icon: Icons.quiz_outlined,
                    message: l10n.noLessonExam,
                  ),
                )
              else
                ...lessonExams.map((e) => LessonExamTile(
                      exam: e,
                      onTap: () => _openExam(e),
                    )),
              SizedBox(height: 20.h),
              NotebookSectionHeader(title: l10n.courseSectionTitle),
              SizedBox(height: 10.h),
              _buildLessonsList(),
            ],
          ),
        ),
      );
    }

    if (isYoutube && youtubeController != null) {
      return YoutubePlayerBuilder(
        key: ValueKey(activeUrl),
        player: YoutubePlayer(
          controller: youtubeController!,
          showVideoProgressIndicator: true,
          onReady: () => handleViewStarted(activeLessonId),
        ),
        builder: (context, player) => buildBody(player),
      );
    }

    return buildBody(null);
  }

  Widget _buildLessonsList() {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      bloc: coursesCubit,
      builder: (context, state) {
        if (state.lessonsStatus == StudentCoursesStatus.loading && state.lessons.isEmpty) {
          return Padding(padding: EdgeInsets.symmetric(vertical: 30.h), child: const Center(child: CircularProgressIndicator()));
        }
        final statusMap = LessonProgressionHelper.evaluateLessons(
          lessons: state.lessons,
          progress: state.progress,
          isSubscribed: true,
          courseExams: state.courseExams,
          examSubmissions: state.examSubmissions,
        );
        final done = {for (final p in state.progress) if (p.isCompleted) p.lessonId};
        return Column(children: state.lessons.asMap().entries.map((e) {
          final l = e.value;
          final active = l.videoUrlOrId == activeUrl && l.title == activeTitle;
          final isLocked = !(statusMap[l.id]?.isUnlocked ?? true);
          return LessonListItem(
            lesson: l,
            index: e.key,
            isActive: active,
            isCompleted: done.contains(l.id),
            isLocked: isLocked,
            onTap: () => openLesson(l, widget.courseId),
          );
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
