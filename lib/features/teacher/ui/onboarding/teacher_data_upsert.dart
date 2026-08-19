import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/core/supabase/storage_helper.dart';

/// Handles uploading teacher documents and upserting profile data to Supabase.
Future<void> upsertTeacherData({
  required XFile? avatar,
  required XFile? idFront,
  required XFile? idBack,
  required XFile? proof,
  XFile? paymentReceipt,
  required String? subjectId,
  required String? stage,
  required String teachingSystem,
  required List<String> stages,
  required List<String> baccalaureateTracks,
  required String? governorate,
  required String teachingMode,
  String? selectedPlan,
  String? paymentMethod,
  double? subscriptionAmount,
  String? bio,
}) async {
  try {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final urls = await StorageHelper.uploadTeacherDocuments(
      userId: uid,
      files: {
        'avatar': avatar,
        'id_front': idFront,
        'id_back': idBack,
        'proof': proof,
        'receipt': paymentReceipt,
      },
    );

    final payload = <String, dynamic>{
      'id': uid,
      'subject_id': subjectId,
      'stage': stage,
      'teaching_system': teachingSystem,
      'stages': stages,
      'baccalaureate_tracks': baccalaureateTracks,
      'governorate': governorate,
      'teaching_mode': teachingMode,
      'bio': bio?.isNotEmpty == true ? bio : null,
      'approval_status': 'pending',
      'avatar_url': urls['avatar'],
      'id_card_front_url': urls['id_front'],
      'id_card_back_url': urls['id_back'],
      'teacher_proof_url': urls['proof'],
      'payment_receipt_url': urls['receipt'],
      'selected_plan': selectedPlan,
      'payment_method': paymentMethod ?? 'instapay',
      'subscription_amount': subscriptionAmount,
    };

    try {
      await Supabase.instance.client.from('teachers').upsert(payload, onConflict: 'id');
    } catch (upsertErr) {
      debugPrint('[TeacherForm] initial upsert with extra fields failed: $upsertErr, attempting standard payload');
      // Fallback in case newly added schema columns are not yet applied in remote db
      payload.remove('payment_receipt_url');
      payload.remove('selected_plan');
      payload.remove('payment_method');
      payload.remove('subscription_amount');
      await Supabase.instance.client.from('teachers').upsert(payload, onConflict: 'id');
    }

    if (urls['avatar'] != null) {
      await Supabase.instance.client.from('users').update({'avatar_url': urls['avatar']}).eq('id', uid);
    }
  } catch (e) {
    debugPrint('[TeacherForm] upsert failed: $e');
  }
}
