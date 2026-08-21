import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/exam_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/widgets.dart';

import 'package:thanaweya_online/core/router/route_observer.dart';
import 'package:thanaweya_online/core/services/teacher_realtime_service.dart';

/// Screen listing all teacher exams with search, CRUD, and grades summary.
class ExamsListScreen extends StatefulWidget {
  const ExamsListScreen({super.key});
  @override
  State<ExamsListScreen> createState() => _ExamsListScreenState();
}

class _ExamsListScreenState extends State<ExamsListScreen> with RouteAware {
  final _cubit = TeacherExamsCubit(repo: TeacherExamsRepo());
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Map<String, String> _courseTitles = {};
  Map<String, ExamGradesSummary> _gradesSummaryByExam = {};

  @override
  void initState() {
    super.initState();
    _loadExams();
    TeacherRealtimeService.instance.addExamsListener(_onRealtimeExams);
  }

  void _onRealtimeExams() {
    if (!mounted) return;
    _loadExams();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() => _loadExams();

  @override
  void dispose() {
    TeacherRealtimeService.instance.removeExamsListener(_onRealtimeExams);
    appRouteObserver.unsubscribe(this);
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExams() async {
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
      _cubit.loadExams(userId);
      _cubit.loadExamQuestionStats(userId);
      await _loadCourses(userId);
      await _loadGradesSummary(userId);
    }
  }

  Future<void> _loadGradesSummary(String teacherId) async {
    final result = await TeacherExamsRepo().getExamGradesSummary(teacherId);
    result.when(
      success: (data) { if (mounted) setState(() => _gradesSummaryByExam = GradesSummaryComputer.compute(data)); },
      failure: (_, _) {},
    );
  }

  Future<void> _loadCourses(String teacherId) async {
    try {
      final result = await TeacherCoursesRepo().getCourses(teacherId);
      result.when(
        success: (courses) { if (mounted) setState(() => _courseTitles = {for (final c in courses) c.id: c.title}); },
        failure: (_, _) {},
      );
    } catch (e) {
      debugPrint('[ExamsList] load courses error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: DeskTopBar(
          title: 'الامتحانات والاختبارات',
          subtitle: 'إدارة وتصحيح الاختبارات الإلكترونية',
        ),
        body: BlocBuilder<TeacherExamsCubit, TeacherExamsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == TeacherExamsStatus.loading && state.exams.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
            }
            if (state.status == TeacherExamsStatus.error && state.exams.isEmpty) {
              return Center(
                child: DeskEmptyNote(
                  message: state.errorMessage ?? 'حدث خطأ أثناء تحميل الاختبارات',
                  icon: Icons.error_outline_rounded,
                  actionLabel: 'إعادة المحاولة',
                  onAction: _loadExams,
                ),
              );
            }
            if (state.exams.isEmpty) {
              return DeskEmptyNote(
                message: 'لا توجد اختبارات مسجلة بعد',
                subMessage: 'استخدم زر + لإنشاء أول اختبار وإضافة أسئلة',
                icon: Icons.quiz_outlined,
                actionLabel: 'إنشاء اختبار جديد',
                onAction: () => _showExamSheet(context, null),
              );
            }
            return ExamListBody(
              exams: state.exams,
              state: state,
              courseTitles: _courseTitles,
              gradesSummaryByExam: _gradesSummaryByExam,
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onRefresh: _loadExams,
              onExamTap: (exam) async {
                HapticFeedback.lightImpact();
                await Navigator.pushNamed(
                  context,
                  AppRouter.teacherAddQuestion,
                  arguments: exam.id,
                );
                _loadExams();
              },
              onExamEdit: (exam) => _showExamSheet(context, exam),
              onExamDelete: (exam) async {
                if (await showDeleteExamDialog(context, exam)) _cubit.deleteExam(exam.id);
              },
              onExamResults: (exam) async {
                await Navigator.pushNamed(
                  context,
                  AppRouter.teacherExamResults,
                  arguments: {'examId': exam.id, 'examTitle': exam.title},
                );
                _loadExams();
              },
              onTogglePublish: (exam) => _cubit.setExamPublished(exam.id, !exam.isPublished),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          onPressed: () async {
            HapticFeedback.lightImpact();
            await Navigator.pushNamed(context, AppRouter.teacherExamBuilder);
            _loadExams();
          },
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: Text(
            '+ إنشاء امتحان جديد',
            style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  void _showExamSheet(BuildContext context, ExamModel? exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DeskColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (sc) => Directionality(
        textDirection: TextDirection.rtl,
        child: ExamEditSheet(exam: exam, courseTitles: _courseTitles, cubit: _cubit),
      ),
    );
  }
}
