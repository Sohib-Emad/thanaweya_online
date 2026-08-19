import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'desk_colors.dart';
import 'desk_text.dart';

/// The desk top bar: white strip, green title, soft back tab + actions.
class DeskTopBar extends StatelessWidget implements PreferredSizeWidget {
  const DeskTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.automaticallyImplyBack = true,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool automaticallyImplyBack;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => Size.fromHeight(64.h);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final topPadding = MediaQuery.paddingOf(context).top;
    return Container(
      height: preferredSize.height + topPadding,
      padding: EdgeInsets.only(top: topPadding),
      color: DeskColors.surface,
      child: Row(
        children: [
          SizedBox(width: 12.w),
          if (automaticallyImplyBack && canPop)
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: const BoxDecoration(
                  color: DeskColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: DeskColors.primary,
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
                  style: DeskText.heading(17.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: DeskText.note(11.sp),
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
