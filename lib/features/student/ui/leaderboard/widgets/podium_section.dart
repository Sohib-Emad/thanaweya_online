import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/student/data/repos/student_leaderboard_repo.dart';

/// Renders the top 3 podium for the student leaderboard with gold, silver, and bronze styling.
class PodiumSection extends StatelessWidget {
  final List<LeaderboardEntry> topThree;

  const PodiumSection({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withAlpha(40),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: const Color(0xFFF59E0B), size: 20.r),
                SizedBox(width: 6.w),
                Text(
                  'لوحة شرف الثانوية أونلاين',
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF8FAFC),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 2nd Place (Silver)
                if (second != null)
                  Expanded(
                    child: _buildPodiumItem(
                      entry: second,
                      rank: 2,
                      pedestalHeight: 85.h,
                      avatarSize: 52.r,
                      accentColor: const Color(0xFF94A3B8),
                      crownIcon: '🥈',
                    ),
                  )
                else
                  const Spacer(),

                SizedBox(width: 8.w),

                // 1st Place (Gold)
                if (first != null)
                  Expanded(
                    child: _buildPodiumItem(
                      entry: first,
                      rank: 1,
                      pedestalHeight: 110.h,
                      avatarSize: 66.r,
                      accentColor: const Color(0xFFF59E0B),
                      crownIcon: '👑',
                      isWinner: true,
                    ),
                  )
                else
                  const Spacer(),

                SizedBox(width: 8.w),

                // 3rd Place (Bronze)
                if (third != null)
                  Expanded(
                    child: _buildPodiumItem(
                      entry: third,
                      rank: 3,
                      pedestalHeight: 65.h,
                      avatarSize: 48.r,
                      accentColor: const Color(0xFFD97706),
                      crownIcon: '🥉',
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumItem({
    required LeaderboardEntry entry,
    required int rank,
    required double pedestalHeight,
    required double avatarSize,
    required Color accentColor,
    required String crownIcon,
    bool isWinner = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Crown / Medal emoji
        Text(crownIcon, style: TextStyle(fontSize: isWinner ? 22.sp : 16.sp)),
        SizedBox(height: 2.h),

        // Avatar with glowing ring
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: accentColor, width: isWinner ? 3 : 2),
            boxShadow: [
              if (isWinner)
                BoxShadow(
                  color: accentColor.withAlpha(90),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
            ],
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
        SizedBox(height: 6.h),

        // Name
        Text(
          entry.fullName,
          style: GoogleFonts.cairo(
            fontSize: isWinner ? 12.sp : 10.5.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),

        // Teacher Name
        if (entry.teacherName != null && entry.teacherName!.isNotEmpty) ...[
          Text(
            entry.teacherName!,
            style: GoogleFonts.cairo(
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],

        // Points
        Container(
          margin: EdgeInsets.only(top: 2.h, bottom: 6.h),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(30),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            '${entry.totalScore} نقطة',
            style: GoogleFonts.cairo(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
          ),
        ),

        // Pedestal
        Container(
          height: pedestalHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: accentColor.withAlpha(25),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            border: Border.all(
              color: accentColor.withAlpha(80),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: GoogleFonts.cairo(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar(String name) {
    final initial = name.isNotEmpty ? name.characters.first : 'ط';
    return Container(
      color: const Color(0xFF334155),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.cairo(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
