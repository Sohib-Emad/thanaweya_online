// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — طالب · الدفتر (ruled school notebook)
// THESIS: The home tab is the student's own ruled exercise book — cream
//   ruled-paper ground, a red margin down the page, headings written like
//   notebook titles. It refuses the marketplace-hero rut: no gradient promo
//   slabs or stock course grid.
// OWN-WORLD: cream paper + faint blue ruling + classic red margin; deep pen
//   ink text, pencil-gray secondary, mint green as highlighter ink, yellow
//   for important notes; a red خصم stamp for offers; margin tabs carry
//   subjects.
// STORY: A student opens their دفتر, reads the greeting line, taps a subject
//   margin tab, and sees only their courses; each course is a ruled summary
//   page with the teacher's signature and a marker underline.
// FIRST VIEWPORT: masthead (ثانوية أونلاين · دفتر الطالب) over the greeting,
//   a ruled-line search, the yellow "عرض اليوم" note with its red stamp,
//   subject margin tabs, then the courses page and teacher signatures.
// FORM: Grounded direction #6 (الدفتر), dealt by concept-seed key a98532b3.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_courses_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';
import 'package:thanaweya_online/features/student/ui/courses/course_filter_screen.dart';
import 'package:thanaweya_online/features/student/ui/exams/exams_list_screen.dart';
import 'package:thanaweya_online/features/student/ui/courses/student_my_courses_list_screen.dart';
import 'package:thanaweya_online/features/student/ui/transactions/student_transactions_screen.dart';
import 'package:thanaweya_online/features/student/ui/profile/student_profile_tab.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late final StudentCoursesCubit _coursesCubit;
  String _firstName = 'طالب';
  String _homeSubjectFilter = 'الكل';
  CourseFilters? _homeFilters;

  static const List<Color> _palette = [
    Color(0xFF0FA37F),
    Color(0xFF2563EB),
    Color(0xFFEF4444),
    Color(0xFFD97706),
    Color(0xFF9333EA),
    Color(0xFF0284C7),
  ];

  Color _colorFor(String key) =>
      _palette[key.hashCode.abs() % _palette.length];

  List<Map<String, dynamic>> get _studentEnrolledCourses =>
      _coursesCubit.state.popularCourses
          .where((c) {
            if (_homeSubjectFilter != 'الكل' &&
                c['subject_name'] != _homeSubjectFilter) {
              return false;
            }
            if (_homeFilters != null && !_homeFilters!.matches(c)) {
              return false;
            }
            return true;
          })
          .map((c) {
            return {
              'id': c['id'],
              'title': c['title'],
              'teacher': c['teacher_name'],
              'subject': c['subject_name'],
              'cover': c['cover_image_url'],
              'stage': c['stage'],
              'color': _colorFor(c['id'] as String),
            };
          })
          .toList();

  List<Map<String, dynamic>> get _popularTeachersList =>
      _coursesCubit.state.approvedTeachers.map((t) {
        final users = t['users'] as Map<String, dynamic>?;
        final name =
            users?['full_name'] as String? ?? '';
        final subject =
            (t['subjects'] as Map<String, dynamic>?)?['name_ar'] as String? ??
                '';
        return {
          'id': t['id'],
          'name': 'أ. $name',
          'subject': subject,
          'avatarUrl': users?['avatar_url'] as String?,
          'bgColor': _colorFor(t['id'] as String).withAlpha(40),
          'initials': name.isNotEmpty ? name[0] : 'م',
          'textColor': const Color(0xFF1B2530),
        };
      }).toList();

  @override
  void initState() {
    super.initState();
    _coursesCubit = StudentCoursesCubit(repo: StudentCoursesRepo());
    final user = Supabase.instance.client.auth.currentUser;
    _firstName =
        user?.userMetadata?['full_name']?.toString().split(' ').first ?? 'طالب';
    final userId = user?.id;
    if (userId != null) {
      _coursesCubit.loadSubscribedTeachers(userId);
      _coursesCubit.loadMyCourses(userId);
      _coursesCubit.loadPopularCourses();
      _coursesCubit.loadApprovedTeachers();
      _coursesCubit.loadSubjects();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _coursesCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _currentIndex,
            children: [
              BlocBuilder<StudentCoursesCubit, StudentCoursesState>(
                bloc: _coursesCubit,
                builder: (context, _) => _buildHomeDashboardTab(context),
              ),
              const StudentMyCoursesListScreen(),
              const StudentTransactionsScreen(),
              const StudentExamsListScreen(),
              const StudentProfileTab(isTabMode: true),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  // ─── TAB 0: HOME DASHBOARD — دفتر الطالب ───
  Widget _buildHomeDashboardTab(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: NotebookPaper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Masthead + Greeting ──
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 18.h, 24.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ثانوية أونلاين',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w900,
                          color: NotebookColors.green,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 1,
                        height: 12.h,
                        color: NotebookColors.ink.withAlpha(45),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'دفتر الطالب',
                        style: NotebookText.note(12.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مرحباً بك، $_firstName 👋',
                              style: NotebookText.heading(21.sp),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              'ما الذي تريد تعلمه اليوم؟',
                              style: NotebookText.note(12.sp),
                            ),
                          ],
                        ),
                      ),
                      // Notifications — a red margin-note bell
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.notifications),
                        child: Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: BoxDecoration(
                            color: NotebookColors.surfaceBright,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: NotebookColors.marginRed.withAlpha(120),
                              width: 1.4,
                            ),
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: NotebookColors.marginRed,
                            size: 20.r,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // ── 2. Search — a ruled line to write on ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: NotebookColors.pencil,
                    size: 20.r,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: NotebookText.body(13.sp),
                      decoration: InputDecoration(
                        hintText: 'ابحث عن مادة أو دورة أو مدرس...',
                        hintStyle: NotebookText.note(12.sp)
                            .copyWith(color: NotebookColors.pencil.withAlpha(180)),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      final result = await Navigator.pushNamed<CourseFilters>(
                        context,
                        AppRouter.studentFilter,
                      );
                      if (!mounted) return;
                      setState(() => _homeFilters = result);
                    },
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: NotebookColors.surfaceBright,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: NotebookColors.marginRed.withAlpha(140),
                          width: 1.4,
                        ),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: NotebookColors.marginRed,
                        size: 18.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // the ruled underline beneath the search line
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 0),
              child: Container(
                height: 1.4,
                color: NotebookColors.ink.withAlpha(70),
              ),
            ),

            SizedBox(height: 22.h),

            // ── 3. Promo — a highlighted study note with a خصم stamp ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: NotebookColors.surfaceBright,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: NotebookColors.ink.withAlpha(35)),
                  boxShadow: [
                    BoxShadow(
                      color: NotebookColors.ink.withAlpha(14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const NotebookStamp(label: 'خصم 25%'),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          color: NotebookColors.highlighter,
                          child: Text(
                            'عرض اليوم الخاص!',
                            style: NotebookText.heading(15.sp),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'اشترك الآن واحصل على خصم على أي كورس لمدة محدودة',
                      style: NotebookText.note(11.sp),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 26.h),

            // ── 4. Popular Courses — ruled summary pages ──
            NotebookSectionHeader(title: 'الكورسات الشائعة', onAction: () {
              setState(() => _homeSubjectFilter = 'الكل');
            }),
            SizedBox(height: 12.h),

            // Filter chips (highlighter chips)
            SizedBox(
              height: 34.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                children: [
                  'الكل',
                  ..._coursesCubit.state.subjects
                      .map((s) => s['name_ar'] as String),
                ].map((label) {
                  return NotebookChip(
                    label: label,
                    selected: _homeSubjectFilter == label,
                    onTap: () =>
                        setState(() => _homeSubjectFilter = label),
                  );
                }).toList(),
              ),
            ),
            if (_homeFilters != null && _homeFilters!.isActive)
              NotebookHighlightNote(
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt_rounded,
                      color: NotebookColors.ink,
                      size: 16.r,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'تم التصفية: ${_studentEnrolledCourses.length} دورة',
                        style: NotebookText.strong(12.sp),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _homeFilters = null),
                      child: Text(
                        'مسح',
                        style: NotebookText.strong(12.sp,
                            color: NotebookColors.marginRed),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 14.h),

            // Course cards (ruled summary pages)
            if (_studentEnrolledCourses.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: const NotebookEmptyNote(
                  message: 'لا توجد كورسات مطابقة للتصفية — جرّب مادة أخرى',
                ),
              )
            else
              SizedBox(
                height: 250.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: _studentEnrolledCourses.length,
                  separatorBuilder: (_, _) => SizedBox(width: 14.w),
                  itemBuilder: (context, index) =>
                      _buildCourseCard(_studentEnrolledCourses[index]),
                ),
              ),

            SizedBox(height: 26.h),

            // ── 6. Top Mentors — teacher signatures ──
            const NotebookSectionHeader(title: 'أفضل المدرسين'),
            SizedBox(height: 12.h),
            SizedBox(
              height: 112.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                itemCount: _popularTeachersList.length,
                separatorBuilder: (_, _) => SizedBox(width: 18.w),
                itemBuilder: (context, index) =>
                    _buildTeacherSignature(_popularTeachersList[index]),
              ),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  // A course as a ruled summary page in the دفتر.
  Widget _buildCourseCard(Map<String, dynamic> course) {
    final title = course['title'] as String;
    final teacher = course['teacher'] as String;
    final subject = (course['subject'] as String)
        .replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), '')
        .trim();
    final teacherLine = teacher.startsWith('أ.') ? teacher : 'أ. $teacher';
    final color = course['color'] as Color;
    final coverUrl = course['cover'] as String? ?? '';

    return NotebookCard(
      ruled: true,
      ruledStartY: 96,
      marginTab: true,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          AppRouter.studentCourseDetails,
          arguments: course['id'],
        );
      },
      child: SizedBox(
        width: 180.w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course cover photo
            Container(
              width: double.infinity,
              height: 92.h,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: NotebookColors.ink,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: coverUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: coverUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _coverPlaceholder(color),
                      errorWidget: (_, _, _) => _coverPlaceholder(color),
                    )
                  : _coverPlaceholder(color),
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                if (subject.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: NotebookColors.green,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      subject,
                      style: GoogleFonts.cairo(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.studentBookmarks,
                  ),
                  child: Icon(
                    Icons.bookmark_border_rounded,
                    size: 16.r,
                    color: NotebookColors.pencil,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              teacherLine,
              style: NotebookText.note(11.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: NotebookText.heading(13.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5.h),
            // marker underline
            Container(
              width: 44.w,
              height: 3.h,
              color: color,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'متابعة الكورس',
                  style: NotebookText.note(10.sp),
                ),
                const Spacer(),
                Container(
                  width: 26.r,
                  height: 26.r,
                  decoration: BoxDecoration(
                    color: NotebookColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 15.r,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverPlaceholder(Color color) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(
          painter: RuledLinesPainter(
            lineGap: 22,
            color: Color(0x33FFFFFF),
          ),
        ),
        Center(
          child: Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 18.r,
            ),
          ),
        ),
      ],
    );
  }

  // A top teacher as a signed name in the دفتر.
  Widget _buildTeacherSignature(Map<String, dynamic> teacher) {
    final name = teacher['name'] as String;
    final subject = teacher['subject'] as String;
    final firstName = name.replaceAll('أ. ', '').split(' ').first;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          AppRouter.studentTeacherPage,
          arguments: {
            'teacherId': teacher['id'],
            'title': teacher['name'],
            'avatarUrl': teacher['avatarUrl'],
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NotebookTeacherAvatar(
            avatarUrl: teacher['avatarUrl'] as String?,
            name: (teacher['name'] as String).replaceFirst('أ. ', ''),
            size: 62.r,
          ),
          SizedBox(height: 8.h),
          Text(
            firstName,
            style: NotebookText.strong(12.sp),
          ),
          SizedBox(height: 2.h),
          // signature underline beneath the name
          Container(
            width: 34.w,
            height: 2.h,
            color: NotebookColors.marginRed.withAlpha(160),
          ),
          if (subject.isNotEmpty) ...[
            SizedBox(height: 3.h),
            Text(
              subject,
              style: NotebookText.note(10.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ─── BOTTOM NAVIGATION — 5 tabs, written in the دفتر's language ───
  Widget _buildBottomNavBar(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 62 + bottomPad,
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        border: Border(
          top: BorderSide(color: NotebookColors.ink.withAlpha(30)),
        ),
        boxShadow: [
          BoxShadow(
            color: NotebookColors.ink.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'الرئيسية',
            isSelected: _currentIndex == 0,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 0);
            },
          ),
          _NavBarItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: 'كورساتي',
            isSelected: _currentIndex == 1,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 1);
            },
          ),
          _NavBarItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            label: 'المعاملات',
            isSelected: _currentIndex == 2,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 2);
            },
          ),
          _NavBarItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: 'الامتحانات',
            isSelected: _currentIndex == 3,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 3);
            },
          ),
          _NavBarItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'الملف',
            isSelected: _currentIndex == 4,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = 4);
            },
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? NotebookColors.green : NotebookColors.pencil;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: color,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // marker underline on the active tab
            Container(
              margin: EdgeInsets.only(top: 3),
              width: isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: NotebookColors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
