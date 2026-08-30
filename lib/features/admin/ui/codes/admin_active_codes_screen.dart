import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/features/admin/data/repos/admin_active_codes_repo.dart';
import 'package:thanaweya_online/features/admin/logic/admin_active_codes_cubit.dart';
import 'services/admin_pdf_cards_generator.dart';
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
        teachers: _cubit.state.teachers,
        initialTeacherId: _cubit.state.selectedTeacherId,
        onGenerate: (tId, cId, count, price) async {
          final ok = await _cubit.generateCodes(teacherId: tId, courseId: cId, count: count, price: price);
          if (mounted && ok) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم توليد $count كود بقيمة $price ج.م بنجاح 🎉'),
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _printFilteredCodes() async {
    final codes = _cubit.state.filteredCodes;
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد أكواد حالياً للطباعة'), backgroundColor: Color(0xFF0F172A)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10.r)),
                    child: const Icon(Icons.print_rounded, color: Color(0xFF1D4ED8)),
                  ),
                  SizedBox(width: 10.w),
                  Text('خيارات طباعة كروت A4 (${codes.length} كود)', style: GoogleFonts.cairo(fontSize: 15.sp, fontWeight: FontWeight.w800)),
                ],
              ),
              SizedBox(height: 16.h),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(8.r)),
                  child: const Icon(Icons.grid_view_rounded, color: Color(0xFF16A34A)),
                ),
                title: Text('8 كروت في الصفحة (2 × 4 صفوف)', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                subtitle: Text('حجم كبير وواضح - قراءة ممتازة للطلاب (موصى به)', style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _executePrint(codes, tenCards: false);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8.r)),
                  child: const Icon(Icons.view_compact_rounded, color: Color(0xFFB45309)),
                ),
                title: Text('10 كروت في الصفحة (2 × 5 صفوف)', style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 13.sp)),
                subtitle: Text('حجم بطاقة شحن قياسي - اقتصادي في استهلاك الورق', style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  Navigator.pop(ctx);
                  _executePrint(codes, tenCards: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executePrint(List<Map<String, dynamic>> codes, {required bool tenCards}) async {
    try {
      HapticFeedback.mediumImpact();
      await AdminPdfCardsGenerator.printCards(cards: codes, tenCardsPerPage: tenCards);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تجهيز ملف الطباعة: $e'), backgroundColor: const Color(0xFFDC2626)),
        );
      }
    }
  }

  Future<void> _printSingleCard(Map<String, dynamic> card) async {
    try {
      HapticFeedback.lightImpact();
      await AdminPdfCardsGenerator.printSingleCard(card: card);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تجهيز الكارت للطباعة: $e'), backgroundColor: const Color(0xFFDC2626)),
        );
      }
    }
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
            IconButton(
              icon: const Icon(Icons.print_rounded),
              tooltip: 'طباعة كروت A4 (PDF)',
              onPressed: _printFilteredCodes,
            ),
            IconButton(
              icon: const Icon(Icons.add_card_rounded),
              tooltip: 'توليد أكواد جديدة',
              onPressed: _openGenerateDialog,
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'تحديث',
              onPressed: () => _cubit.loadCodes(initialTeacherId: _cubit.state.selectedTeacherId),
            ),
          ],
        ),
        body: BlocBuilder<AdminActiveCodesCubit, AdminActiveCodesState>(
          bloc: _cubit,
          builder: (_, state) => Column(
            children: [
              AdminCodesFilterBar(
                searchController: _searchController,
                onSearchChanged: (v) => _cubit.setSearchQuery(v),
                teachers: state.teachers,
                selectedTeacherId: state.selectedTeacherId,
                onTeacherSelected: (t) => _cubit.selectTeacher(t),
                courses: state.courses,
                selectedCourseId: state.selectedCourseId,
                onCourseSelected: (c) => _cubit.selectCourse(c),
                totalCount: state.filteredCodes.length,
                onOpenGenerate: _openGenerateDialog,
                onPrintAll: _printFilteredCodes,
              ),
              Expanded(
                child: AdminCodesListView(
                  state: state,
                  onRefresh: () => _cubit.loadCodes(initialTeacherId: state.selectedTeacherId),
                  onPrintCode: _printSingleCard,
                  onDeleteCode: (id) async {
                    final sm = ScaffoldMessenger.of(context);
                    final ok = await _cubit.deleteCode(id);
                    if (mounted && ok) {
                      sm.showSnackBar(const SnackBar(content: Text('تم حذف الكود بنجاح'), backgroundColor: Color(0xFFDC2626)));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
