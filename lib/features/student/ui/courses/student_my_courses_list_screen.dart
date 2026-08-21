import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/services/student_realtime_service.dart';

import '../../../../core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/course_filter_screen.dart';
import 'package:thanaweya_online/features/student/ui/courses/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen listing the student's enrolled courses with tab switching.
class StudentMyCoursesListScreen extends StatefulWidget {
  final bool isSelected;

  const StudentMyCoursesListScreen({super.key, this.isSelected = false});

  @override
  State<StudentMyCoursesListScreen> createState() =>
      _StudentMyCoursesListScreenState();
}

class _StudentMyCoursesListScreenState
    extends State<StudentMyCoursesListScreen> {
  int _selectedTab = 1;
  late final StudentCoursesCubit _coursesCubit;
  CourseFilters? _activeFilters;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _loadMyCourses();

    StudentRealtimeService.instance.addCoursesListener(_onRealtimeCourses);
  }

  void _onRealtimeCourses() {
    if (!mounted) return;
    _loadMyCourses();
  }

  @override
  void didUpdateWidget(covariant StudentMyCoursesListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) _loadMyCourses();
  }

  Future<void> _loadMyCourses() async {
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
    if (userId != null && mounted) _coursesCubit.loadMyCourses(userId);
  }

  @override
  void dispose() {
    StudentRealtimeService.instance.removeCoursesListener(_onRealtimeCourses);
    _searchController.dispose();
    _coursesCubit.close();
    super.dispose();
  }

  Future<void> _openFilter() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.pushNamed<CourseFilters>(
        context, AppRouter.studentFilter);
    if (!mounted) return;
    setState(() => _activeFilters = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.myCoursesTitle, subtitle: l10n.myCoursesSubtitle),
      body: NotebookPaper(
        child: Column(
          children: [
            SizedBox(height: 14.h),
            NotebookSearchField(
                controller: _searchController,
                hint: l10n.searchInCoursesHint,
                onFilter: _openFilter),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: NotebookSegmentControl(
                options: [l10n.completedTab, l10n.ongoingTab],
                index: _selectedTab,
                onChanged: (i) => setState(() => _selectedTab = i),
              ),
            ),
            if (_activeFilters != null && _activeFilters!.isActive && _selectedTab == 1)
              NotebookHighlightNote(
                child: Row(
                  children: [
                    Icon(Icons.filter_alt_rounded, color: NotebookColors.ink, size: 16.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        l10n.filteredCourses(
                            _coursesCubit.state.myCourses.where(_activeFilters!.matches).length),
                        style: NotebookText.strong(12.sp),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _activeFilters = null),
                      child: Text(l10n.clear,
                          style: NotebookText.strong(12.sp, color: NotebookColors.marginRed)),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                bloc: _coursesCubit,
                builder: (context, state) {
                  return CoursesListView(
                    state: state,
                    isOngoing: _selectedTab == 1,
                    onRefresh: _loadMyCourses,
                    emptyOngoingText: l10n.noCoursesMatching,
                    emptyCompletedText: l10n.noCompletedCourses,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
