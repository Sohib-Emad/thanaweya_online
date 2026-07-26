import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/core/data/mock_data.dart';

class LessonCommentsScreen extends StatefulWidget {
  final String lessonId;

  const LessonCommentsScreen({super.key, required this.lessonId});

  @override
  State<LessonCommentsScreen> createState() => _LessonCommentsScreenState();
}

class _LessonCommentsScreenState extends State<LessonCommentsScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التعليقات')),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: MockData.mockComments.length,
                itemBuilder: (context, index) {
                  final comment = MockData.mockComments[index];
                  final user = comment['users'] as Map<String, dynamic>;
                  final name = user['full_name'] as String;
                  final initials = name.isNotEmpty ? name[0] : 'م';

                  return Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16.r,
                          backgroundColor: AppColors.studentPrimaryLight,
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: AppColors.studentPrimary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.caption),
                              SizedBox(height: 4.h),
                              Text(comment['text'] as String, style: AppTextStyles.body2),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'اكتب تعليقاً...',
                        hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.r),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _commentController.clear();
                    },
                    icon: Icon(Icons.send_rounded,
                        color: AppColors.studentPrimary, size: 22.r),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
