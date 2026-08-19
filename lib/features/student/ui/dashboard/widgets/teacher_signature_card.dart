import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A single teacher's signature card showing avatar, name, and subject.
class TeacherSignatureCard extends StatelessWidget {
  /// Creates a [TeacherSignatureCard].
  const TeacherSignatureCard({
    super.key,
    required this.id,
    required this.name,
    required this.subject,
    this.avatarUrl,
  });

  /// The teacher's unique identifier.
  final String id;

  /// The teacher's display name (e.g. 'أ. محمد').
  final String name;

  /// The teacher's subject name in Arabic.
  final String subject;

  /// Optional URL for the teacher's avatar image.
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final firstName = name.replaceAll('أ. ', '').split(' ').first;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.pushNamed(
          context,
          AppRouter.studentTeacherPage,
          arguments: {
            'teacherId': id,
            'title': name,
            'avatarUrl': avatarUrl,
          },
        );
      },
      child: SizedBox(
        width: 72.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NotebookTeacherAvatar(
              avatarUrl: avatarUrl,
              name: name.replaceFirst('أ. ', ''),
              size: 62.r,
            ),
            SizedBox(height: 8.h),
            Text(
              firstName,
              style: NotebookText.strong(12.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Container(
              width: 34.w,
              height: 2.h,
              color: NotebookColors.marginRed.withAlpha(160),
            ),
            if (subject.isNotEmpty) ...[
              SizedBox(height: 3.h),
              Text(
                subject,
                style: NotebookText.note(10.sp),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
