import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chalk_colors.dart';
import 'chalk_text.dart';

/// The chalkboard top bar: dark board strip, chalk title, colored-chalk
/// back tab and actions.
class ChalkTopBar extends StatelessWidget implements PreferredSizeWidget {
  const ChalkTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.automaticallyImplyBack = true,
    this.onBack,
    this.accent = ChalkboardColors.accent,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool automaticallyImplyBack;
  final VoidCallback? onBack;
  final Color accent;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      height: preferredSize.height + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      color: ChalkboardColors.ground,
      child: Row(
        children: [
          SizedBox(width: 12.w),
          if (automaticallyImplyBack && canPop)
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: ChalkboardColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withAlpha(160),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: accent,
                  size: 20.r,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ChalkboardText.heading(17.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: ChalkboardText.note(11.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          ...?actions,
          SizedBox(width: 12.w),
        ],
      ),
    );
  }
}
