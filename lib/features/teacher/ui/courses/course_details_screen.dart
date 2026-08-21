import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/router/app_router.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';

import 'package:thanaweya_online/core/router/route_observer.dart';
import 'package:thanaweya_online/core/services/teacher_realtime_service.dart';

import 'widgets/widgets.dart';

/// Course details screen with tabs for lessons, students, exams, and statistics.
class CourseDetailsScreen extends StatefulWidget {
  final CourseModel course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  late CourseModel _currentCourse;
  final _coursesRepo = TeacherCoursesRepo();
  final _examsRepo = TeacherExamsRepo();
  final _studentsRepo = TeacherStudentsRepo();

  bool _loadingLessons = true;
  List<LessonModel> _lessons = [];
  bool _loadingExams = true;
  List<ExamModel> _exams = [];
  bool _loadingStudents = true;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _currentCourse = widget.course;
    _tabController = TabController(length: 4, vsync: this);
    _loadAll();

    TeacherRealtimeService.instance.addLessonsListener(_onRealtimeRefresh);
    TeacherRealtimeService.instance.addExamsListener(_onRealtimeRefresh);
    TeacherRealtimeService.instance.addCoursesListener(_onRealtimeRefresh);
  }

  void _onRealtimeRefresh() {
    if (!mounted) return;
    _loadAll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() => _loadAll();

  @override
  void dispose() {
    TeacherRealtimeService.instance.removeLessonsListener(_onRealtimeRefresh);
    TeacherRealtimeService.instance.removeExamsListener(_onRealtimeRefresh);
    TeacherRealtimeService.instance.removeCoursesListener(_onRealtimeRefresh);
    appRouteObserver.unsubscribe(this);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() => Future.wait([_loadLessons(), _loadExams(), _loadStudents()]);

  Future<void> _loadLessons() async {
    setState(() => _loadingLessons = true);
    final res = await _coursesRepo.lessonsRepo.getLessons(_currentCourse.id);
    if (!mounted) return;
    res.when(success: (l) => setState(() { _lessons = l; _loadingLessons = false; }), failure: (_, _) => setState(() => _loadingLessons = false));
  }

  Future<void> _loadExams() async {
    setState(() => _loadingExams = true);
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) { setState(() => _loadingExams = false); return; }
    final res = await _examsRepo.getExams(uid);
    if (!mounted) return;
    res.when(
      success: (all) => setState(() { _exams = all.where((e) => e.courseId == _currentCourse.id).toList(); _loadingExams = false; }),
      failure: (_, _) => setState(() => _loadingExams = false),
    );
  }

  Future<void> _loadStudents() async {
    setState(() => _loadingStudents = true);
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) { setState(() => _loadingStudents = false); return; }
    final res = await _studentsRepo.getStudents(uid);
    if (!mounted) return;
    res.when(success: (d) => setState(() { _students = d; _loadingStudents = false; }), failure: (_, _) => setState(() => _loadingStudents = false));
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: DeskColors.primaryDeep, content: Text(msg, style: GoogleFonts.cairo(fontWeight: FontWeight.w700))));
  }

  void _openEditModal() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) =>
      EditCourseModal(course: _currentCourse, coursesRepo: _coursesRepo, onShowSnack: _snack, onCourseUpdated: (u) => setState(() => _currentCourse = u)));
  }

  void _openDocsSheet(LessonModel lesson) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) =>
      LessonDocumentsModal(lesson: lesson, coursesRepo: _coursesRepo));
  }

  Future<void> _deleteLesson(LessonModel lesson) async {
    final ok = await showDeleteLessonDialog(context, lesson: lesson);
    if (!ok) return;
    final res = await _coursesRepo.lessonsRepo.deleteLesson(lesson.id);
    res.when(success: (_) { _snack('تم حذف المحاضرة بنجاح'); _loadLessons(); }, failure: (m, _) => _snack('فشل حذف المحاضرة: $m'));
  }

  void _handleLessonExam(LessonModel lesson, ExamModel? exam) async {
    HapticFeedback.lightImpact();
    if (exam == null) {
      // Create new exam specifically for this lesson
      await Navigator.pushNamed(
        context,
        AppRouter.teacherExamBuilder,
        arguments: {
          'courseId': _currentCourse.id,
          'lessonId': lesson.id,
        },
      );
      _loadAll();
    } else {
      // Existing exam menu
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'امتحان: ${exam.title}',
                  style: DeskText.heading(15.sp),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: Color(0xFF0284C7)),
                  title: Text('إدارة الأسئلة وإضافة أسئلة جديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, AppRouter.teacherAddQuestion, arguments: exam.id).then((_) => _loadAll());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined, color: Color(0xFF16A34A)),
                  title: Text('عرض درجات ونتائج الطلاب', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, AppRouter.teacherExamResults, arguments: {'examId': exam.id, 'examTitle': exam.title});
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: _currentCourse.title,
          subtitle: 'تفاصيل الكورس والمحاضرات والطلاب',
          automaticallyImplyBack: true,
          actions: [IconButton(icon: Icon(Icons.edit_note_rounded, color: DeskColors.primary, size: 22.r), tooltip: 'تعديل بيانات الكورس', onPressed: _openEditModal)],
        ),
        body: DeskSurface(
          child: Column(children: [
            CourseHeader(course: _currentCourse, studentsCount: _students.length, lessonsCount: _lessons.length, examsCount: _exams.length),
            CourseTabBar(controller: _tabController, lessonsCount: _lessons.length, studentsCount: _students.length, examsCount: _exams.length),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  CourseLessonsTab(
                    isLoading: _loadingLessons,
                    lessons: _lessons,
                    exams: _exams,
                    courseId: _currentCourse.id,
                    onRefresh: _loadLessons,
                    onShowDocuments: _openDocsSheet,
                    onConfirmDelete: _deleteLesson,
                    onExamTap: _handleLessonExam,
                  ),
                  CourseStudentsTab(isLoading: _loadingStudents, students: _students, onRefresh: _loadStudents),
                  CourseExamsTab(isLoading: _loadingExams, exams: _exams, courseId: _currentCourse.id, onRefresh: _loadExams),
                  CourseStatisticsTab(lessonsCount: _lessons.length, examsCount: _exams.length, studentsCount: _students.length, course: _currentCourse),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
