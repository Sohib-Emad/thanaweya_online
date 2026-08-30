import 'package:flutter/material.dart';

import '../../features/student/ui/transactions/student_transactions_screen.dart';
import '../../features/student/ui/transactions/e_receipt_screen.dart';
import '../../features/student/ui/profile/student_profile_tab.dart';
import '../../features/student/ui/profile/student_edit_profile_screen.dart';
import '../../features/student/ui/profile/student_notification_settings_screen.dart';
import '../../features/student/ui/profile/student_payment_options_screen.dart';
import '../../features/student/ui/profile/student_add_card_screen.dart';
import '../../features/student/ui/profile/student_change_password_screen.dart';
import '../../features/student/ui/profile/student_language_screen.dart';
import '../../features/student/ui/profile/student_terms_screen.dart';
import '../../features/wallet/presentation/pages/mobile_wallet_page.dart';

/// Route names and page builder for student profile & transaction routes.
class StudentProfileRoutes {
  StudentProfileRoutes._();

  static const String studentWallet = '/student/wallet';
  static const String studentTransactions = '/student/transactions';
  static const String studentEReceipt = '/student/e-receipt';
  static const String studentProfile = '/student/profile';
  static const String studentEditProfile = '/student/edit-profile';
  static const String studentNotificationSettings = '/student/notification-settings';
  static const String studentPaymentOptions = '/student/payment-options';
  static const String studentAddCard = '/student/add-card';
  static const String studentChangePassword = '/student/change-password';
  static const String studentLanguage = '/student/language';
  static const String studentTerms = '/student/terms';

  static Widget? build(RouteSettings settings) {
    switch (settings.name) {
      case studentWallet:
        return const MobileWalletPage();
      case studentTransactions:
        return const StudentTransactionsScreen(showBackButton: true);
      case studentEReceipt:
        return EReceiptScreen(transactionData: settings.arguments as Map<String, dynamic>?);
      case studentProfile:
        return const StudentProfileTab(isTabMode: false);
      case studentEditProfile:
        return const StudentEditProfileScreen();
      case studentNotificationSettings:
        return const StudentNotificationSettingsScreen();
      case studentPaymentOptions:
        return const StudentPaymentOptionsScreen();
      case studentAddCard:
        return const StudentAddCardScreen();
      case studentChangePassword:
        return const StudentChangePasswordScreen();
      case studentLanguage:
        return const StudentLanguageScreen();
      case studentTerms:
        return const StudentTermsScreen();
      default:
        return null;
    }
  }
}
