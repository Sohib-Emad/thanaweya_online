import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

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
    this.videoSourceType = 'youtube',
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final StudentCoursesCubit _coursesCubit;

  String _activeTitle = '';
  String _activeDescription = '';
  String _activeUrl = '';
  bool _isYoutube = true;
  bool _isUploadLoading = false;

  bool _isSubscribed = false;
  bool _isCheckingSubscription = true;

  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    if (widget.courseId.isNotEmpty) {
      _coursesCubit.loadCourseLessons(widget.courseId);
    }
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _coursesCubit.loadProgress(userId);
    }
    _activeTitle = widget.title;
    _activeDescription = widget.description;

    _checkSubscription();
  }

  Future<void> _checkSubscription() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isSubscribed = false;
        _isCheckingSubscription = false;
      });
      return;
    }
    // Check if user is subscribed to this course/teacher
    final res = await StudentCoursesRepo().checkIsSubscribed(
      studentId: userId,
      courseId: widget.courseId,
    );
    if (!mounted) return;
    res.when(
      success: (isSub) {
        setState(() {
          _isSubscribed = isSub;
          _isCheckingSubscription = false;
        });
        if (isSub) {
          _initPlayer(
            url: widget.videoUrl,
            sourceType: widget.videoSourceType,
            title: widget.title,
            description: widget.description,
            notify: false,
          );
        }
      },
      failure: (_, __) {
        setState(() {
          _isSubscribed = false;
          _isCheckingSubscription = false;
        });
      },
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _videoController?.dispose();
    _coursesCubit.close();
    super.dispose();
  }

  void _initPlayer({
    required String url,
    required String sourceType,
    required String title,
    String description = '',
    bool notify = true,
  }) {
    _youtubeController?.dispose();
    _videoController?.dispose();
    _youtubeController = null;
    _videoController = null;

    final isYoutube = sourceType == 'youtube';

    if (notify) {
      setState(() {
        _activeTitle = title;
        _activeDescription = description;
        _activeUrl = url;
        _isYoutube = isYoutube;
        _isUploadLoading = true;
      });
    } else {
      _activeTitle = title;
      _activeDescription = description;
      _activeUrl = url;
      _isYoutube = isYoutube;
      _isUploadLoading = true;
    }

    if (isYoutube) {
      final videoId = YoutubePlayer.convertUrlToId(url) ?? url.trim();
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
      _isUploadLoading = false;
    } else {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
          ..initialize().then((_) {
            if (!mounted) return;
            setState(() => _isUploadLoading = false);
            _videoController?.play();
          }).catchError((Object e) {
            if (!mounted) return;
            setState(() => _isUploadLoading = false);
            debugPrint('[VideoPlayer] media init error: $e');
          });
      } catch (e) {
        _isUploadLoading = false;
        debugPrint('[VideoPlayer] media url error: $e');
      }
    }
  }

  void _openLesson(LessonModel lesson) {
    if (!_isSubscribed) {
      _showSubscriptionRequiredDialog();
      return;
    }
    HapticFeedback.lightImpact();
    _initPlayer(
      url: lesson.videoUrlOrId,
      sourceType: lesson.videoSourceType.name,
      title: lesson.title,
      description: lesson.description ?? '',
    );
  }

  void _showSubscriptionRequiredDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          backgroundColor: NotebookColors.ground,
          title: Row(
            children: [
              Icon(Icons.lock_rounded, color: NotebookColors.marginRed, size: 24.r),
              SizedBox(width: 8.w),
              Text('المحتوى مغلق', style: NotebookText.heading(16.sp)),
            ],
          ),
          content: Text(
            'هذه الحصة متاحة فقط للطلاب المشتركين. يرجى تفعيل كود الاشتراك أو الاشتراك للوصول الكامل للفيديوهات.',
            style: NotebookText.body(13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: NotebookText.strong(13.sp)),
            ),
            NotebookPrimaryButton(
              label: 'تفعيل كود الاشتراك',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRouter.studentPaymentMethods,
                  arguments: {
                    'courseId': widget.courseId,
                  },
                ).then((_) => _checkSubscription());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareLink() async {
    HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: _activeUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ رابط الدرس للمشاركة',
          style: NotebookText.strong(12.sp),
        ),
        backgroundColor: NotebookColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'مشاهدة الدرس',
          subtitle: _activeTitle,
          actions: [
            GestureDetector(
              onTap: _shareLink,
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: NotebookColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NotebookColors.green.withAlpha(160),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: NotebookColors.green,
                  size: 18.r,
                ),
              ),
            ),
          ],
        ),
        body: NotebookPaper(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            children: [
              _buildVideoArea(),
              SizedBox(height: 16.h),
              Text(_activeTitle, style: NotebookText.heading(17.sp)),
              if (_activeDescription.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  _activeDescription,
                  style: NotebookText.body(12.sp),
                ),
              ],
              SizedBox(height: 20.h),
              NotebookSectionHeader(title: 'دروس الكورس'),
              SizedBox(height: 10.h),
              BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                bloc: _coursesCubit,
                builder: (context, state) {
                  if (state.lessonsStatus ==
                          StudentCoursesStatus.loading &&
                      state.lessons.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 30.h),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: NotebookColors.green,
                        ),
                      ),
                    );
                  }

                  final completedIds = {
                    for (final p in state.progress)
                      if (p.isCompleted) p.lessonId,
                  };

                  return Column(
                    children: state.lessons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final lesson = entry.value;
                      final isActive =
                          lesson.videoUrlOrId == _activeUrl &&
                              lesson.title == _activeTitle;
                      final isCompleted = completedIds.contains(lesson.id);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: NotebookCard(
                          ruled: true,
                          ruledStartY: 20,
                          marginTab: isActive || isCompleted,
                          onTap: () => _openLesson(lesson),
                          child: Row(
                            children: [
                              Icon(
                                isActive
                                    ? Icons.play_circle_fill_rounded
                                    : isCompleted
                                        ? Icons.check_circle_rounded
                                        : Icons.play_circle_outline_rounded,
                                color: isActive || isCompleted
                                    ? NotebookColors.green
                                    : NotebookColors.pencil,
                                size: 22.r,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  '${index + 1}. ${lesson.title}',
                                  style: NotebookText.body(12.sp,
                                      color: isActive
                                          ? NotebookColors.green
                                          : NotebookColors.ink),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (lesson.durationSeconds != null)
                                Text(
                                  Formatters.formatDurationMinutes(
                                    (lesson.durationSeconds! / 60).ceil(),
                                  ),
                                  style: NotebookText.note(10.sp),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: Colors.black,
        child: _isCheckingSubscription
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              )
            : (!_isSubscribed
                ? _buildLockedOverlay()
                : (_isYoutube
                    ? (_youtubeController != null
                        ? Stack(
                            children: [
                              YoutubePlayer(
                                controller: _youtubeController!,
                                showVideoProgressIndicator: true,
                              ),
                              if (!_youtubeController!.value.isReady)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          )
                        : const SizedBox())
                    : (_videoController != null
                        ? Stack(
                            children: [
                              Positioned.fill(
                                child: Center(child: VideoPlayer(_videoController!)),
                              ),
                              if (_isUploadLoading)
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              else
                                _buildUploadOverlay(),
                            ],
                          )
                        : const SizedBox()))),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: NotebookColors.marginRed.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              color: NotebookColors.marginRed,
              size: 24.r,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'هذا الفيديو مغلق للمشتركين فقط',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'اشترك في الكورس وفعل كود الاشتراك لمشاهدة جميع الفيديوهات',
            style: GoogleFonts.cairo(
              fontSize: 10.sp,
              color: Colors.white.withAlpha(180),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRouter.studentPaymentMethods,
                arguments: {
                  'courseId': widget.courseId,
                },
              ).then((_) => _checkSubscription());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: NotebookColors.green,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vpn_key_rounded, color: Colors.white, size: 14.r),
                  SizedBox(width: 6.w),
                  Text(
                    'تفعيل كود الاشتراك',
                    style: GoogleFonts.cairo(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadOverlay() {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: _videoController!,
      builder: (context, value, _) {
        final position = value.position;
        final duration = value.duration;
        final progress = duration.inMilliseconds == 0
            ? 0.0
            : (position.inMilliseconds / duration.inMilliseconds)
                .clamp(0.0, 1.0);

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    value.isPlaying
                        ? _videoController?.pause()
                        : _videoController?.play();
                  });
                },
                child: Container(
                  margin: EdgeInsets.all(8.r),
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(210),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    value.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: const Color(0xFF0F172A),
                    size: 26.r,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  SizedBox(width: 8.w),
                  Text(
                    Formatters.formatDuration(position.inSeconds),
                    style: NotebookText.note(10.sp,
                        color: Colors.white.withAlpha(230)),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        activeTrackColor: NotebookColors.green,
                        inactiveTrackColor: Colors.white.withAlpha(100),
                        thumbColor: NotebookColors.green,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: progress,
                        onChanged: (v) {
                          if (duration.inMilliseconds == 0) return;
                          final target = Duration(
                            milliseconds:
                                (duration.inMilliseconds * v).round(),
                          );
                          _videoController?.seekTo(target);
                        },
                      ),
                    ),
                  ),
                  Text(
                    Formatters.formatDuration(duration.inSeconds),
                    style: NotebookText.note(10.sp,
                        color: Colors.white.withAlpha(230)),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
            SizedBox(height: 4.h),
          ],
        );
      },
    );
  }
}
