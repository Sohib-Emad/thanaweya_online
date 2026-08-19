import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header widget for courses list with search, filter chips, and stats.
class CourseListHeader extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final int filterIndex;
  final int publishedCount;
  final int draftCount;
  final int totalCount;
  final int filteredCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onFilterChanged;

  const CourseListHeader({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.filterIndex,
    required this.publishedCount,
    required this.draftCount,
    required this.totalCount,
    required this.filteredCount,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _SearchField(controller: searchController, onChanged: onSearchChanged),
        ),
        SizedBox(height: 10.h),
        _FilterChips(
          filterIndex: filterIndex,
          totalCount: totalCount,
          publishedCount: publishedCount,
          draftCount: draftCount,
          onFilterChanged: onFilterChanged,
        ),
        SizedBox(height: 10.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('إجمالي $filteredCount كورس متاح', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
              Text('اضغط على الكورس لإدارة دروسه', style: GoogleFonts.cairo(fontSize: 10.5.sp, color: const Color(0xFF94A3B8))),
            ],
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFF0F172A)),
      decoration: InputDecoration(
        hintText: 'ابحث باسم الكورس أو الوصف...',
        hintStyle: GoogleFonts.cairo(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int filterIndex;
  final int totalCount;
  final int publishedCount;
  final int draftCount;
  final ValueChanged<int> onFilterChanged;

  const _FilterChips({
    required this.filterIndex,
    required this.totalCount,
    required this.publishedCount,
    required this.draftCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          _chip(0, 'الكل ($totalCount)', Icons.grid_view_rounded),
          SizedBox(width: 8.w),
          _chip(1, 'المنشورة ($publishedCount)', Icons.check_circle_outline_rounded),
          SizedBox(width: 8.w),
          _chip(2, 'المسودات ($draftCount)', Icons.edit_note_rounded),
        ],
      ),
    );
  }

  Widget _chip(int index, String label, IconData icon) {
    final isSelected = filterIndex == index;
    return GestureDetector(
      onTap: () => onFilterChanged(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0284C7) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0284C7).withAlpha(30), blurRadius: 8)] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16.r, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            SizedBox(width: 6.w),
            Text(label, style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
