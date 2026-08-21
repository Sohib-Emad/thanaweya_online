import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/utils/formatters.dart';

/// A banner displaying real-time playback progress.
/// Completion is determined automatically upon reaching 90% watch time.
class LiveProgressBanner extends StatelessWidget {
  const LiveProgressBanner({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.isCompleted,
  });

  final Duration currentPosition;
  final Duration totalDuration;
  final bool isCompleted;

  Color get _accent =>
      isCompleted ? const Color(0xFF059669) : const Color(0xFF0284C7);

  String _label(int pos, int dur, int rem) {
    if (isCompleted) {
      return 'تم إكمال مشاهدة هذه المحاضرة بنجاح 🎉';
    }
    if (dur > 0) {
      return 'شاهدت ${Formatters.formatDuration(pos)} من ${Formatters.formatDuration(dur)} • متبقي ${Formatters.formatDuration(rem)}';
    }
    return 'جاري تسجيل ومتابعة الاستماع للمحاضرة...';
  }

  @override
  Widget build(BuildContext context) {
    final p = currentPosition.inSeconds;
    final d = totalDuration.inSeconds;
    final pct = d > 0 ? (p / d).clamp(0.0, 1.0) : (isCompleted ? 1.0 : 0.0);
    final pctInt = (pct * 100).round();
    final rem = d > p ? d - p : 0;
    final iconColor =
        isCompleted ? const Color(0xFF059669) : const Color(0xFF0F172A);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _accent.withAlpha(isCompleted ? 12 : 10),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _accent.withAlpha(isCompleted ? 40 : 30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_fill_rounded,
                color: _accent,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  _label(p, d, rem),
                  style: GoogleFonts.cairo(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                  ),
                ),
              ),
              if (isCompleted) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withAlpha(25),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFF059669)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 12.r, color: const Color(0xFF059669)),
                      SizedBox(width: 4.w),
                      Text(
                        'مكتمل ✅',
                        style: GoogleFonts.cairo(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
              ],
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '$pctInt%',
                  style: GoogleFonts.cairo(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 5.h,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(_accent),
            ),
          ),
        ],
      ),
    );
  }
}
