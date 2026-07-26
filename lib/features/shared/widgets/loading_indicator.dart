import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;

  const LoadingIndicator({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size?.h ?? 32.h,
        width: size?.w ?? 32.w,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color ?? AppColors.studentPrimary,
        ),
      ),
    );
  }
}
