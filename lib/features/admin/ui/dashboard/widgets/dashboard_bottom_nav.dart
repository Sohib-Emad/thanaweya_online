import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';

/// Bottom navigation bar for the admin dashboard.
class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const DashboardBottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      elevation: 1,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.adminPrimary,
      unselectedItemColor: AppColors.textTertiary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard_rounded),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outlined),
          activeIcon: Icon(Icons.people_rounded),
          label: 'المعلمين',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subject_rounded),
          activeIcon: Icon(Icons.subject_rounded),
          label: 'المواد',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.card_membership_outlined),
          activeIcon: Icon(Icons.card_membership_rounded),
          label: 'الباقات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart_outlined),
          activeIcon: Icon(Icons.bar_chart_rounded),
          label: 'التقارير',
        ),
      ],
    );
  }
}
