import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';

class AdminCodesFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<Map<String, dynamic>> teachers;
  final String? selectedTeacherId;
  final ValueChanged<String?> onTeacherSelected;
  final List<Map<String, dynamic>> courses;
  final String? selectedCourseId;
  final ValueChanged<String?> onCourseSelected;
  final int totalCount;
  final VoidCallback onOpenGenerate;
  final VoidCallback onPrintAll;

  const AdminCodesFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.teachers,
    required this.selectedTeacherId,
    required this.onTeacherSelected,
    required this.courses,
    required this.selectedCourseId,
    required this.onCourseSelected,
    required this.totalCount,
    required this.onOpenGenerate,
    required this.onPrintAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'ابحث بالكود أو اسم المدرس أو الكورس...',
              hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.person_pin_rounded, size: 18.r, color: AppColors.adminPrimary),
              SizedBox(width: 6.w),
              Text('المعلم:', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              SizedBox(width: 8.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('جميع المعلمين'),
                        selected: selectedTeacherId == null,
                        selectedColor: AppColors.adminPrimary,
                        backgroundColor: AppColors.background,
                        showCheckmark: false,
                        labelStyle: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: selectedTeacherId == null ? FontWeight.w800 : FontWeight.w600,
                          color: selectedTeacherId == null ? Colors.white : AppColors.textPrimary,
                        ),
                        onSelected: (_) => onTeacherSelected(null),
                      ),
                      ...teachers.map((t) => Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: ChoiceChip(
                              label: Text((t['users'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'معلم'),
                              selected: selectedTeacherId == (t['id'] as String? ?? ''),
                              selectedColor: AppColors.adminPrimary,
                              backgroundColor: AppColors.background,
                              showCheckmark: false,
                              labelStyle: GoogleFonts.cairo(
                                fontSize: 11.sp,
                                fontWeight: selectedTeacherId == t['id'] ? FontWeight.w800 : FontWeight.w600,
                                color: selectedTeacherId == t['id'] ? Colors.white : AppColors.textPrimary,
                              ),
                              onSelected: (s) => onTeacherSelected(s ? t['id'] as String? : null),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأكواد النشطة: $totalCount كود',
                style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800, color: const Color(0xFF16A34A)),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: onPrintAll,
                    borderRadius: BorderRadius.circular(6.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.print_rounded, size: 14, color: Color(0xFF1D4ED8)),
                          SizedBox(width: 4.w),
                          Text(
                            'طباعة A4 (PDF)',
                            style: GoogleFonts.cairo(
                              fontSize: 10.5.sp,
                              color: const Color(0xFF1D4ED8),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: onOpenGenerate,
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline_rounded, size: 15, color: AppColors.adminPrimary),
                        SizedBox(width: 4.w),
                        Text(
                          '+ توليد أكواد',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: AppColors.adminPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
