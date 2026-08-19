import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Helper for WhatsApp sharing and clipboard copy of report text.
class ReportSharingActions {
  const ReportSharingActions._();

  /// Builds the WhatsApp deep-link URI for the given phone and text.
  static Uri buildWhatsAppUri(String phone, String reportText) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final encoded = Uri.encodeComponent(reportText);
    if (cleaned.isNotEmpty) {
      final formatted = cleaned.startsWith('+')
          ? cleaned.substring(1)
          : (cleaned.startsWith('0') ? '20${cleaned.substring(1)}' : cleaned);
      return Uri.parse('https://wa.me/$formatted?text=$encoded');
    }
    return Uri.parse('https://wa.me/?text=$encoded');
  }

  /// Attempts to launch WhatsApp; falls back to copy on failure.
  static Future<void> shareViaWhatsApp({
    required String phone,
    required String reportText,
    required VoidCallback onFallbackCopy,
  }) async {
    final uri = buildWhatsAppUri(phone, reportText);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        onFallbackCopy();
      }
    } catch (_) {
      onFallbackCopy();
    }
  }

  /// Copies [text] to clipboard and shows a success snackbar.
  static void copyToClipboard({
    required String text,
    required BuildContext context,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8.w),
            Text(
              'تم نسخ تقرير ولي الأمر بنجاح!',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        backgroundColor: DeskColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
