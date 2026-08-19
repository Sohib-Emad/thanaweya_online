import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// WhatsApp quick-contact card for reaching out to a teacher.
class WhatsAppContactCard extends StatelessWidget {
  final String phone;
  final String teacherName;
  final VoidCallback onPressed;

  const WhatsAppContactCard({
    super.key,
    required this.phone,
    required this.teacherName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F8F5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: const Color(0xFF075E54),
                  size: 20.r,
                ),
              ),
              SizedBox(width: 10.w),
              Text(context.l10n.quickContact, style: NotebookText.strong(14.sp)),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            context.l10n.quickContactMessage,
            style: NotebookText.body(11.sp, color: NotebookColors.pencil),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                shadowColor: Colors.black12,
                elevation: 2,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.send_rounded, size: 20.r),
              label: Text(
                context.l10n.contactOnWhatsapp,
                style: GoogleFonts.cairo(
                    fontSize: 12.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
