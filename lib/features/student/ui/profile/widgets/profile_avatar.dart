import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Display-only avatar with optional edit badge for the profile tab.
class ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    super.key,
    this.avatarUrl,
    required this.name,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: NotebookColors.surfaceBright,
                  border: Border.all(
                    color: const Color(0xFF0284C7),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl!.isNotEmpty
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          width: 100.r,
                          height: 100.r,
                          errorBuilder: (_, _, _) => _fallbackAvatar(),
                        )
                      : _fallbackAvatar(),
                ),
              ),
              if (onEditTap != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: GestureDetector(
                    onTap: onEditTap,
                    child: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0284C7),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.photo_camera_rounded,
                        color: Colors.white,
                        size: 16.r,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(name, style: NotebookText.heading(18.sp)),
        ],
      ),
    );
  }

  Widget _fallbackAvatar() {
    return CircleAvatar(
      backgroundColor: NotebookColors.surfaceBright,
      child: Text(
        name.isEmpty ? 'ط' : name.substring(0, 1),
        style: GoogleFonts.cairo(
          fontSize: 40.sp,
          fontWeight: FontWeight.w900,
          color: NotebookColors.ink,
        ),
      ),
    );
  }
}
