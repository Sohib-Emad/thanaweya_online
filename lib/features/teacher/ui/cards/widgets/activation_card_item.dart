import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Single activation card display with code, course, status, and actions.
class ActivationCardItem extends StatelessWidget {
  final String code;
  final bool isUsed;
  final String courseTitle;
  final String? studentName;
  final VoidCallback onCopy;
  final VoidCallback? onDelete;

  const ActivationCardItem({
    super.key,
    required this.code,
    required this.isUsed,
    required this.courseTitle,
    this.studentName,
    required this.onCopy,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return DeskCard(
      padding: EdgeInsets.all(14.r),
      accent: isUsed ? DeskColors.accent : DeskColors.success,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.vpn_key_rounded,
                    color: isUsed ? DeskColors.muted : DeskColors.success,
                    size: 18.r,
                  ),
                  SizedBox(width: 8.w),
                  SelectableText(
                    code,
                    style: GoogleFonts.robotoMono(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: DeskColors.ink,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              DeskStatusChip(
                label: isUsed ? 'تم الاستخدام' : 'متاح',
                color: isUsed ? DeskColors.accent : DeskColors.success,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 14.r,
                color: DeskColors.muted,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  courseTitle,
                  style: DeskText.note(11.sp),
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
                  color: DeskColors.accent,
                ),
                SizedBox(width: 4.w),
                Text(
                  'استخدمه الطالب: $studentName',
                  style: GoogleFonts.cairo(
                    fontSize: 11.sp,
                    color: DeskColors.accent,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 10.h),
          Divider(color: DeskColors.line, height: 1),
          SizedBox(height: 6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DeskIconAction(
                icon: Icons.copy_rounded,
                color: DeskColors.primary,
                tooltip: 'نسخ الكود',
                onTap: onCopy,
              ),
              if (!isUsed)
                DeskIconAction(
                  icon: Icons.delete_outline_rounded,
                  color: DeskColors.danger,
                  tooltip: 'حذف الكرت',
                  onTap: onDelete ?? () {},
                ),
            ],
          ),
        ],
      ),
    );
  }
}
