import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String lessonId;
  final String videoUrl;
  final String title;
  final String courseId;

  const VideoPlayerScreen({
    super.key,
    required this.lessonId,
    required this.videoUrl,
    required this.title,
    required this.courseId,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  int _selectedTab = 0; // 0 = Lessons, 1 = Assignments & PDFs, 2 = Achievements
  bool _isPlaying = false;
  late String _activeLessonTitle;

  late final StudentCoursesCubit _coursesCubit;

  final Map<String, bool> _expandedSections = {};

  final List<Map<String, String>> _pdfAttachments = const [
    {
      'title': 'مذكرة الشرح والملخص الأساسي (PDF)',
      'subtitle': 'مادة الفيزياء والرياضيات • 4.2 MB',
      'fileName': 'Physics_Summary_Ch1.pdf',
    },
    {
      'title': 'أسئلة وإجابات النموذج التجريبي الشامل (PDF)',
      'subtitle': 'ملف التمارين والتطبيقات • 2.8 MB',
      'fileName': 'Exam_Questions_Model.pdf',
    },
    {
      'title': 'جدول القوانين والمخططات الذهنية (PDF)',
      'subtitle': 'خرائط ذهنية مخصصة • 1.5 MB',
      'fileName': 'Mindmaps_Cheatsheet.pdf',
    },
  ];

  @override
  void initState() {
    super.initState();
    _activeLessonTitle = widget.title;
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    if (widget.courseId.isNotEmpty) {
      _coursesCubit.loadCourseLessons(widget.courseId);
    }
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _coursesCubit.loadProgress(userId);
    }
  }

  @override
  void dispose() {
    _coursesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Column(
              children: [
                // Top Video Player Container
                Container(
                  width: double.infinity,
                  height: 230.h,
                  color: Colors.black,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          'https://images.unsplash.com/photo-1577896851231-70ef18881754?q=80&w=800&auto=format&fit=crop',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF0F172A)),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(color: Colors.black.withAlpha(90)),
                      ),

                      // Top Navigation Row (Back & Share)
                      Positioned(
                        top: 40.h,
                        left: 16.w,
                        right: 16.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back_rounded,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: Text(
                                  _activeLessonTitle,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'تم نسخ رابط الدرس للمشاركة 🚀',
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: const Color(0xFF0FA37F),
                                  ),
                                );
                              },
                              child: Container(
                                width: 36.r,
                                height: 36.r,
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(100),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.share_rounded,
                                  color: Colors.white,
                                  size: 18.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Play/Pause Center Button
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _isPlaying = !_isPlaying);
                          },
                          child: Container(
                            width: 56.r,
                            height: 56.r,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(220),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: const Color(0xFF0F172A),
                              size: 36.r,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pill Tabs Header Bar (Lessons, Assignments, Achievements)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildPillTab(index: 0, label: 'Lessons (الدروس)'),
                      SizedBox(width: 8.w),
                      _buildPillTab(
                        index: 1,
                        label: 'Assignments & PDFs',
                        hasNotificationDot: true,
                      ),
                      SizedBox(width: 8.w),
                      _buildPillTab(index: 2, label: 'Achievements'),
                    ],
                  ),
                ),

                // Main Tab Body Content
                Expanded(
                  child: _selectedTab == 0
                      ? _buildLessonsTab()
                      : _selectedTab == 1
                      ? _buildAssignmentsAndPDFsTab()
                      : _buildAchievementsTab(),
                ),
              ],
            ),

            // Floating Bottom Button: "💬 Chat with Instructor" (Matching Screenshot)
            Positioned(
              left: 30.w,
              right: 30.w,
              bottom: 20.h,
              child: SafeArea(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showWhatsAppChatDialog(context);
                    },
                    child: Container(
                      height: 48.h,
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x180F172A),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 28.r,
                            height: 28.r,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_rounded,
                              color: Colors.white,
                              size: 14.r,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Chat with Instructor (التواصل مع المحاضر)',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
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

  // Pill Tab Item Widget
  Widget _buildPillTab({
    required int index,
    required String label,
    bool hasNotificationDot = false,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 38.h,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (hasNotificationDot && !isSelected)
                Positioned(
                  top: 6.h,
                  right: 8.w,
                  child: Container(
                    width: 7.r,
                    height: 7.r,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 1: Lessons Accordion View (Matching Screenshot 100%)
  Widget _buildLessonsTab() {
    return BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
      bloc: _coursesCubit,
      builder: (context, state) {
        final lessons = state.lessons;
        if (state.lessonsStatus == StudentCoursesStatus.loading &&
            lessons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final completedIds = {
          for (final p in state.progress)
            if (p.isCompleted) p.lessonId,
        };
        final sectionTitle = 'دروس الكورس';
        final sectionsData = [
          {
            'title': sectionTitle,
            'lessons': [
              for (var i = 0; i < lessons.length; i++)
                {
                  'id': lessons[i].id,
                  'title': lessons[i].title,
                  'duration': lessons[i].durationSeconds != null
                      ? Formatters.formatDurationMinutes(
                          (lessons[i].durationSeconds! / 60).ceil())
                      : '',
                  'status': lessons[i].id == widget.lessonId
                      ? 'active'
                      : completedIds.contains(lessons[i].id)
                          ? 'completed'
                          : 'locked',
                },
            ],
          },
        ];

        return ListView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 85.h),
          physics: const BouncingScrollPhysics(),
          children: [
            // Subtitle Total Count
            Text(
              '${lessons.length} دروس',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 12.h),

            ...sectionsData.map((sec) {
              final title = sec['title'] as String;
              final lessons = sec['lessons'] as List<Map<String, dynamic>>;
              final isExpanded = _expandedSections[title] ?? true;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header Accordion Row
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedSections[title] = !isExpanded;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF64748B),
                        size: 20.r,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 6.h),

              if (isExpanded)
                ...lessons.map((les) {
                  final lesTitle = les['title'] as String;
                  final dur = les['duration'] as String;
                  final status = les['status'] as String;

                  final isCompleted = status == 'completed';
                  final isActive = status == 'active';
                  final isLocked = status == 'locked';

                  return GestureDetector(
                    onTap: () {
                      if (isLocked) {
                        HapticFeedback.vibrate();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'هذا الدرس مغلق، يرجى إكمال الدروس السابقة أولاً 🔒',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: const Color(0xFFEA580C),
                          ),
                        );
                      } else {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _activeLessonTitle = lesTitle;
                          _isPlaying = true;
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 4.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFFEFF6FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Icon Status (Green Check, Blue Play, Gray Lock)
                              if (isCompleted)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: const Color(0xFF10B981),
                                  size: 20.r,
                                )
                              else if (isActive)
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: const Color(0xFF2563EB),
                                  size: 22.r,
                                )
                              else
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: const Color(0xFF94A3B8),
                                  size: 20.r,
                                ),
                              SizedBox(width: 12.w),
                              Text(
                                lesTitle,
                                style: GoogleFonts.cairo(
                                  fontSize: 12.sp,
                                  fontWeight: isActive
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                  color: isActive
                                      ? const Color(0xFF2563EB)
                                      : isLocked
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            dur,
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

              SizedBox(height: 10.h),
            ],
          );
        }),
        ],
      );
      },
    );
  }

  // TAB 2: Assignments & PDF Downloads View (Requested by User)
  Widget _buildAssignmentsAndPDFsTab() {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 85.h),
      physics: const BouncingScrollPhysics(),
      children: [
        // Section Header: PDF Downloads
        Row(
          children: [
            Icon(
              Icons.picture_as_pdf_rounded,
              color: const Color(0xFFEF4444),
              size: 22.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'ملفات الـ PDF والملازم المتاحة للتحميل:',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        ..._pdfAttachments.map((pdf) {
          final title = pdf['title']!;
          final subtitle = pdf['subtitle']!;
          final fileName = pdf['fileName']!;

          return Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x060F172A),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Red PDF Icon Badge
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: const Color(0xFFEF4444),
                    size: 24.r,
                  ),
                ),

                SizedBox(width: 12.w),

                // PDF Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // Download Button Action
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'جاري تحميل $fileName بنجاح 📥',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: const Color(0xFF0FA37F),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Icon(
                      Icons.file_download_outlined,
                      color: const Color(0xFF2563EB),
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),

        SizedBox(height: 16.h),

        // Section Header: Homework & Assignments
        Row(
          children: [
            Icon(
              Icons.assignment_turned_in_rounded,
              color: const Color(0xFF2563EB),
              size: 22.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'الواجبات والتكليفات (Assignments):',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Assignment Item Card
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تطبيق واجب المحاضرة الأولى: حل المسائل الكهربية',
                style: GoogleFonts.cairo(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'تاريخ التسليم الأخير: غداً الساعة 11:59 مساءً',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  color: const Color(0xFFEA580C),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'فتح نموذج إرسال الواجب 📝',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                        ),
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.upload_file_rounded,
                    color: Colors.white,
                    size: 18.r,
                  ),
                  label: Text(
                    'رفع حل الواجب (Submit Assignment)',
                    style: GoogleFonts.cairo(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // TAB 3: Achievements & Certificate View
  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 85.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: const Color(0xFFF59E0B),
                  size: 56.r,
                ),
                SizedBox(height: 12.h),
                Text(
                  'شهادة إتمام الكورس والتقديرات 🎓',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'لقد أتممت 80% من محتوى الكورس المخصص بنجاح. يمكنك استعراض الشهادة المعتمدة فور الإتمام.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pushNamed(
                        context,
                        AppRouter.studentCertificate,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0FA37F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    child: Text(
                      'استعراض وتحميل الشهادة (Certificate)',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
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
    );
  }

  // Dialog to Chat with Instructor (WhatsApp Chat Dialog)
  void _showWhatsAppChatDialog(BuildContext context) {
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
              Icon(
                Icons.chat_bubble_rounded,
                color: const Color(0xFF25D366),
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'التواصل مع المحاضر',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          content: Text(
            'هل ترغب في فتح محادثة مباشرة عبر الواتساب مع أ. محمد علي للاستفسار عن الدرس والتكليفات؟',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              color: const Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'جاري فتح المحادثة على الواتساب 💬',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    backgroundColor: const Color(0xFF25D366),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'محادثة الآن',
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
