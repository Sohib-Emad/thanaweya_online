import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Circular avatar with a fallback initial, used on the student header.
class StudentAvatar extends StatelessWidget {
  final String name;
  final String avatarUrl;

  const StudentAvatar({super.key, required this.name, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty ? name.trim().substring(0, 1) : 'ط';
    return Container(
      width: 54.r, height: 54.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: const Color(0xFF0284C7).withAlpha(40), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: avatarUrl.isNotEmpty
          ? ClipOval(child: Image.network(avatarUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fb(initials)))
          : _fb(initials),
    );
  }

  Widget _fb(String i) => Center(child: Text(i,
      style: GoogleFonts.cairo(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Colors.white)));
}
