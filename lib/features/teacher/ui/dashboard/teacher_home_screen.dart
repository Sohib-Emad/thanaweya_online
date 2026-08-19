import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/teacher/data/repos/teacher_cards_repo.dart';
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
  int _usedCodesCount = 0;
  int _availableCodesCount = 0;
  @override
  void initState() {
    super.initState();
    _profileCubit = TeacherProfileCubit(repo: TeacherProfileRepo());
    _loadData();
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
    _profileCubit.loadProfile(userId);
    _profileCubit.loadStats(userId);
    await Future.wait([
      _loadRecentStudents(userId),
      _loadCodesStats(userId),
    ]);
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
  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }
  String _greetingLabel() => DateTime.now().hour < 12 ? 'صباح الخير' : 'مساء الخير';
  String _teacherName() {
    final name = Supabase.instance.client.auth.currentUser?.userMetadata?['full_name']?.toString();
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
                teacherName: _teacherName(),
                greetingLabel: _greetingLabel(),
                teacherIdCode: _teacherIdCode(),
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
