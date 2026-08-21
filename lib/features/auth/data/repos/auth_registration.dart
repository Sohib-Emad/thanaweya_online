import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/user_model.dart';

/// Handles user registration and current-user model construction.
class AuthRegistration {
  AuthRegistration._();

  /// Registers a new user with email, password, and profile metadata.
  ///
  /// Attempts to upsert the `users` row (non-fatal if it fails due to RLS).
  /// Returns a [UserModel] on success.
  static Future<ApiResult<UserModel>> signUp(
    GoTrueClient auth, {
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    try {
      debugPrint('[AuthRepo] signUp called: email=$email, role=${role.name}');

      final response = await auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role.name,
          'plain_password': password,
        },
      );

      debugPrint(
        '[AuthRepo] signUp response: user=${response.user?.id}, '
        'session=${response.session != null}',
      );

      if (response.user == null) {
        return const ApiResult.failure('حدث خطأ أثناء إنشاء الحساب');
      }

      final uid = response.user!.id;
      try {
        await Supabase.instance.client.from('users').upsert({
          'id': uid,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'role': role.name,
          'plain_password': password,
        }, onConflict: 'id');
        debugPrint('[AuthRepo] users row upserted OK');
      } catch (e) {
        debugPrint('[AuthRepo] users row upsert failed (non-fatal): $e');
      }

      if (role == UserRole.student) {
        try {
          await Supabase.instance.client.from('students').upsert({
            'id': uid,
            'plain_password': password,
          }, onConflict: 'id');
        } catch (_) {}
      } else if (role == UserRole.teacher) {
        try {
          await Supabase.instance.client.from('teachers').upsert({
            'id': uid,
            'plain_password': password,
          }, onConflict: 'id');
        } catch (_) {}
      }

      final userModel = UserModel(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return ApiResult.success(userModel);
    } catch (e, stackTrace) {
      debugPrint('[AuthRepo] signUp CRITICAL error: $e');
      debugPrint('[AuthRepo] stackTrace: $stackTrace');
      return ApiErrorHandler.handleException(e);
    }
  }

  /// Builds a [UserModel] from the currently authenticated Supabase user.
  static UserModel? getCurrentUserModel(GoTrueClient auth) {
    final user = auth.currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] ?? '',
      phone: user.userMetadata?['phone'] ?? '',
      role: UserRole.fromString(user.userMetadata?['role']),
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
    );
  }
}
