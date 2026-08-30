import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/services/student_realtime_service.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/course_filter_screen.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/course_filters.dart';
import 'package:thanaweya_online/features/student/ui/courses/student_my_courses_list_screen.dart';
import 'package:thanaweya_online/features/student/ui/leaderboard/student_leaderboard_screen.dart';
import 'package:thanaweya_online/features/student/ui/exams/exams_list_screen.dart';
import 'package:thanaweya_online/features/student/ui/profile/student_profile_tab.dart';
import 'package:thanaweya_online/features/student/logic/student_rewards_cubit.dart';
import 'package:thanaweya_online/features/student/ui/dashboard/home_init.dart';
import 'package:thanaweya_online/features/student/ui/dashboard/widgets/student_rewards_sheet.dart';
import 'package:thanaweya_online/features/student/ui/dashboard/widgets/widgets.dart';
import 'package:thanaweya_online/features/chatbot/presentation/widgets/chatbot_sheet.dart';
import 'package:thanaweya_online/features/wallet/presentation/pages/mobile_wallet_page.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// The main home screen for the student dashboard.
class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});
  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  late final StudentCoursesCubit _coursesCubit;
  late final StudentRewardsCubit _rewardsCubit;
  String _firstName = 'طالب';
  String _homeSubjectFilter = 'الكل';
  CourseFilters? _homeFilters;
  static const _palette = [Color(0xFF0FA37F), Color(0xFF2563EB), Color(0xFFEF4444), Color(0xFFD97706), Color(0xFF9333EA), Color(0xFF0284C7)];
  Color _colorFor(String k) => _palette[k.hashCode.abs() % _palette.length];

  List<Map<String, dynamic>> get _enrolledCourses =>
      _coursesCubit.state.popularCourses.where((c) {
        if (_homeSubjectFilter != 'الكل' && c['subject_name'] != _homeSubjectFilter) return false;
        if (_homeFilters != null && !_homeFilters!.matches(c)) return false;
        return true;
      }).map((c) => {
        'id': c['id'], 'title': c['title'], 'teacher': c['teacher_name'],
        'subject': c['subject_name'], 'cover': c['cover_image_url'],
        'price': (c['price'] as num?)?.toDouble(), 'color': _colorFor(c['id'] as String),
      }).toList();

  List<Map<String, dynamic>> get _teachers =>
      _coursesCubit.state.approvedTeachers.map((t) {
        final u = t['users'] as Map<String, dynamic>?;
        final name = u?['full_name'] as String? ?? '';
        return {
          'id': t['id'], 'name': 'أ. $name',
          'subject': (t['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ?? '',
          'avatarUrl': u?['avatar_url'] as String?,
        };
      }).toList();

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _rewardsCubit = StudentRewardsCubit();
    _rewardsCubit.loadRewards();
    loadStudentHomeData(cubit: _coursesCubit, onNameLoaded: (n) { if (mounted) setState(() => _firstName = n); }, isMounted: () => mounted);

    // Initialize Realtime subscriptions
    StudentRealtimeService.instance.init();
    StudentRealtimeService.instance.addPointsListener(_onRealtimePoints);
    StudentRealtimeService.instance.addCoursesListener(_onRealtimeCourses);
  }

  void _onRealtimePoints() {
    if (!mounted) return;
    _rewardsCubit.loadRewards();
  }

  void _onRealtimeCourses() {
    if (!mounted) return;
    loadStudentHomeData(cubit: _coursesCubit, onNameLoaded: (n) { if (mounted) setState(() => _firstName = n); }, isMounted: () => mounted);
  }

  @override
  void dispose() { 
    StudentRealtimeService.instance.removePointsListener(_onRealtimePoints);
    StudentRealtimeService.instance.removeCoursesListener(_onRealtimeCourses);
    _searchController.dispose(); 
    _coursesCubit.close(); 
    _rewardsCubit.close();
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
              bloc: _coursesCubit,
              builder: (context, _) => _buildHomeTab(context),
            ),
            StudentMyCoursesListScreen(isSelected: _currentIndex == 1),
            const MobileWalletPage(isTabMode: true),
            StudentLeaderboardScreen(isSelected: _currentIndex == 3),
            StudentExamsListScreen(isSelected: _currentIndex == 4),
            const StudentProfileTab(isTabMode: true),
          ],
        ),
      ),
      bottomNavigationBar: StudentBottomNavBar(currentIndex: _currentIndex, onTabChanged: (i) => setState(() => _currentIndex = i)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'student_chatbot_fab',
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Text('🤖', style: TextStyle(fontSize: 18)),
        label: Text(
          'المساعد الذكي',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () => ChatbotSheet.show(context),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    final l10n = context.l10n;
    return RefreshIndicator(
      color: NotebookColors.green,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await Future.wait([
          loadStudentHomeData(
            cubit: _coursesCubit,
            onNameLoaded: (n) {
              if (mounted) setState(() => _firstName = n);
            },
            isMounted: () => mounted,
          ),
          _rewardsCubit.loadRewards(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: NotebookPaper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<StudentRewardsCubit, StudentRewardsState>(
                bloc: _rewardsCubit,
                builder: (context, rewardState) {
                  return HomeMasthead(
                    firstName: _firstName,
                    points: rewardState.totalPoints,
                    canClaimDaily: rewardState.canClaimDaily,
                    onPointsTap: () => StudentRewardsSheet.show(context, _rewardsCubit),
                    onNotificationsTap: () =>
                        Navigator.pushNamed(context, AppRouter.notifications),
                  );
                },
              ),
              SizedBox(height: 20.h),
              HomeSearchBar(controller: _searchController, onFiltersChanged: (f) { if (mounted) setState(() => _homeFilters = f); }),
              SizedBox(height: 22.h),
              const HomePromoCard(),
              SizedBox(height: 26.h),
              EnrolledCoursesList(
                courses: _coursesCubit.state.myCourses,
                onNavigateToCourses: () => setState(() => _currentIndex = 1),
                onCourseTap: (c) { HapticFeedback.lightImpact(); Navigator.pushNamed(context, AppRouter.studentCurriculum, arguments: c['id'] as String); },
              ),
              NotebookSectionHeader(title: l10n.popularCourses, onAction: () => setState(() => _homeSubjectFilter = 'الكل')),
              SizedBox(height: 12.h),
              SubjectFilterChips(
                subjects: _coursesCubit.state.subjects.map((s) => s['name_ar'] as String).toList(),
                selectedFilter: _homeSubjectFilter, allLabel: l10n.all,
                onFilterChanged: (f) => setState(() => _homeSubjectFilter = f),
              ),
              if (_homeFilters?.isActive == true)
                NotebookHighlightNote(
                  child: Row(children: [
                    Icon(Icons.filter_alt_rounded, color: NotebookColors.ink, size: 16.r),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(l10n.filteredCourses(_enrolledCourses.length), style: NotebookText.strong(12.sp))),
                    GestureDetector(onTap: () => setState(() => _homeFilters = null), child: Text(l10n.clear, style: NotebookText.strong(12.sp, color: NotebookColors.marginRed))),
                  ]),
                ),
              SizedBox(height: 14.h),
              if (_enrolledCourses.isEmpty)
                Padding(padding: EdgeInsets.symmetric(horizontal: 24.w), child: NotebookEmptyNote(message: l10n.noCoursesMatch))
              else
                SizedBox(
                  height: 265.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal, padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: _enrolledCourses.length, separatorBuilder: (_, _) => SizedBox(width: 14.w),
                    itemBuilder: (_, i) { final c = _enrolledCourses[i]; return CourseCard(id: c['id'], title: c['title'], teacher: c['teacher'], subject: c['subject'], coverUrl: c['cover'], color: c['color'], price: c['price']); },
                  ),
                ),
              SizedBox(height: 26.h),
              NotebookSectionHeader(title: l10n.topTeachers),
              SizedBox(height: 12.h),
              TopTeachersList(teachers: _teachers),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
