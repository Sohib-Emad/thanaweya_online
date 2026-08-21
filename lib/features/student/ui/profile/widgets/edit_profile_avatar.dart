import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// Circular avatar with camera edit badge for the edit profile screen.
class EditProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final File? pickedAvatar;
  final String name;
  final VoidCallback onTap;

  const EditProfileAvatar({
    super.key,
    this.avatarUrl,
    this.pickedAvatar,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 96.r,
              height: 96.r,
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
              child: ClipOval(child: _buildChild()),
            ),
            Positioned(
              bottom: 0,
              left: 0,
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
          ],
        ),
      ),
    );
  }

  Widget _buildChild() {
    if (pickedAvatar != null) {
      return Image.file(
        pickedAvatar!,
        fit: BoxFit.cover,
        width: 96.r,
        height: 96.r,
      );
    }
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: avatarUrl!,
        fit: BoxFit.cover,
        width: 96.r,
        height: 96.r,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0284C7), strokeWidth: 2),
        ),
        errorWidget: (_, _, _) => _fallbackAvatar(),
      );
    }
    return _fallbackAvatar();
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
