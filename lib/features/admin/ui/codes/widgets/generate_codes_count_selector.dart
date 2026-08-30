import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class GenerateCodesCountSelector extends StatelessWidget {
  final int selectedCount;
  final ValueChanged<int> onSelectCount;

  const GenerateCodesCountSelector({
    super.key,
    required this.selectedCount,
    required this.onSelectCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'عدد الأكواد المراد توليدها:',
          style: GoogleFonts.cairo(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 6.h,
          children: [5, 10, 20, 50, 100].map((itemCount) {
            final isSel = selectedCount == itemCount;
            return ChoiceChip(
              label: Text('$itemCount كود'),
              selected: isSel,
              selectedColor: AppColors.adminPrimary,
              labelStyle: GoogleFonts.cairo(
                color: isSel ? Colors.white : AppColors.textPrimary,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                fontSize: 11.5.sp,
              ),
              onSelected: (val) {
                if (val) onSelectCount(itemCount);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
