import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'teacher_signature_card.dart';

/// A horizontal list of top teacher signature cards.
class TopTeachersList extends StatelessWidget {
  /// Creates a [TopTeachersList].
  const TopTeachersList({super.key, required this.teachers});

  /// The list of teacher data maps (keys: id, name, subject, avatarUrl).
  final List<Map<String, dynamic>> teachers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: teachers.length,
        separatorBuilder: (_, _) => SizedBox(width: 18.w),
        itemBuilder: (context, index) {
          final t = teachers[index];
          return TeacherSignatureCard(
            id: t['id'] as String,
            name: t['name'] as String,
            subject: t['subject'] as String,
            avatarUrl: t['avatarUrl'] as String?,
          );
        },
      ),
    );
  }
}
