import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import 'package:thanaweya_online/core/theme/teacher_desk_theme.dart';

/// Interactive receipt upload box for selecting, previewing,
/// and managing payment transfer screenshots.
class ReceiptUploadBox extends StatelessWidget {
  final XFile? receiptFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const ReceiptUploadBox({
    super.key,
    required this.receiptFile,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (receiptFile != null) {
      return Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: Image.file(
                    File(receiptFile!.path),
                    width: 58.r,
                    height: 58.r,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 58.r,
                      height: 58.r,
                      color: DeskColors.surfaceAlt,
                      child: Icon(Icons.receipt_long_rounded,
                          color: DeskColors.primary, size: 26.r),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: const Color(0xFF16A34A), size: 18.r),
                          SizedBox(width: 6.w),
                          Text(
                            'تم إرفاق إيصال التحويل ✓',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        receiptFile!.name,
                        style: DeskText.note(10.5.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: 22.r),
                  tooltip: 'إزالة',
                ),
              ],
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF16A34A),
                  side: const BorderSide(color: Color(0xFF86EFAC)),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                icon: Icon(Icons.refresh_rounded, size: 16.r),
                label: Text('تغيير الصورة',
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFCD34D),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border:
                    Border.all(color: const Color(0xFFF59E0B).withAlpha(80)),
              ),
              child: Icon(
                Icons.add_photo_alternate_rounded,
                color: const Color(0xFFD97706),
                size: 26.r,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'انقر لاختيار أو تصوير إيصال التحويل (InstaPay)',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF92400E),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'أرفق لقطة شاشة واضحة لعملية التحويل الناجحة لتأكيد وتفعيل الاشتراك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB45309),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
