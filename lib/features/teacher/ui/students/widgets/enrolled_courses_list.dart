import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';
import 'package:thanaweya_online/features/teacher/ui/students/students_list_screen.dart'
    show gradeLabelOf;

/// Lists the courses the student is enrolled in, each with a cover thumbnail,
/// stage badge, and per-course lesson completion count.
class EnrolledCoursesList extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> lessons;

  const EnrolledCoursesList({
    super.key,
    required this.courses,
    required this.lessons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: courses.map((c) => _buildTile(c)).toList());
  }

  Widget _buildTile(Map<String, dynamic> c) {
    final title = c['title'] as String? ?? 'كورس';
    final coverUrl = c['cover_image_url'] as String? ?? '';
    final stage = c['stage'] as String? ?? '';
    final cid = c['id'];
    final cl = lessons.where((l) => l['course_id'] == cid).toList();
    final total = cl.length;
    final done = cl.where((l) => l['is_completed'] == true).length;
    final pct = total > 0 ? ((done / total) * 100).round() : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(4), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        _cover(coverUrl),
        SizedBox(width: 12.w),
        Expanded(child: _info(title, stage, total, done, pct)),
        _badge(),
      ]),
    );
  }

  Widget _cover(String url) => Container(
    width: 46.r, height: 46.r, clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: const Color(0xFF0284C7).withAlpha(20), borderRadius: BorderRadius.circular(10.r)),
    child: url.isNotEmpty
        ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _icon())
        : _icon(),
  );

  Icon _icon() => Icon(Icons.menu_book_rounded, color: const Color(0xFF0284C7), size: 22.r);

  Widget _info(String title, String stage, int total, int done, int pct) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.cairo(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: 2.h),
        Row(children: [
          if (stage.isNotEmpty) ...[Text(gradeLabelOf(stage), style: DeskText.note(10.5.sp)), SizedBox(width: 8.w)],
          Text(
            total > 0 ? '$done من $total دروس مكتملة ($pct%)' : 'مشترك في الكورس',
            style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF059669)),
          ),
        ]),
      ],
    );
  }

  Widget _badge() => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(color: const Color(0xFF059669).withAlpha(15), borderRadius: BorderRadius.circular(8.r)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check_circle_rounded, size: 12.r, color: const Color(0xFF059669)),
      SizedBox(width: 4.w),
      Text('مشترك', style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF059669))),
    ]),
  );
}
