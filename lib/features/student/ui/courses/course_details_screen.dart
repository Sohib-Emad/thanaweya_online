import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/formatters.dart';
import 'package:thanaweya_online/features/shared/models/lesson_model.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

class CourseDetailsScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailsScreen({super.key, required this.courseId});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> {
  int _selectedTab = 0; // 0 = About, 1 = Curriculum
  bool _isDescriptionExpanded = false;

  late final StudentCoursesCubit _coursesCubit;

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    _coursesCubit.loadCourse(widget.courseId);
    _coursesCubit.loadCourseLessons(widget.courseId);
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
  }

  int _lessonCountOf(dynamic lessons) {
    if (lessons is Map) return (lessons['count'] as int?) ?? 0;
    if (lessons is List && lessons.isNotEmpty) {
      final first = lessons.first;
      if (first is Map) return (first['count'] as int?) ?? 0;
    }
    return 0;
  }

  List<Map<String, dynamic>> _buildCurriculumSections(
    List<LessonModel> lessons,
  ) {
    if (lessons.isEmpty) return const [];
    final totalSeconds = lessons.fold<int>(
      0,
      (sum, l) => sum + (l.durationSeconds ?? 0),
    );
    return [
      {
        'sectionNumber': 'القسم 01',
        'title': 'دروس الكورس',
        'totalDuration': totalSeconds > 0
            ? Formatters.formatDurationMinutes((totalSeconds / 60).ceil())
            : '',
        'lessons': [
          for (var i = 0; i < lessons.length; i++)
            {
              'id': lessons[i].id,
              'videoUrl': lessons[i].videoUrlOrId,
              'number': (i + 1).toString().padLeft(2, '0'),
              'title': lessons[i].title,
              'duration': lessons[i].durationSeconds != null
                  ? Formatters.formatDurationMinutes(
                      (lessons[i].durationSeconds! / 60).ceil(),
                    )
                  : '',
              'isUnlocked': true,
            },
        ],
      },
    ];
  }

  final List<Map<String, dynamic>> _whatYouGetList = [
    {
      'icon': Icons.video_collection_outlined,
      'text': '25 درس فيديو عالي الجودة HD',
    },
    {
      'icon': Icons.devices_rounded,
      'text': 'مشاهدة سلسة على الموبايل والتابلت والكمبيوتر',
    },
    {'icon': Icons.bar_chart_rounded, 'text': 'مناسب للمستوى المبتدئ والمتوسط'},
    {
      'icon': Icons.menu_book_rounded,
      'text': 'ملخصات ومذكرات PDF قابلة للتحميل',
    },
    {
      'icon': Icons.all_inclusive_rounded,
      'text': 'وصول كامل ومدى الحياة للمحتوى',
    },
    {'icon': Icons.quiz_outlined, 'text': 'أكثر من 100 كويز وسؤال تدريبي'},
    {
      'icon': Icons.workspace_premium_outlined,
      'text': 'شهادة تفوق عند إتمام الكورس',
    },
  ];

  final List<Map<String, dynamic>> _reviewsList = [
    {
      'name': 'وليد أحمد',
      'avatar': 'و',
      'bgColor': const Color(0xFF0FA37F),
      'rating': '4.8',
      'comment':
          'شرح ممتاز جداً ومبسط، الأستاذ يقدم المعلومة بطريقة سهلة وتفاعلية!',
      'likes': '250',
      'date': 'منذ أسبوعين',
    },
    {
      'name': 'مريم محمود',
      'avatar': 'م',
      'bgColor': const Color(0xFF2563EB),
      'rating': '4.5',
      'comment':
          'كورس رائع أزال كل مخاوفي من مادة الفيزياء، أنصح كل زملائي به.',
      'likes': '150',
      'date': 'منذ أسبوعين',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      bloc: _coursesCubit,
      builder: (context, state) {
        if (state.courseStatus == StudentCoursesStatus.loading &&
            state.course == null) {
          return const Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return _buildScreen(context, state);
      },
    );
  }

  Widget _buildScreen(BuildContext context, StudentCoursesState state) {
    final course = state.course ?? const <String, dynamic>{};
    final teachers = course['teachers'] as Map<String, dynamic>? ?? const {};
    final users = teachers['users'] as Map<String, dynamic>? ?? const {};
    final subjects = teachers['subjects'] as Map<String, dynamic>? ?? const {};
    final teacherName = users['full_name'] as String? ?? 'مدرس';
    final teacherInitial = teacherName.isNotEmpty ? teacherName[0] : 'م';
    final teacherId = teachers['id'] as String? ?? '';
    final subjectName = subjects['name_ar'] as String? ?? '';
    final lessonCount = _lessonCountOf(course['lessons']);
    final description = course['description'] as String? ?? '';
    final totalSeconds = state.lessons.fold<int>(
      0,
      (sum, l) => sum + (l.durationSeconds ?? 0),
    );
    final totalDurationText = totalSeconds > 0
        ? Formatters.formatDurationMinutes((totalSeconds / 60).ceil())
        : '28 ساعة';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 100.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Media Thumbnail Video Player
                  Stack(
                    children: [
                      Container(
                        height: 230.h,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Dark gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withAlpha(140),
                                    Colors.black.withAlpha(40),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.play_circle_fill_rounded,
                              color: Colors.white.withAlpha(220),
                              size: 56.r,
                            ),
                          ],
                        ),
                      ),
                      // Top Back Button
                      Positioned(
                        top: 44.h,
                        right: 16.w,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 38.r,
                            height: 38.r,
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(100),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18.r,
                            ),
                          ),
                        ),
                      ),
                      // Bottom right video icon badge
                      Positioned(
                        bottom: 14.h,
                        left: 16.w,
                        child: Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0FA37F),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.video_library_rounded,
                            color: Colors.white,
                            size: 20.r,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 2. Course Meta Information Section
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              subjectName,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0FA37F),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: const Color(0xFFFBBF24),
                                  size: 16.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '4.8',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),

                        Text(
                          course['title'] as String? ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        // Stats Row (25 Lessons | 28 Hours | Price)
                        Row(
                          children: [
                            Icon(
                              Icons.video_collection_outlined,
                              size: 16.r,
                              color: const Color(0xFF64748B),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '$lessonCount درس',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Text(
                              '|',
                              style: TextStyle(
                                color: const Color(0xFFCBD5E1),
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Icon(
                              Icons.access_time_rounded,
                              size: 16.r,
                              color: const Color(0xFF64748B),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              totalDurationText,
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '499 ج.م',
                              style: GoogleFonts.cairo(
                                fontSize: 17.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 3. Custom Tab Bar (About / Curriculum)
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedTab = 0);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: _selectedTab == 0
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x0A000000),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  'عن الكورس (About)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: _selectedTab == 0
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: _selectedTab == 0
                                        ? const Color(0xFF0FA37F)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedTab = 1);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10.r),
                                boxShadow: _selectedTab == 1
                                    ? [
                                        const BoxShadow(
                                          color: Color(0x0A000000),
                                          blurRadius: 6,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  'المنهج (Curriculum)',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: _selectedTab == 1
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: _selectedTab == 1
                                        ? const Color(0xFF0FA37F)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // 4. Tab Body Content
                  _selectedTab == 0
                      ? _buildAboutTabContent(
                          description: description,
                          teacherName: teacherName,
                          teacherInitial: teacherInitial,
                          teacherId: teacherId,
                          subjectName: subjectName,
                        )
                      : _buildCurriculumTabContent(state),
                ],
              ),
            ),

            // Sticky Bottom Enroll Bar
            Positioned(
              left: 20.w,
              right: 20.w,
              bottom: 20.h,
              child: SafeArea(
                child: SizedBox(
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      Navigator.pushNamed(
                        context,
                        AppRouter.studentPaymentMethods,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      elevation: 4,
                      shadowColor: const Color(0x330FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Text(
                          'الاشتراك في الكورس - 499 ج.م',
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: const Color(0xFF0FA37F),
                            size: 20.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ABOUT TAB ──
  Widget _buildAboutTabContent({
    required String description,
    required String teacherName,
    required String teacherInitial,
    required String teacherId,
    required String subjectName,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            description.isEmpty
                ? 'هذا الكورس مصمم خصيصاً لطلاب الثانوية العامة لبناء أساس متين وحل جميع أنواع مسائل الفيزياء الكهربية بكل سهولة وبدون تعقيد. يتضمن الكورس مراجعات شاملة، حل أسئلة الامتحانات السابقة، واختبارات تفاعلية.'
                : description,
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
            maxLines: _isDescriptionExpanded ? null : 3,
            overflow: _isDescriptionExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
          GestureDetector(
            onTap: () => setState(
              () => _isDescriptionExpanded = !_isDescriptionExpanded,
            ),
            child: Text(
              _isDescriptionExpanded ? 'عرض أقل' : 'اقرأ المزيد...',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0FA37F),
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Instructor Section
          Text(
            'المحاضر',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.studentTeacherPage,
              arguments: {'teacherId': teacherId, 'title': teacherName},
            ),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: const Color(0xFF0FA37F),
                    child: Text(
                      teacherInitial,
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherName,
                          style: GoogleFonts.cairo(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          subjectName.isEmpty ? 'مدرس' : subjectName,
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFF0FA37F),
                      size: 18.r,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // What You'll Get Section
          Text(
            'ماذا ستتعلم وتأخذ في الكورس؟',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),
          ..._whatYouGetList.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: const Color(0xFF0FA37F),
                    size: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      item['text'] as String,
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Reviews Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'آراء الطلاب',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRouter.studentReviews,
                  arguments: widget.courseId,
                ),
                child: Text(
                  'عرض الكل >',
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0FA37F),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._reviewsList.map(
            (rev) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16.r,
                            backgroundColor: rev['bgColor'] as Color,
                            child: Text(
                              rev['avatar'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            rev['name'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: const Color(0xFFD97706),
                              size: 14.r,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              rev['rating'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    rev['comment'] as String,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                        size: 14.r,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        rev['likes'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        rev['date'] as String,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── CURRICULUM TAB ──
  Widget _buildCurriculumTabContent(StudentCoursesState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildCurriculumSections(state.lessons).map((sec) {
          final sectionNumber = sec['sectionNumber'] as String;
          final title = sec['title'] as String;
          final totalDuration = sec['totalDuration'] as String;
          final lessons = sec['lessons'] as List<Map<String, dynamic>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$sectionNumber : $title',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    totalDuration,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              ...lessons.map((les) {
                final num = les['number'] as String;
                final lesTitle = les['title'] as String;
                final dur = les['duration'] as String;
                final unlocked = les['isUnlocked'] as bool;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pushNamed(
                      context,
                      AppRouter.studentVideoPlayer,
                      arguments: {
                        'lessonId': les['id'],
                        'videoUrl': les['videoUrl'],
                        'title': lesTitle,
                        'courseId': widget.courseId,
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36.r,
                          height: 36.r,
                          decoration: BoxDecoration(
                            color: unlocked
                                ? const Color(0xFFECFDF5)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              num,
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: unlocked
                                    ? const Color(0xFF0FA37F)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesTitle,
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                dur,
                                style: GoogleFonts.cairo(
                                  fontSize: 11.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 32.r,
                          height: 32.r,
                          decoration: BoxDecoration(
                            color: unlocked
                                ? const Color(0xFF0FA37F)
                                : const Color(0xFFCBD5E1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            unlocked
                                ? Icons.play_arrow_rounded
                                : Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 18.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: 16.h),
            ],
          );
        }).toList(),
      ),
    );
  }
}
