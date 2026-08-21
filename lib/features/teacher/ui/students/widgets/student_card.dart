import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Displays a single student with avatar, name, status, grade, and progress.
class StudentCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String gradeLabel;
  final bool active;
  final int completedLessons;
  final int totalLessons;
  final int progressPercent;
  final VoidCallback onTap;

  const StudentCard({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.gradeLabel,
    required this.active,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.progressPercent = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap, borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(children: [
              CircleAvatar(
                radius: 24.r, backgroundColor: const Color(0xFF0284C7).withAlpha(20),
                child: Text(name.isNotEmpty ? name[0] : 'ط',
                  style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w900, color: const Color(0xFF0284C7))),
              ),
              SizedBox(width: 12.w),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(child: Text(name,
                      style: GoogleFonts.cairo(fontSize: 14.5.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF059669).withAlpha(16) : const Color(0xFF64748B).withAlpha(16),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(active ? 'مشترك نشط' : 'غير نشط',
                        style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800,
                          color: active ? const Color(0xFF059669) : const Color(0xFF64748B))),
                    ),
                  ]),
                  SizedBox(height: 3.h),
                  Row(children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(color: const Color(0xFF0284C7).withAlpha(14), borderRadius: BorderRadius.circular(4.r)),
                      child: Text(gradeLabel, style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0284C7))),
                    ),
                    if (phone.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Icon(Icons.phone_iphone_rounded, size: 12.r, color: const Color(0xFF94A3B8)),
                      SizedBox(width: 2.w),
                      Text(phone, style: GoogleFonts.cairo(fontSize: 10.5.sp, color: const Color(0xFF64748B))),
                    ] else if (email.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Expanded(child: Text(email, style: GoogleFonts.cairo(fontSize: 10.5.sp, color: const Color(0xFF94A3B8)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ],
              )),
              SizedBox(width: 6.w),
              Icon(Icons.chevron_left_rounded, size: 20.r, color: const Color(0xFFCBD5E1)),
            ]),
          ),
        ),
      ),
    );
  }
}
