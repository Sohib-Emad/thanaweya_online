import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_text_styles.dart';

/// Generic empty or error state with icon and message.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String message;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56.r, color: iconColor),
          SizedBox(height: 16.h),
          Text(message, style: AppTextStyles.body2),
        ],
      ),
    );
  }
}
