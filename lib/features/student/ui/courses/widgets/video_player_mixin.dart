import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thanaweya_online/core/utils/dailymotion_utils.dart';
import 'package:thanaweya_online/core/utils/lesson_progression_helper.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/lesson_exam_required_dialog.dart';

/// Mixin encapsulating video player and lesson content logic.
mixin VideoPlayerMixin<T extends StatefulWidget> on State<T> {
  final StudentCoursesCubit coursesCubit = StudentCoursesCubit(
    repo: StudentCoursesRepo(),
  );
  final _repo = StudentCoursesRepo();

  String activeTitle = '';
  String activeDescription = '';
  String activeUrl = '';
  String activeLessonId = '';
  bool isYoutube = false, isDailymotion = true, isUploadLoading = false;
  bool isSubscribed = false, isCheckingSubscription = true, viewLocked = false;
  int viewCount = 0, maxViews = 3;
  String _viewIncrementedFor = '';
  List<Map<String, dynamic>> documents = [], lessonExams = [];
  YoutubePlayerController? youtubeController;
  VideoPlayerController? videoController;
  Duration currentPosition = Duration.zero, totalDuration = Duration.zero;
  Duration maxWatchedPosition = Duration.zero;
  bool isCompleted = false;
  int _lastSavedSecond = 0;
  int resumeSeconds = 0;
  DateTime? _lastSeekNoticeTime;
  bool _disposed = false;

  void _showForwardSeekBlockedNotice() {
    if (_lastSeekNoticeTime != null &&
        DateTime.now().difference(_lastSeekNoticeTime!).inSeconds < 3) {
      return;
    }
    _lastSeekNoticeTime = DateTime.now();
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'غير مسموح بتقديم الفيديو، يجب متابعة الشرح بالترتيب ⏳',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void disposePlayerControllers() {
    _disposed = true;

    // Step 1: Capture old references then immediately null them out.
    // This ensures the next setState/build will NOT pass the old controller
    // to YoutubePlayerBuilder, so it can unregister its WidgetsBindingObserver
    // before we call dispose() on the controller.
    final oldYt = youtubeController;
    final oldVid = videoController;
    youtubeController = null;
    videoController = null;

    // Step 2: Remove our own listeners synchronously.
    try {
      oldYt?.removeListener(_onYoutubeTick);
    } catch (_) {}
    try {
      oldVid?.removeListener(_onVideoTick);
    } catch (_) {}

    void doDispose() {
      try {
        oldYt?.dispose();
      } catch (_) {}
      try {
        oldVid?.pause();
        oldVid?.dispose();
      } catch (_) {}
    }

    // Step 3: Choose disposal strategy based on mount state:
    // - If still mounted (lesson switch): use double-postFrameCallback so the
    //   Flutter framework fully rebuilds the widget tree (removing
    //   YoutubePlayerBuilder and its WidgetsBindingObserver) BEFORE dispose().
    //   A microtask fires BEFORE the frame, postFrameCallback fires AFTER.
    // - If not mounted (State.dispose() path): the widget is already removed
    //   from the tree, so dispose immediately (postFrameCallback won't fire).
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => doDispose());
      });
    } else {
      doDispose();
    }
  }

  void _setActive({
    required String title,
    required String description,
    required String url,
    required String lessonId,
    required bool dm,
    required bool yt,
  }) {
    activeTitle = title;
    activeDescription = description;
    activeUrl = url;
    activeLessonId = lessonId;
    isDailymotion = dm;
    isYoutube = yt;
    isUploadLoading = true;
  }

  Future<void> checkSubscription({
    required String courseId,
    required String lessonId,
    required String videoUrl,
    required String videoSourceType,
    required String title,
    required String description,
    required VoidCallback onSubscribed,
  }) async {
    var userId =
        Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    if (userId == null) {
      for (int i = 0; i < 6; i++) {
        await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
        if (!mounted) return;
        userId =
            Supabase.instance.client.auth.currentUser?.id ??
            Supabase.instance.client.auth.currentSession?.user.id;
        if (userId != null) break;
      }
    }
    if (userId == null || !mounted) {
      setState(() {
        isSubscribed = false;
        isCheckingSubscription = false;
      });
      return;
    }
    var cid = courseId;
    if (cid.isEmpty && lessonId.isNotEmpty) {
      try {
        final l = await Supabase.instance.client
            .from('lessons')
            .select('course_id')
            .eq('id', lessonId)
            .maybeSingle();
        cid = l?['course_id'] as String? ?? '';
      } catch (_) {}
    }
    final res = await _repo.subscription.checkIsSubscribed(
      studentId: userId,
      courseId: cid,
    );
    if (!mounted) return;
    res.when(
      success: (isSub) {
        setState(() {
          isSubscribed = isSub;
          isCheckingSubscription = false;
        });
        if (isSub) onSubscribed();
      },
      failure: (_, __) {
        setState(() {
          isSubscribed = false;
          isCheckingSubscription = false;
        });
      },
    );
  }

  Future<void> loadLessonContent(String lessonId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final statusRes = await _repo.lessons.detail.getLessonViewStatus(
      studentId: userId,
      lessonId: lessonId,
    );
    statusRes.when(
      success: (s) {
        if (s != null && mounted) {
          setState(() {
            maxViews = s['maxViews'] as int? ?? 3;
            viewCount = s['viewCount'] as int? ?? 0;
            viewLocked = viewCount >= maxViews;
          });
        }
      },
      failure: (_, __) {},
    );
    final docsRes = await _repo.lessons.detail.getLessonDocuments(lessonId);
    docsRes.when(
      success: (d) {
        if (mounted) setState(() => documents = d);
      },
      failure: (_, __) {},
    );
    final examsRes = await _repo.lessons.detail.examsRepo.getLessonExams(
      lessonId: lessonId,
      studentId: userId,
    );
    examsRes.when(
      success: (e) {
        if (mounted) setState(() => lessonExams = e);
      },
      failure: (_, __) {},
    );
    try {
      final prog = await Supabase.instance.client
          .from('lesson_progress')
          .select('is_completed, watched_seconds')
          .eq('student_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();
      if (prog != null && mounted) {
        final wc = (prog['watched_seconds'] as num?)?.toInt() ?? 0;
        final done = (prog['is_completed'] as bool?) ?? false;
        setState(() {
          isCompleted = done;
          if (wc > 0) {
            _lastSavedSecond = wc;
            resumeSeconds = wc;
            currentPosition = Duration(seconds: wc);
            maxWatchedPosition = Duration(seconds: wc);
          }
        });
      }
    } catch (_) {}
  }

  void initPlayer({
    required String url,
    required String sourceType,
    required String title,
    String description = '',
    String lessonId = '',
    int? startAtSeconds,
    bool notify = true,
  }) {
    disposePlayerControllers();
    // We're initializing a new player right away, so clear the disposed flag.
    _disposed = false;
    final dm =
        sourceType.toLowerCase() == 'dailymotion' ||
        DailymotionUtils.isDailymotionUrl(url);
    final yt =
        !dm &&
        (sourceType.toLowerCase() == 'youtube' ||
            url.contains('youtube') ||
            url.contains('youtu.be'));
    final startSec = startAtSeconds ?? resumeSeconds;
    resumeSeconds = startSec;
    currentPosition = Duration(seconds: startSec);
    maxWatchedPosition = Duration(seconds: startSec);
    totalDuration = Duration.zero;
    _lastSavedSecond = startSec;
    final updater = () => _setActive(
      title: title,
      description: description,
      url: url,
      lessonId: lessonId,
      dm: dm,
      yt: yt,
    );
    notify ? setState(updater) : updater();

    if (dm) {
      setState(() => isUploadLoading = false);
      handleViewStarted(lessonId);
    } else if (yt) {
      setState(() {
        isUploadLoading = false;
        youtubeController = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(url) ?? url.trim(),
          flags: YoutubePlayerFlags(
            autoPlay: true,
            startAt: startSec,
            enableCaption: false,
            disableDragSeek: true,
            useHybridComposition: true,
          ),
        )..addListener(_onYoutubeTick);
      });
    } else {
      try {
        videoController = VideoPlayerController.networkUrl(Uri.parse(url))
          ..initialize()
              .then((_) {
                if (mounted) {
                  if (startSec > 0) {
                    videoController?.seekTo(Duration(seconds: startSec));
                  }
                  setState(() => isUploadLoading = false);
                  videoController?.play();
                }
              })
              .catchError((_) {
                if (mounted) setState(() => isUploadLoading = false);
              })
          ..addListener(_onVideoTick);
      } catch (_) {
        setState(() => isUploadLoading = false);
      }
    }
  }

  Future<void> handleViewStarted(String lessonId) async {
    // Views are only counted when reaching 90% of the video duration.
  }

  Future<void> _incrementViewOn90Percent(String lessonId) async {
    if (lessonId.isEmpty || _viewIncrementedFor == lessonId) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _viewIncrementedFor = lessonId;
    final res = await _repo.lessons.detail.incrementLessonView(
      studentId: userId,
      lessonId: lessonId,
    );
    res.when(
      success: (count) {
        if (mounted) {
          setState(() {
            viewCount = count;
            viewLocked = count >= maxViews;
          });
        }
      },
      failure: (_, __) {},
    );
  }

  void onPlayerPositionChanged(Duration pos, Duration dur) {
    if (!mounted || activeLessonId.isEmpty) return;
    currentPosition = pos;
    if (dur > Duration.zero) totalDuration = dur;
    final posSec = pos.inSeconds, durSec = totalDuration.inSeconds;
    final reached90Percent =
        durSec > 0 &&
        (posSec >= (durSec * 0.9).round() || posSec >= durSec - 3);

    if (reached90Percent) {
      if (!isCompleted) {
        isCompleted = true;
        saveProgress(posSec, true);
        if (mounted) setState(() {});
      }
      if (_viewIncrementedFor != activeLessonId) {
        _incrementViewOn90Percent(activeLessonId);
      }
    } else if (posSec > 0 && (posSec - _lastSavedSecond).abs() >= 10) {
      _lastSavedSecond = posSec;
      saveProgress(posSec, isCompleted);
      if (mounted) setState(() {});
    }
  }

  Future<void> saveProgress(int sec, bool done) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || activeLessonId.isEmpty) return;
    await _repo.lessons.updateLessonProgress(
      studentId: userId,
      lessonId: activeLessonId,
      watchedSeconds: sec,
      isCompleted: done,
    );
  }

  void _onYoutubeTick() {
    if (_disposed) return;
    final c = youtubeController;
    if (c == null || !c.value.isReady) return;
    try {
      final pos = c.value.position;
      final dur = c.metadata.duration;

      // Prevent fast-forwarding beyond what student has actually watched
      if (pos > maxWatchedPosition + const Duration(seconds: 2)) {
        c.seekTo(maxWatchedPosition);
        _showForwardSeekBlockedNotice();
      } else {
        if (pos > maxWatchedPosition) {
          maxWatchedPosition = pos;
        }
        onPlayerPositionChanged(pos, dur);
      }
    } catch (_) {}
  }

  void _onVideoTick() {
    final c = videoController;
    if (c == null || !c.value.isInitialized) return;
    final pos = c.value.position;
    final dur = c.value.duration;

    // Prevent fast-forwarding beyond what student has actually watched
    if (pos > maxWatchedPosition + const Duration(seconds: 2)) {
      c.seekTo(maxWatchedPosition);
      _showForwardSeekBlockedNotice();
    } else {
      if (pos > maxWatchedPosition) {
        maxWatchedPosition = pos;
      }
      onPlayerPositionChanged(pos, dur);
    }
  }

  Future<void> openLesson(
    LessonModel lesson,
    String courseId, {
    VoidCallback? onLocked,
  }) async {
    HapticFeedback.lightImpact();

    // 1. Check progression lock status (mandatory exam on previous lesson)
    if (coursesCubit.state.lessons.isNotEmpty) {
      final statusMap = LessonProgressionHelper.evaluateLessons(
        lessons: coursesCubit.state.lessons,
        progress: coursesCubit.state.progress,
        isSubscribed: true,
        courseExams: coursesCubit.state.courseExams,
        examSubmissions: coursesCubit.state.examSubmissions,
      );
      final lockStatus = statusMap[lesson.id];
      if (lockStatus != null && !lockStatus.isUnlocked) {
        LessonExamRequiredDialog.show(
          context,
          lessonTitle: lesson.title,
          lockStatus: lockStatus,
          courseId: courseId,
          onRefresh: () {
            final uid = Supabase.instance.client.auth.currentUser?.id;
            coursesCubit.loadCourseLessons(courseId, studentId: uid);
            if (uid != null) coursesCubit.loadProgress(uid, courseId: courseId);
          },
        );
        return;
      }
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    final res = await _repo.lessons.detail.getLessonViewStatus(
      studentId: userId ?? '',
      lessonId: lesson.id,
    );
    var locked = false, vc = 0, mv = 3;
    res.when(
      success: (s) {
        if (s != null) {
          vc = s['viewCount'] as int? ?? 0;
          mv = s['maxViews'] as int? ?? 3;
          locked = vc >= mv;
        }
      },
      failure: (_, __) {},
    );
    if (locked) {
      setState(() {
        activeLessonId = lesson.id;
        activeTitle = lesson.title;
        viewCount = vc;
        maxViews = mv;
        viewLocked = true;
      });
      onLocked?.call();
      return;
    }
    _viewIncrementedFor = '';
    resumeSeconds = 0;
    _lastSavedSecond = 0;
    setState(() {
      activeLessonId = lesson.id;
      activeTitle = lesson.title;
      viewCount = vc;
      maxViews = mv;
      viewLocked = false;
    });
    await loadLessonContent(lesson.id);
    if (!mounted || viewLocked) return;
    initPlayer(
      url: lesson.videoUrlOrId,
      sourceType: lesson.videoSourceType.name,
      title: lesson.title,
      description: lesson.description ?? '',
      lessonId: lesson.id,
      startAtSeconds: resumeSeconds,
    );
  }

  void toggleCompleted() async {
    final next = !isCompleted;
    setState(() => isCompleted = next);
    final s = next
        ? (totalDuration.inSeconds > 0
              ? totalDuration.inSeconds
              : (currentPosition.inSeconds > 0
                    ? currentPosition.inSeconds
                    : 60))
        : 0;
    await saveProgress(s, next);
  }
}
