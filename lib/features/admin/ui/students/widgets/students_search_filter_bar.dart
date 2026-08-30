import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';

class StudentsSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final List<Map<String, dynamic>> teachers;
  final String? selectedTeacherId;
  final ValueChanged<String?> onTeacherSelected;
  final int totalCount;

  const StudentsSearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.teachers,
    required this.selectedTeacherId,
    required this.onTeacherSelected,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
      child: Column(
        children: [
          TextField(
            controller: searchController, onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'ابحث بالاسم، هاتف الطالب، أو ولي الأمر...',
              hintStyle: GoogleFonts.cairo(fontSize: 12.5.sp, color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: searchController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () { searchController.clear(); onSearchChanged(''); }) : null,
              filled: true, fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.filter_list_rounded, size: 18.r, color: AppColors.adminPrimary),
              SizedBox(width: 6.w),
              Text('المعلم:', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              SizedBox(width: 8.w),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('جميع المعلمين'), selected: selectedTeacherId == null,
                        selectedColor: AppColors.adminPrimary, backgroundColor: AppColors.background, showCheckmark: false,
                        labelStyle: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: selectedTeacherId == null ? FontWeight.w800 : FontWeight.w600, color: selectedTeacherId == null ? Colors.white : AppColors.textPrimary),
                        onSelected: (_) => onTeacherSelected(null),
                      ),
                      ...teachers.map((t) {
                        final tid = t['id'] as String? ?? '', isSel = selectedTeacherId == tid;
                        return Padding(
                          padding: EdgeInsets.only(right: 6.w),
                          child: ChoiceChip(
                            label: Text((t['users'] as Map<String, dynamic>?)?['full_name'] as String? ?? 'معلم'), selected: isSel,
                            selectedColor: AppColors.adminPrimary, backgroundColor: AppColors.background, showCheckmark: false,
                            labelStyle: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, color: isSel ? Colors.white : AppColors.textPrimary),
                            onSelected: (s) => onTeacherSelected(s ? tid : null),
                          ),
                        );
                      }),
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
              Text('إجمالي الطلاب: $totalCount', style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.adminPrimary)),
              if (selectedTeacherId != null)
                GestureDetector(
                  onTap: () => onTeacherSelected(null),
                  child: Row(children: [
                    Icon(Icons.close_rounded, size: 14.r, color: AppColors.error), SizedBox(width: 2.w),
                    Text('إلغاء فلتر المعلم', style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.error, fontWeight: FontWeight.w700)),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
