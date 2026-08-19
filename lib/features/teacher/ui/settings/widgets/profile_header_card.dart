import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// The top profile section of the teacher settings screen showing avatar,
/// name, email, and an "accredited teacher" badge.
class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String teacherIdCode;
  final VoidCallback onEditTap;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.teacherIdCode,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : 'م';
    return Center(
      child: Column(
        children: [
          _buildAvatarStack(initial),
          SizedBox(height: 12.h),
          Text(
            name,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            email,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          _buildBadge(),
          SizedBox(height: 10.h),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(String initial) {
    return Stack(
      children: [
        Container(
          width: 96.r,
          height: 96.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFF0284C7), width: 2.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withAlpha(30),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            backgroundColor: const Color(0xFFF0F9FF),
            child: Text(
              initial,
              style: GoogleFonts.cairo(
                fontSize: 38.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0284C7),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onEditTap();
            },
            child: Container(
              width: 30.r,
              height: 30.r,
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(Icons.photo_camera_rounded, color: Colors.white, size: 15.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Text(
        'معلم معتمد • كود الحساب ($teacherIdCode)',
        style: GoogleFonts.cairo(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFD97706),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 48.w,
      height: 2.5.h,
      decoration: BoxDecoration(
        color: const Color(0xFF0284C7).withAlpha(120),
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }
}
