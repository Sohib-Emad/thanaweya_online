import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_comments_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_comments_cubit.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

import 'widgets/widgets.dart';

/// Screen for viewing and posting comments on a lesson.
class LessonCommentsScreen extends StatefulWidget {
  /// Creates a [LessonCommentsScreen].
  const LessonCommentsScreen({super.key, required this.lessonId});

  /// The ID of the lesson to display comments for.
  final String lessonId;

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
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.commentsTitle,
        subtitle: l10n.commentsSubtitle,
      ),
      body: NotebookPaper(
        child: BlocBuilder<StudentCommentsCubit, StudentCommentsState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                Expanded(child: _buildList(context, state)),
                CommentInputBar(
                  controller: _commentController,
                  hint: l10n.commentHint,
                  onSend: _addComment,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, StudentCommentsState state) {
    final l10n = context.l10n;
    if (state.status == StudentCommentsStatus.loading &&
        state.comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.comments.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(24.w),
        child: NotebookEmptyNote(
          icon: Icons.chat_bubble_outline_rounded,
          message: l10n.noCommentsYet,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _cubit.loadComments(widget.lessonId),
      color: NotebookColors.green,
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
        itemCount: state.comments.length,
        itemBuilder: (context, index) {
          final comment = state.comments[index];
          final user = (comment['users'] as Map<String, dynamic>?) ?? {};
          final name = (user['full_name'] as String?) ?? '';
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CommentTile(
              name: name,
              text: (comment['text'] as String?) ?? '',
            ),
          );
        },
      ),
    );
  }
}
