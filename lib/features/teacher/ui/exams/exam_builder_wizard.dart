import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/widgets.dart';

/// Three-step wizard for creating or editing an exam.
class ExamBuilderWizard extends StatefulWidget {
  const ExamBuilderWizard({
    super.key,
    this.initialCourseId,
    this.initialLessonId,
    this.examId,
  });

  final String? initialCourseId, initialLessonId, examId;

  @override
  State<ExamBuilderWizard> createState() => _ExamBuilderWizardState();
}

class _ExamBuilderWizardState extends State<ExamBuilderWizard> {
  int _step = 0;
  bool _saving = false;
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _time = TextEditingController(text: '45');
  final _passingScore = TextEditingController(text: '50');
  final _maxAttempts = TextEditingController(text: '3');
  DateTime? _startAt;
  DateTime? _endAt;
  bool _allowRetake = false;
  bool _shuffleQuestions = false;
  String? _courseId;
  String? _lessonId;
  List<Map<String, dynamic>> _courses = [];
  List<LessonModel> _courseLessons = [];
  final _questions = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _courseId = widget.initialCourseId;
    _lessonId = widget.initialLessonId;
    _loadCourses();
    if (_courseId != null) {
      _loadCourseLessons(_courseId!);
    }
  }

  Future<void> _loadCourses() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final res = await TeacherCoursesRepo().getCourses(uid);
    res.when(
      success: (courses) {
        if (!mounted) return;
        setState(() {
          _courses =
              courses.map((c) => {'id': c.id, 'title': c.title}).toList();
          _courseId ??= _courses.firstOrNull?['id'] as String?;
          if (_courseId != null && _courseLessons.isEmpty) {
            _loadCourseLessons(_courseId!);
          }
        });
      },
      failure: (_, _) {},
    );
  }

  Future<void> _loadCourseLessons(String courseId) async {
    final res = await TeacherCoursesRepo().lessonsRepo.getLessons(courseId);
    res.when(
      success: (lessons) {
        if (mounted) setState(() => _courseLessons = lessons);
      },
      failure: (_, _) {},
    );
  }

  void _onCourseChanged(String? newCourseId) {
    setState(() {
      _courseId = newCourseId;
      _lessonId = null;
      _courseLessons = [];
    });
    if (newCourseId != null) {
      _loadCourseLessons(newCourseId);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _time.dispose();
    _passingScore.dispose();
    _maxAttempts.dispose();
    super.dispose();
  }

  String _courseTitle() {
    for (final c in _courses) {
      if (c['id'] == _courseId) return (c['title'] as String?) ?? 'كورس عام';
    }
    return 'كورس عام';
  }

  void _next() {
    if (_step == 0 && _title.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم الامتحان')),
      );
      return;
    }
    if (_step == 1 && _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة سؤال واحد على الأقل للمتابعة')),
      );
      return;
    }
    if (_step < 2) {
      HapticFeedback.selectionClick();
      setState(() => _step++);
    }
  }

  void _prev() {
    if (_step > 0) {
      HapticFeedback.selectionClick();
      setState(() => _step--);
    }
  }

  Future<void> _publish() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final passingScoreVal = int.tryParse(_passingScore.text.trim()) ?? 50;
      final maxAttemptsVal = int.tryParse(_maxAttempts.text.trim()) ?? 3;
      final ok = await publishExam(
        context: context,
        userId: uid,
        title: _title.text.trim(),
        durationText: _time.text.trim(),
        courseId: _courseId,
        lessonId: _lessonId,
        startAt: _startAt,
        endAt: _endAt,
        passingScore: passingScoreVal,
        allowRetake: _allowRetake,
        maxAttempts: _allowRetake ? maxAttemptsVal : 1,
        shuffleQuestions: _shuffleQuestions,
        questions: _questions,
      );
      if (ok && mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _stepView() {
    switch (_step) {
      case 0:
        return StepBasicInfo(
          titleController: _title,
          descriptionController: _desc,
          timeLimitController: _time,
          passingScoreController: _passingScore,
          maxAttemptsController: _maxAttempts,
          selectedCourseId: _courseId,
          selectedLessonId: _lessonId,
          teacherCourses: _courses,
          courseLessons: _courseLessons,
          onCourseChanged: _onCourseChanged,
          onLessonChanged: (v) => setState(() => _lessonId = v),
          startAt: _startAt,
          endAt: _endAt,
          onStartAtChanged: (v) => setState(() => _startAt = v),
          onEndAtChanged: (v) => setState(() => _endAt = v),
          allowRetake: _allowRetake,
          onAllowRetakeChanged: (v) => setState(() => _allowRetake = v),
          shuffleQuestions: _shuffleQuestions,
          onShuffleQuestionsChanged: (v) =>
              setState(() => _shuffleQuestions = v),
        );
      case 1:
        return StepQuestionsBuilder(
          questions: _questions,
          onAddQuestion: () => StepQuestionsBuilder.showAddQuestionSheet(
            context,
            onAdded: (q) => setState(() => _questions.add(q)),
          ),
          onRemoveQuestion: (i) => setState(() => _questions.removeAt(i)),
        );
      case 2:
        return StepReviewPublish(
          title: _title.text,
          description: _desc.text,
          courseTitle: _courseTitle(),
          duration: _time.text,
          questionCount: _questions.length,
          totalScore: _questions.fold<int>(
            0,
            (s, q) => s + ((q['points'] as int?) ?? 5),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: widget.examId != null ? 'تعديل الامتحان' : 'إنشاء امتحان جديد',
          subtitle: 'معالج الـ 3 خطوات (خطوة ${_step + 1} من 3)',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: Column(children: [
            StepProgressBar(currentStep: _step),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(18.r),
                child: _stepView(),
              ),
            ),
            WizardBottomNav(
              currentStep: _step,
              isSaving: _saving,
              onPrev: _prev,
              onNext: _next,
              onPublish: _publish,
            ),
          ]),
        ),
      ),
    );
  }
}
