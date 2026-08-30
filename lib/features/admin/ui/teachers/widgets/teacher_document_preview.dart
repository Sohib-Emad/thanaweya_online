import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/constants/app_text_styles.dart';

class TeacherDocumentPreview extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double height;

  const TeacherDocumentPreview({
    super.key,
    required this.title,
    required this.imageUrl,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: height.h,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: height.h,
              color: Colors.grey.shade100,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => Container(
              height: 100.h,
              color: Colors.grey.shade100,
              child: Center(child: Text('تعذر تحميل $title')),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
