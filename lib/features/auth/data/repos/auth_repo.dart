import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_error_handler.dart';
import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/user_model.dart';

class AuthRepo {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Future<ApiResult<UserModel>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    try {
      debugPrint('[AuthRepo] signUp called: email=$email, role=${role.name}');

      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role.name,
        },
      );

      debugPrint('[AuthRepo] signUp response: user=${response.user?.id}, session=${response.session != null}');

      if (response.user == null) {
        return const ApiResult.failure('حدث خطأ أثناء إنشاء الحساب');
      }

      // Try to create users row (may fail if trigger already handled it or RLS blocks)
      try {
        await Supabase.instance.client.from('users').upsert({
          'id': response.user!.id,
          'email': email,
          'full_name': fullName,
          'phone': phone,
          'role': role.name,
        }, onConflict: 'id');
        debugPrint('[AuthRepo] users row upserted OK');
      } catch (e) {
        debugPrint('[AuthRepo] users row upsert failed (non-fatal): $e');
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

  Future<ApiResult<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return const ApiResult.failure('بيانات الدخول غير صحيحة');
      }

      debugPrint('[AuthRepo] signIn success: userId=${response.user!.id}');

      final user = response.user!;
      final userModel = UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? '',
        phone: user.userMetadata?['phone'] ?? '',
        role: UserRole.values.byName(user.userMetadata?['role'] ?? 'student'),
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

  Future<ApiResult<void>> signOut() async {
    try {
      await _auth.signOut();
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        return const ApiResult.failure('لا يوجد مستخدم مسجل حالياً');
      }

      final verified = await _auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
      if (verified.user == null) {
        return const ApiResult.failure('كلمة المرور الحالية غير صحيحة');
      }

      await _auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return const ApiResult.success(null);
    } catch (e, stackTrace) {
      debugPrint('[AuthRepo] changePassword error: $e');
      debugPrint('[AuthRepo] stackTrace: $stackTrace');
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  Future<ApiResult<void>> verifyOtp({
    required String email,
    required String token,
  }) async {
    try {
      await _auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      return const ApiResult.success(null);
    } catch (e) {
      return ApiErrorHandler.handleException(e);
    }
  }

  UserModel? getCurrentUserModel() {
    final user = currentUser;
    if (user == null) return null;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] ?? '',
      phone: user.userMetadata?['phone'] ?? '',
      role: UserRole.values.byName(user.userMetadata?['role'] ?? 'student'),
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt ?? user.createdAt),
    );
  }
}
