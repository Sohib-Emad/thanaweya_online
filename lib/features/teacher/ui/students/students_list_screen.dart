import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_strings.dart';
import 'package:thanaweya_online/features/shared/models/activation_code_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_students_cubit.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _cubit = TeacherStudentsCubit(repo: TeacherStudentsRepo());
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedGradeFilter = 'الكل';

  final List<String> _gradeFilters = [
    'الكل',
    'الصف الأول الثانوي',
    'الصف الثاني الثانوي',
    'الصف الثالث الثانوي',
    'مسار البكالوريا (IB)',
  ];

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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.chevron_right_rounded,
                      color: const Color(0xFF0F172A), size: 28.r),
                  onPressed: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                )
              : null,
          centerTitle: true,
          title: Text(
            AppStrings.studentsList,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: BlocBuilder<TeacherStudentsCubit, TeacherStudentsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.status == TeacherStudentsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == TeacherStudentsStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48.r, color: AppColors.error),
                    SizedBox(height: 12.h),
                    Text(
                      state.errorMessage ?? 'حدث خطأ أثناء تحميل الطلاب',
                      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: _loadStudents,
                      child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
                    ),
                  ],
                ),
              );
            }

            final allStudents = state.students;
            final filteredStudents = allStudents.where((student) {
              final user = student['users'] as Map<String, dynamic>? ?? {};
              final name = (user['full_name'] as String? ?? '').toLowerCase();
              final email = (user['email'] as String? ?? '').toLowerCase();
              final grade = (student['grade'] ?? '') as String? ?? '';

              final matchesQuery = name.contains(_searchQuery.toLowerCase()) ||
                  email.contains(_searchQuery.toLowerCase());
              final matchesGrade = _selectedGradeFilter == 'الكل' || grade.contains(_selectedGradeFilter);

              return matchesQuery && matchesGrade;
            }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input Field
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم الطالب أو الإيميل...',
                      hintStyle: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: const Color(0xFF94A3B8), size: 20.r),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: AppColors.teacherPrimary, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // Grade Filter Chips Row
                SizedBox(
                  height: 44.h,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _gradeFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final gradeFilter = _gradeFilters[index];
                      final isSelected = _selectedGradeFilter == gradeFilter;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedGradeFilter = gradeFilter);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.teacherPrimary : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: isSelected ? AppColors.teacherPrimary : const Color(0xFFE2E8F0),
                            ),
                            boxShadow: isSelected
                                ? const [BoxShadow(color: Color(0x200FA37F), blurRadius: 8, offset: Offset(0, 3))]
                                : null,
                          ),
                          child: Text(
                            gradeFilter,
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 12.h),

                // Students Count Banner
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'عرض ${filteredStudents.length} طالب',
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),

                SizedBox(height: 8.h),

                // Students List
                Expanded(
                  child: filteredStudents.isEmpty
                      ? Center(
                          child: Text(
                            'لا يوجد طلاب مطابقين للبحث أو الفلتر المحدد',
                            style: GoogleFonts.cairo(fontSize: 14.sp, color: const Color(0xFF94A3B8)),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadStudents,
                          child: ListView.separated(
                            padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h),
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredStudents.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              final user = student['users'] as Map<String, dynamic>? ?? {};
                              final name = user['full_name'] as String? ?? '';
                              final email = user['email'] as String? ?? '';
                              final phone = (user['phone'] ?? '') as String? ?? '';
                              final grade = (student['grade'] ?? 'غير محدد') as String? ?? 'غير محدد';
                              final initials = name.isNotEmpty ? name[0] : 'ط';

                              return _StudentCard(
                                name: name,
                                email: email,
                                phone: phone,
                                grade: grade,
                                initials: initials,
                                onTap: () => _showStudentDetailsModal(context, student),
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
    );
  }

  void _showStudentDetailsModal(BuildContext context, Map<String, dynamic> student) {
    final user = student['users'] as Map<String, dynamic>? ?? {};
    final name = user['full_name'] as String? ?? '';
    final email = user['email'] as String? ?? '';
    final phone = (user['phone'] ?? '01000000000') as String? ?? '01000000000';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28.r,
                      backgroundColor: const Color(0xFFECFDF5),
                      child: Icon(Icons.person_rounded, size: 32.r, color: const Color(0xFF0FA37F)),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
                          SizedBox(height: 2.h),
                          Text(email, style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Divider(color: const Color(0xFFF1F5F9), height: 1),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(icon: Icons.phone_rounded, title: 'رقم التليفون', value: phone),
                            Divider(color: const Color(0xFFE2E8F0), height: 16.h),
                            _buildInfoRow(icon: Icons.email_rounded, title: 'البريد الإلكتروني', value: email),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({required IconData icon, required String title, required String value}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 18.r),
        SizedBox(width: 10.w),
        Text('$title: ', style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
      ],
    );
  }
}

class _StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String grade;
  final String initials;
  final VoidCallback onTap;

  const _StudentCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.grade,
    required this.initials,
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
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: const [BoxShadow(color: Color(0x050F172A), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: const Color(0xFFECFDF5),
              child: Text(initials, style: GoogleFonts.cairo(color: const Color(0xFF0FA37F), fontWeight: FontWeight.w900, fontSize: 16.sp)),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                  SizedBox(height: 3.h),
                  Text('$grade • $phone', style: GoogleFonts.cairo(fontSize: 11.sp, color: const Color(0xFF64748B))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
