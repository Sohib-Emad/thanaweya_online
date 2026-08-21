import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thanaweya_online/core/services/student_realtime_service.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/student/data/repos/student_leaderboard_repo.dart';
import 'package:thanaweya_online/features/student/logic/student_leaderboard_cubit.dart';
import 'widgets/widgets.dart';

/// Screen showcasing student leaderboards, top 3 podium, and gamified ranking stats.
class StudentLeaderboardScreen extends StatefulWidget {
  final bool isSelected;

  const StudentLeaderboardScreen({super.key, this.isSelected = false});

  @override
  State<StudentLeaderboardScreen> createState() =>
      _StudentLeaderboardScreenState();
}

class _StudentLeaderboardScreenState extends State<StudentLeaderboardScreen> {
  late final StudentLeaderboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = StudentLeaderboardCubit(repo: StudentLeaderboardRepo());
    _cubit.loadLeaderboard();

    StudentRealtimeService.instance.addPointsListener(_onRealtimePoints);
  }

  void _onRealtimePoints() {
    if (!mounted) return;
    _cubit.loadLeaderboard();
  }

  @override
  void didUpdateWidget(covariant StudentLeaderboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _cubit.loadLeaderboard();
    }
  }

  @override
  void dispose() {
    StudentRealtimeService.instance.removePointsListener(_onRealtimePoints);
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: NotebookColors.ground,
        appBar: const NotebookTopBar(
          title: 'لوحة المتفوقين',
          subtitle: 'أوائل طلاب الثانوية أونلاين',
          automaticallyImplyBack: false,
        ),
        body: BlocBuilder<StudentLeaderboardCubit, StudentLeaderboardState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: _buildBody(context, state, currentUserId),
                ),
                if (state.hasPoints)
                  MyRankBadge(myEntry: state.myEntry),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    StudentLeaderboardState state,
    String? currentUserId,
  ) {
    if (state.status == LeaderboardStatus.loading && state.entries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0284C7)),
      );
    }

    if (state.status == LeaderboardStatus.error && state.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48.r, color: const Color(0xFFE11D48)),
            SizedBox(height: 12.h),
            Text(
              state.errorMessage ?? 'تعذر تحميل لوحة المتفوقين',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 8.h),
            ElevatedButton(
              onPressed: () => _cubit.loadLeaderboard(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If no entries at all, show empty state
    if (state.entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _cubit.loadLeaderboard(),
        color: const Color(0xFF0284C7),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 120.h),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(22.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.emoji_events_outlined,
                        size: 58.r,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'لا يوجد متفوقين بعد',
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'شاهد الدروس واجتز الامتحانات واجمع النقاط لتكون أول المتصدرين في لوحة الشرف! 🏆',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5.sp,
                        color: const Color(0xFF64748B),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final topThree = state.topThree;
    final rest = state.restOfLeaderboard;

    return RefreshIndicator(
      onRefresh: () async => _cubit.loadLeaderboard(),
      color: const Color(0xFF0284C7),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20.h),
        children: [
          if (topThree.isNotEmpty)
            PodiumSection(topThree: topThree),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_list_numbered_rounded,
                        size: 16.r, color: const Color(0xFF64748B)),
                    SizedBox(width: 6.w),
                    Text(
                      'ترتيب طلاب المنصة',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${state.entries.length} طالب',
                  style: GoogleFonts.cairo(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          if (rest.isNotEmpty)
            ...rest.map(
              (entry) => LeaderboardTile(
                entry: entry,
                isCurrentUser: entry.studentId == currentUserId,
              ),
            ),
        ],
      ),
    );
  }
}
