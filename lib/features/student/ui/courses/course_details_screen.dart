import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/services/student_realtime_service.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/widgets.dart';

/// Full course detail screen with cover, meta, about, and curriculum tabs.
class CourseDetailsScreen extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic>? initialCourse;

  const CourseDetailsScreen({
    super.key,
    required this.courseId,
    this.initialCourse,
  });

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int _selectedTab = 0;
  bool _isDescriptionExpanded = false;
  bool _isSubscribed = false;
  late final StudentCoursesCubit _coursesCubit;
  final _playerManager = IntroPlayerManager();

  @override
  void initState() {
    super.initState();
    debugPrint('[CourseDetailsScreen] initState -> courseId: "${widget.courseId}", hasInitialCourse: ${widget.initialCourse != null}');
    _coursesCubit = StudentCoursesCubit(
      repo: StudentCoursesRepo(),
      initialCourse: widget.initialCourse,
    );
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    _coursesCubit.loadCourse(widget.courseId, initialData: widget.initialCourse);
    _coursesCubit.loadCourseLessons(widget.courseId, studentId: userId);
    if (userId != null) _coursesCubit.loadProgress(userId, courseId: widget.courseId);
    _checkSubscription();

    StudentRealtimeService.instance.addCoursesListener(_onRealtimeUpdate);
  }

  void _onRealtimeUpdate() {
    if (!mounted) return;
    final userId = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    _coursesCubit.loadCourse(widget.courseId);
    _coursesCubit.loadCourseLessons(widget.courseId, studentId: userId);
    if (userId != null) _coursesCubit.loadProgress(userId, courseId: widget.courseId);
    _checkSubscription();
  }

  @override
  void dispose() {
    StudentRealtimeService.instance.removeCoursesListener(_onRealtimeUpdate);
    _playerManager.dispose();
    _coursesCubit.close();
    super.dispose();
  }

  Future<void> _checkSubscription() async {
    var userId = Supabase.instance.client.auth.currentUser?.id ??
        Supabase.instance.client.auth.currentSession?.user.id;
    if (userId == null) {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
        if (!mounted) return;
        userId = Supabase.instance.client.auth.currentUser?.id ??
            Supabase.instance.client.auth.currentSession?.user.id;
        if (userId != null) break;
      }
    }
    if (userId == null || !mounted) return;
    _coursesCubit.loadCourseLessons(widget.courseId, studentId: userId);
    _coursesCubit.loadProgress(userId, courseId: widget.courseId);
    final res = await StudentCoursesRepo().subscription.checkIsSubscribed(studentId: userId, courseId: widget.courseId);
    if (!mounted) return;
    res.when(
      success: (isSub) => setState(() => _isSubscribed = isSub),
      failure: (_, _) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StudentCoursesCubit, StudentCoursesState>(
      bloc: _coursesCubit,
      listener: (context, state) {
        if (state.course != null) {
          final url = state.course!['intro_video_url'] as String? ?? '';
          final type = state.course!['intro_video_source_type'] as String? ?? 'youtube';
          if (url.isNotEmpty) {
            _playerManager.init(url, type, onReady: () { if (mounted) setState(() {}); });
          }
        }
      },
      builder: (context, state) {
        debugPrint('[CourseDetailsScreen] build -> courseStatus: ${state.courseStatus}, hasCourse: ${state.course != null && state.course!.isNotEmpty}');
        if (state.course == null || state.course!.isEmpty) {
          if (state.courseStatus == StudentCoursesStatus.error) {
            return CourseErrorView(onRetry: () {
              _coursesCubit.loadCourse(widget.courseId);
              _coursesCubit.loadCourseLessons(widget.courseId);
              _checkSubscription();
            });
          }
          return const CourseLoadingView();
        }
        return CourseDetailsBody(
          state: state, courseId: widget.courseId,
          selectedTab: _selectedTab, isDescriptionExpanded: _isDescriptionExpanded,
          isSubscribed: _isSubscribed,
          youtubeController: _playerManager.youtubeController,
          videoController: _playerManager.videoController,
          onTabChanged: (i) { HapticFeedback.selectionClick(); setState(() => _selectedTab = i); },
          onToggleDescription: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
          onLocked: (title) => showLockedLessonDialog(
            context: context, lessonTitle: title, courseId: widget.courseId,
            course: state.course!, onComplete: () => _checkSubscription(),
          ),
          onComplete: () => _checkSubscription(),
          onEnroll: () {
            final course = state.course!;
            final teachers = course['teachers'] as Map<String, dynamic>? ?? {};
            final tid = (teachers['id'] as String? ?? '').isNotEmpty
                ? teachers['id'] as String
                : (course['teacher_id'] as String? ?? '');
            Navigator.pushNamed(context, AppRouter.studentPaymentMethods, arguments: {
              'courseId': widget.courseId, 'teacherId': tid,
              'courseTitle': course['title'] ?? '',
              'price': (course['price'] as num?)?.toDouble(),
            }).then((_) => _checkSubscription());
          },
          onRefresh: () async {
            HapticFeedback.lightImpact();
            final userId = Supabase.instance.client.auth.currentUser?.id ??
                Supabase.instance.client.auth.currentSession?.user.id;
            _coursesCubit.loadCourse(widget.courseId);
            _coursesCubit.loadCourseLessons(widget.courseId, studentId: userId);
            if (userId != null) _coursesCubit.loadProgress(userId, courseId: widget.courseId);
            await _checkSubscription();
          },
          onBack: () => Navigator.pop(context),
        );
      },
    );
  }
}
