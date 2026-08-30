import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';

class PushTokenUserInfoRow extends StatelessWidget {
  final String displayName;
  final String email;
  final String roleLabel;
  final Color roleColor;
  final Color roleBg;
  final bool isAndroid;
  final String? avatarUrl;

  const PushTokenUserInfoRow({
    super.key,
    required this.displayName,
    required this.email,
    required this.roleLabel,
    required this.roleColor,
    required this.roleBg,
    required this.isAndroid,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: roleColor.withValues(alpha: 0.15),
          backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null || avatarUrl!.isEmpty
              ? Text(displayName.isNotEmpty ? displayName.characters.first : 'U', style: GoogleFonts.cairo(fontWeight: FontWeight.w800, color: roleColor, fontSize: 14.sp))
              : null,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(child: Text(displayName, style: GoogleFonts.cairo(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                SizedBox(width: 6.w),
                Container(padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.5.h), decoration: BoxDecoration(color: roleBg, borderRadius: BorderRadius.circular(6.r)), child: Text(roleLabel, style: GoogleFonts.cairo(fontSize: 10.sp, fontWeight: FontWeight.w800, color: roleColor))),
              ]),
              if (email.isNotEmpty) Text(email, style: GoogleFonts.cairo(fontSize: 11.sp, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(color: isAndroid ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6.r)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isAndroid ? Icons.android_rounded : Icons.apple_rounded, size: 13.r, color: isAndroid ? const Color(0xFF16A34A) : const Color(0xFF475569)),
            SizedBox(width: 4.w),
            Text(isAndroid ? 'Android' : 'iOS', style: GoogleFonts.cairo(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: isAndroid ? const Color(0xFF16A34A) : const Color(0xFF475569))),
          ]),
        ),
      ],
    );
  }
}
