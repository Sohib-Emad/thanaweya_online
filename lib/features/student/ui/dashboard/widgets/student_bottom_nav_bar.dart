import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/l10n/l10n.dart';
import 'nav_bar_item.dart';

/// The bottom navigation bar for the student dashboard.
class StudentBottomNavBar extends StatelessWidget {
  /// Creates a [StudentBottomNavBar].
  const StudentBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  /// The currently selected tab index.
  final int currentIndex;

  /// Called when the user selects a new tab.
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 62 + bottomPad,
      padding: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: NotebookColors.surface,
        border: Border(
          top: BorderSide(color: NotebookColors.ink.withAlpha(30)),
        ),
        boxShadow: [
          BoxShadow(
            color: NotebookColors.ink.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          NavBarItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: l10n.home,
            isSelected: currentIndex == 0,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabChanged(0);
            },
          ),
          NavBarItem(
            icon: Icons.assignment_outlined,
            activeIcon: Icons.assignment_rounded,
            label: l10n.myCoursesTab,
            isSelected: currentIndex == 1,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabChanged(1);
            },
          ),
          NavBarItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet_rounded,
            label: 'الخزنة',
            isSelected: currentIndex == 2,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabChanged(2);
            },
          ),
          NavBarItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events_rounded,
            label: 'المتفوقين',
            isSelected: currentIndex == 3,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabChanged(3);
            },
          ),
          NavBarItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: l10n.examsTab,
            isSelected: currentIndex == 4,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabChanged(4);
            },
          ),
          NavBarItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l10n.profileTab,
            isSelected: currentIndex == 5,
            onTap: () {
              HapticFeedback.selectionClick();
              onTabChanged(5);
            },
          ),
        ],
      ),
    );
  }
}
