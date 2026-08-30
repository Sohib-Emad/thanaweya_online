import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/l10n/locale_controller.dart';
import '../../../../../core/router/app_router.dart';
import '../../../../../core/theme/notebook_theme.dart';
import '../../../../../l10n/l10n.dart';
import 'profile_menu_item.dart';
import 'logout_confirm_dialog.dart';
import '../../../../chatbot/presentation/widgets/chatbot_sheet.dart';

/// Settings menu card with all profile navigation items.
class ProfileMenuCard extends StatelessWidget {
  final AppLocalizations l10n;

  const ProfileMenuCard({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return NotebookCard(
      ruled: true,
      ruledStartY: 24,
      borderRadius: 12,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.person_outline_rounded,
            title: l10n.editProfile,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.studentEditProfile,
            ),
          ),
          ProfileMenuItem(
            icon: Icons.account_balance_wallet_rounded,
            title: 'خزنة الطالب (المحفظة الرقمية)',
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.studentWallet,
            ),
          ),
          ProfileMenuItem(
            icon: Icons.support_agent_rounded,
            title: 'المساعد الذكي (الدعم الفوري 24/7)',
            onTap: () => ChatbotSheet.show(context),
          ),
          ProfileMenuItem(
            icon: Icons.receipt_long_outlined,
            title: 'سجل المعاملات والاشتراكات',
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.studentTransactions,
            ),
          ),
          ProfileMenuItem(
            icon: Icons.notifications_none_rounded,
            title: l10n.notificationSettings,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.studentNotificationSettings,
            ),
          ),
          ProfileMenuItem(
            icon: Icons.password_rounded,
            title: l10n.changePassword,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.studentChangePassword,
            ),
          ),
          ProfileMenuItem(
            icon: Icons.translate_rounded,
            title: l10n.appLanguage,
            trailingText: LocaleController.instance.label,
            onTap: () async {
              await Navigator.pushNamed(context, AppRouter.studentLanguage);
            },
          ),
          ProfileMenuItem(
            icon: Icons.description_outlined,
            title: l10n.termsAndPolicies,
            onTap: () => Navigator.pushNamed(context, AppRouter.studentTerms),
          ),
          ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: l10n.supportCenter,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.supportCenterMessage,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: AppColors.studentPrimary,
                ),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.person_pin_rounded,
            title: 'عن مالك ومبرمج المنصة',
            onTap: () => Navigator.pushNamed(context, AppRouter.aboutOwner),
          ),
          ProfileMenuItem(
            icon: Icons.mail_outline_rounded,
            title: l10n.inviteFriends,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.inviteCopied,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                  ),
                  backgroundColor: const Color(0xFF0FA37F),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: NotebookColors.ink.withAlpha(30),
          ),
          ProfileMenuItem(
            icon: Icons.logout_rounded,
            title: l10n.logout,
            isDanger: true,
            onTap: () => showLogoutConfirmDialog(context),
          ),
        ],
      ),
    );
  }
}
