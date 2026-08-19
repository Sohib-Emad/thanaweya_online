import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Grade filter chips row with 'All', 'First', 'Second', 'Third' options.
class StudentGradeFilter extends StatelessWidget {
  final List<({String label, String value})> filters;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const StudentGradeFilter({
    super.key,
    required this.filters,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final selected = selectedValue == filter.value;
          return Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(filter.value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF0284C7) : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: selected ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: selected
                      ? [BoxShadow(
                          color: const Color(0xFF0284C7).withAlpha(40),
                          blurRadius: 6, offset: const Offset(0, 2),
                        )]
                      : null,
                ),
                child: Text(
                  filter.label,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5.sp,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
