import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Dialog that shows exported available codes and copies them to clipboard.
class ExportCodesDialog extends StatelessWidget {
  final String exportText;
  final int codeCount;

  const ExportCodesDialog({
    super.key,
    required this.exportText,
    required this.codeCount,
  });

  /// Builds the formatted export text from a list of code maps.
  static String buildExportText(List<Map<String, dynamic>> codes) {
    final buffer = StringBuffer();
    buffer.writeln(
      '📋 قائمة أكواد التفعيل المتاحة (${codes.length} كود) - ثانوية أونلاين:',
    );
    buffer.writeln('---------------------------------------');
    for (int i = 0; i < codes.length; i++) {
      final c = codes[i];
      final courseTitle =
          (c['courses'] as Map?)?['title'] ?? 'كورس عام';
      buffer.writeln('${i + 1}. الكود: ${c['code']} ($courseTitle)');
    }
    buffer.writeln('---------------------------------------');
    return buffer.toString();
  }

  static Future<void> show(
    BuildContext context, {
    required List<Map<String, dynamic>> codes,
  }) {
    final text = buildExportText(codes);
    Clipboard.setData(ClipboardData(text: text));

    return showDialog(
      context: context,
      builder: (ctx) => ExportCodesDialog(
        exportText: text,
        codeCount: codes.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        title: Text(
          'تصدير الأكواد المتاحة',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w800,
            fontSize: 16.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تم تجهيز ونسخ $codeCount كود متاح إلى الحافظة بنجاح جاهزة للمشاركة والطباعة!',
              style: DeskText.body(13.sp),
            ),
            SizedBox(height: 12.h),
            Container(
              constraints: BoxConstraints(maxHeight: 160.h),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: SingleChildScrollView(
                child: Text(
                  exportText,
                  style: GoogleFonts.cairo(fontSize: 11.sp),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: DeskColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(
              'إغلاق',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
