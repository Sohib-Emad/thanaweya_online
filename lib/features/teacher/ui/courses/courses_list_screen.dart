import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_courses_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/course_list_header.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/widgets/widgets.dart';

import 'package:thanaweya_online/core/router/route_observer.dart';
import 'package:thanaweya_online/core/services/teacher_realtime_service.dart';

/// Screen for listing and managing teacher's courses.
class CoursesListScreen extends StatefulWidget {
  const CoursesListScreen({super.key});

  @override
  State<CoursesListScreen> createState() => _CoursesListScreenState();
}

class _CoursesListScreenState extends State<CoursesListScreen> with RouteAware {
  final _cubit = TeacherCoursesCubit(repo: TeacherCoursesRepo());
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    TeacherRealtimeService.instance.addCoursesListener(_onRealtimeCourses);
  }

  void _onRealtimeCourses() {
    if (!mounted) return;
    _loadCourses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() => _loadCourses();

  Future<void> _loadCourses() async {
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
    if (userId != null && mounted) {
      _cubit.loadCourses(userId);
    }
  }

  void _openCreateCourseSheet() {
    HapticFeedback.lightImpact();
    CreateCourseSheet.show(
      context,
      onCourseCreated: () {
        _loadCourses();
        TeacherRealtimeService.instance.notifyCoursesChanged();
      },
    );
  }

  @override
  void dispose() {
    TeacherRealtimeService.instance.removeCoursesListener(_onRealtimeCourses);
    appRouteObserver.unsubscribe(this);
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: DeskTopBar(title: 'الكورسات والدورات', subtitle: 'إدارة وتنسيق المحتوى التعليمي والدروس', automaticallyImplyBack: true),
        body: BlocBuilder<TeacherCoursesCubit, TeacherCoursesState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == TeacherCoursesStatus.loading && state.courses.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
            }
            if (state.status == TeacherCoursesStatus.error && state.courses.isEmpty) {
              return Center(child: DeskEmptyNote(
                message: state.errorMessage ?? 'حدث خطأ أثناء تحميل الدورات',
                icon: Icons.error_outline_rounded, actionLabel: 'إعادة المحاولة', onAction: _loadCourses));
            }
            if (state.courses.isEmpty) {
              return Center(child: DeskEmptyNote(
                message: 'لا توجد دورات مسجلة بعد', subMessage: 'اضغط على زر + لإنشاء أول كورس',
                icon: Icons.menu_book_outlined, actionLabel: 'إنشاء دورة جديدة الآن', onAction: _openCreateCourseSheet));
            }
            return _buildCourseList(context, state);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: _openCreateCourseSheet,
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text('+ إنشاء دورة جديدة', style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  void _openEditModal(CourseModel course) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditCourseModal(
        course: course,
        coursesRepo: TeacherCoursesRepo(),
        onShowSnack: (msg) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: DeskColors.primaryDeep,
              content: Text(msg, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onCourseUpdated: (_) => _loadCourses(),
      ),
    );
  }

  Widget _buildCourseList(BuildContext context, TeacherCoursesState state) {
    final publishedCount = state.courses.where((c) => c.isPublished).length;
    final draftCount = state.courses.where((c) => !c.isPublished).length;
    final filteredCourses = state.courses.where((c) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = c.title.toLowerCase().contains(q) || (c.description?.toLowerCase().contains(q) ?? false);
      if (!matchesSearch) return false;
      if (_filterIndex == 1) return c.isPublished;
      if (_filterIndex == 2) return !c.isPublished;
      return true;
    }).toList();

    return Column(
      children: [
        CourseListHeader(
          searchController: _searchController, searchQuery: _searchQuery,
          filterIndex: _filterIndex, publishedCount: publishedCount, draftCount: draftCount,
          totalCount: state.courses.length, filteredCount: filteredCourses.length,
          onSearchChanged: (val) => setState(() => _searchQuery = val),
          onFilterChanged: (i) => setState(() => _filterIndex = i),
        ),
        Expanded(
          child: filteredCourses.isEmpty
              ? const Center(child: DeskEmptyNote(message: 'لا توجد دورات مطابقة', icon: Icons.search_off_rounded))
              : RefreshIndicator(
                  onRefresh: _loadCourses, color: const Color(0xFF0284C7),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
                    itemCount: filteredCourses.length,
                    separatorBuilder: (_, _) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final course = filteredCourses[index];
                      final lessonCount = 0;
                      return CourseCard(
                        course: course, lessonCount: lessonCount,
                        onTap: () { HapticFeedback.lightImpact(); Navigator.pushNamed(context, AppRouter.teacherCourseDetails, arguments: course); },
                        onEdit: () => _openEditModal(course),
                        onDelete: () async {
                          final confirmed = await showConfirmDeleteCourseDialog(context, course);
                          if (confirmed == true) _cubit.deleteCourse(course.id);
                        },
                        onTogglePublish: () => _cubit.updateCourse(courseId: course.id, title: course.title, description: course.description, isPublished: !course.isPublished),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
