import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_bookmarks_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_bookmarks_cubit.dart';

import '../../../../core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'widgets/bookmark_category_bar.dart';
import 'widgets/bookmark_course_card.dart';

class MyBookmarksScreen extends StatefulWidget {
  const MyBookmarksScreen({super.key});

  @override
  State<MyBookmarksScreen> createState() => _MyBookmarksScreenState();
}

class _MyBookmarksScreenState extends State<MyBookmarksScreen> {
  int _selectedCategoryIndex = 1;
  String _userId = '';
  final _cubit = StudentBookmarksCubit(repo: StudentBookmarksRepo());

  static const _categories = ['الكل', 'الفيزياء', 'الرياضيات', 'الأحياء', 'الكيمياء'];

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_userId.isNotEmpty) _cubit.loadBookmarks(_userId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _removeBookmark(String courseId) async {
    if (_userId.isEmpty) return;
    HapticFeedback.selectionClick();
    await _cubit.checkBookmarked(_userId, courseId);
    await _cubit.toggleBookmark(_userId, courseId);
    await _cubit.loadBookmarks(_userId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(title: l10n.bookmarksTitle, subtitle: l10n.bookmarksSubtitle),
      body: NotebookPaper(
        child: Column(
          children: [
            SizedBox(height: 14.h),
            BookmarkCategoryBar(
              categories: _categories,
              selectedIndex: _selectedCategoryIndex,
              onSelected: (i) => setState(() => _selectedCategoryIndex = i),
            ),
            SizedBox(height: 16.h),
            Expanded(child: _buildBookmarksList(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarksList(AppLocalizations l10n) {
    return BlocBuilder<StudentBookmarksCubit, StudentBookmarksState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state.status == StudentBookmarksStatus.loading && state.bookmarks.isEmpty) {
          return Center(child: CircularProgressIndicator(color: NotebookColors.green));
        }
        if (state.status == StudentBookmarksStatus.error && state.bookmarks.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: NotebookEmptyNote(icon: Icons.error_outline_rounded, message: state.errorMessage ?? l10n.loadBookmarksError),
          );
        }
        if (state.bookmarks.isEmpty) {
          return RefreshIndicator(
            color: NotebookColors.green,
            onRefresh: () async {
              if (_userId.isNotEmpty) await _cubit.loadBookmarks(_userId);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: NotebookEmptyNote(icon: Icons.bookmark_border_rounded, message: l10n.noBookmarks),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: NotebookColors.green,
          onRefresh: () async {
            if (_userId.isNotEmpty) await _cubit.loadBookmarks(_userId);
          },
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: state.bookmarks.length,
            separatorBuilder: (_, _) => SizedBox(height: 14.h),
            itemBuilder: (context, index) {
              final bookmark = state.bookmarks[index];
              final course = bookmark['courses'] as Map<String, dynamic>? ?? {};
              final teachers = course['teachers'] as Map<String, dynamic>? ?? {};
              final users = teachers['users'] as Map<String, dynamic>? ?? {};
              final subjects = teachers['subjects'] as Map<String, dynamic>? ?? {};
              final courseId = course['id'] as String? ?? '';
              return BookmarkCourseCard(
                title: course['title'] as String? ?? '',
                subject: subjects['name_ar'] as String? ?? '',
                teacherName: users['full_name'] as String? ?? '',
                coverUrl: course['cover_image_url'] as String? ?? '',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, AppRouter.studentCourseDetails, arguments: course);
                },
                onRemoveBookmark: () => _removeBookmark(courseId),
              );
            },
          ),
        );
      },
    );
  }
}
