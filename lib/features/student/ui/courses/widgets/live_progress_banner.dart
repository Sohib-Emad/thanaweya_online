import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/core/utils/formatters.dart';

/// A banner displaying real-time playback progress with a completion toggle.
class LiveProgressBanner extends StatelessWidget {
  const LiveProgressBanner({
    super.key,
    required this.currentPosition,
    required this.totalDuration,
    required this.isCompleted,
    required this.onToggleCompleted,
  });

  final Duration currentPosition;
  final Duration totalDuration;
  final bool isCompleted;
  final VoidCallback onToggleCompleted;

  Color get _accent =>
      isCompleted ? const Color(0xFF059669) : const Color(0xFF0284C7);

  String _label(int pos, int dur, int rem) {
    if (isCompleted) return '\u062a\u0645 \u0625\u0643\u0645\u0627\u0644 \u0645\u0634\u0627\u0647\u062f\u0629 \u0647\u0630\u0647 \u0627\u0644\u0645\u062d\u0627\u0636\u0631\u0629 \u0628\u0646\u062c\u0627\u062d \ud83c\udf89';
    if (dur > 0) return '\u0633\u0645\u0639\u062a ${Formatters.formatDuration(pos)} \u0645\u0646 ${Formatters.formatDuration(dur)} \u2022 \u0645\u062a\u0628\u0642\u064a ${Formatters.formatDuration(rem)}';
    return '\u062c\u0627\u0631\u064a \u062a\u0633\u062c\u064a\u0644 \u0648\u0645\u062a\u0627\u0628\u0639\u0629 \u0627\u0644\u0627\u0633\u062a\u0645\u0627\u0639 \u0644\u0644\u0645\u062d\u0627\u0636\u0631\u0629...';
  }

  @override
  Widget build(BuildContext context) {
    final p = currentPosition.inSeconds;
    final d = totalDuration.inSeconds;
    final pct = d > 0 ? (p / d).clamp(0.0, 1.0) : (isCompleted ? 1.0 : 0.0);
    final pctInt = (pct * 100).round();
    final rem = d > p ? d - p : 0;
    final iconColor = isCompleted ? const Color(0xFF059669) : const Color(0xFF0F172A);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _accent.withAlpha(isCompleted ? 12 : 10),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _accent.withAlpha(isCompleted ? 40 : 30)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(isCompleted ? Icons.check_circle_rounded : Icons.play_circle_fill_rounded, color: _accent, size: 18.r),
          SizedBox(width: 8.w),
          Expanded(child: Text(_label(p, d, rem), style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: iconColor))),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(20.r)),
            child: Text('$pctInt%', style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
          SizedBox(width: 8.w),
          _buildToggle(),
        ]),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LinearProgressIndicator(value: pct, minHeight: 5.h, backgroundColor: const Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation<Color>(_accent)),
        ),
      ]),
    );
  }

  Widget _buildToggle() {
    return InkWell(
      onTap: () { HapticFeedback.lightImpact(); onToggleCompleted(); },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFF059669).withAlpha(25) : NotebookColors.surfaceBright,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: isCompleted ? const Color(0xFF059669) : NotebookColors.ink.withAlpha(50)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(isCompleted ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded, size: 13.r, color: isCompleted ? const Color(0xFF059669) : NotebookColors.ink),
          SizedBox(width: 4.w),
          Text(isCompleted ? '\u0645\u0643\u062a\u0645\u0644 \u2705' : '\u062a\u0639\u0644\u064a\u0645 \u0643\u0645\u0643\u062a\u0645\u0644', style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800, color: isCompleted ? const Color(0xFF059669) : NotebookColors.ink)),
        ]),
      ),
    );
  }
}
