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
      debugPrint('[AuthRepo] Attempting signIn with email: $email');
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

      // Auto-provision if user exists in Auth but not in public.users
      if (userProfile == null) {
        debugPrint('[AuthRepo] User ${user.id} authenticated with Supabase Auth but row does not exist in public.users – auto-provisioning');

        // Step 1: Try to find existing row by email and sync the ID
        if (user.email != null) {
          try {
            final existingRow = await Supabase.instance.client
                .from('users')
                .select('id, email, full_name, phone, role')
                .eq('email', user.email!)
                .maybeSingle();
            if (existingRow != null) {
              final oldId = existingRow['id'] as String;
              final metaRole = user.userMetadata?['role'] as String?;
              final dbRole = existingRow['role'] as String?;
              debugPrint('[AuthRepo] Found existing row: email=${user.email}, dbRole=$dbRole, metaRole=$metaRole');

              // Sync ID if changed
              if (oldId != user.id) {
                debugPrint('[AuthRepo] Syncing old id=$oldId to new id=${user.id}');
                final client = Supabase.instance.client;
                // Sync dependent tables FIRST (before users FK changes)
                for (final table in ['teachers', 'subscriptions', 'courses', 'exams', 'students']) {
                  try {
                    await client.from(table).update({'id': user.id}).eq('id', oldId);
                    debugPrint('[AuthRepo] Synced $table id');
                  } catch (e) {
                    debugPrint('[AuthRepo] Sync $table skipped: $e');
                  }
                }
                // Also sync teacher_id references
                for (final table in ['courses', 'exams', 'subscriptions']) {
                  try {
                    await client.from(table).update({'teacher_id': user.id}).eq('teacher_id', oldId);
                  } catch (_) {}
                }
                // Finally sync users table
                try {
                  await client.from('users').update({'id': user.id}).eq('id', oldId);
                  debugPrint('[AuthRepo] Synced users id');
                } catch (e) {
                  debugPrint('[AuthRepo] Users ID sync failed: $e');
                }
              }

              // Sync role from metadata if DB role is wrong
              final resolvedRole = metaRole ?? dbRole ?? 'teacher';
              if (dbRole != resolvedRole) {
                debugPrint('[AuthRepo] Updating role from $dbRole to $resolvedRole');
                try {
                  await Supabase.instance.client.from('users').update({'role': resolvedRole}).eq('id', user.id);
                } catch (_) {}
              }

              userProfile = {
                'id': user.id,
                'email': existingRow['email'],
                'full_name': existingRow['full_name'],
                'phone': existingRow['phone'],
                'role': resolvedRole,
              };
            }
          } catch (e) {
            debugPrint('[AuthRepo] Email lookup failed: $e');
          }
        }

        // Step 2: If still no profile, insert a new row
        if (userProfile == null) {
          final metaRole = user.userMetadata?['role'] as String? ?? 'teacher';
          final metaName = (user.userMetadata?['full_name'] as String?) ??
              (user.email?.split('@').first ?? '');
          final metaPhone = user.userMetadata?['phone'] as String? ?? '';
          try {
            await Supabase.instance.client.from('users').upsert({
              'id': user.id,
              'email': user.email ?? email,
              'full_name': metaName,
              'phone': metaPhone,
              'role': metaRole,
            }, onConflict: 'id');
            userProfile = {
              'id': user.id,
              'email': user.email ?? email,
              'full_name': metaName,
              'phone': metaPhone,
              'role': metaRole,
            };
            debugPrint('[AuthRepo] Auto-provisioned user ${user.id} in public.users');
          } catch (e) {
            debugPrint('[AuthRepo] Auto-provision failed: $e');
            try {
              await auth.signOut();
            } catch (_) {}
            return const ApiResult.failure('الحساب غير موجود أو تم حذفه من النظام');
          }
        }
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
