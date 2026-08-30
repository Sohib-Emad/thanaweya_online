import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_students_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_students_cubit.dart';
import 'widgets/student_courses_sheet.dart';
import 'widgets/students_search_filter_bar.dart';
import 'widgets/student_card_item.dart';
import 'widgets/student_gift_points_dialog.dart';

class AdminStudentsScreen extends StatefulWidget {
  final String? initialTeacherId;
  const AdminStudentsScreen({super.key, this.initialTeacherId});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  late final AdminStudentsCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = AdminStudentsCubit(repo: AdminStudentsRepo())..loadData(initialTeacherId: widget.initialTeacherId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('إدارة طلاب المعلمين والاشتراكات'),
          actions: [IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'تحديث', onPressed: () => _cubit.loadData(initialTeacherId: _cubit.state.selectedTeacherId))],
        ),
        body: BlocBuilder<AdminStudentsCubit, AdminStudentsState>(
          bloc: _cubit,
          builder: (context, state) => Column(
            children: [
              StudentsSearchFilterBar(
                searchController: _searchController,
                onSearchChanged: (v) => _cubit.setSearchQuery(v),
                teachers: state.teachers,
                selectedTeacherId: state.selectedTeacherId,
                onTeacherSelected: (tId) => _cubit.selectTeacher(tId),
                totalCount: state.filteredStudents.length,
              ),
              Expanded(child: _buildList(state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(AdminStudentsState state) {
    if (state.status == AdminStudentsStatus.loading) return const Center(child: CircularProgressIndicator());
    if (state.status == AdminStudentsStatus.failure) {
      return Center(child: Text(state.errorMessage ?? 'حدث خطأ', style: AppTextStyles.body2));
    }
    if (state.filteredStudents.isEmpty) {
      return Center(child: Text('لا يوجد طلاب مطابقين للبحث', style: AppTextStyles.h3));
    }
    return RefreshIndicator(
      onRefresh: () => _cubit.loadData(initialTeacherId: state.selectedTeacherId),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: state.filteredStudents.length,
        separatorBuilder: (_, _) => SizedBox(height: 12.h),
        itemBuilder: (_, index) {
          final s = state.filteredStudents[index];
          return StudentCardItem(
            student: s,
            onOpenCourses: () => showModalBottomSheet(
              context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
              builder: (_) => StudentCoursesSheet(student: s, teachers: state.teachers, initialTeacherId: _cubit.state.selectedTeacherId),
            ),
            onGiftPoints: () => showStudentGiftPointsDialog(context: context, student: s),
          );
        },
      ),
    );
  }
}
