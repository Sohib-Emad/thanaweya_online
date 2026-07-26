import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/router/app_router.dart';

class ExamTakingScreen extends StatefulWidget {
  const ExamTakingScreen({super.key});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _secondsRemaining = 45 * 60; // 45 minutes countdown
  Timer? _timer;
  final Map<int, String> _answers = {};

  final List<Map<String, dynamic>> _questions = const [
    {
      'id': 1,
      'text':
          'أي من العوامل التالية يؤدي إلى زيادة شدة التيار الكهربائي المار في موصل كهربائي مع ثبوت درجة الحرارة؟',
      'options': [
        'زيادة فرق الجهد بين طرفي الموصل',
        'زيادة طول الموصل مع ثبوت المساحة',
        'زيادة المقاومة النوعية لمادة الموصل',
        'نقصان مساحة مقطع الموصل',
      ],
      'correctIndex': 0,
    },
    {
      'id': 2,
      'text':
          'في دائرة كيرشوف الثانية، ما هو مجموع القوى الدافعة الكهربائية في أي مسار مغلق؟',
      'options': [
        'يساوي صفر دائماً',
        'يساوي مجموع فروق الجهد في نفس المسار المغلق',
        'يساوي المقاومة المكافئة للدائرة',
        'يساوي شدة التيار الكلي',
      ],
      'correctIndex': 1,
    },
    {
      'id': 3,
      'text':
          'ما هي وحدة قياس المقاومة النوعية للموصل في النظام الدولي للوحدات (SI)؟',
      'options': [
        'أوم (Ω)',
        'أوم • متر (Ω.m)',
        'أوم / متر (Ω/m)',
        'فولت / أمبير (V/A)',
      ],
      'correctIndex': 1,
    },
    {
      'id': 4,
      'text':
          'عند توصيل 3 مقاومات متساوية على التوازي تكون المقاومة المكافئة لهم 4 أوم، فكم تكون مقاومتهم المكافئة عند توصيلهم على التوالي؟',
      'options': [
        '12 أوم',
        '36 أوم',
        '24 أوم',
        '16 أوم',
      ],
      'correctIndex': 1,
    },
    {
      'id': 5,
      'text':
          'ما العلاقة بين قدرة الموصل الكهربائي والمقاومة عند ثبوت فرق الجهد الكهربائي؟',
      'options': [
        'علاقة طردية خطية',
        'علاقة عكسية',
        'علاقة تربيعية طردية',
        'لا تتأثر بالمقاومة',
      ],
      'correctIndex': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // App Lifecycle Observer: Auto-submit on app background / exit attempt (User Requirement)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      // Auto submit exam because student exited the screen/app!
      _autoSubmitDueToExit();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
        _submitExam(isTimeOut: true);
      }
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minStr = minutes.toString().padLeft(2, '0');
    final secStr = seconds.toString().padLeft(2, '0');
    return '$minStr:$secStr';
  }

  void _autoSubmitDueToExit() {
    _timer?.cancel();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        AppRouter.studentExamResult,
        arguments: {
          'score': _calculateScore(),
          'total': _questions.length,
          'autoSubmitted': true,
        },
      );
    }
  }

  int _calculateScore() {
    int score = 0;
    _answers.forEach((qIndex, selectedOption) {
      final correctOption =
          _questions[qIndex]['options'][_questions[qIndex]['correctIndex']];
      if (selectedOption == correctOption) {
        score++;
      }
    });
    return score;
  }

  void _submitExam({bool isTimeOut = false}) {
    _timer?.cancel();
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(
      context,
      AppRouter.studentExamResult,
      arguments: {
        'score': _calculateScore(),
        'total': _questions.length,
        'isTimeOut': isTimeOut,
        'autoSubmitted': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final options = (question['options'] as List).cast<String>();
    final totalQuestions = _questions.length;
    final letters = ['أ', 'ب', 'ج', 'د'];

    return PopScope(
      canPop: false, // Prevent back swipe / button without warning
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitWarningDialog();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: Column(
              children: [
                // Top Strict Anti-Cheat Header Banner
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  color: const Color(0xFFE11D48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 16.r,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '🚨 مراقبة أمنية: يمنع خروجك أو تصغير الشاشة لعدم التسليم التلقائي!',
                        style: GoogleFonts.cairo(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer & Question Counter Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.timer_rounded,
                            color: _secondsRemaining < 300
                                ? const Color(0xFFE11D48)
                                : const Color(0xFF2563EB),
                            size: 20.r,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            _formatTimer(_secondsRemaining),
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w900,
                              color: _secondsRemaining < 300
                                  ? const Color(0xFFE11D48)
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'سؤال ${_currentIndex + 1} من $totalQuestions',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),

                // Linear Progress Bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / totalQuestions,
                      minHeight: 6.h,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // Question Numbers Navigator Grid Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: List.generate(totalQuestions, (index) {
                      final isAnswered = _answers.containsKey(index);
                      final isCurrent = index == _currentIndex;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _currentIndex = index);
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 8.w),
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? const Color(0xFF2563EB)
                                : isAnswered
                                    ? const Color(0xFFECFDF5)
                                    : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFF2563EB)
                                  : isAnswered
                                      ? const Color(0xFF0FA37F)
                                      : const Color(0xFFCBD5E1),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? Colors.white
                                    : isAnswered
                                        ? const Color(0xFF0FA37F)
                                        : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                SizedBox(height: 16.h),

                // Question Body & Options
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Card Container
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x060F172A),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            question['text'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              height: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(height: 16.h),

                        // Options Cards
                        ...List.generate(options.length, (optIndex) {
                          final optionText = options[optIndex];
                          final isSelected =
                              _answers[_currentIndex] == optionText;

                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _answers[_currentIndex] = optionText;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEFF6FF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFE2E8F0),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32.r,
                                    height: 32.r,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFFF1F5F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        letters[optIndex],
                                        style: GoogleFonts.cairo(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w800,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: Text(
                                      optionText,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Bottom Action Buttons (Next, Previous, Submit)
                Container(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (_currentIndex > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _currentIndex--);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                            ),
                            child: Text(
                              'السابق',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(
                        child: _currentIndex < totalQuestions - 1
                            ? ElevatedButton(
                                onPressed: () {
                                  setState(() => _currentIndex++);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                child: Text(
                                  'السؤال التالي',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: () => _submitExam(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0FA37F),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                ),
                                child: Text(
                                  'تسليم الامتحان 🏁',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
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
      ),
    );
  }

  void _showExitWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(Icons.report_problem_rounded, color: const Color(0xFFE11D48), size: 26.r),
              SizedBox(width: 8.w),
              Text(
                'حظر الخروج من الامتحان',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: Text(
            'مغادرة شاشة الامتحان الآن ستؤدي إلى التسليم الفوري لكافة إجاباتك الحالية واحتساب الدرجة النهائية. هل ترغب بالتسليم والخروج؟',
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء ومتابعة الحل',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF2563EB),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _submitExam(); // Submit exam
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'تسليم الآن',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
