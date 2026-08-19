import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_error_model.dart';
import 'api_result.dart';

class ApiErrorHandler {
  ApiErrorHandler._();

  static ApiResult<T> handleException<T>(dynamic e) {
    debugPrint('[ApiErrorHandler] Exception type: ${e.runtimeType}');
    debugPrint('[ApiErrorHandler] Exception: $e');

    if (e is PostgrestException) {
      debugPrint('[ApiErrorHandler] PostgrestException code: ${e.code}, message: ${e.message}, details: ${e.details}');
      return ApiResult.failure(
        _mapPostgrestError(e.message),
        statusCode: int.tryParse(e.code ?? '') ?? 500,
      );
    }

    if (e is AuthException) {
      debugPrint('[ApiErrorHandler] AuthException message: ${e.message}, statusCode: ${e.statusCode}');
      return ApiResult.failure(
        _mapAuthError(e.message),
        statusCode: 401,
      );
    }

    if (e is StorageException) {
      return ApiResult.failure(
        e.message,
        statusCode: 500,
      );
    }

    if (e is ApiErrorModel) {
      return ApiResult.failure(e.message, statusCode: e.statusCode);
    }

    return ApiResult.failure(e.toString());
  }

  static String _mapPostgrestError(String message) {
    if (message.contains('PGRST301') || message.contains('JWT') || message.contains('wrong key type')) {
      return 'رمز المصادقة غير صالح، يرجى إعادة تسجيل الدخول';
    }
    if (message.contains('duplicate key')) {
      return 'البيانات موجودة مسبقاً';
    }
    if (message.contains('foreign key')) {
      return 'البيانات المرجعية غير موجودة';
    }
    if (message.contains('permission denied')) {
      return 'ليس لديك صلاحية للقيام بهذه العملية';
    }
    if (message.contains('row-level security')) {
      return 'ليس لديك صلاحية للوصول لهذه البيانات';
    }
    return 'حدث خطأ في قاعدة البيانات';
  }

  static String _mapAuthError(String message) {
    if (message.contains('email_address_invalid') || (message.contains('invalid') && message.contains('Email'))) {
      return 'البريد الإلكتروني غير صالح أو مرفوض من خادم المصادقة. تحقق من صيغة الإيميل وإعدادات Supabase';
    }
    if (message.contains('Invalid login credentials')) {
      return 'بيانات الدخول غير صحيحة';
    }
    if (message.contains('Email not confirmed')) {
      return 'لم يتم تأكيد البريد الإلكتروني';
    }
    if (message.contains('User already registered')) {
      return 'البريد الإلكتروني مسجل مسبقاً';
    }
    if (message.contains('Password should be at least')) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return 'حدث خطأ في المصادقة';
  }
}
