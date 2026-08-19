import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';

/// Handles password management and OTP verification.
class AuthPassword {
  AuthPassword._();

  /// Verifies the current password and updates it with [newPassword].
  static Future<ApiResult<void>> changePassword(
    GoTrueClient auth, {
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = auth.currentUser;
      if (user == null || user.email == null) {
        return const ApiResult.failure('لا يوجد مستخدم مسجل حالياً');
      }

      final verified = await auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
      if (verified.user == null) {
        return const ApiResult.failure('كلمة المرور الحالية غير صحيحة');
      }

      await auth.updateUser(UserAttributes(password: newPassword));
      return const ApiResult.success(null);
    } catch (e, stackTrace) {
      debugPrint('[AuthRepo] changePassword error: $e');
      debugPrint('[AuthRepo] stackTrace: $stackTrace');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Sends a password-reset email to [email].
  static Future<ApiResult<void>> resetPassword(
    GoTrueClient auth,
    String email,
  ) async {
    try {
      await auth.resetPasswordForEmail(email);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Verifies an OTP code sent during sign-up.
  static Future<ApiResult<void>> verifyOtp(
    GoTrueClient auth, {
    required String email,
    required String token,
  }) async {
    try {
      await auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
