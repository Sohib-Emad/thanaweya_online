import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wallet_model.dart';
import '../models/wallet_transaction_model.dart';

abstract class WalletRemoteDatasource {
  Future<WalletModel> getWallet(String userId);

  Future<WalletModel> rechargeWithCard({
    required String userId,
    required String cardCode,
  });

  Future<bool> purchaseCourse({
    required String userId,
    required String courseId,
    required String teacherId,
    required double price,
    required String courseTitle,
  });
}

class WalletSupabaseDatasource implements WalletRemoteDatasource {
  final SupabaseClient _client;

  WalletSupabaseDatasource([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  @override
  Future<WalletModel> getWallet(String userId) async {
    double currentBalance = 0.0;

    // 1. استعلام عن رصيد الطالب من جدول students
    try {
      final studentRes = await _client
          .from('students')
          .select('wallet_balance')
          .eq('id', userId)
          .maybeSingle();

      if (studentRes != null && studentRes['wallet_balance'] != null) {
        final rawBal = studentRes['wallet_balance'];
        currentBalance = (rawBal is num)
            ? rawBal.toDouble()
            : (double.tryParse(rawBal.toString()) ?? 0.0);
      }
    } catch (e) {
      debugPrint('[WalletDatasource] Failed to get wallet_balance: $e');
    }

    // 2. استعلام عن حركات الخزنة
    List<WalletTransactionModel> transactions = [];
    try {
      final txRes = await _client
          .from('wallet_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      transactions = (txRes as List)
          .map((item) => WalletTransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      debugPrint('[WalletDatasource] Failed to get wallet_transactions: $e');
    }

    return WalletModel.fromData(
      balance: currentBalance,
      transactions: transactions,
    );
  }

  @override
  Future<WalletModel> rechargeWithCard({
    required String userId,
    required String cardCode,
  }) async {
    final rawTrimmed = cardCode.trim();
    final cleanUpper = rawTrimmed.replaceAll('-', '').replaceAll(' ', '').toUpperCase();
    if (cleanUpper.isEmpty) {
      throw Exception('يرجى إدخال كود الكارت أولاً');
    }

    String? formattedWithDashes;
    if (cleanUpper.length == 10 && cleanUpper.startsWith('TH')) {
      formattedWithDashes = 'TH-${cleanUpper.substring(2, 6)}-${cleanUpper.substring(6)}';
    } else if (cleanUpper.length == 12 && cleanUpper.startsWith('RSLN')) {
      formattedWithDashes = 'RSLN-${cleanUpper.substring(4, 8)}-${cleanUpper.substring(8)}';
    } else if (cleanUpper.length >= 8) {
      formattedWithDashes = '${cleanUpper.substring(0, 4)}-${cleanUpper.substring(4)}';
    }

    final queryFilter = [
      'code.eq.$rawTrimmed',
      'code.eq.$cleanUpper',
      'code.ilike.$rawTrimmed',
      if (formattedWithDashes != null) 'code.eq.$formattedWithDashes',
    ].join(',');

    // 1. محاولة التنفيذ عبر دالة الـ RPC الذرية إذا توفرت
    try {
      final rpcRes = await _client.rpc(
        'recharge_wallet_with_card',
        params: {
          'p_student_id': userId,
          'p_card_code': cleanUpper,
        },
      );

      if (rpcRes is Map) {
        final success = rpcRes['success'] == true;
        if (success) {
          return await getWallet(userId);
        } else {
          final errorMsg = rpcRes['error']?.toString() ?? '';
          if (errorMsg.contains('تم استخدام') || errorMsg.contains('انتهت صلاحية')) {
            throw Exception(errorMsg);
          }
        }
      }
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('تم استخدام') || errStr.contains('انتهت صلاحية')) {
        rethrow;
      }
      debugPrint('[WalletDatasource] RPC not available or failed: $e');
    }

    // 2. البحث في جدول كروت الشحن recharge_cards
    Map<String, dynamic>? targetCard;
    bool isFromActivationCodes = false;

    try {
      final cardRows = await _client
          .from('recharge_cards')
          .select()
          .or(queryFilter);

      if (cardRows.isNotEmpty) {
        targetCard = Map<String, dynamic>.from(cardRows.first);
      }
    } catch (e) {
      debugPrint('[WalletDatasource] Error querying recharge_cards: $e');
    }

    // 3. إذا لم يوجد في recharge_cards، يتم البحث في جدول أكواد التفعيل activation_codes
    if (targetCard == null) {
      try {
        final actRows = await _client
            .from('activation_codes')
            .select('*, courses(id, title, price)')
            .or(queryFilter);

        if (actRows.isNotEmpty) {
          targetCard = Map<String, dynamic>.from(actRows.first);
          isFromActivationCodes = true;
        }
      } catch (e) {
        debugPrint('[WalletDatasource] Error querying activation_codes: $e');
      }
    }

    if (targetCard == null) {
      throw Exception('كود الكارت غير صحيح أو غير مسجل بالنظام');
    }

    if (targetCard['is_used'] == true) {
      throw Exception('تم استخدام هذا الكود مسبقاً');
    }

    final expiresAt = targetCard['expires_at'];
    if (expiresAt != null) {
      final exp = DateTime.tryParse(expiresAt.toString());
      if (exp != null && exp.isBefore(DateTime.now())) {
        throw Exception('انتهت صلاحية هذا الكود');
      }
    }

    final cardId = targetCard['id'].toString();
    final actualCode = targetCard['code']?.toString() ?? rawTrimmed;

    // استخراج قيمة الرصيد
    double cardValue = 100.0;
    if (isFromActivationCodes) {
      final courseMap = targetCard['courses'] as Map<String, dynamic>?;
      if (courseMap != null && courseMap['price'] != null) {
        final pr = (courseMap['price'] as num?)?.toDouble() ?? 0.0;
        if (pr > 0) cardValue = pr;
      }
    } else {
      cardValue = (targetCard['value'] is num)
          ? (targetCard['value'] as num).toDouble()
          : (double.tryParse(targetCard['value']?.toString() ?? '0') ?? 100.0);
    }

    // أ) تحديث الكارت كمستخدم والتحقق من عدم تكرار الشحن
    if (isFromActivationCodes) {
      final updated = await _client.from('activation_codes').update({
        'is_used': true,
        'used_by': userId,
        'used_at': DateTime.now().toIso8601String(),
      }).eq('id', cardId).eq('is_used', false).select('id');

      if (updated.isEmpty) {
        throw Exception('تم استخدام هذا الكود مسبقاً');
      }

      // تفعيل اشتراك الكورس أيضاً إذا كان الكود مرتبطاً بكورس
      final courseId = targetCard['course_id']?.toString();
      final teacherId = targetCard['teacher_id']?.toString() ?? '';
      if (courseId != null && courseId.isNotEmpty) {
        try {
          final existingSub = await _client
              .from('subscriptions')
              .select('id')
              .eq('student_id', userId)
              .eq('course_id', courseId)
              .maybeSingle();

          if (existingSub != null) {
            await _client.from('subscriptions').update({
              'status': 'active',
              'starts_at': DateTime.now().toIso8601String(),
              'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
            }).eq('id', existingSub['id']);
          } else {
            await _client.from('subscriptions').insert({
              'student_id': userId,
              if (teacherId.isNotEmpty) 'teacher_id': teacherId,
              'course_id': courseId,
              'status': 'active',
              'starts_at': DateTime.now().toIso8601String(),
              'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
            });
          }
        } catch (_) {}
      }
    } else {
      final updated = await _client.from('recharge_cards').update({
        'is_used': true,
        'used_by': userId,
        'used_at': DateTime.now().toIso8601String(),
      }).eq('id', cardId).eq('is_used', false).select('id');

      if (updated.isEmpty) {
        throw Exception('تم استخدام هذا الكارت مسبقاً');
      }
    }

    // ب) تحديث رصيد الطالب
    double currentBal = 0.0;
    try {
      final studentRow = await _client
          .from('students')
          .select('wallet_balance')
          .eq('id', userId)
          .maybeSingle();

      if (studentRow != null) {
        final oldBal = (studentRow['wallet_balance'] is num)
            ? (studentRow['wallet_balance'] as num).toDouble()
            : 0.0;
        currentBal = oldBal + cardValue;
        await _client.from('students').update({
          'wallet_balance': currentBal,
        }).eq('id', userId);
      } else {
        currentBal = cardValue;
        await _client.from('students').insert({
          'id': userId,
          'wallet_balance': currentBal,
        });
      }
    } catch (e) {
      debugPrint('[WalletDatasource] Warning while updating student balance: $e');
    }

    // ج) تسجيل حركة إيداع في الخزنة
    try {
      await _client.from('wallet_transactions').insert({
        'user_id': userId,
        'title': 'شحن رصيد بكارت ',
        'subtitle': 'كود: $actualCode',
        'amount': cardValue,
        'type': 'credit',
        'status': 'completed',
        'reference_id': cardId,
      });
    } catch (e) {
      debugPrint('[WalletDatasource] Warning while logging credit transaction: $e');
    }

    return await getWallet(userId);
  }

  @override
  Future<bool> purchaseCourse({
    required String userId,
    required String courseId,
    required String teacherId,
    required double price,
    required String courseTitle,
  }) async {
    // 1. التحقق من الرصيد الحالي
    final wallet = await getWallet(userId);
    if (wallet.currentBalance < price) {
      throw Exception('رصيد الخزنة الحالي (${wallet.currentBalance.toStringAsFixed(2)} ج.م) غير كافٍ لإتمام عملية الشراء (${price.toStringAsFixed(2)} ج.م)');
    }

    final newBalance = wallet.currentBalance - price;

    // 2. خصم المبلغ من رصيد الخزنة
    await _client.from('students').update({
      'wallet_balance': newBalance,
    }).eq('id', userId);

    // 3. تسجيل حركة خصم في الخزنة
    try {
      await _client.from('wallet_transactions').insert({
        'user_id': userId,
        'title': 'شراء كورس من الخزنة',
        'subtitle': courseTitle,
        'amount': price,
        'type': 'debit',
        'status': 'completed',
        'reference_id': courseId,
      });
    } catch (e) {
      debugPrint('[WalletDatasource] Failed to log debit transaction: $e');
    }

    // 4. تفعيل الاشتراك في الكورس للطالب
    try {
      final existingSub = await _client
          .from('subscriptions')
          .select('id')
          .eq('student_id', userId)
          .eq('course_id', courseId)
          .maybeSingle();

      if (existingSub != null) {
        await _client.from('subscriptions').update({
          'status': 'active',
          'starts_at': DateTime.now().toIso8601String(),
          'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        }).eq('id', existingSub['id']);
      } else {
        await _client.from('subscriptions').insert({
          'student_id': userId,
          if (teacherId.isNotEmpty) 'teacher_id': teacherId,
          'course_id': courseId,
          'status': 'active',
          'starts_at': DateTime.now().toIso8601String(),
          'expires_at': DateTime.now().add(const Duration(days: 365)).toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('[WalletDatasource] Failed to save subscription: $e');
    }

    // 5. تسجيل حركة الدفع في جدول payments العام للمنصة
    try {
      await _client.from('payments').insert({
        'payer_id': userId,
        'payer_type': 'student_subscription',
        'course_id': courseId,
        'amount': price,
        'payment_gateway': 'fawry',
        'gateway_transaction_id': 'WALLET-${DateTime.now().millisecondsSinceEpoch}',
        'status': 'success',
      });
    } catch (e) {
      debugPrint('[WalletDatasource] Failed to log payment: $e');
    }

    return true;
  }
}
