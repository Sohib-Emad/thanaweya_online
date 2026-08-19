import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/notebook_theme.dart';

/// A single menu row used in the profile settings list.
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? trailingText;
  final Widget? trailingWidget;
  final bool isDanger;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.trailingWidget,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isDanger
                    ? NotebookColors.marginRed.withAlpha(14)
                    : NotebookColors.surfaceBright,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: isDanger
                      ? NotebookColors.marginRed.withAlpha(90)
                      : NotebookColors.ink.withAlpha(28),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color:
                    isDanger ? NotebookColors.marginRed : NotebookColors.ink,
                size: 19.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: NotebookText.body(13.sp).copyWith(
                  color: isDanger ? NotebookColors.marginRed : null,
                  fontWeight: isDanger ? FontWeight.w800 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (trailingText != null)
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        trailingText!,
                        style: NotebookText.note(11.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Icon(
                    Icons.chevron_left_rounded,
                    color: isDanger
                        ? NotebookColors.marginRed
                        : NotebookColors.pencil,
                    size: 20.r,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
