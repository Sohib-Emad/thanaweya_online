import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_cards_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_cards_cubit.dart';
import 'package:thanaweya_online/features/teacher/ui/cards/services/pdf_cards_generator.dart';
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

  @override
  void initState() {
    super.initState();
    _cubit = TeacherCardsCubit(repo: TeacherCardsRepo());
    _teacherId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_teacherId.isNotEmpty) {
      _cubit.loadCodes(_teacherId);
    }
  }

  @override
  void dispose() { _cubit.close(); super.dispose(); }

  Future<void> _printAllCardsPdf() async {
    final available = _cubit.state.codes.where((c) => c['is_used'] != true).toList();
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد أكواد متاحة للطباعة حالياً', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFF0F172A),
        ),
      );
      return;
    }
    final teacherName = Supabase.instance.client.auth.currentUser?.userMetadata?['full_name'] as String? ?? 'المعلم';
    try {
      await PdfCardsGenerator.printAllCards(
        cards: available,
        defaultTeacherName: teacherName,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى إعادة تشغيل التطبيق بالكامل (Full Restart) لتفعيل خدمة الطباعة: $e', style: GoogleFonts.cairo()),
            backgroundColor: DeskColors.danger,
          ),
        );
      }
    }
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
      Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FF),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFBAE6FD)),
        ),
        child: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFF0284C7), size: 18),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'تنويه: توليد وتسعير أكواد التفعيل مخصص حصرياً لإدارة المنصة لضمان أمان العمليات المالية.',
                style: GoogleFonts.cairo(fontSize: 11.sp, color: const Color(0xFF0369A1), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
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
            subtitle: 'يتم إصدار وتسعير الأكواد حصرياً عبر إدارة المنصة',
            actions: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                child: ElevatedButton.icon(
                  onPressed: _printAllCardsPdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 16),
                  label: Text(
                    'طباعة PDF',
                    style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          body: DeskSurface(
            child: BlocConsumer<TeacherCardsCubit, TeacherCardsState>(
              listener: _onStateChanged, builder: _buildBody,
            ),
          ),
        ),
      ),
    );
  }
}
