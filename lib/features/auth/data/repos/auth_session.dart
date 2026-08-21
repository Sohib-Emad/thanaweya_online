import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/user_model.dart';

/// Handles sign-in and sign-out operations.
class AuthSession {
  AuthSession._();

  /// Signs in with email and password.
  ///
  /// Returns a [UserModel] on success, or a failure result with an Arabic
  /// error message.
  static Future<ApiResult<UserModel>> signIn(
    GoTrueClient auth, {
    required String email,
    required String password,
  }) async {
    try {
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const ApiResult.failure('بيانات الدخول غير صحيحة');
      }

      final user = response.user!;

      // Verify that user profile exists in database
      Map<String, dynamic>? userProfile;
      try {
        userProfile = await Supabase.instance.client
            .from('users')
            .select('id, email, full_name, phone, role')
            .eq('id', user.id)
            .maybeSingle();
      } catch (_) {}

      if (userProfile == null) {
        debugPrint('[AuthRepo] User ${user.id} authenticated with Supabase Auth but row does not exist in public.users');
        try {
          await auth.signOut();
        } catch (_) {}
        return const ApiResult.failure('الحساب غير موجود أو تم حذفه من النظام');
      }

      debugPrint('[AuthRepo] signIn success: userId=${user.id}');

      final userModel = UserModel(
        id: user.id,
        email: (userProfile['email'] as String?) ?? (user.email ?? ''),
        fullName: (userProfile['full_name'] as String?) ??
            (user.userMetadata?['full_name'] ?? ''),
        phone: (userProfile['phone'] as String?) ??
            (user.userMetadata?['phone'] ?? ''),
        role: UserRole.fromString(userProfile['role'] ?? user.userMetadata?['role']),
        createdAt: DateTime.parse(user.createdAt),
        updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
      );

      return ApiResult.success(userModel);
    } catch (e, stackTrace) {
      debugPrint('[AuthRepo] signIn error: $e');
      debugPrint('[AuthRepo] signIn stackTrace: $stackTrace');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Signs out the current user.
  static Future<ApiResult<void>> signOut(GoTrueClient auth) async {
    try {
      await auth.signOut();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }
}
