// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// QUESTIONS BOARD: this page manages the questions of one exam. Existing
//   questions are chalk frames stamped with their type (اختيارات mint /
//   صح وخطأ blue / مقال yellow) and their points, each with a red chalk
//   delete action. Below them is the "write a new question" chalk form:
//   a type switch, the question text, options, the correct answer and a
//   points field that actually saves the entered value.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/features/shared/models/question_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';

class AddQuestionsScreen extends StatefulWidget {
  final String examId;

  const AddQuestionsScreen({super.key, required this.examId});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  String _selectedType = 'mcq';
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final _pointsController = TextEditingController(text: '1');
  int _correctAnswer = 0;
  String _tfAnswer = 'true';
  bool _isSaving = false;
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
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    _pointsController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ChalkboardColors.accentDeep,
        content: Text(message, style: ChalkboardText.strong(12.sp)),
      ),
    );
  }

  Future<void> _saveQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      _showSnack('برجاء إدخال نص السؤال');
      return;
    }
    final points = int.tryParse(_pointsController.text.trim());
    if (points == null || points <= 0) {
      _showSnack('برجاء إدخال درجات السؤال بصورة صحيحة');
      return;
    }
    if (_selectedType == 'mcq') {
      for (final c in _optionControllers) {
        if (c.text.trim().isEmpty) {
          _showSnack('برجاء إدخال جميع الخيارات');
          return;
        }
      }
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    String? correctAnswer;
    List<String> options;

    if (_selectedType == 'mcq') {
      const letters = ['أ', 'ب', 'ج', 'د'];
      options = _optionControllers.map((c) => c.text.trim()).toList();
      correctAnswer = letters[_correctAnswer];
    } else if (_selectedType == 'tf') {
      options = const ['صحيح', 'خطأ'];
      correctAnswer = _tfAnswer == 'true' ? 'صحيح' : 'خطأ';
    } else {
      options = [];
    }

    await _cubit.addQuestion(
      examId: widget.examId,
      questionType: _selectedType == 'tf' ? 'true_false' : _selectedType,
      text: _questionController.text.trim(),
      options: options,
      correctAnswer: correctAnswer,
      points: points,
    );

    if (mounted) {
      setState(() {
        _isSaving = false;
        _questionController.clear();
        _pointsController.text = '1';
        for (final c in _optionControllers) {
          c.clear();
        }
        _correctAnswer = 0;
      });
      _showSnack('تمت إضافة السؤال على السبورة');
    }
  }

  String _typeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.mcq:
        return 'اختيار من متعدد';
      case QuestionType.trueFalse:
        return 'صح أو خطأ';
      case QuestionType.essay:
        return 'سؤال مقالي';
    }
  }

  Color _typeColor(QuestionType type) {
    switch (type) {
      case QuestionType.mcq:
        return ChalkboardColors.accent;
      case QuestionType.trueFalse:
        return ChalkboardColors.chalkBlue;
      case QuestionType.essay:
        return ChalkboardColors.chalkYellow;
    }
  }

  Future<void> _confirmDeleteQuestion(QuestionModel question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: ChalkboardColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(color: ChalkboardColors.ink.withAlpha(60)),
            ),
            title: Text('حذف السؤال؟', style: ChalkboardText.heading(16.sp)),
            content: Text(
              'سيتم حذف هذا السؤال من الاختبار.',
              style: ChalkboardText.body(12.sp),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'إلغاء',
                  style: ChalkboardText.strong(12.sp,
                      color: ChalkboardColors.chalkSoft),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  'حذف',
                  style: ChalkboardText.strong(12.sp,
                      color: ChalkboardColors.chalkRed),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed == true) {
      _cubit.deleteQuestion(question.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        appBar: ChalkTopBar(
          title: 'أسئلة الاختبار',
          subtitle: 'اكتب وأدر أسئلتك على السبورة',
        ),
        body: ChalkboardSurface(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<TeacherExamsCubit, TeacherExamsState>(
                    bloc: _cubit,
                    builder: (context, state) {
                      if (state.questionsStatus ==
                          TeacherExamsStatus.loading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(
                              color: ChalkboardColors.accent,
                            ),
                          ),
                        );
                      }
                      if (state.questions.isEmpty) {
                        return ChalkEmptyNote(
                          message: 'لا توجد أسئلة بعد',
                          subMessage: 'اكتب أول سؤال من النموذج بالأسفل',
                          icon: Icons.help_outline_rounded,
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الأسئلة المكتوبة (${state.questions.length})',
                            style: ChalkboardText.heading(15.sp),
                          ),
                          SizedBox(height: 12.h),
                          for (final q in state.questions) ...[
                            ChalkCard(
                              padding: EdgeInsets.all(12.r),
                              accent: _typeColor(q.questionType),
                              accentLabel: '${_typeLabel(q.questionType)} · ${q.points} نقطة',
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q.text,
                                    style: ChalkboardText.body(13.sp),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.stars_outlined,
                                        size: 14.r,
                                        color: ChalkboardColors.chalkSoft,
                                      ),
                                      SizedBox(width: 5.w),
                                      Text(
                                        '${q.points} نقطة',
                                        style: ChalkboardText.note(11.sp),
                                      ),
                                      const Spacer(),
                                      _IconAction(
                                        icon: Icons.delete_outline_rounded,
                                        color: ChalkboardColors.chalkRed,
                                        tooltip: 'حذف السؤال',
                                        onTap: () =>
                                            _confirmDeleteQuestion(q),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 12.h),
                          ],
                          SizedBox(height: 8.h),
                          Container(
                            height: 1,
                            color: ChalkboardColors.ink.withAlpha(40),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      );
                    },
                  ),

                  Text(
                    'كتابة سؤال جديد',
                    style: ChalkboardText.heading(15.sp),
                  ),
                  SizedBox(height: 16.h),

                  ChalkSegmentedControl(
                    options: const ['اختيارات', 'صح أو خطأ', 'مقالي'],
                    index: _selectedType == 'mcq'
                        ? 0
                        : (_selectedType == 'tf' ? 1 : 2),
                    onChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedType = i == 0
                          ? 'mcq'
                          : (i == 1 ? 'tf' : 'essay'));
                    },
                  ),

                  SizedBox(height: 20.h),

                  ChalkInputField(
                    label: 'نص السؤال',
                    controller: _questionController,
                    icon: Icons.help_outline_rounded,
                    hint: 'اكتب نص السؤال بوضوح هنا...',
                    maxLines: 3,
                  ),

                  if (_selectedType == 'mcq') ...[
                    SizedBox(height: 20.h),
                    Text(
                      'خيارات الإجابة (حدد الإجابة الصحيحة)',
                      style: ChalkboardText.strong(13.sp),
                    ),
                    SizedBox(height: 12.h),
                    ...List.generate(4, (index) {
                      const letters = ['أ', 'ب', 'ج', 'د'];
                      final isCorrect = _correctAnswer == index;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _correctAnswer = index);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? ChalkboardColors.accent
                                      : ChalkboardColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isCorrect
                                        ? ChalkboardColors.accent
                                        : ChalkboardColors.ink.withAlpha(60),
                                    width: isCorrect ? 1.6 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    letters[index],
                                    style: ChalkboardText.strong(13.sp,
                                        color: isCorrect
                                            ? ChalkboardColors.onAccent
                                            : ChalkboardColors.chalkSoft),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _ChalkMiniField(
                                controller: _optionControllers[index],
                                hint: 'الخيار (${letters[index]})',
                                isCorrect: isCorrect,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  if (_selectedType == 'tf') ...[
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: _AnswerTile(
                            label: 'صحيح',
                            selected: _tfAnswer == 'true',
                            accent: ChalkboardColors.accent,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _tfAnswer = 'true');
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _AnswerTile(
                            label: 'خطأ',
                            selected: _tfAnswer == 'false',
                            accent: ChalkboardColors.chalkRed,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _tfAnswer = 'false');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(height: 20.h),

                  ChalkInputField(
                    label: 'درجة السؤال (النقاط)',
                    controller: _pointsController,
                    icon: Icons.stars_outlined,
                    hint: '1',
                    keyboardType: TextInputType.number,
                  ),

                  SizedBox(height: 24.h),

                  ChalkPrimaryButton(
                    label: 'إضافة السؤال',
                    icon: Icons.add_rounded,
                    loading: _isSaving,
                    onPressed: _isSaving ? null : _saveQuestion,
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

class _ChalkMiniField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isCorrect;

  const _ChalkMiniField({
    required this.controller,
    required this.hint,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: ChalkboardColors.surface.withAlpha(180),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isCorrect
              ? ChalkboardColors.accent.withAlpha(150)
              : ChalkboardColors.ink.withAlpha(50),
          width: isCorrect ? 1.5 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: ChalkboardText.body(13.sp),
        cursorColor: ChalkboardColors.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ChalkboardText.note(11.sp)
              .copyWith(color: ChalkboardColors.chalkFaint),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _AnswerTile({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: selected
              ? accent.withAlpha(30)
              : ChalkboardColors.surface.withAlpha(160),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? accent : ChalkboardColors.ink.withAlpha(50),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: ChalkboardText.strong(15.sp,
                color: selected ? accent : ChalkboardColors.chalkSoft),
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: color.withAlpha(22),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: color.withAlpha(110), width: 1.1),
          ),
          child: Icon(icon, size: 17.r, color: color),
        ),
      ),
    );
  }
}
