import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Helper for WhatsApp sharing, custom phone input fallback, and clipboard copy of report text.
class ReportSharingActions {
  const ReportSharingActions._();

  /// Extracts clean digits from phone string, ignoring non-phone text like emails.
  static String extractCleanPhone(String input) {
    // If input is an email, it's not a phone number
    if (input.contains('@')) return '';
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    return digits;
  }

  /// Builds the WhatsApp deep-link URI for the given phone and text.
  static Uri buildWhatsAppUri(String phone, String reportText) {
    final cleaned = extractCleanPhone(phone);
    final encoded = Uri.encodeComponent(reportText);
    if (cleaned.isNotEmpty) {
      final formatted = cleaned.startsWith('20')
          ? cleaned
          : (cleaned.startsWith('0') ? '20${cleaned.substring(1)}' : '20$cleaned');
      return Uri.parse('https://wa.me/$formatted?text=$encoded');
    }
    // General share without phone
    return Uri.parse('https://wa.me/?text=$encoded');
  }

  /// Attempts to launch WhatsApp; if phone is missing or invalid, asks the teacher to enter phone or copies text.
  static Future<void> shareViaWhatsApp({
    required BuildContext context,
    required String phone,
    required String reportText,
    required VoidCallback onFallbackCopy,
  }) async {
    HapticFeedback.mediumImpact();
    final cleanPhone = extractCleanPhone(phone);

    if (cleanPhone.isEmpty) {
      // Prompt teacher to enter parent phone number
      final enteredPhone = await _showPhoneInputDialog(context);
      if (enteredPhone == null) {
        onFallbackCopy();
        return;
      }
      return _launchWhatsApp(enteredPhone, reportText, onFallbackCopy);
    }

    return _launchWhatsApp(cleanPhone, reportText, onFallbackCopy);
  }

  static Future<void> _launchWhatsApp(
    String phone,
    String reportText,
    VoidCallback onFallbackCopy,
  ) async {
    final uri = buildWhatsAppUri(phone, reportText);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        onFallbackCopy();
      }
    } catch (_) {
      onFallbackCopy();
    }
  }

  static Future<String?> _showPhoneInputDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366)),
              SizedBox(width: 8.w),
              Text(
                'إرسال التقرير عبر واتساب',
                style: GoogleFonts.cairo(fontSize: 14.sp, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لم يتم العثور على رقم هاتف مسجل لولي الأمر. يرجى إدخال رقم الواتساب:',
                style: GoogleFonts.cairo(fontSize: 11.5.sp, color: const Color(0xFF64748B)),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'مثال: 01012345678',
                  hintStyle: GoogleFonts.cairo(fontSize: 12.sp, color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFF0284C7)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: Text('نسخ فقط', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final txt = controller.text.trim();
                Navigator.pop(ctx, txt.isNotEmpty ? txt : null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              icon: const Icon(Icons.send_rounded, size: 16),
              label: Text('فتح واتساب', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  /// Copies [text] to clipboard and shows a success snackbar.
  static void copyToClipboard({
    required String text,
    required BuildContext context,
  }) {
    HapticFeedback.selectionClick();
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
