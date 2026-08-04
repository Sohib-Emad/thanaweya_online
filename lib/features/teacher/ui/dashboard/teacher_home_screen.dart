import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/features/shared/models/teacher_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_profile_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_profile_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/courses/courses_list_screen.dart';
import 'package:thanaweya_online/features/teacher/ui/students/students_list_screen.dart';

const _ink = Color(0xFF0F172A);
const _inkSoft = Color(0xFF64748B);
const _inkFaint = Color(0xFF94A3B8);
const _hairline = Color(0xFFEEF2F7);
const _canvas = Color(0xFFF8FAFC);
const _brand = Color(0xFF0FA37F);
const _brandDeep = Color(0xFF065F46);
const _brandTint = Color(0xFFE6F7F2);

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

  String _initialOf(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? 'م' : trimmed[0];
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
          backgroundColor: _canvas,
          body: SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeDashboardView(context),
                const CoursesListScreen(),
                const StudentsListScreen(),
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
    return CustomScrollView(
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أحدث الطلاب',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _currentIndex = 2),
                      child: Text(
                        'عرض الكل',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: _brand,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                if (_recentStudents.isEmpty)
                  _buildEmptyRecent()
                else
                  _buildRecentList(),
              ],
            ),
          ),
        ),
      ],
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
          style: GoogleFonts.cairo(
            fontSize: 13.sp,
            color: _inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          name,
          style: GoogleFonts.cairo(
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
            color: _ink,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // A single plain card with every number on this screen.
  Widget _buildStatsCard(BuildContext context, TeacherProfileState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCell(
              label: 'طالب',
              value: '${state.studentsCount}',
              onTap: () => setState(() => _currentIndex = 2),
            ),
          ),
          Container(width: 1, height: 32.h, color: _hairline),
          Expanded(
            child: _buildStatCell(
              label: 'دورة',
              value: '${state.coursesCount}',
              onTap: () => setState(() => _currentIndex = 1),
            ),
          ),
          Container(width: 1, height: 32.h, color: _hairline),
          Expanded(
            child: _buildStatCell(
              label: 'امتحان',
              value: '${state.examsCount}',
              onTap: () => setState(() => _currentIndex = 3),
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
              style: GoogleFonts.cairo(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: _inkFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _hairline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _recentStudents.length; i++) ...[
            if (i > 0)
              Divider(
                color: _hairline,
                height: 1,
                indent: 14.w,
                endIndent: 14.w,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  grade.isNotEmpty ? 'المرحلة: $grade' : 'طالب جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: _inkSoft,
                  ),
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
                style: GoogleFonts.cairo(fontSize: 10.sp, color: _inkFaint),
              ),
              SizedBox(height: 4.h),
              Text(
                active ? 'نشط' : 'غير نشط',
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: active ? _brand : _inkFaint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecent() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: _hairline),
      ),
      child: Column(
        children: [
          Icon(Icons.people_alt_rounded, size: 28.r, color: _inkFaint),
          SizedBox(height: 8.h),
          Text(
            'لا يوجد طلاب بعد',
            style: GoogleFonts.cairo(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: _inkSoft,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'عندما ينضم طالب جديد ستجده هنا',
            style: GoogleFonts.cairo(fontSize: 11.sp, color: _inkFaint),
          ),
        ],
      ),
    );
  }

  // ---------- settings ----------

  Widget _buildSettingsDashboardView(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حسابك وإعداداتك',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          SizedBox(height: 20.h),

          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: _hairline),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25.r,
                  backgroundColor: _brandTint,
                  child: Text(
                    _initialOf(
                      Supabase
                              .instance
                              .client
                              .auth
                              .currentUser
                              ?.userMetadata?['full_name'] ??
                          'م',
                    ),
                    style: GoogleFonts.cairo(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: _brand,
                    ),
                  ),
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
                            style: GoogleFonts.cairo(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            profileState.teacher != null
                                ? 'معلم · ${_stageShortOf(profileState.teacher)}'
                                : 'معلم',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: _inkSoft,
                              fontWeight: FontWeight.w600,
                            ),
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
            icon: Icons.person_outline_rounded,
            title: 'تعديل الملف الشخصي',
            onTap: () {},
          ),
          SizedBox(height: 10.h),
          _SettingsOptionRow(
            icon: Icons.notifications_none_rounded,
            title: 'إعدادات الإشعارات',
            onTap: () {
              Navigator.pushNamed(context, AppRouter.notifications);
            },
          ),
          SizedBox(height: 10.h),
          _SettingsOptionRow(
            icon: Icons.qr_code_2_rounded,
            title: 'أكواد التفعيل المتاحة',
            onTap: () {
              Navigator.pushNamed(context, AppRouter.teacherActivationCodes);
            },
          ),

          SizedBox(height: 28.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.roleSelection,
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              icon: Icon(Icons.logout_rounded, size: 20.r),
              label: Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- navigation ----------

  Widget _buildBottomNavBar() {
    return Container(
      color: _canvas,
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      child: Container(
        height: 68.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(34.r),
          border: Border.all(color: _hairline),
          boxShadow: const [
            BoxShadow(
              color: Color(0x140F172A),
              blurRadius: 24,
              offset: Offset(0, 10),
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
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
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'إنشاء جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                SizedBox(height: 12.h),
                ListTile(
                  leading: Icon(
                    Icons.add_circle_outline_rounded,
                    color: _brand,
                    size: 26.r,
                  ),
                  title: Text(
                    'دورة تعليمية جديدة',
                    style: GoogleFonts.cairo(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.teacherCourses);
                  },
                ),
                const Divider(color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Icon(
                    Icons.quiz_outlined,
                    color: const Color(0xFFD97706),
                    size: 26.r,
                  ),
                  title: Text(
                    'اختبار إلكتروني جديد',
                    style: GoogleFonts.cairo(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRouter.teacherExams);
                  },
                ),
                const Divider(color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: Icon(
                    Icons.qr_code_2_rounded,
                    color: const Color(0xFF7C3AED),
                    size: 26.r,
                  ),
                  title: Text(
                    'أكواد تفعيل للطلاب',
                    style: GoogleFonts.cairo(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5.sp,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRouter.teacherActivationCodes,
                    );
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
    final color = isSelected ? _brand : _inkFaint;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? _brandTint : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.r, color: color),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
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
          gradient: const LinearGradient(
            colors: [_brand, _brandDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D0FA37F),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add_rounded, color: Colors.white, size: 28.r),
      ),
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
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _hairline),
        ),
        child: Row(
          children: [
            Icon(icon, color: _inkSoft, size: 20.r),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            Icon(Icons.chevron_left_rounded, size: 22.r, color: _inkFaint),
          ],
        ),
      ),
    );
  }
}
