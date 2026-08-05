import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
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
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'التعليقات',
          subtitle: 'ملاحظات الطلاب على الدرس',
        ),
        body: NotebookPaper(
          child: BlocBuilder<StudentCommentsCubit, StudentCommentsState>(
            bloc: _cubit,
            builder: (context, state) {
              return Column(
                children: [
                  if (state.status == StudentCommentsStatus.loading &&
                      state.comments.isEmpty)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state.comments.isEmpty)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: NotebookEmptyNote(
                          icon: Icons.chat_bubble_outline_rounded,
                          message: 'لا توجد تعليقات بعد\nكن أول من يعلق على الدرس',
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _cubit.loadComments(widget.lessonId),
                        color: NotebookColors.green,
                        child: ListView.builder(
                          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
                          itemCount: state.comments.length,
                          itemBuilder: (context, index) {
                            final comment = state.comments[index];
                            final user =
                                comment['users'] as Map<String, dynamic>? ??
                                {};
                            final name = user['full_name'] as String? ?? '';
                            final initials = name.isNotEmpty ? name[0] : 'م';

                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: NotebookCard(
                                ruled: true,
                                ruledStartY: 56,
                                padding: EdgeInsets.all(12.r),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 34.r,
                                      height: 34.r,
                                      decoration: BoxDecoration(
                                        color: NotebookColors.green
                                            .withAlpha(24),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: NotebookColors.green
                                              .withAlpha(90),
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          initials,
                                          style: NotebookText.strong(
                                            12.sp,
                                            color: NotebookColors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name.isNotEmpty ? name : 'مستخدم',
                                            style: NotebookText.strong(11.sp),
                                          ),
                                          SizedBox(height: 3.h),
                                          Text(
                                            comment['text'] as String? ?? '',
                                            style: NotebookText.body(13.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
                    decoration: BoxDecoration(
                      color: NotebookColors.surfaceBright,
                      border: Border(
                        top: BorderSide(color: NotebookColors.ink.withAlpha(50)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            textDirection: TextDirection.rtl,
                            style: NotebookText.body(13.sp),
                            decoration: InputDecoration(
                              hintText: 'اكتب تعليقاً...',
                              hintStyle: NotebookText.note(12.sp),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: NotebookColors.surface,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 10.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: _addComment,
                          child: Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              color: NotebookColors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
