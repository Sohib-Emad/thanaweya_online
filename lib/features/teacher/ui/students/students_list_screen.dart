import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_students_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_students_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/students/widgets/widgets.dart';

const _gradeFilters = [
  (label: 'الكل', value: ''),
  (label: 'الصف الأول الثانوي', value: 'first'),
  (label: 'الصف الثاني الثانوي', value: 'second'),
  (label: 'الصف الثالث الثانوي', value: 'third'),
];

/// Converts a grade level key to its Arabic label.
String gradeLabelOf(String? value) {
  switch (value) {
    case 'first': return 'الأول الثانوي';
    case 'second': return 'الثاني الثانوي';
    case 'third': return 'الثالث الثانوي';
    default: return 'المرحلة الثانوية';
  }
}

/// Screen listing all subscribed students with search and grade filtering.
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
  void initState() { super.initState(); _loadStudents(); }
  @override
  void dispose() { _cubit.close(); _searchController.dispose(); super.dispose(); }

  Future<void> _loadStudents() async {
    String? uid = Supabase.instance.client.auth.currentUser?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
    if (uid == null) {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
        if (!mounted) return;
        uid = Supabase.instance.client.auth.currentUser?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
        if (uid != null) break;
      }
    }
    if (uid != null && mounted) _cubit.loadStudents(uid);
  }

  Future<void> _sendMessage() async {
    final sent = await SendStudentMessageSheet.show(context);
    if (sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم إرسال الرسالة بنجاح لجميع طلابك', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF0284C7),
      ));
    }
  }

  Widget _buildCard(Map<String, dynamic> student) {
    final user = student['users'] as Map<String, dynamic>? ?? {};
    final meta = student['students'] as Map<String, dynamic>? ?? {};
    final name = user['full_name'] as String? ?? 'طالب منصة';
    final email = user['email'] as String? ?? '';
    final phone = user['phone'] as String? ?? '';
    final grade = meta['grade_level'] as String? ?? '';
    final active = student['status'] == 'active' || student['status'] == null;
    final completed = (student['completed_lessons'] as num?)?.toInt() ?? 0;
    final total = (student['total_lessons'] as num?)?.toInt() ?? 0;
    final progress = (student['progress_percent'] as num?)?.toInt() ?? 0;
    return StudentCard(
      name: name, email: email, phone: phone,
      gradeLabel: gradeLabelOf(grade), active: active,
      completedLessons: completed, totalLessons: total, progressPercent: progress,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(context, AppRouter.teacherStudentDetail, arguments: {
          'studentId': student['student_id'] ?? student['id'],
          'name': name, 'grade': grade, 'email': email,
        });
      },
    );
  }

  Widget _buildBody(BuildContext ctx, TeacherStudentsState state) {
    if (state.status == TeacherStudentsStatus.loading && state.students.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
    }
    if (state.status == TeacherStudentsStatus.error && state.students.isEmpty) {
      return Center(child: StudentsEmptyState(message: state.errorMessage ?? 'حدث خطأ أثناء تحميل الطلاب', icon: Icons.error_outline_rounded, actionLabel: 'إعادة المحاولة', onAction: _loadStudents));
    }
    if (state.students.isEmpty) {
      return Center(child: StudentsEmptyState(
        message: 'لا يوجد طلاب مشتركون بعد',
        subMessage: 'عندما يشترك الطلاب في كورساتك أو يفعلون أكواد الاشتراك سيظهرون هنا فوراً',
        icon: Icons.people_outline_rounded, actionLabel: 'تحديث القائمة', onAction: _loadStudents,
      ));
    }
    final filtered = filterStudents(students: state.students, searchQuery: _searchQuery, gradeFilter: _selectedGradeFilter);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 12.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: DeskSearchField(controller: _searchController, hint: 'ابحث باسم الطالب، الإيميل، أو رقم الهاتف...', onChanged: (v) => setState(() => _searchQuery = v)),
      ),
      SizedBox(height: 10.h),
      StudentGradeFilter(filters: _gradeFilters, selectedValue: _selectedGradeFilter, onSelected: (v) => setState(() => _selectedGradeFilter = v)),
      SizedBox(height: 10.h),
      StudentCountLabel(count: filtered.length),
      SizedBox(height: 6.h),
      Expanded(child: filtered.isEmpty
          ? const Center(child: StudentsEmptyState(message: 'لا يوجد طلاب مطابقين للبحث أو الفلتر', icon: Icons.person_search_outlined))
          : RefreshIndicator(onRefresh: _loadStudents, color: const Color(0xFF0284C7),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 80.h),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => SizedBox(height: 10.h),
                itemBuilder: (ctx, i) => _buildCard(filtered[i]),
              ),
            )),
    ]);
  }
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: DeskTopBar(
          title: 'قائمة الطلاب', subtitle: 'متابعة المشتركين ونتائج الامتحانات',
          automaticallyImplyBack: true,
          actions: [DeskIconAction(icon: Icons.campaign_rounded, color: const Color(0xFF0284C7), tooltip: 'إرسال تنبيه للطلاب', onTap: _sendMessage)],
        ),
        body: BlocBuilder<TeacherStudentsCubit, TeacherStudentsState>(bloc: _cubit, builder: _buildBody),
      ),
    );
  }
}
