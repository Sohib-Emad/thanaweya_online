import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Copies [code] to clipboard and shows a confirmation snackbar.
void copyCodeToClipboard(BuildContext context, String code) {
  HapticFeedback.lightImpact();
  Clipboard.setData(ClipboardData(text: code));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'تم نسخ الكود: $code',
        style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.white),
      ),
      backgroundColor: DeskColors.primary,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
