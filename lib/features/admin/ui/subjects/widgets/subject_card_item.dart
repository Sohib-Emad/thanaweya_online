import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/shared/widgets/app_card.dart';

class SubjectCardItem extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onDelete;

  const SubjectCardItem({super.key, required this.subject, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final nameAr = subject['name_ar'] as String? ?? '';

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 40.r, height: 40.r,
            decoration: BoxDecoration(color: AppColors.studentPrimaryLight, borderRadius: BorderRadius.circular(10.r)),
            child: Icon(Icons.menu_book_outlined, color: AppColors.studentPrimary, size: 20.r),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Text(nameAr, style: AppTextStyles.h3)),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 20.r, color: AppColors.error),
            onPressed: () {
              HapticFeedback.lightImpact();
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
