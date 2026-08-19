import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// A single lesson progress row showing title, watch status, view count badge,
/// and an optional "grant extra views" button.
class ProgressRow extends StatelessWidget {
  final Map<String, dynamic> row;
  final VoidCallback? onGrantViews;

  const ProgressRow({super.key, required this.row, this.onGrantViews});

  @override
  Widget build(BuildContext context) {
    final title = row['title'] as String? ?? 'درس';
    final completed = row['is_completed'] == true;
    final watched = (row['watched_seconds'] as num?)?.toInt() ?? 0;
    final duration = (row['duration_seconds'] as num?)?.toInt() ?? 0;
    final viewCount = (row['view_count'] as num?)?.toInt() ?? 0;
    final maxViews = (row['max_views'] as num?)?.toInt() ?? 5;
    final isExhausted = viewCount >= maxViews;
    final lastWatched = row['last_watched_at'] as String?;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: DeskColors.line.withAlpha(140)))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _statusIcon(completed, watched),
            SizedBox(width: 10.w),
            Expanded(child: _textColumn(completed, watched, duration, title)),
            if (lastWatched != null && lastWatched.isNotEmpty)
              Text(_fmtDate(lastWatched), style: DeskText.note(10.sp)),
          ]),
          SizedBox(height: 6.h),
          Row(children: [
            _viewBadge(isExhausted, viewCount, maxViews),
            const Spacer(),
            if (onGrantViews != null) _grantButton(onGrantViews!),
          ]),
        ],
      ),
    );
  }

  Widget _statusIcon(bool completed, int watched) {
    if (completed) return Icon(Icons.check_circle_rounded, size: 20.r, color: const Color(0xFF059669));
    if (watched > 0) return Icon(Icons.timelapse_rounded, size: 20.r, color: const Color(0xFF0284C7));
    return Icon(Icons.radio_button_unchecked_rounded, size: 20.r, color: DeskColors.faint);
  }

  Widget _textColumn(bool completed, int watched, int duration, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: DeskText.body(13.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: 2.h),
        Text(_progressText(completed, watched, duration),
            style: GoogleFonts.cairo(
              fontSize: 10.5.sp,
              fontWeight: completed || watched > 0 ? FontWeight.w700 : FontWeight.w500,
              color: completed ? const Color(0xFF059669) : watched > 0 ? const Color(0xFF0284C7) : DeskColors.muted,
            )),
      ],
    );
  }

  String _progressText(bool completed, int watched, int duration) {
    if (completed) return '✅ تم إكمال المحاضرة بنجاح (100%)';
    if (watched <= 0) return '⚪ لم يبدأ المشاهدة بعد';
    final wMin = (watched / 60).ceil();
    final tMin = (duration / 60).ceil();
    if (tMin > 0 && tMin >= wMin) {
      final rem = tMin - wMin;
      final pct = ((watched / duration) * 100).round();
      return '⏳ سمع $wMin د من $tMin د • متبقي $rem د ($pct%)';
    }
    final m = watched ~/ 60;
    final s = watched % 60;
    return '⏳ سمع ${m > 0 ? '$m د ' : ''}${s > 0 ? '$s ث' : ''}';
  }

  Widget _viewBadge(bool exhausted, int count, int max) {
    final color = exhausted ? const Color(0xFFEF4444) : const Color(0xFF0284C7);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Text(
        exhausted ? '⚠️ استنفد المشاهدات ($count / $max)' : '👀 المشاهدات: $count / $max',
        style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w700,
            color: exhausted ? const Color(0xFFB91C1C) : const Color(0xFF0284C7)),
      ),
    );
  }

  Widget _grantButton(VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withAlpha(15),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFF059669).withAlpha(50)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.add_circle_outline_rounded, size: 13.r, color: const Color(0xFF059669)),
          SizedBox(width: 4.w),
          Text('زيادة المشاهدات',
              style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF059669))),
        ]),
      ),
    );
  }

  String _fmtDate(String iso) {
    try { final d = DateTime.parse(iso); return '${d.day}/${d.month}/${d.year}'; }
    catch (_) { return iso; }
  }
}
