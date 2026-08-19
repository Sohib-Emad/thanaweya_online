import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

/// Popup menu button with share, download, and print actions.
class ReceiptMenuButton extends StatelessWidget {
  const ReceiptMenuButton({super.key, required this.onSelected});

  /// Callback when a menu item is selected.
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Container(
        width: 36.r,
        height: 36.r,
        decoration: BoxDecoration(
          color: NotebookColors.surfaceBright,
          shape: BoxShape.circle,
          border: Border.all(color: NotebookColors.ink.withAlpha(50), width: 1.2),
        ),
        child: Icon(Icons.more_horiz_rounded, color: NotebookColors.ink, size: 20.r),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 6,
      onSelected: (value) {
        HapticFeedback.mediumImpact();
        onSelected(value);
      },
      itemBuilder: (context) => [
        _menuItem(context.l10n.shareAction, Icons.send_rounded, NotebookColors.green, context.l10n.shareReceipt),
        _menuItem(context.l10n.downloadAction, Icons.download_rounded, NotebookColors.green, context.l10n.downloadPdf),
        _menuItem(context.l10n.printAction, Icons.print_rounded, NotebookColors.pencil, context.l10n.printReceipt),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String label, IconData icon, Color iconColor, String value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: NotebookText.strong(13.sp)),
          Icon(icon, size: 18.r, color: iconColor),
        ],
      ),
    );
  }
}
