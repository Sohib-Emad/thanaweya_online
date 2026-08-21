import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/router/route_observer.dart';
import 'package:thanaweya_online/core/services/student_realtime_service.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_exams_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_exams_cubit.dart';
import 'package:thanaweya_online/features/student/ui/exams/widgets/widgets.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Screen listing available exams with attempt tracking.
class StudentExamsListScreen extends StatefulWidget {
  final bool isSelected;
  const StudentExamsListScreen({super.key, this.isSelected = false});
  @override
  State<StudentExamsListScreen> createState() => _StudentExamsListScreenState();
}

class _StudentExamsListScreenState extends State<StudentExamsListScreen>
    with RouteAware {
  final _cubit = StudentExamsCubit(repo: StudentExamsRepo());
  @override
  void initState() {
    super.initState();
    _loadExams();
    StudentRealtimeService.instance.addExamsListener(_onRealtimeExams);
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
  void didUpdateWidget(covariant StudentExamsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) _loadExams();
  }

  @override
  void didPopNext() => _loadExams();

  @override
  void dispose() {
    StudentRealtimeService.instance.removeExamsListener(_onRealtimeExams);
    appRouteObserver.unsubscribe(this);
    _cubit.close();
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
    if (userId != null && mounted) _cubit.loadAvailableExams(userId);
  }

  void _openExam(Map<String, dynamic> exam) {
    final used = exam['attempts_used'] as int? ?? 0;
    final maxAttempts = exam['max_attempts'] as int? ?? 3;
    if (used >= maxAttempts) {
      HapticFeedback.heavyImpact();
      showDialog(context: context, builder: (_) =>
          ExamLockedDialog(exam: exam, onViewResults: () => _openResults(exam)));
      return;
    }
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRouter.studentExamStart, arguments: exam);
  }

  void _openResults(Map<String, dynamic> exam) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRouter.studentExamAttempts,
        arguments: {'examId': exam['id'], 'examTitle': exam['title']});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.examProgressTitle, subtitle: l10n.examProgressSubtitle),
      body: BlocBuilder<StudentExamsCubit, StudentExamsState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.status == StudentExamsStatus.loading) {
            return Center(child: CircularProgressIndicator(color: NotebookColors.green));
          }
          if (state.status == StudentExamsStatus.error) {
            return Padding(padding: EdgeInsets.all(24.w),
                child: NotebookEmptyNote(icon: Icons.error_outline_rounded,
                    message: state.errorMessage ?? l10n.loadExamsError));
          }
          if (state.availableExams.isEmpty) {
            return RefreshIndicator(onRefresh: _loadExams, color: NotebookColors.green,
              child: ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
                Padding(padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 100.h),
                    child: NotebookEmptyNote(icon: Icons.quiz_outlined, message: l10n.noExamsAvailable)),
              ]));
          }
          return NotebookPaper(child: RefreshIndicator(onRefresh: _loadExams,
              color: NotebookColors.green, child: ListView.builder(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                itemCount: state.availableExams.length,
                itemBuilder: (_, i) {
                  final exam = state.availableExams[i];
                  return ExamCard(exam: exam, onTap: () => _openExam(exam),
                      onResults: () => _openResults(exam));
                })));
        },
      ),
    );
  }
}
