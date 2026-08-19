import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Confirmation dialog shown before granting extra lesson views.
/// Returns `true` if the teacher confirms, `false`/`null` otherwise.
class GrantViewsDialog extends StatelessWidget {
  final String lessonTitle;
  final int currentViewCount;

  const GrantViewsDialog({
    super.key,
    required this.lessonTitle,
    required this.currentViewCount,
  });

  /// Shows the dialog and returns whether the teacher confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String lessonTitle,
    required int currentViewCount,
  }) async {
    HapticFeedback.lightImpact();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => GrantViewsDialog(
        lessonTitle: lessonTitle,
        currentViewCount: currentViewCount,
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Row(
        children: [
          Icon(Icons.video_library_rounded, color: const Color(0xFF0284C7), size: 22.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'تجديد مشاهدات الحصة',
              style: GoogleFonts.cairo(
                  fontSize: 15.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الدرس: $lessonTitle',
              style: GoogleFonts.cairo(
                  fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7))),
          SizedBox(height: 6.h),
          Text(
            'شاهد الطالب هذه الحصة $currentViewCount مرات من أصل 5 مرات مسموحة.\n'
            'هل ترغب في إعادة ضبط العداد ومنح الطالب 5 مشاهدات جديدة؟',
            style: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF475569)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('إلغاء',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          icon: Icon(Icons.refresh_rounded, size: 16.r),
          label: Text('منح 5 مشاهدات جديدة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12.sp)),
        ),
      ],
    );
  }
}
