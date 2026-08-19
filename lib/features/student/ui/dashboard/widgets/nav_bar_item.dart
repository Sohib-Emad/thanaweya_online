import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';

/// A single item in the bottom navigation bar.
class NavBarItem extends StatelessWidget {
  /// Creates a [NavBarItem].
  const NavBarItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  /// The icon shown when the tab is not selected.
  final IconData icon;

  /// The icon shown when the tab is selected.
  final IconData activeIcon;

  /// The text label beneath the icon.
  final String label;

  /// Whether this tab is currently selected.
  final bool isSelected;

  /// Called when the user taps this item.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? NotebookColors.green : NotebookColors.pencil;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(isSelected ? activeIcon : icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: color,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              margin: const EdgeInsets.only(top: 3),
              width: isSelected ? 20 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: NotebookColors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
