import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
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
  int _correctAnswer = 0;
  String _tfAnswer = 'true';
  bool _isSaving = false;
  late final TeacherExamsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TeacherExamsCubit(repo: TeacherExamsRepo());
  }

  @override
  void dispose() {
    _cubit.close();
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF0F172A),
              size: 28.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            AppStrings.addQuestion,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Selector Chips
                Row(
                  children: [
                    _TypeChip(
                      label: AppStrings.multipleChoice,
                      isSelected: _selectedType == 'mcq',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedType = 'mcq');
                      },
                    ),
                    SizedBox(width: 8.w),
                    _TypeChip(
                      label: AppStrings.trueFalse,
                      isSelected: _selectedType == 'tf',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedType = 'tf');
                      },
                    ),
                    SizedBox(width: 8.w),
                    _TypeChip(
                      label: AppStrings.essay,
                      isSelected: _selectedType == 'essay',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedType = 'essay');
                      },
                    ),
                  ],
                ),

                SizedBox(height: 24.h),

                Text(
                  'نص السؤال*',
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 6.h),
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب نص السؤال بوضوح هنا...',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      color: const Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18.w,
                      vertical: 14.h,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(
                        color: AppColors.teacherPrimary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                if (_selectedType == 'mcq') ...[
                  SizedBox(height: 24.h),
                  Text(
                    'خيارات الإجابة (حدد الإجابة الصحيحة)',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...List.generate(4, (index) {
                    final letters = ['أ', 'ب', 'ج', 'د'];
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
                              width: 40.r,
                              height: 40.r,
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? AppColors.teacherPrimary
                                    : const Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  letters[index],
                                  style: GoogleFonts.cairo(
                                    color: isCorrect
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextFormField(
                              controller: _optionControllers[index],
                              style: GoogleFonts.cairo(
                                fontSize: 14.sp,
                                color: const Color(0xFF0F172A),
                              ),
                              decoration: InputDecoration(
                                hintText: 'الخيار (${letters[index]})',
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: BorderSide(
                                    color: isCorrect
                                        ? AppColors.teacherPrimary
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.teacherPrimary,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                if (_selectedType == 'tf') ...[
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _tfAnswer = 'true');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            decoration: BoxDecoration(
                              color: _tfAnswer == 'true'
                                  ? const Color(0xFFECFDF5)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: _tfAnswer == 'true'
                                    ? const Color(0xFF0FA37F)
                                    : const Color(0xFFE2E8F0),
                                width: _tfAnswer == 'true' ? 1.5 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'صحيح ✓',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _tfAnswer == 'true'
                                      ? const Color(0xFF0FA37F)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _tfAnswer = 'false');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            decoration: BoxDecoration(
                              color: _tfAnswer == 'false'
                                  ? const Color(0xFFFEF2F2)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: _tfAnswer == 'false'
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFFE2E8F0),
                                width: _tfAnswer == 'false' ? 1.5 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'خطأ ✗',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: _tfAnswer == 'false'
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: 36.h),

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            if (_questionController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('برجاء إدخال نص السؤال'),
                                ),
                              );
                              return;
                            }

                            if (_selectedType == 'mcq') {
                              for (final c in _optionControllers) {
                                if (c.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'برجاء إدخال جميع الخيارات'),
                                    ),
                                  );
                                  return;
                                }
                              }
                            }

                            HapticFeedback.mediumImpact();
                            setState(() => _isSaving = true);

                            String? correctAnswer;
                            List<String> options;

                            if (_selectedType == 'mcq') {
                              final letters = ['أ', 'ب', 'ج', 'د'];
                              options = _optionControllers
                                  .map((c) => c.text.trim())
                                  .toList();
                              correctAnswer = letters[_correctAnswer];
                            } else if (_selectedType == 'tf') {
                              options = ['صحيح', 'خطأ'];
                              correctAnswer = _tfAnswer == 'true'
                                  ? 'صحيح'
                                  : 'خطأ';
                            } else {
                              options = [];
                            }

                            await _cubit.addQuestion(
                              examId: widget.examId,
                              questionType: _selectedType == 'tf'
                                  ? 'true_false'
                                  : _selectedType,
                              text: _questionController.text.trim(),
                              options: options,
                              correctAnswer: correctAnswer,
                              points: 1,
                            );

                            if (mounted) {
                              setState(() => _isSaving = false);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم إضافة السؤال بنجاح'),
                                  backgroundColor: Color(0xFF10B981),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teacherPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 24.r,
                            height: 24.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            AppStrings.save,
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.teacherPrimary : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.teacherPrimary
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }
}
