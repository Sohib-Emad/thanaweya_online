import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/services/teacher_realtime_service.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_exams_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_exams_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/widgets/widgets.dart';

/// Screen for managing and adding questions to an exam with the 3-step wizard layout.
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
  final _pointsCtrl = TextEditingController(text: '5');
  int _correctAnswer = 0;
  String _tfAnswer = 'true';
  File? _pickedImage;
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
    for (final c in _optionCtrls) {
      c.dispose();
    }
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    try {
      final f = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (f != null && mounted) {
        setState(() => _pickedImage = File(f.path));
      }
    } catch (e) {
      debugPrint('Error picking question image: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: DeskColors.primaryDeep,
        content: Text(msg, style: DeskText.strong(12.sp)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _save() async {
    final text = _questionCtrl.text.trim();
    if (text.isEmpty) {
      _snack('برجاء إدخال نص السؤال');
      return;
    }
    final pts = int.tryParse(_pointsCtrl.text.trim());
    if (pts == null || pts <= 0) {
      _snack('برجاء إدخال درجات السؤال بصورة صحيحة');
      return;
    }
    if (_selectedType == 'mcq') {
      for (final c in _optionCtrls) {
        if (c.text.trim().isEmpty) {
          _snack('برجاء إدخال جميع الخيارات');
          return;
        }
      }
    }
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    const letters = ['أ', 'ب', 'ج', 'د'];
    String? ca;
    List<String> opts;
    if (_selectedType == 'mcq') {
      opts = _optionCtrls.map((c) => c.text.trim()).toList();
      ca = letters[_correctAnswer];
    } else if (_selectedType == 'tf') {
      opts = const ['صحيح', 'خطأ'];
      ca = _tfAnswer == 'true' ? 'صحيح' : 'خطأ';
    } else {
      opts = [];
    }

    String? uploadedImageUrl;
    if (_pickedImage != null) {
      final uid = Supabase.instance.client.auth.currentUser?.id ?? '';
      uploadedImageUrl = await TeacherExamsRepo().questions.uploadQuestionImage(
        teacherId: uid,
        examId: widget.examId,
        imageFile: _pickedImage!,
      );
    }

    await _cubit.addQuestion(
      examId: widget.examId,
      questionType: _selectedType == 'tf' ? 'true_false' : _selectedType,
      text: text,
      options: opts,
      correctAnswer: ca,
      points: pts,
      imageUrl: uploadedImageUrl,
    );

    if (mounted) {
      setState(() {
        _saving = false;
        _pickedImage = null;
        _questionCtrl.clear();
        _pointsCtrl.text = '5';
        for (final c in _optionCtrls) {
          c.clear();
        }
        _correctAnswer = 0;
      });
      _cubit.loadQuestions(widget.examId);
      TeacherRealtimeService.instance.notifyExamsChanged();
      _snack('تمت إضافة السؤال بنجاح 🎉');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DeskColors.ground,
        appBar: DeskTopBar(
          title: 'إنشاء امتحان جديد',
          subtitle: 'معالج الـ 3 خطوات (خطوة 2 من 3)',
          automaticallyImplyBack: true,
        ),
        body: DeskSurface(
          child: Column(
            children: [
              const StepProgressBar(currentStep: 1),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الخطوة 2: أسئلة الاختبار',
                        style: DeskText.heading(15.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'أضف أسئلة الامتحان وحدد الإجابات الصحيحة والدرجات',
                        style: DeskText.note(12.sp),
                      ),
                      SizedBox(height: 16.h),

                      // Existing Questions List Section
                      BlocBuilder<TeacherExamsCubit, TeacherExamsState>(
                        bloc: _cubit,
                        builder: (context, state) => QuestionsListSection(
                          questions: state.questions
                              .map((q) => {
                                    'id': q.id,
                                    'text': q.text,
                                    'type': q.questionType.name,
                                    'points': q.points,
                                  })
                              .toList(),
                          isLoading: state.questionsStatus ==
                              TeacherExamsStatus.loading,
                          onDeleteQuestion: (id) async {
                            if (await showDeleteQuestionDialog(context)) {
                              _cubit.deleteQuestion(id);
                            }
                          },
                        ),
                      ),

                      // New Question Input Form
                      NewQuestionForm(
                        selectedType: _selectedType,
                        onTypeChanged: (t) => setState(() => _selectedType = t),
                        questionController: _questionCtrl,
                        pointsController: _pointsCtrl,
                        correctAnswer: _correctAnswer,
                        optionControllers: _optionCtrls,
                        onCorrectAnswerChanged: (i) =>
                            setState(() => _correctAnswer = i),
                        tfAnswer: _tfAnswer,
                        onTfAnswerChanged: (v) => setState(() => _tfAnswer = v),
                        pickedImage: _pickedImage,
                        onPickImage: _pickImage,
                        onClearImage: () => setState(() => _pickedImage = null),
                        isSaving: _saving,
                        onSave: _save,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46.h,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'السابق',
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'التالي (المعاينة والنشر)',
                            style: GoogleFonts.cairo(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
