import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';

class ReportStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? badgeColor;

  const ReportStatRow({
    super.key,
    required this.label,
    required this.value,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        if (badgeColor != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(color: badgeColor!.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8.r)),
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w800, color: badgeColor),
            ),
          )
        else
          Text(
            value,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w800),
          ),
      ],
    );
  }
}
