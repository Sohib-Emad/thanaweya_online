import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Upgraded dialog allowing the teacher to grant extra views or reset watch limits for a student.
class GrantViewsDialog extends StatefulWidget {
  final String lessonTitle;
  final int currentViewCount;
  final int maxViews;

  const GrantViewsDialog({
    super.key,
    required this.lessonTitle,
    required this.currentViewCount,
    this.maxViews = 5,
  });

  /// Shows the dialog and returns the new view_count value (e.g. 0) or null if cancelled.
  static Future<int?> show(
    BuildContext context, {
    required String lessonTitle,
    required int currentViewCount,
    int maxViews = 5,
  }) {
    HapticFeedback.lightImpact();
    return showDialog<int>(
      context: context,
      barrierColor: Colors.black.withAlpha(160),
      builder: (_) => GrantViewsDialog(
        lessonTitle: lessonTitle,
        currentViewCount: currentViewCount,
        maxViews: maxViews,
      ),
    );
  }

  @override
  State<GrantViewsDialog> createState() => _GrantViewsDialogState();
}

class _GrantViewsDialogState extends State<GrantViewsDialog> {
  int _selectedOption = 0; // 0: Reset to 0 (Full 5 views), 1: +3 views, 2: +5 views

  int get _calculatedNewCount {
    switch (_selectedOption) {
      case 0:
        return 0; // Full reset gives all maxViews
      case 1:
        return (widget.currentViewCount - 3).clamp(0, widget.maxViews);
      case 2:
        return (widget.currentViewCount - 5).clamp(0, widget.maxViews);
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ───────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withAlpha(20),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      color: const Color(0xFF059669),
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'زيادة وتجديد مشاهدات الحصة',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'السماح للطالب بمشاهدة الدرس مجدداً',
                          style: GoogleFonts.cairo(
                            fontSize: 10.5.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // ─── Lesson Info Box ───────────────────────────────────────
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.play_lesson_rounded, size: 16.r, color: const Color(0xFF0284C7)),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            widget.lessonTitle,
                            style: GoogleFonts.cairo(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'استهلاك الطالب الحالي:',
                          style: GoogleFonts.cairo(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withAlpha(15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '${widget.currentViewCount} / ${widget.maxViews} مشاهدة',
                            style: GoogleFonts.cairo(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // ─── Options Selection ─────────────────────────────────────
              Text(
                'اختر الإجراء المطلوب:',
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
              SizedBox(height: 8.h),

              _buildOptionTile(
                index: 0,
                title: 'تصفير العداد بالكامل (إعادة فتح 5 مشاهدات)',
                subtitle: 'يعيد ضبط المشاهدات إلى 0 / ${widget.maxViews} ليتمكن الطالب من الحضور بحرية',
                icon: Icons.refresh_rounded,
                badge: 'موصى به',
              ),
              SizedBox(height: 8.h),
              _buildOptionTile(
                index: 1,
                title: 'إضافة 3 مشاهدات إضافية (+3)',
                subtitle: 'خصم 3 مشاهدات من عداد الطالب المسجل',
                icon: Icons.exposure_plus_1_rounded,
              ),
              SizedBox(height: 18.h),

              // ─── Action Buttons ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context, _calculatedNewCount);
                      },
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      label: Text(
                        'تأكيد الزيادة',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, null),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
  }) {
    final isSelected = _selectedOption == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedOption = index);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669).withAlpha(12) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF059669) : const Color(0xFF94A3B8),
              size: 20.r,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.cairo(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? const Color(0xFF065F46) : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.cairo(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 9.5.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
