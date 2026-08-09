import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/chalkboard_theme.dart';
import 'package:thanaweya_online/features/shared/models/course_model.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_cards_repo.dart';
import 'package:thanaweya_online/features/teacher/data/repos/teacher_courses_repo.dart';
import 'package:thanaweya_online/features/teacher/logic/teacher_cards_cubit.dart';

class TeacherCardsScreen extends StatefulWidget {
  const TeacherCardsScreen({super.key});

  @override
  State<TeacherCardsScreen> createState() => _TeacherCardsScreenState();
}

class _TeacherCardsScreenState extends State<TeacherCardsScreen> {
  late final TeacherCardsCubit _cardsCubit;
  String _teacherId = '';
  int _selectedFilter = 0; // 0 = الكل, 1 = المتاحة, 2 = المستعملة
  List<CourseModel> _teacherCourses = [];

  @override
  void initState() {
    super.initState();
    _cardsCubit = TeacherCardsCubit(repo: TeacherCardsRepo());
    _teacherId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_teacherId.isNotEmpty) {
      _cardsCubit.loadCodes(_teacherId);
      _loadCourses();
    }
  }

  Future<void> _loadCourses() async {
    final res = await TeacherCoursesRepo().getCourses(_teacherId);
    res.when(
      success: (courses) {
        if (mounted) setState(() => _teacherCourses = courses);
      },
      failure: (_, __) {},
    );
  }

  @override
  void dispose() {
    _cardsCubit.close();
    super.dispose();
  }

  void _copyCode(String code) {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الكود: $code',
          style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.white),
        ),
        backgroundColor: ChalkboardColors.accent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDelete(String codeId, String code) async {
    HapticFeedback.warningNotification();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: ChalkboardColors.surface,
          title: Text(
            'حذف كرت التفعيل',
            style: ChalkboardText.strong(15.sp),
          ),
          content: Text(
            'هل تريد حذف الكرت ($code)؟ لن يتمكن أي طالب من استخدامه لاحقاً.',
            style: ChalkboardText.body(13.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('إلغاء', style: ChalkboardText.strong(13.sp)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'حذف',
                style: ChalkboardText.strong(
                  13.sp,
                  color: ChalkboardColors.chalkRed,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _cardsCubit.deleteCode(codeId);
    }
  }

  void _showGenerateModal() {
    String? selectedCourseId;
    int selectedCount = 5;

    showModalBottomSheet(
      context: context,
      backgroundColor: ChalkboardColors.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  20.h,
                  20.w,
                  MediaQuery.of(context).viewInsets.bottom + 24.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: ChalkboardColors.ink.withAlpha(90),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'توليد كروت تفعيل جديدة',
                      style: ChalkboardText.heading(17.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'قم باختيار العدد والكورس لإنشاء كروت اشتراك جاهزة للطباعة والتوزيع',
                      style: ChalkboardText.note(11.sp),
                    ),
                    SizedBox(height: 18.h),
                    Text('الكورس المستهدف:', style: ChalkboardText.strong(13.sp)),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String?>(
                      initialValue: selectedCourseId,
                      dropdownColor: ChalkboardColors.surface,
                      style: ChalkboardText.body(13.sp),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: ChalkboardColors.groundDeep,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: ChalkboardColors.ink.withAlpha(60),
                          ),
                        ),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            'جميع كورسات المدرس',
                            style: ChalkboardText.body(13.sp),
                          ),
                        ),
                        ..._teacherCourses.map(
                          (c) => DropdownMenuItem<String?>(
                            value: c.id,
                            child: Text(
                              c.title,
                              style: ChalkboardText.body(13.sp),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) => setModalState(() => selectedCourseId = val),
                    ),
                    SizedBox(height: 18.h),
                    Text('عدد الكروت:', style: ChalkboardText.strong(13.sp)),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [1, 5, 10, 20, 50].map((cnt) {
                        final isSelected = selectedCount == cnt;
                        return ChoiceChip(
                          label: Text(
                            '$cnt كرت',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? ChalkboardColors.onAccent
                                  : ChalkboardColors.chalkSoft,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: ChalkboardColors.accent,
                          backgroundColor: ChalkboardColors.groundDeep,
                          onSelected: (_) =>
                              setModalState(() => selectedCount = cnt),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24.h),
                    BlocBuilder<TeacherCardsCubit, TeacherCardsState>(
                      bloc: _cardsCubit,
                      builder: (context, state) {
                        return ChalkPrimaryButton(
                          label: 'إنشاء $selectedCount كرت تفعيل الآن',
                          icon: Icons.add_card_rounded,
                          loading: state.isGenerating,
                          onPressed: () async {
                            final ok = await _cardsCubit.generateCodes(
                              teacherId: _teacherId,
                              courseId: selectedCourseId,
                              count: selectedCount,
                            );
                            if (ok && modalCtx.mounted) {
                              Navigator.pop(modalCtx);
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cardsCubit,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: ChalkboardColors.ground,
          appBar: AppBar(
            backgroundColor: ChalkboardColors.groundDeep,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: ChalkboardColors.chalkSoft,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'كروت الدفع والتفعيل',
              style: ChalkboardText.heading(16.sp),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: ChalkboardColors.accent,
                ),
                onPressed: () => _cardsCubit.loadCodes(_teacherId),
              ),
            ],
          ),
          body: ChalkboardSurface(
            child: BlocConsumer<TeacherCardsCubit, TeacherCardsState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.errorMessage!,
                        style: GoogleFonts.cairo(fontSize: 12.sp),
                      ),
                      backgroundColor: ChalkboardColors.chalkRed,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == TeacherCardsStatus.loading &&
                    state.codes.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: ChalkboardColors.accent,
                    ),
                  );
                }

                final allCodes = state.codes;
                final availableCodes =
                    allCodes.where((c) => c['is_used'] == false).toList();
                final usedCodes =
                    allCodes.where((c) => c['is_used'] == true).toList();

                List<Map<String, dynamic>> filteredList = allCodes;
                if (_selectedFilter == 1) filteredList = availableCodes;
                if (_selectedFilter == 2) filteredList = usedCodes;

                return Column(
                  children: [
                    // Stats Bar
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      color: ChalkboardColors.groundDeep.withAlpha(180),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              label: 'الإجمالي',
                              value: allCodes.length.toString(),
                              color: ChalkboardColors.chalkSoft,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 28.h,
                            color: ChalkboardColors.ink.withAlpha(40),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              label: 'المتاحة',
                              value: availableCodes.length.toString(),
                              color: ChalkboardColors.accent,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 28.h,
                            color: ChalkboardColors.ink.withAlpha(40),
                          ),
                          Expanded(
                            child: _buildStatItem(
                              label: 'المستعملة',
                              value: usedCodes.length.toString(),
                              color: ChalkboardColors.chalkYellow,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Filter tabs
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          _buildFilterTab(
                            index: 0,
                            label: 'الكل (${allCodes.length})',
                          ),
                          SizedBox(width: 8.w),
                          _buildFilterTab(
                            index: 1,
                            label: 'المتاحة (${availableCodes.length})',
                          ),
                          SizedBox(width: 8.w),
                          _buildFilterTab(
                            index: 2,
                            label: 'المستعملة (${usedCodes.length})',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    // Cards list
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.subtitles_off_rounded,
                                    size: 48.r,
                                    color: ChalkboardColors.chalkSoft
                                        .withAlpha(120),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'لا توجد كروت تفعيل في هذه القائمة',
                                    style: ChalkboardText.body(13.sp),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                4.h,
                                16.w,
                                80.h,
                              ),
                              itemCount: filteredList.length,
                              separatorBuilder: (_, _) =>
                                  SizedBox(height: 10.h),
                              itemBuilder: (context, index) {
                                final card = filteredList[index];
                                final code = card['code'] as String? ?? '';
                                final isUsed =
                                    card['is_used'] as bool? ?? false;
                                final courseMap =
                                    card['courses'] as Map<String, dynamic>?;
                                final courseTitle = courseMap?['title'] ??
                                    'جميع كورسات المدرس';
                                final studentMap =
                                    card['students'] as Map<String, dynamic>?;
                                final userMap = studentMap?['users']
                                    as Map<String, dynamic>?;
                                final studentName =
                                    userMap?['full_name'] as String?;

                                return ChalkCard(
                                  padding: EdgeInsets.all(14.r),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.vpn_key_rounded,
                                                color: isUsed
                                                    ? ChalkboardColors
                                                        .chalkSoft
                                                    : ChalkboardColors.accent,
                                                size: 18.r,
                                              ),
                                              SizedBox(width: 8.w),
                                              SelectableText(
                                                code,
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.w900,
                                                  color: ChalkboardColors.ink,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isUsed
                                                  ? ChalkboardColors.chalkYellow
                                                      .withAlpha(40)
                                                  : ChalkboardColors.accent
                                                      .withAlpha(40),
                                              borderRadius:
                                                  BorderRadius.circular(6.r),
                                              border: Border.all(
                                                color: isUsed
                                                    ? ChalkboardColors.chalkYellow
                                                    : ChalkboardColors.accent,
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              isUsed ? 'تم الاستخدام' : 'متاح',
                                              style: GoogleFonts.cairo(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w800,
                                                color: isUsed
                                                    ? ChalkboardColors
                                                        .chalkYellow
                                                    : ChalkboardColors.accent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 8.h),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.menu_book_rounded,
                                            size: 14.r,
                                            color: ChalkboardColors.chalkSoft,
                                          ),
                                          SizedBox(width: 4.w),
                                          Expanded(
                                            child: Text(
                                              courseTitle,
                                              style: ChalkboardText.note(11.sp),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),

                                      if (isUsed && studentName != null) ...[
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.person_outline_rounded,
                                              size: 14.r,
                                              color: ChalkboardColors.chalkYellow,
                                            ),
                                            SizedBox(width: 4.w),
                                            Text(
                                              'استخدمه الطالب: $studentName',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11.sp,
                                                color: ChalkboardColors
                                                    .chalkYellow,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],

                                      SizedBox(height: 10.h),
                                      Divider(
                                        color:
                                            ChalkboardColors.ink.withAlpha(30),
                                        height: 1,
                                      ),
                                      SizedBox(height: 8.h),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  Icons.copy_rounded,
                                                  color: ChalkboardColors.accent,
                                                  size: 18.r,
                                                ),
                                                tooltip: 'نسخ الكود',
                                                onPressed: () =>
                                                    _copyCode(code),
                                              ),
                                            ],
                                          ),
                                          if (!isUsed)
                                            IconButton(
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                color:
                                                    ChalkboardColors.chalkRed,
                                                size: 18.r,
                                              ),
                                              tooltip: 'حذف الكرت',
                                              onPressed: () => _confirmDelete(
                                                card['id'] as String,
                                                code,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: ChalkboardColors.accent,
            onPressed: _showGenerateModal,
            icon: Icon(
              Icons.add_card_rounded,
              color: ChalkboardColors.onAccent,
            ),
            label: Text(
              'إنشاء كروت تفعيل',
              style: GoogleFonts.cairo(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: ChalkboardColors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: ChalkboardText.note(10.sp),
        ),
      ],
    );
  }

  Widget _buildFilterTab({
    required int index,
    required String label,
  }) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedFilter = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? ChalkboardColors.accent.withAlpha(35)
                : ChalkboardColors.groundDeep,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected
                  ? ChalkboardColors.accent
                  : ChalkboardColors.ink.withAlpha(40),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected
                  ? ChalkboardColors.accent
                  : ChalkboardColors.chalkSoft,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
