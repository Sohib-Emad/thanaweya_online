import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'notebook_colors.dart';
import 'notebook_text.dart';

/// The notebook's top bar: paper strip with a red-margin back tab and an
/// inked page title.
class NotebookTopBar extends StatelessWidget implements PreferredSizeWidget {
  const NotebookTopBar({
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
      color: NotebookColors.surface,
      child: Row(
        children: [
          SizedBox(width: 4.w),
          if (automaticallyImplyBack && canPop)
            GestureDetector(
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: NotebookColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: NotebookColors.marginRed.withAlpha(120),
                    width: 1.4,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: NotebookColors.marginRed,
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
                  style: NotebookText.heading(17.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: NotebookText.note(11.sp),
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
