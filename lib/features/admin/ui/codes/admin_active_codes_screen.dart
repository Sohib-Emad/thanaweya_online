import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_active_codes_cubit.dart';
import 'widgets/generate_admin_codes_dialog.dart';
import 'widgets/admin_codes_filter_bar.dart';
import 'widgets/admin_codes_list_view.dart';

class AdminActiveCodesScreen extends StatefulWidget {
  final String? initialTeacherId;
  const AdminActiveCodesScreen({super.key, this.initialTeacherId});

  @override
  State<AdminActiveCodesScreen> createState() => _AdminActiveCodesScreenState();
}

class _AdminActiveCodesScreenState extends State<AdminActiveCodesScreen> {
  late final AdminActiveCodesCubit _cubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = AdminActiveCodesCubit(repo: AdminActiveCodesRepo())..loadCodes(initialTeacherId: widget.initialTeacherId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _openGenerateDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (_) => GenerateAdminCodesDialog(
        teachers: _cubit.state.teachers, initialTeacherId: _cubit.state.selectedTeacherId,
        onGenerate: (tId, cId, count) async {
          final ok = await _cubit.generateCodes(teacherId: tId, courseId: cId, count: count);
          if (mounted && ok) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم توليد $count كود بنجاح 🎉'), backgroundColor: const Color(0xFF16A34A)));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('الأكواد النشطة للمعلمين'),
          actions: [
            IconButton(icon: const Icon(Icons.add_card_rounded), tooltip: 'توليد أكواد جديدة', onPressed: _openGenerateDialog),
            IconButton(icon: const Icon(Icons.refresh_rounded), tooltip: 'تحديث', onPressed: () => _cubit.loadCodes(initialTeacherId: _cubit.state.selectedTeacherId)),
          ],
        ),
        body: BlocBuilder<AdminActiveCodesCubit, AdminActiveCodesState>(
          bloc: _cubit,
          builder: (_, state) => Column(children: [
            AdminCodesFilterBar(
              searchController: _searchController, onSearchChanged: (v) => _cubit.setSearchQuery(v),
              teachers: state.teachers, selectedTeacherId: state.selectedTeacherId, onTeacherSelected: (t) => _cubit.selectTeacher(t),
              courses: state.courses, selectedCourseId: state.selectedCourseId, onCourseSelected: (c) => _cubit.selectCourse(c),
              totalCount: state.filteredCodes.length, onOpenGenerate: _openGenerateDialog,
            ),
            Expanded(child: AdminCodesListView(
              state: state,
              onRefresh: () => _cubit.loadCodes(initialTeacherId: state.selectedTeacherId),
              onDeleteCode: (id) async {
                final ok = await _cubit.deleteCode(id);
                if (mounted && ok) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الكود بنجاح'), backgroundColor: Color(0xFFDC2626)));
              },
            )),
          ]),
        ),
      ),
    );
  }
}
