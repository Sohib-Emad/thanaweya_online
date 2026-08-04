import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'package:thanaweya_online/core/constants/app_text_styles.dart';
import 'package:thanaweya_online/features/student/data/repos/student_comments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_comments_cubit.dart';

class LessonCommentsScreen extends StatefulWidget {
  final String lessonId;

  const LessonCommentsScreen({super.key, required this.lessonId});

  @override
  State<LessonCommentsScreen> createState() => _LessonCommentsScreenState();
}

class _LessonCommentsScreenState extends State<LessonCommentsScreen> {
  final _cubit = StudentCommentsCubit(repo: StudentCommentsRepo());
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit.loadComments(widget.lessonId);
  }

  @override
  void dispose() {
    _cubit.close();
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      _cubit.addComment(
        lessonId: widget.lessonId,
        authorId: userId,
        text: text,
      );
    }
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التعليقات')),
        body: BlocBuilder<StudentCommentsCubit, StudentCommentsState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                if (state.status == StudentCommentsStatus.loading && state.comments.isEmpty)
                  const Expanded(child: Center(child: CircularProgressIndicator()))
                else if (state.comments.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 64, color: AppColors.textTertiary),
                          SizedBox(height: 16.h),
                          Text('لا توجد تعليقات بعد', style: AppTextStyles.h3),
                          SizedBox(height: 8.h),
                          Text('كن أول من يعلق!', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => _cubit.loadComments(widget.lessonId),
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: state.comments.length,
                        itemBuilder: (context, index) {
                          final comment = state.comments[index];
                          final user = comment['users'] as Map<String, dynamic>? ?? {};
                          final name = user['full_name'] as String? ?? '';
                          final initials = name.isNotEmpty ? name[0] : 'م';

                          return Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16.r,
                                  backgroundColor: AppColors.studentPrimaryLight,
                                  child: Text(initials,
                                      style: TextStyle(
                                          color: AppColors.studentPrimary,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600)),
                                ),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: AppTextStyles.caption),
                                      SizedBox(height: 4.h),
                                      Text(comment['text'] as String? ?? '', style: AppTextStyles.body2),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
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
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: _addComment,
                        icon: Icon(Icons.send_rounded, color: AppColors.studentPrimary, size: 22.r),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
