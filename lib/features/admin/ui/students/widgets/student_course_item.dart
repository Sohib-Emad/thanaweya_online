import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class StudentCourseItem extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isProcessing;
  final VoidCallback onToggleAccess;

  const StudentCourseItem({
    super.key,
    required this.course,
    required this.isProcessing,
    required this.onToggleAccess,
  });

  @override
  Widget build(BuildContext context) {
    final title = course['title'] as String? ?? 'كورس تعليمي';
    final coverUrl = course['cover_image_url'] as String? ?? '';
    final price = course['price'];
    final isUnlocked = course['is_unlocked'] == true;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF16A34A).withValues(alpha: 0.5) : AppColors.cardBorder,
          width: isUnlocked ? 1.5 : 1,
        ),
        boxShadow: [BoxShadow(color: (isUnlocked ? const Color(0xFF16A34A) : Colors.black).withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 52.r, height: 52.r, clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: isUnlocked ? const Color(0xFFDCFCE7) : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12.r)),
            child: coverUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: coverUrl, fit: BoxFit.cover,
                    placeholder: (_, _) => const Center(child: CircularProgressIndicator(color: Color(0xFF16A34A), strokeWidth: 2)),
                    errorWidget: (_, _, _) => Icon(Icons.menu_book_rounded, color: isUnlocked ? const Color(0xFF16A34A) : AppColors.textTertiary, size: 26.r),
                  )
                : Icon(Icons.menu_book_rounded, color: isUnlocked ? const Color(0xFF16A34A) : AppColors.textTertiary, size: 26.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Wrap(
                  spacing: 8.w, runSpacing: 4.h, crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(color: isUnlocked ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6.r)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded, size: 12.r, color: isUnlocked ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
                          SizedBox(width: 4.w),
                          Text(isUnlocked ? 'مفتوح للطالب' : 'مغلق', style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w800, color: isUnlocked ? const Color(0xFF16A34A) : const Color(0xFFDC2626))),
                        ],
                      ),
                    ),
                    if (price != null) Text('$price ج.م', style: GoogleFonts.cairo(fontSize: 11.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          isProcessing
              ? SizedBox(width: 32.r, height: 32.r, child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)))
              : ElevatedButton.icon(
                  onPressed: onToggleAccess,
                  icon: Icon(isUnlocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 15.r),
                  label: Text(isUnlocked ? 'قفل الكورس' : 'فتح الكورس', style: GoogleFonts.cairo(fontSize: 11.5.sp, fontWeight: FontWeight.w800)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isUnlocked ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    minimumSize: Size.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
        ],
      ),
    );
  }
}
