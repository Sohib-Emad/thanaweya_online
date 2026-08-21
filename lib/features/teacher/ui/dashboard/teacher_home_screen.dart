import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/services/teacher_realtime_service.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_cards_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_profile_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_profile_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/courses_list_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/dashboard/widgets/widgets.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/exams_list_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/settings/teacher_settings_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/students/students_list_screen.dart';

/// Teacher home screen with tabbed navigation and overview dashboard.
class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;
  late final TeacherProfileCubit _profileCubit;
  List<Map<String, dynamic>> _recentStudents = [];
  List<CourseModel> _recentCourses = [];
  List<ExamModel> _recentExams = [];
  bool _isLoadingContent = false;
  int _usedCodesCount = 0;
  int _availableCodesCount = 0;
  bool _requiresRenewal = false;

  @override
  void initState() {
    super.initState();
    _profileCubit = TeacherProfileCubit(repo: TeacherProfileRepo());
    _loadData();

    TeacherRealtimeService.instance.init();
    TeacherRealtimeService.instance.addCoursesListener(_onRealtimeData);
    TeacherRealtimeService.instance.addExamsListener(_onRealtimeData);
    TeacherRealtimeService.instance.addDataListener(_onRealtimeData);
  }

  void _onRealtimeData() {
    if (!mounted) return;
    _loadData();
  }

  @override
  void dispose() {
    TeacherRealtimeService.instance.removeCoursesListener(_onRealtimeData);
    TeacherRealtimeService.instance.removeExamsListener(_onRealtimeData);
    TeacherRealtimeService.instance.removeDataListener(_onRealtimeData);
    _profileCubit.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    String? userId = Supabase.instance.client.auth.currentUser?.id ??
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

    setState(() => _isLoadingContent = true);
    _profileCubit.loadProfile(userId);
    _profileCubit.loadStats(userId);

    await Future.wait([
      _loadRecentStudents(userId),
      _loadRecentCourses(userId),
      _loadRecentExams(userId),
      _loadCodesStats(userId),
      _loadRenewalStatus(userId),
    ]);

    if (mounted) {
      setState(() => _isLoadingContent = false);
    }
  }

  Future<void> _loadRecentCourses(String teacherId) async {
    try {
      final res = await TeacherCoursesRepo().getCourses(teacherId);
      res.when(
        success: (courses) {
          if (mounted) setState(() => _recentCourses = courses);
        },
        failure: (_, _) {},
      );
    } catch (e) {
      debugPrint('[TeacherHome] load courses error: $e');
    }
  }

  Future<void> _loadRecentExams(String teacherId) async {
    try {
      final res = await TeacherExamsRepo().getExams(teacherId);
      res.when(
        success: (exams) {
          if (mounted) setState(() => _recentExams = exams);
        },
        failure: (_, _) {},
      );
    } catch (e) {
      debugPrint('[TeacherHome] load exams error: $e');
    }
  }

  Future<void> _loadRenewalStatus(String teacherId) async {
    try {
      final doc = await Supabase.instance.client
          .from('teachers')
          .select('requires_renewal')
          .eq('id', teacherId)
          .maybeSingle();
      if (doc != null && mounted) {
        setState(() {
          _requiresRenewal = doc['requires_renewal'] == true;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRecentStudents(String teacherId) async {
    try {
      final result = await TeacherStudentsRepo().getStudents(teacherId);
      result.when(
        success: (data) {
          if (mounted) {
            setState(() {
              _recentStudents = data.length > 5 ? data.sublist(0, 5) : data;
            });
          }
        },
        failure: (_, _) {},
      );
    } catch (e) {
      debugPrint('[TeacherHome] load recent students error: $e');
    }
  }

  Future<void> _loadCodesStats(String teacherId) async {
    try {
      final result = await TeacherCardsRepo().getActivationCodes(teacherId);
      result.when(
        success: (codes) {
          if (mounted) {
            final used = codes.where((c) => c['is_used'] == true).length;
            final available =
                codes.where((c) => c['is_used'] != true).length;
            setState(() {
              _usedCodesCount = used;
              _availableCodesCount = available;
            });
          }
        },
        failure: (_, _) {},
      );
    } catch (e) {
      debugPrint('[TeacherHome] load codes error: $e');
    }
  }


  String _greetingLabel() =>
      DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير';

  String _teacherName() {
    final name = Supabase.instance.client.auth.currentUser
        ?.userMetadata?['full_name']
        ?.toString();
    return name != null && name.isNotEmpty ? name : 'أحمد محمود';
  }

  String _teacherIdCode() {
    final uid = Supabase.instance.client.auth.currentUser?.id ?? '7458';
    final code = uid.length >= 5 ? uid.substring(0, 5).toUpperCase() : uid;
    return 'T$code';
  }

  void _switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              TeacherOverviewTab(
                availableCodesCount: _availableCodesCount,
                usedCodesCount: _usedCodesCount,
                recentStudents: _recentStudents,
                recentCourses: _recentCourses,
                recentExams: _recentExams,
                isLoadingContent: _isLoadingContent,
                teacherName: _teacherName(),
                greetingLabel: _greetingLabel(),
                teacherIdCode: _teacherIdCode(),
                requiresRenewal: _requiresRenewal,
                onRefresh: _loadData,
                onSwitchTab: _switchTab,
              ),
              const CoursesListScreen(),
              const ExamsListScreen(),
              const StudentsListScreen(),
              const TeacherSettingsScreen(),
            ],
          ),
          bottomNavigationBar: TeacherBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _switchTab,
          ),
        ),
      ),
    );
  }
}
