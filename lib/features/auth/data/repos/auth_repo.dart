import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/network/api_result.dart';
import 'package:thanaweya_online/features/shared/models/user_model.dart';
import 'auth_registration.dart';
import 'auth_session.dart';
import 'auth_password.dart';

/// Authentication repository that delegates to domain-specific helpers.
///
/// Provides a unified API for sign-up, sign-in, sign-out, password management,
/// and OTP verification.
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
  }) =>
      AuthRegistration.signUp(
        _auth,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );

  Future<ApiResult<UserModel>> signIn({
    required String email,
    required String password,
  }) =>
      AuthSession.signIn(_auth, email: email, password: password);

  Future<ApiResult<void>> signOut() => AuthSession.signOut(_auth);

  Future<ApiResult<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      AuthPassword.changePassword(
        _auth,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  Future<ApiResult<void>> resetPassword(String email) =>
      AuthPassword.resetPassword(_auth, email);

  Future<ApiResult<void>> verifyOtp({
    required String email,
    required String token,
  }) =>
      AuthPassword.verifyOtp(_auth, email: email, token: token);

  UserModel? getCurrentUserModel() =>
      AuthRegistration.getCurrentUserModel(_auth);
}
