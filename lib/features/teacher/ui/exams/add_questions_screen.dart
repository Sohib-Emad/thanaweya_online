import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/widgets.dart';

/// Screen for managing and adding questions to an exam.
class AddQuestionsScreen extends StatefulWidget {
  final String examId;
  const AddQuestionsScreen({super.key, required this.examId});
  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  String _selectedType = 'mcq';
  final _questionCtrl = TextEditingController();
  final _optionCtrls = List.generate(4, (_) => TextEditingController());
  final _pointsCtrl = TextEditingController(text: '1');
  int _correctAnswer = 0;
  String _tfAnswer = 'true';
  bool _saving = false;
  late final TeacherExamsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TeacherExamsCubit(repo: TeacherExamsRepo());
    _cubit.loadQuestions(widget.examId);
  }

  @override
  void dispose() {
    _cubit.close();
    _questionCtrl.dispose();
    for (final c in _optionCtrls) { c.dispose(); }
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DeskColors.primaryDeep,
        content: Text(msg, style: DeskText.strong(12.sp)),
      ),
    );
  }

  Future<void> _save() async {
    final text = _questionCtrl.text.trim();
    if (text.isEmpty) { _snack('برجاء إدخال نص السؤال'); return; }
    final pts = int.tryParse(_pointsCtrl.text.trim());
    if (pts == null || pts <= 0) {
      _snack('برجاء إدخال درجات السؤال بصورة صحيحة'); return;
    }
    if (_selectedType == 'mcq') {
      for (final c in _optionCtrls) {
        if (c.text.trim().isEmpty) {
          _snack('برجاء إدخال جميع الخيارات'); return;
        }
      }
    }
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    const letters = ['أ', 'ب', 'ج', 'د'];
    String? ca; List<String> opts;
    if (_selectedType == 'mcq') {
      opts = _optionCtrls.map((c) => c.text.trim()).toList();
      ca = letters[_correctAnswer];
    } else if (_selectedType == 'tf') {
      opts = const ['صحيح', 'خطأ'];
      ca = _tfAnswer == 'true' ? 'صحيح' : 'خطأ';
    } else { opts = []; }
    await _cubit.addQuestion(
      examId: widget.examId,
      questionType: _selectedType == 'tf' ? 'true_false' : _selectedType,
      text: text, options: opts, correctAnswer: ca, points: pts,
    );
    if (mounted) {
      setState(() {
        _saving = false;
        _questionCtrl.clear();
        _pointsCtrl.text = '1';
        for (final c in _optionCtrls) { c.clear(); }
        _correctAnswer = 0;
      });
      _snack('تمت إضافة السؤال');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(title: 'أسئلة الاختبار', subtitle: 'اكتب وأدر أسئلتك'),
        body: DeskSurface(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<TeacherExamsCubit, TeacherExamsState>(
                    bloc: _cubit,
                    builder: (context, state) => QuestionsListSection(
                      questions: state.questions
                          .map((q) => {'id': q.id, 'text': q.text,
                              'type': q.questionType.name, 'points': q.points})
                          .toList(),
                      isLoading: state.questionsStatus == TeacherExamsStatus.loading,
                      onDeleteQuestion: (id) async {
                        if (await showDeleteQuestionDialog(context)) {
                          _cubit.deleteQuestion(id);
                        }
                      },
                    ),
                  ),
                  NewQuestionForm(
                    selectedType: _selectedType,
                    onTypeChanged: (t) => setState(() => _selectedType = t),
                    questionController: _questionCtrl,
                    pointsController: _pointsCtrl,
                    correctAnswer: _correctAnswer,
                    optionControllers: _optionCtrls,
                    onCorrectAnswerChanged: (i) => setState(() => _correctAnswer = i),
                    tfAnswer: _tfAnswer,
                    onTfAnswerChanged: (v) => setState(() => _tfAnswer = v),
                    isSaving: _saving,
                    onSave: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
