import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thanaweya_online/core/constants/app_colors.dart';
import 'copy_tokens_option_tile.dart';

class CopyTokensOptionsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> tokens;
  const CopyTokensOptionsDialog({super.key, required this.tokens});

  void _copy(BuildContext context, String content, String name) {
    Clipboard.setData(ClipboardData(text: content));
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم نسخ ${tokens.length} توكن بصيغة ($name)!'), backgroundColor: const Color(0xFF16A34A)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokenStrings = tokens.map((t) => t['token'] as String?).whereType<String>().toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: EdgeInsets.all(10.r), decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)), child: Icon(Icons.copy_all_rounded, color: const Color(0xFF2563EB), size: 24.r)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('نسخ التوكنز (${tokenStrings.length})', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      Text('اختر الصيغة المناسبة لنسخ التوكنز', style: GoogleFonts.cairo(fontSize: 11.5.sp, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded), color: AppColors.textSecondary),
              ],
            ),
            const Divider(height: 24),
            CopyTokensOptionTile(
              icon: Icons.data_object_rounded, title: 'JSON Array (قائمة برمجية)', subtitle: 'مناسب لـ Firebase SDK و Node.js / Python scripts',
              onTap: () => _copy(context, const JsonEncoder.withIndent('  ').convert(tokenStrings), 'JSON Array'),
            ),
            SizedBox(height: 10.h),
            CopyTokensOptionTile(
              icon: Icons.format_list_bulleted_rounded, title: 'مفصولة بفواصل (Comma Separated)', subtitle: 'token1, token2, token3 ...',
              onTap: () => _copy(context, tokenStrings.join(', '), 'Comma Separated'),
            ),
            SizedBox(height: 10.h),
            CopyTokensOptionTile(
              icon: Icons.view_headline_rounded, title: 'سطر بسطر (Line by Line)', subtitle: 'كل توكن في سطر مستقل',
              onTap: () => _copy(context, tokenStrings.join('\n'), 'Line by Line'),
            ),
          ],
        ),
      ),
    );
  }
}
