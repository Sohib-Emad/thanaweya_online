import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/data/repos/student_bookmarks_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_bookmarks_cubit.dart';

import '../../../../core/router/app_router.dart';

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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF0F172A),
              size: 20.r,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: false,
          title: Text(
            'محفوظاتي (My Bookmarks)',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 14.h),

            // Horizontal Filter Chips
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategoryIndex = index);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF0FA37F)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF0FA37F)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index],
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16.h),

            // Bookmarked Course Cards List
            Expanded(
              child: BlocBuilder<StudentBookmarksCubit, StudentBookmarksState>(
                bloc: _cubit,
                builder: (context, state) {
                  if (state.status == StudentBookmarksStatus.loading &&
                      state.bookmarks.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == StudentBookmarksStatus.error &&
                      state.bookmarks.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Text(
                          state.errorMessage ?? 'حدث خطأ في تحميل المحفوظات',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }
                  if (state.bookmarks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bookmark_border_rounded,
                            size: 64,
                            color: const Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'لا توجد محفوظات بعد',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'اضغط على أيقونة الحفظ لإضافة الكورسات هنا',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.bookmarks.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (context, index) {
                      final bookmark = state.bookmarks[index];
                      final course =
                          bookmark['courses'] as Map<String, dynamic>? ?? {};
                      final teachers =
                          course['teachers'] as Map<String, dynamic>? ?? {};
                      final users =
                          teachers['users'] as Map<String, dynamic>? ?? {};
                      final subjects =
                          teachers['subjects'] as Map<String, dynamic>? ?? {};
                      final courseId = course['id'] as String? ?? '';
                      final title = course['title'] as String? ?? '';
                      final subject = subjects['name_ar'] as String? ?? '';
                      final teacherName = users['full_name'] as String? ?? '';
                      final coverUrl =
                          course['cover_image_url'] as String? ?? '';
                      final accent = const Color(0xFF0FA37F);

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamed(
                            context,
                            AppRouter.studentCourseDetails,
                            arguments: courseId,
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Course Thumbnail Box
                              Container(
                                width: 100.r,
                                height: 100.r,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  color: accent.withAlpha(25),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                child: coverUrl.isNotEmpty
                                    ? Image.network(
                                        coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => Center(
                                              child: Icon(
                                                Icons.play_circle_fill_rounded,
                                                color: accent,
                                                size: 36.r,
                                              ),
                                            ),
                                      )
                                    : Center(
                                        child: Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: accent,
                                          size: 36.r,
                                        ),
                                      ),
                              ),
                              SizedBox(width: 14.w),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            subject,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w700,
                                              color: accent,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _removeBookmark(courseId),
                                          child: Tooltip(
                                            message: 'إزالة',
                                            child: Icon(
                                              Icons.bookmark_rounded,
                                              color: const Color(0xFF0FA37F),
                                              size: 20.r,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      title,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF0F172A),
                                        height: 1.3,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person_rounded,
                                          color: const Color(0xFF64748B),
                                          size: 14.r,
                                        ),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            teacherName,
                                            style: GoogleFonts.cairo(
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                            ),
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
    );
  }
}
