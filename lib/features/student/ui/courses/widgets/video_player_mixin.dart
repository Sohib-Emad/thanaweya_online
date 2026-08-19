import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thanaweya_online/core/utils/dailymotion_utils.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

/// Mixin encapsulating video player and lesson content logic.
mixin VideoPlayerMixin<T extends StatefulWidget> on State<T> {
  final StudentCoursesCubit coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
  final _repo = StudentCoursesRepo();

  String activeTitle = '';
  String activeDescription = '';
  String activeUrl = '';
  String activeLessonId = '';
  bool isYoutube = false, isDailymotion = true, isUploadLoading = false;
  bool isSubscribed = false, isCheckingSubscription = true, viewLocked = false;
  int viewCount = 0, maxViews = 5;
  String _viewIncrementedFor = '';
  List<Map<String, dynamic>> documents = [], lessonExams = [];
  YoutubePlayerController? youtubeController;
  VideoPlayerController? videoController;
  Duration currentPosition = Duration.zero, totalDuration = Duration.zero;
  bool isCompleted = false;
  int _lastSavedSecond = 0;

  void disposePlayerControllers() {
    try { youtubeController?.removeListener(_onYoutubeTick); youtubeController?.dispose(); } catch (_) {}
    try { videoController?.removeListener(_onVideoTick); videoController?.pause(); videoController?.dispose(); } catch (_) {}
    youtubeController = null; videoController = null;
  }

  void _setActive({required String title, required String description, required String url, required String lessonId, required bool dm, required bool yt}) {
    activeTitle = title; activeDescription = description; activeUrl = url;
    activeLessonId = lessonId; isDailymotion = dm; isYoutube = yt; isUploadLoading = true;
  }

  Future<void> checkSubscription({required String courseId, required String lessonId, required String videoUrl, required String videoSourceType, required String title, required String description, required VoidCallback onSubscribed}) async {
    var userId = Supabase.instance.client.auth.currentUser?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
    if (userId == null) {
      for (int i = 0; i < 6; i++) {
        await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
        if (!mounted) return;
        userId = Supabase.instance.client.auth.currentUser?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
        if (userId != null) break;
      }
    }
    if (userId == null || !mounted) { setState(() { isSubscribed = false; isCheckingSubscription = false; }); return; }
    var cid = courseId;
    if (cid.isEmpty && lessonId.isNotEmpty) {
      try { final l = await Supabase.instance.client.from('lessons').select('course_id').eq('id', lessonId).maybeSingle(); cid = l?['course_id'] as String? ?? ''; } catch (_) {}
    }
    final res = await _repo.subscription.checkIsSubscribed(studentId: userId, courseId: cid);
    if (!mounted) return;
    res.when(
      success: (isSub) { setState(() { isSubscribed = isSub; isCheckingSubscription = false; }); if (isSub) onSubscribed(); },
      failure: (_, __) { setState(() { isSubscribed = false; isCheckingSubscription = false; }); },
    );
  }

  Future<void> loadLessonContent(String lessonId) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final statusRes = await _repo.lessons.detail.getLessonViewStatus(studentId: userId, lessonId: lessonId);
    statusRes.when(success: (s) { if (s != null && mounted) setState(() { maxViews = s['maxViews'] as int? ?? 3; viewCount = s['viewCount'] as int? ?? 0; viewLocked = viewCount >= maxViews; }); }, failure: (_, __) {});
    final docsRes = await _repo.lessons.detail.getLessonDocuments(lessonId);
    docsRes.when(success: (d) { if (mounted) setState(() => documents = d); }, failure: (_, __) {});
    final examsRes = await _repo.lessons.detail.examsRepo.getLessonExams(lessonId: lessonId, studentId: userId);
    examsRes.when(success: (e) { if (mounted) setState(() => lessonExams = e); }, failure: (_, __) {});
    try {
      final prog = await Supabase.instance.client.from('lesson_progress').select('is_completed, watched_seconds').eq('student_id', userId).eq('lesson_id', lessonId).maybeSingle();
      if (prog != null && mounted) setState(() { final wc = (prog['watched_seconds'] as num?)?.toInt() ?? 0; isCompleted = ((prog['is_completed'] as bool?) ?? false) || wc > 0; if (wc > 0 && _lastSavedSecond == 0) _lastSavedSecond = wc; });
    } catch (_) {}
  }

  void initPlayer({required String url, required String sourceType, required String title, String description = '', String lessonId = '', bool notify = true}) {
    disposePlayerControllers();
    final dm = sourceType.toLowerCase() == 'dailymotion' || DailymotionUtils.isDailymotionUrl(url);
    final yt = !dm && (sourceType.toLowerCase() == 'youtube' || url.contains('youtube') || url.contains('youtu.be'));
    currentPosition = Duration.zero; totalDuration = Duration.zero; isCompleted = false; _lastSavedSecond = 0;
    final updater = () => _setActive(title: title, description: description, url: url, lessonId: lessonId, dm: dm, yt: yt);
    notify ? setState(updater) : updater();
    if (dm) { setState(() => isUploadLoading = false); _handleViewStarted(lessonId); }
    else if (yt) { setState(() { isUploadLoading = false; youtubeController = YoutubePlayerController(initialVideoId: YoutubePlayer.convertUrlToId(url) ?? url.trim(), flags: const YoutubePlayerFlags(autoPlay: true))..addListener(_onYoutubeTick); }); }
    else { try { videoController = VideoPlayerController.networkUrl(Uri.parse(url))..initialize().then((_) { if (mounted) { setState(() => isUploadLoading = false); videoController?.play(); _handleViewStarted(lessonId); } }).catchError((_) { if (mounted) setState(() => isUploadLoading = false); })..addListener(_onVideoTick); } catch (_) { setState(() => isUploadLoading = false); } }
  }

  Future<void> _handleViewStarted(String lessonId) async {
    if (lessonId.isEmpty || _viewIncrementedFor == lessonId) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final res = await _repo.lessons.detail.incrementLessonView(studentId: userId, lessonId: lessonId);
    res.when(success: (count) { _viewIncrementedFor = lessonId; if (mounted) setState(() => viewCount = count); }, failure: (_, __) {});
  }

  void onPlayerPositionChanged(Duration pos, Duration dur) {
    if (!mounted || activeLessonId.isEmpty) return;
    currentPosition = pos;
    if (dur > Duration.zero) totalDuration = dur;
    final posSec = pos.inSeconds, durSec = totalDuration.inSeconds;
    final reachedEnd = durSec > 0 && (posSec >= durSec * 0.9 || posSec >= durSec - 3);
    if (reachedEnd && !isCompleted) { isCompleted = true; saveProgress(posSec, true); if (mounted) setState(() {}); }
    else if (posSec > 0 && (posSec - _lastSavedSecond).abs() >= 10) { _lastSavedSecond = posSec; saveProgress(posSec, isCompleted); if (mounted) setState(() {}); }
  }

  Future<void> saveProgress(int sec, bool done) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || activeLessonId.isEmpty) return;
    await _repo.lessons.updateLessonProgress(studentId: userId, lessonId: activeLessonId, watchedSeconds: sec, isCompleted: done);
  }

  void _onYoutubeTick() { final c = youtubeController; if (c == null || !c.value.isReady) return; onPlayerPositionChanged(c.value.position, c.metadata.duration); }
  void _onVideoTick() { final c = videoController; if (c == null || !c.value.isInitialized) return; onPlayerPositionChanged(c.value.position, c.value.duration); }

  Future<void> openLesson(LessonModel lesson, String courseId, {VoidCallback? onLocked}) async {
    HapticFeedback.lightImpact();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    final res = await _repo.lessons.detail.getLessonViewStatus(studentId: userId ?? '', lessonId: lesson.id);
    var locked = false, vc = 0, mv = 3;
    res.when(success: (s) { if (s != null) { vc = s['viewCount'] as int? ?? 0; mv = s['maxViews'] as int? ?? 5; locked = vc >= mv; } }, failure: (_, __) {});
    if (locked) { setState(() { activeLessonId = lesson.id; activeTitle = lesson.title; viewCount = vc; maxViews = mv; viewLocked = true; }); onLocked?.call(); return; }
    _viewIncrementedFor = '';
    setState(() { activeLessonId = lesson.id; activeTitle = lesson.title; viewCount = vc; maxViews = mv; viewLocked = false; });
    loadLessonContent(lesson.id);
    initPlayer(url: lesson.videoUrlOrId, sourceType: lesson.videoSourceType.name, title: lesson.title, description: lesson.description ?? '', lessonId: lesson.id);
  }

  void toggleCompleted() async {
    final next = !isCompleted;
    setState(() => isCompleted = next);
    final s = next ? (totalDuration.inSeconds > 0 ? totalDuration.inSeconds : (currentPosition.inSeconds > 0 ? currentPosition.inSeconds : 60)) : 0;
    await saveProgress(s, next);
  }
}
