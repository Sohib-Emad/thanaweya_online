// ────────────────────────────────────────────────────────────
// DIRECTION CONTRACT — معلم · السبورة الطباشير (the chalkboard)
// STUDENTS BOARD: the teacher's students are chalk frames on the board,
//   written with the student's name, المرحلة (from students.grade_level),
//   email and active status. A chalk search line and grade chips filter the
//   frames; tapping a student opens their real progress page (not a fake
//   details sheet with a made-up phone number).
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
//   finish review, the verdict, and DESIGN.md.
// ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_students_cubit.dart';

const _gradeFilters = [
  (label: 'الكل', value: ''),
  (label: 'الأول الثانوي', value: 'first'),
  (label: 'الثاني الثانوي', value: 'second'),
  (label: 'الثالث الثانوي', value: 'third'),
];

String gradeLabelOf(String? value) {
  switch (value) {
    case 'first':
      return 'الأول الثانوي';
    case 'second':
      return 'الثاني الثانوي';
    case 'third':
      return 'الثالث الثانوي';
    default:
      return 'غير محدد';
  }
}

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _cubit = TeacherStudentsCubit(repo: TeacherStudentsRepo());
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGradeFilter = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  @override
  void dispose() {
    _cubit.close();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.loadStudents(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ChalkboardColors.ground,
        appBar: ChalkTopBar(
          title: 'الطلاب',
          subtitle: 'طلابك على السبورة',
          automaticallyImplyBack: true,
        ),
        body: ChalkboardSurface(
          child: BlocBuilder<TeacherStudentsCubit, TeacherStudentsState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.status == TeacherStudentsStatus.loading &&
                  state.students.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: ChalkboardColors.accent,
                  ),
                );
              }
              if (state.status == TeacherStudentsStatus.error &&
                  state.students.isEmpty) {
                return Center(
                  child: ChalkEmptyNote(
                    message: state.errorMessage ?? 'حدث خطأ أثناء تحميل الطلاب',
                    icon: Icons.error_outline_rounded,
                    actionLabel: 'إعادة المحاولة',
                    onAction: _loadStudents,
                  ),
                );
              }

              final filteredStudents = state.students.where((student) {
                final user = student['users'] as Map<String, dynamic>? ?? {};
                final name = (user['full_name'] as String? ?? '').toLowerCase();
                final email = (user['email'] as String? ?? '').toLowerCase();
                final grade =
                    (student['students'] as Map<String, dynamic>?)?['grade_level']
                            as String? ??
                        '';

                final matchesQuery = name.contains(_searchQuery.toLowerCase()) ||
                    email.contains(_searchQuery.toLowerCase());
                final matchesGrade = _selectedGradeFilter.isEmpty ||
                    grade == _selectedGradeFilter;

                return matchesQuery && matchesGrade;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  ChalkSearchField(
                    controller: _searchController,
                    hint: 'ابحث باسم الطالب أو الإيميل...',
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 40.h,
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _gradeFilters.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 4),
                      itemBuilder: (context, index) {
                        final filter = _gradeFilters[index];
                        return ChalkChip(
                          label: filter.label,
                          selected: _selectedGradeFilter == filter.value,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(
                              () => _selectedGradeFilter = filter.value,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Text(
                      'عرض ${filteredStudents.length} طالب',
                      style: ChalkboardText.note(12.sp),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? const ChalkEmptyNote(
                            message: 'لا يوجد طلاب مطابقين للبحث أو الفلتر',
                            icon: Icons.person_search_outlined,
                          )
                        : RefreshIndicator(
                            onRefresh: _loadStudents,
                            color: ChalkboardColors.accent,
                            child: ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                  20.w, 4.h, 20.w, 20.h),
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredStudents.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                final user =
                                    student['users'] as Map<String, dynamic>? ??
                                        {};
                                final name = user['full_name'] as String? ?? '';
                                final email = user['email'] as String? ?? '';
                                final grade = (student['students']
                                        as Map<String, dynamic>?)?['grade_level']
                                        as String? ??
                                    '';
                                final active = student['status'] == 'active';

                                return _StudentCard(
                                  name: name,
                                  email: email,
                                  gradeLabel: gradeLabelOf(grade),
                                  active: active,
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.teacherStudentDetail,
                                      arguments: {
                                        'studentId': student['student_id'] ??
                                            student['id'],
                                        'name': name,
                                        'grade': grade,
                                        'email': email,
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String gradeLabel;
  final bool active;
  final VoidCallback onTap;

  const _StudentCard({
    required this.name,
    required this.email,
    required this.gradeLabel,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        active ? ChalkboardColors.accent : ChalkboardColors.chalkSoft;
    return ChalkCard(
      onTap: onTap,
      accent: accent,
      child: Row(
        children: [
          ChalkAvatar(initial: name, radius: 22, color: accent),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: ChalkboardText.strong(14.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  '$gradeLabel • $email',
                  style: ChalkboardText.note(11.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ChalkStatusChip(
            label: active ? 'نشط' : 'غير نشط',
            color: accent,
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.chevron_left_rounded,
            size: 20.r,
            color: ChalkboardColors.chalkSoft,
          ),
        ],
      ),
    );
  }
}
