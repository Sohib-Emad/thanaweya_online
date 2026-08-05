import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_bookmarks_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_bookmarks_cubit.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/notebook_theme.dart';

class MyBookmarksScreen extends StatefulWidget {
  const MyBookmarksScreen({super.key});

  @override
  State<MyBookmarksScreen> createState() => _MyBookmarksScreenState();
}

class _MyBookmarksScreenState extends State<MyBookmarksScreen> {
  int _selectedCategoryIndex = 1;
  String _userId = '';

  final _cubit = StudentBookmarksCubit(repo: StudentBookmarksRepo());

  final List<String> _categories = [
    'الكل',
    'الفيزياء',
    'الرياضيات',
    'الأحياء',
    'الكيمياء',
  ];

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_userId.isNotEmpty) {
      _cubit.loadBookmarks(_userId);
    }
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: NotebookTopBar(
          title: 'محفوظاتي',
          subtitle: 'كورسات حفظتها للمراجعة',
        ),
        body: NotebookPaper(
          child: Column(
            children: [
              SizedBox(height: 14.h),

              // Horizontal filter chips
              SizedBox(
                height: 36.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  children: List.generate(_categories.length, (index) {
                    return NotebookChip(
                      label: _categories[index],
                      selected: _selectedCategoryIndex == index,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategoryIndex = index);
                      },
                    );
                  }),
                ),
              ),

              SizedBox(height: 16.h),

              // Bookmarked Course Cards List
              Expanded(
                child: BlocBuilder<StudentBookmarksCubit,
                    StudentBookmarksState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    if (state.status == StudentBookmarksStatus.loading &&
                        state.bookmarks.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: NotebookColors.green,
                        ),
                      );
                    }
                    if (state.status == StudentBookmarksStatus.error &&
                        state.bookmarks.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(24.w),
                        child: NotebookEmptyNote(
                          icon: Icons.error_outline_rounded,
                          message:
                              state.errorMessage ?? 'حدث خطأ في تحميل المحفوظات',
                        ),
                      );
                    }
                    if (state.bookmarks.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: NotebookEmptyNote(
                          icon: Icons.bookmark_border_rounded,
                          message: 'لا توجد محفوظات بعد\nاضغط على أيقونة الحفظ لإضافة الكورسات هنا',
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: state.bookmarks.length,
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (context, index) {
                        final bookmark = state.bookmarks[index];
                        final course =
                            bookmark['courses']
                                as Map<String, dynamic>? ??
                            {};
                        final teachers =
                            course['teachers']
                                as Map<String, dynamic>? ??
                            {};
                        final users =
                            teachers['users'] as Map<String, dynamic>? ?? {};
                        final subjects =
                            teachers['subjects'] as Map<String, dynamic>? ?? {};
                        final courseId = course['id'] as String? ?? '';
                        final title = course['title'] as String? ?? '';
                        final subject = subjects['name_ar'] as String? ?? '';
                        final teacherName =
                            users['full_name'] as String? ?? '';
                        final coverUrl =
                            course['cover_image_url'] as String? ?? '';
                        final accent = NotebookColors.green;

                        return NotebookCard(
                          ruled: true,
                          ruledStartY: 116,
                          marginTab: true,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamed(
                              context,
                              AppRouter.studentCourseDetails,
                              arguments: courseId,
                            );
                          },
                          child: Row(
                            children: [
                              // Course cover box
                              Container(
                                width: 96.r,
                                height: 96.r,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: accent.withAlpha(22),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(
                                    color: accent.withAlpha(90),
                                    width: 1.2,
                                  ),
                                ),
                                child: coverUrl.isNotEmpty
                                    ? Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _coverFallback(accent),
                                      )
                                    : _coverFallback(accent),
                              ),
                              SizedBox(width: 14.w),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (subject.isNotEmpty)
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 3.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: NotebookColors.green,
                                              borderRadius:
                                                  BorderRadius.circular(4.r),
                                            ),
                                            child: Text(
                                              subject,
                                              style: GoogleFonts.cairo(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        GestureDetector(
                                          onTap: () =>
                                              _removeBookmark(courseId),
                                          child: Tooltip(
                                            message: 'إزالة',
                                            child: Icon(
                                              Icons.bookmark_rounded,
                                              color: NotebookColors.green,
                                              size: 20.r,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6.h),
                                    Text(
                                      title,
                                      style: NotebookText.heading(13.sp),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          color: NotebookColors.pencil,
                                          size: 14.r,
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            teacherName,
                                            style: NotebookText.note(11.sp),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _coverFallback(Color accent) {
    return Center(
      child: Icon(
        Icons.play_circle_fill_rounded,
        color: accent,
        size: 36.r,
      ),
    );
  }
}
