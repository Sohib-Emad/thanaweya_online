import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notebook_colors.dart';

/// A round paper avatar that shows the teacher's photo when available
/// (via [CachedNetworkImage]) and falls back to the name initial.
class NotebookTeacherAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;

  const NotebookTeacherAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = avatarUrl?.isNotEmpty == true;
    final initial = name.trim().isNotEmpty ? name.trim()[0] : 'م';

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: NotebookColors.green.withAlpha(20),
        shape: BoxShape.circle,
        border: Border.all(
          color: NotebookColors.green.withAlpha(90),
          width: 1.4,
        ),
      ),
      child: hasPhoto
          ? CachedNetworkImage(
              imageUrl: avatarUrl!,
              fit: BoxFit.cover,
              placeholder: (_, _) => _buildInitial(initial),
              errorWidget: (_, _, _) => _buildInitial(initial),
            )
          : _buildInitial(initial),
    );
  }

  Widget _buildInitial(String initial) {
    return Center(
      child: Text(
        initial,
        style: GoogleFonts.cairo(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          color: NotebookColors.ink,
        ),
      ),
    );
  }
}
