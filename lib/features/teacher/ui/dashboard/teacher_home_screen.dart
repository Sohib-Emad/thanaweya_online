// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// THESIS: The teacher's world is a classroom blackboard — deep green board
//   ground, chalk-white ink, mint/red/yellow colored chalk, dashed chalk
//   frames and rubber stamps (معتمد / مسودة). It is the deliberate opposite
//   of the student's cream ruled دفتر, so the two roles read as different
//   rooms of the same school.
// OWN-WORLD: slate-green ground with faint chalk ruling; chalk-white
//   headings; mint chalk for primary actions, red chalk for destructive,
//   yellow for drafts/warnings; dashed chalk borders; stamps not margins.
// STORY: A teacher walks into their classroom, reads the greeting on the
//   board, taps a stat to jump to its board, uses the chalk "+" to scribble
//   a new course/exam/code, and manages students from the side boards.
// FIRST VIEWPORT: chalkboard masthead with the teacher's name, a greeting
//   line, the stats card (طالب / دورة / امتحان), recent students, and the
//   bottom chalk nav whose center is the mint chalk "+" action.
// FORM: The chalkboard counterpart of the student's دفتر direction; it keeps
//   the same tab anatomy (الرئيسية، الكورسات، الامتحانات، الطلاب، حسابي)
//   while mirroring every notebook surface into chalk.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/features/shared/models/teacher_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_profile_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_profile_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/courses_list_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/exams/exams_list_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/students/students_list_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;
  late final TeacherProfileCubit _profileCubit;
  List<Map<String, dynamic>> _recentStudents = [];

  @override
  void initState() {
    super.initState();
    _profileCubit = TeacherProfileCubit(repo: TeacherProfileRepo());
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _profileCubit.loadProfile(userId);
    _profileCubit.loadStats(userId);
    await _loadRecentStudents(userId);
  }

  Future<void> _loadRecentStudents(String teacherId) async {
    try {
      final result = await TeacherStudentsRepo().getStudents(teacherId);
      result.when(
        success: (data) {
          if (mounted) {
            setState(() {
              _recentStudents = data.length > 3 ? data.sublist(0, 3) : data;
            });
          }
        },
        failure: (_, _) {},
      );
    } catch (e) {
      debugPrint('[TeacherHome] load recent students error: $e');
    }
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  // ---------- helpers ----------

  String _greetingLabel() {
    final hour = DateTime.now().hour;
    return hour < 12 ? 'صباح الخير' : 'مساء الخير';
  }

  String _stageShortLabel(TeacherStage stage) {
    switch (stage) {
      case TeacherStage.first:
        return 'الأول الثانوي';
      case TeacherStage.second:
        return 'الثاني الثانوي';
      case TeacherStage.third:
        return 'الثالث الثانوي';
    }
  }

  String _stageShortOf(dynamic teacher) {
    if (teacher == null) return '-';
    return _stageShortLabel(teacher.stage as TeacherStage);
  }

  // ---------- root ----------

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ChalkboardColors.ground,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeDashboardView(context),
                const CoursesListScreen(),
                const ExamsListScreen(),
                const StudentsListScreen(),
                _buildSettingsDashboardView(context),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavBar(),
        ),
      ),
    );
  }

  // ---------- home ----------

  Widget _buildHomeDashboardView(BuildContext context) {
    return ChalkboardSurface(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),

                  SizedBox(height: 20.h),

                  BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
                    builder: (context, profileState) {
                      return _buildStatsCard(context, profileState);
                    },
                  ),

                  SizedBox(height: 28.h),

                  ChalkSectionHeader(
                    title: 'أحدث الطلاب',
                    actionLabel: 'عرض الكل',
                    onAction: () => setState(() => _currentIndex = 3),
                  ),
                  SizedBox(height: 12.h),

                  if (_recentStudents.isEmpty)
                    const ChalkEmptyNote(
                      message: 'لا يوجد طلاب بعد',
                      subMessage: 'عندما ينضم طالب جديد ستجده هنا',
                      icon: Icons.people_alt_outlined,
                    )
                  else
                    _buildRecentList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name =
        Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] ??
            'مستخدم';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _greetingLabel(),
          style: ChalkboardText.note(13.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          name,
          style: ChalkboardText.heading(22.sp),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // A chalk card with the three classroom numbers.
  Widget _buildStatsCard(BuildContext context, TeacherProfileState state) {
    return ChalkCard(
      onTap: null,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCell(
              label: 'طالب',
              value: '${state.studentsCount}',
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ),
          Container(width: 1, height: 32.h, color: ChalkboardColors.ink.withAlpha(45)),
          Expanded(
            child: _buildStatCell(
              label: 'دورة',
              value: '${state.coursesCount}',
              onTap: () => setState(() => _currentIndex = 1),
            ),
          ),
          Container(width: 1, height: 32.h, color: ChalkboardColors.ink.withAlpha(45)),
          Expanded(
            child: _buildStatCell(
              label: 'امتحان',
              value: '${state.examsCount}',
              onTap: () => setState(() => _currentIndex = 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCell({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 4.w),
        child: Column(
          children: [
            Text(
              value,
              style: ChalkboardText.heading(20.sp),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: ChalkboardText.note(11.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    return ChalkCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _recentStudents.length; i++) ...[
            if (i > 0)
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 14.w),
                color: ChalkboardColors.ink.withAlpha(35),
              ),
            _buildRecentRow(_recentStudents[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentRow(Map<String, dynamic> student) {
    final users = student['users'] as Map<String, dynamic>? ?? {};
    final name = users['full_name'] as String? ?? 'طالب';
    final grade =
        (student['students'] as Map<String, dynamic>?)?['grade_level']
                as String? ??
            '';
    final active = student['status'] == 'active';
    final time = student['created_at']?.toString().substring(0, 10) ?? '';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          ChalkAvatar(
            initial: name,
            radius: 16,
            color: active ? ChalkboardColors.accent : ChalkboardColors.chalkSoft,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: ChalkboardText.strong(13.5.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  grade.isNotEmpty ? 'المرحلة: $grade' : 'طالب جديد',
                  style: ChalkboardText.note(11.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: ChalkboardText.note(10.sp),
              ),
              SizedBox(height: 4.h),
              ChalkStatusChip(
                label: active ? 'نشط' : 'غير نشط',
                color: active
                    ? ChalkboardColors.accent
                    : ChalkboardColors.chalkSoft,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- settings ----------

  Widget _buildSettingsDashboardView(BuildContext context) {
    return ChalkboardSurface(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حسابك وإعداداتك',
              style: ChalkboardText.heading(16.sp),
            ),
            SizedBox(height: 20.h),

            ChalkCard(
              child: Row(
                children: [
                  ChalkAvatar(
                    initial: Supabase
                            .instance
                            .client
                            .auth
                            .currentUser
                            ?.userMetadata?['full_name']
                            ?.toString() ??
                        'م',
                    radius: 25,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: BlocBuilder<TeacherProfileCubit, TeacherProfileState>(
                      builder: (context, profileState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileState.user?.fullName ??
                                  Supabase
                                      .instance
                                      .client
                                      .auth
                                      .currentUser
                                      ?.userMetadata?['full_name'] ??
                                  'مستخدم',
                              style: ChalkboardText.strong(17.sp),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              profileState.teacher != null
                                  ? 'معلم · ${_stageShortOf(profileState.teacher)}'
                                  : 'معلم',
                              style: ChalkboardText.note(12.sp),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            _SettingsOptionRow(
              icon: Icons.vpn_key_outlined,
              title: 'كروت الدفع والتفعيل',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.teacherCards);
              },
            ),

            SizedBox(height: 12.h),

            _SettingsOptionRow(
              icon: Icons.notifications_none_rounded,
              title: 'الإشعارات',
              onTap: () {
                Navigator.pushNamed(context, AppRouter.notifications);
              },
            ),

            SizedBox(height: 28.h),

            ChalkOutlineButton(
              label: 'تسجيل الخروج',
              icon: Icons.logout_rounded,
              color: ChalkboardColors.chalkRed,
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.roleSelection,
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------- navigation ----------

  Widget _buildBottomNavBar() {
    return Container(
      color: ChalkboardColors.ground,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        height: 66.h,
        decoration: BoxDecoration(
          color: ChalkboardColors.groundDeep,
          borderRadius: BorderRadius.circular(33.r),
          border: Border.all(color: ChalkboardColors.ink.withAlpha(55)),
          boxShadow: [
            BoxShadow(
              color: ChalkboardColors.groundDeep.withAlpha(160),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarItem(
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              isSelected: _currentIndex == 0,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 0);
              },
            ),
            _NavBarItem(
              icon: Icons.grid_view_rounded,
              label: 'الكورسات',
              isSelected: _currentIndex == 1,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 1);
              },
            ),
            _CenterAction(
              onTap: () {
                HapticFeedback.heavyImpact();
                _showQuickCreateModal(context);
              },
            ),
            _NavBarItem(
              icon: Icons.quiz_outlined,
              label: 'الامتحانات',
              isSelected: _currentIndex == 2,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 2);
              },
            ),
            _NavBarItem(
              icon: Icons.people_alt_rounded,
              label: 'الطلاب',
              isSelected: _currentIndex == 3,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 3);
              },
            ),
            _NavBarItem(
              icon: Icons.person_rounded,
              label: 'حسابي',
              isSelected: _currentIndex == 4,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = 4);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickCreateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: ChalkboardColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        side: BorderSide(color: ChalkboardColors.ink.withAlpha(60)),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: ChalkboardColors.ink.withAlpha(90),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'إنشاء جديد على السبورة',
                  style: ChalkboardText.heading(17.sp),
                ),
                SizedBox(height: 12.h),
                _QuickCreateTile(
                  icon: Icons.add_circle_outline_rounded,
                  iconColor: ChalkboardColors.accent,
                  label: 'دورة تعليمية جديدة',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.teacherCourses);
                  },
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  color: ChalkboardColors.ink.withAlpha(30),
                ),
                _QuickCreateTile(
                  icon: Icons.quiz_outlined,
                  iconColor: ChalkboardColors.chalkYellow,
                  label: 'اختبار إلكتروني جديد',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.teacherExams);
                  },
                ),
                Container(
                  height: 1,
                  margin: EdgeInsets.symmetric(horizontal: 8.w),
                  color: ChalkboardColors.ink.withAlpha(30),
                ),
                _QuickCreateTile(
                  icon: Icons.add_card_rounded,
                  iconColor: ChalkboardColors.accent,
                  label: 'كروت التفعيل والدفع',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.teacherCards);
                  },
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------- small widgets ----------

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? ChalkboardColors.accent : ChalkboardColors.chalkSoft;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ChalkboardColors.accent.withAlpha(26)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: ChalkboardColors.accent.withAlpha(120))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 21.r, color: color),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9.sp,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAction extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ChalkboardColors.accent,
          border: Border.all(
            color: ChalkboardColors.ink.withAlpha(120),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: ChalkboardColors.accent.withAlpha(120),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.add_rounded,
          color: ChalkboardColors.onAccent,
          size: 28.r,
        ),
      ),
    );
  }
}

class _QuickCreateTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickCreateTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor, size: 26.r),
      title: Text(
        label,
        style: ChalkboardText.strong(13.5.sp),
      ),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: ChalkboardColors.chalkSoft,
        size: 22.r,
      ),
      onTap: onTap,
    );
  }
}

class _SettingsOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsOptionRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: ChalkCard(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, color: ChalkboardColors.chalkSoft, size: 20.r),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: ChalkboardText.strong(14.sp),
              ),
            ),
            Icon(
              Icons.chevron_left_rounded,
              size: 22.r,
              color: ChalkboardColors.chalkSoft,
            ),
          ],
        ),
      ),
    );
  }
}
