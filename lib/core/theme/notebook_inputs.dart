import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'notebook_colors.dart';
import 'notebook_text.dart';

/// A two-state paper segment switcher.
/// The selected option fills with mint highlighter ink.
class NotebookSegmentControl extends StatelessWidget {
  const NotebookSegmentControl({
    super.key,
    required this.options,
    required this.index,
    required this.onChanged,
  });

  final List<String> options;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: NotebookColors.surfaceBright,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: NotebookColors.ink.withAlpha(40)),
      ),
      child: Row(
        children: List.generate(options.length, (i) {
          final selected = i == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: selected ? NotebookColors.green : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    options[i],
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                      color: selected ? NotebookColors.onGreen : NotebookColors.pencil,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A primary green action, written as a filled highlighter button.
class NotebookPrimaryButton extends StatelessWidget {
  const NotebookPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: NotebookColors.green,
        foregroundColor: NotebookColors.onGreen,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18.r),
            SizedBox(width: 8.w),
          ],
          Text(label, style: NotebookText.strong(13.sp, color: Colors.white)),
        ],
      ),
    );
    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
