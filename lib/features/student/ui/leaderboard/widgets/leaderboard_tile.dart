import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/student/data/repos/student_leaderboard_repo.dart';

/// Clean list tile displaying student rank, avatar, name, teacher name, exams count, and score.
class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasScore = entry.totalScore > 0;
    final isLowScore = entry.totalScore < 30;

    final scoreColor = entry.rank <= 3
        ? const Color(0xFFF59E0B)
        : (hasScore
            ? (isLowScore ? const Color(0xFFD97706) : const Color(0xFF059669))
            : const Color(0xFF94A3B8));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? const Color(0xFF0284C7).withAlpha(15)
            : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF0284C7)
              : const Color(0xFFE2E8F0),
          width: isCurrentUser ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: _rankColor(entry.rank).withAlpha(20),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: _rankColor(entry.rank).withAlpha(80),
              ),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: _rankColor(entry.rank),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),

          // Avatar
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isCurrentUser
                    ? const Color(0xFF0284C7)
                    : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: ClipOval(
              child: entry.avatarUrl != null && entry.avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: entry.avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _defaultAvatar(entry.fullName),
                    )
                  : _defaultAvatar(entry.fullName),
            ),
          ),
          SizedBox(width: 12.w),

          // Name and Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.fullName,
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight:
                              isCurrentUser ? FontWeight.w900 : FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'أنت',
                          style: GoogleFonts.cairo(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),

                // Teacher Name
                Row(
                  children: [
                    Icon(
                      Icons.person_pin_circle_rounded,
                      size: 13.r,
                      color: entry.teacherName != null
                          ? const Color(0xFF0284C7)
                          : const Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        entry.teacherName ?? 'طالب عام بالمنصة',
                        style: GoogleFonts.cairo(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: entry.teacherName != null
                              ? const Color(0xFF0284C7)
                              : const Color(0xFF94A3B8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Exams Completed & Performance Tag
                Row(
                  children: [
                    Icon(Icons.quiz_outlined,
                        size: 11.r, color: const Color(0xFF64748B)),
                    SizedBox(width: 4.w),
                    Text(
                      '${entry.examsCompleted} اختبار',
                      style: GoogleFonts.cairo(
                        fontSize: 10.5.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildPerformanceTag(entry),
                  ],
                ),
              ],
            ),
          ),

          // Score Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: scoreColor.withAlpha(16),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: scoreColor.withAlpha(50),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars_rounded, size: 14.r, color: scoreColor),
                    SizedBox(width: 3.w),
                    Text(
                      '${entry.totalScore}',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'نقطة',
                  style: GoogleFonts.cairo(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceTag(LeaderboardEntry entry) {
    if (entry.rank <= 3) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withAlpha(20),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          'أوائل 🌟',
          style: GoogleFonts.cairo(
            fontSize: 9.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD97706),
          ),
        ),
      );
    }

    if (entry.totalScore >= 50) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withAlpha(20),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          'متميز ⚡',
          style: GoogleFonts.cairo(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF059669),
          ),
        ),
      );
    }

    if (entry.totalScore > 0) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: const Color(0xFF0284C7).withAlpha(20),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          'نشط 🎯',
          style: GoogleFonts.cairo(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0284C7),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0xFF94A3B8).withAlpha(20),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        'بداية المشوار 🚀',
        style: GoogleFonts.cairo(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFF59E0B);
    if (rank == 2) return const Color(0xFF94A3B8);
    if (rank == 3) return const Color(0xFFD97706);
    return const Color(0xFF64748B);
  }

  Widget _defaultAvatar(String name) {
    final initial = name.isNotEmpty ? name.characters.first : 'ط';
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
