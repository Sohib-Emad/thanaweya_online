import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/features/shared/models/course_model.dart';

/// Banner section of the course card with cover image, status badge, menu, and price.
class CourseCardBanner extends StatelessWidget {
  final CourseModel course;
  final bool published;
  final bool hasCover;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublish;

  const CourseCardBanner({
    super.key,
    required this.course,
    required this.published,
    required this.hasCover,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublish,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = published ? const Color(0xFF059669) : const Color(0xFFD97706);
    final priceText = (course.price != null && course.price! > 0) ? '${course.price!.toStringAsFixed(0)} ج.م' : 'مجاني';

    return Stack(
      children: [
        _buildCover(),
        _overlay(),
        _badge(statusColor),
        _menu(context),
        _price(priceText),
      ],
    );
  }

  Widget _buildCover() => Container(
    height: 130.h, width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)], begin: Alignment.topRight, end: Alignment.bottomLeft),
    ),
    child: hasCover
        ? Image.network(course.coverImageUrl!, fit: BoxFit.cover, width: double.infinity, height: 130.h,
            errorBuilder: (_, error, _) { debugPrint('[CourseCard] Cover load failed: $error'); return _fallbackCover(); })
        : _fallbackCover(),
  );

  Widget _overlay() => Positioned.fill(
    child: DecoratedBox(decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Colors.black.withAlpha(20), Colors.transparent, Colors.black.withAlpha(90)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter),
    )),
  );

  Widget _badge(Color color) => Positioned(
    top: 10.r, right: 10.r,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 6)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6.r, height: 6.r, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        SizedBox(width: 5.w),
        Text(published ? 'منشور للطلاب' : 'مسودة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.w800)),
      ]),
    ),
  );

  Widget _menu(BuildContext context) => Positioned(
    top: 8.r, left: 8.r,
    child: Container(
      decoration: BoxDecoration(color: Colors.black.withAlpha(90), shape: BoxShape.circle),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert_rounded, color: Colors.white, size: 18),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        onSelected: (v) { if (v == 'edit') onEdit(); if (v == 'publish') onTogglePublish(); if (v == 'delete') onDelete(); },
        itemBuilder: (_) => [
          _mi('edit', Icons.edit_outlined, const Color(0xFF0284C7), 'تعديل بيانات الكورس'),
          _mi('publish', published ? Icons.visibility_off_outlined : Icons.publish_rounded, published ? const Color(0xFFD97706) : const Color(0xFF059669), published ? 'إلغاء النشر' : 'نشر الكورس'),
          const PopupMenuDivider(),
          _mi('delete', Icons.delete_outline_rounded, const Color(0xFFE11D48), 'حذف الكورس'),
        ],
      ),
    ),
  );

  Widget _price(String text) => Positioned(
    bottom: 10.r, right: 12.r,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 6)]),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.payments_outlined, size: 13.r, color: const Color(0xFF059669)),
        SizedBox(width: 4.w),
        Text(text, style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w900, color: const Color(0xFF059669))),
      ]),
    ),
  );

  Widget _fallbackCover() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.menu_book_rounded, color: Colors.white.withAlpha(220), size: 40.r),
      SizedBox(height: 4.h),
      Text(course.title, style: GoogleFonts.cairo(color: Colors.white.withAlpha(240), fontSize: 13.sp, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );

  PopupMenuItem<String> _mi(String v, IconData i, Color c, String l) => PopupMenuItem(
    value: v,
    child: Row(children: [Icon(i, size: 18, color: c), SizedBox(width: 8.w), Text(l, style: GoogleFonts.cairo(fontSize: 12.sp, fontWeight: FontWeight.w600))]),
  );
}
