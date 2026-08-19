import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_cards_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_cards_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/widgets/widgets.dart';

/// Screen for managing and generating activation card codes.
class TeacherCardsScreen extends StatefulWidget {
  const TeacherCardsScreen({super.key});

  @override
  State<TeacherCardsScreen> createState() => _TeacherCardsScreenState();
}

class _TeacherCardsScreenState extends State<TeacherCardsScreen> {
  late final TeacherCardsCubit _cubit;
  String _teacherId = '';
  int _selectedFilter = 0;
  List<CourseModel> _teacherCourses = [];

  @override
  void initState() {
    super.initState();
    _cubit = TeacherCardsCubit(repo: TeacherCardsRepo());
    _teacherId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_teacherId.isNotEmpty) {
      _cubit.loadCodes(_teacherId);
      _loadCourses();
    }
  }

  Future<void> _loadCourses() async {
    final res = await TeacherCoursesRepo().getCourses(_teacherId);
    res.when(success: (c) { if (mounted) setState(() => _teacherCourses = c); }, failure: (_, __) {});
  }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  void _exportCodes() {
    final available = _cubit.state.codes.where((c) => c['is_used'] != true).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أكواد متاحة للتصدير')),
      );
      return;
    }
    ExportCodesDialog.show(context, codes: available);
  }

  void _onStateChanged(BuildContext ctx, TeacherCardsState state) {
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(state.errorMessage!, style: GoogleFonts.cairo(fontSize: 12.sp)),
        backgroundColor: DeskColors.danger,
      ));
    }
  }

  Widget _buildBody(BuildContext ctx, TeacherCardsState state) {
    if (state.status == TeacherCardsStatus.loading && state.codes.isEmpty) {
      return Center(child: CircularProgressIndicator(color: DeskColors.primary));
    }
    final all = state.codes;
    final available = all.where((c) => c['is_used'] == false).toList();
    final used = all.where((c) => c['is_used'] == true).toList();
    List<Map<String, dynamic>> filtered = all;
    if (_selectedFilter == 1) filtered = available;
    if (_selectedFilter == 2) filtered = used;

    return Column(children: [
      CardStatBar(totalCount: all.length, availableCount: available.length, usedCount: used.length),
      SizedBox(height: 12.h),
      CardFilterTabs(
        selectedIndex: _selectedFilter, allCount: all.length,
        availableCount: available.length, usedCount: used.length,
        onSelected: (i) => setState(() => _selectedFilter = i),
      ),
      SizedBox(height: 14.h),
      Expanded(child: CardsListView(cards: filtered, cubit: _cubit)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: DeskColors.ground,
          appBar: DeskTopBar(
            title: 'أكواد التفعيل والاشتراكات',
            subtitle: 'إدارة وتوليد أكواد التفعيل المجمعة',
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Color(0xFF0284C7)),
                tooltip: 'تصدير ومشاركة الأكواد المتاحة',
                onPressed: _exportCodes,
              ),
              IconButton(
                icon: Icon(Icons.refresh_rounded, color: DeskColors.primary),
                onPressed: () => _cubit.loadCodes(_teacherId),
              ),
            ],
          ),
          body: DeskSurface(
            child: BlocConsumer<TeacherCardsCubit, TeacherCardsState>(
              listener: _onStateChanged, builder: _buildBody,
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: DeskColors.primary,
            onPressed: () => GenerateCardSheet.show(
              context, teacherId: _teacherId,
              teacherCourses: _teacherCourses, cardsCubit: _cubit,
            ),
            icon: Icon(Icons.add_card_rounded, color: DeskColors.onPrimary),
            label: Text('إنشاء كروت تفعيل',
              style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w900, color: DeskColors.onPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
