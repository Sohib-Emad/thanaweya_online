import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:thanaweya_online/core/router/app_router.dart';
import 'package:thanaweya_online/core/theme/notebook_theme.dart';
import 'package:thanaweya_online/features/auth/logic/auth_cubit.dart';
import 'package:thanaweya_online/l10n/l10n.dart';

class StudentSettingsScreen extends StatelessWidget {
  const StudentSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: NotebookColors.ground,
      appBar: NotebookTopBar(
        title: l10n.settings,
        subtitle: l10n.settingsSubtitle,
      ),
      body: NotebookPaper(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 40.h),
          physics: const BouncingScrollPhysics(),
          children: [
            NotebookCard(
              ruled: true,
              ruledStartY: 24,
              borderRadius: 12,
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: l10n.profile,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.translate_rounded,
                    title: l10n.language,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: l10n.notifications,
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    icon: Icons.logout_rounded,
                    title: l10n.logout,
                    isDanger: true,
                    onTap: () {
                      context.read<AuthCubit>().signOut();
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.login,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
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
                color: isDanger
                    ? NotebookColors.marginRed
                    : NotebookColors.ink,
                size: 19.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: NotebookText.body(13.sp).copyWith(
                  color: isDanger ? NotebookColors.marginRed : null,
                ),
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
      ),
    );
  }
}
