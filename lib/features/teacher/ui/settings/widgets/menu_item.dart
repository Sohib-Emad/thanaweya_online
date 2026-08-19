import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single settings menu row with an icon, title, optional subtitle,
/// optional trailing text, and a chevron indicator.
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingText;
  final Color? trailingColor;
  final VoidCallback onTap;
  final bool isDanger;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingText,
    this.trailingColor,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            _buildIcon(),
            SizedBox(width: 12.w),
            Expanded(child: _buildText()),
            if (trailingText != null) ...[
              SizedBox(width: 8.w),
              Text(
                trailingText!,
                style: GoogleFonts.cairo(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: trailingColor ?? const Color(0xFF64748B),
                ),
              ),
            ],
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_left_rounded,
              color: isDanger ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: isDanger ? const Color(0xFFFEF2F2) : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDanger ? const Color(0xFFFECACA) : const Color(0xFFBAE6FD),
        ),
      ),
      child: Icon(
        icon,
        color: isDanger ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
        size: 19.r,
      ),
    );
  }

  Widget _buildText() {
    final titleColor = isDanger ? const Color(0xFFDC2626) : const Color(0xFF0F172A);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
              fontSize: 13.sp, fontWeight: FontWeight.w700, color: titleColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null) ...[
          SizedBox(height: 1.h),
          Text(
            subtitle!,
            style: GoogleFonts.cairo(fontSize: 10.5.sp, color: const Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
