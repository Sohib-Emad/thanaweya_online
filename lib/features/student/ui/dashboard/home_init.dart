import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:thanaweya_online/features/student/logic/student_courses_cubit.dart';

/// Loads initial student home data and ensures profiles exist in the database.
Future<void> loadStudentHomeData({
  required StudentCoursesCubit cubit,
  required ValueChanged<String> onNameLoaded,
  required bool Function() isMounted,
}) async {
  var user = Supabase.instance.client.auth.currentUser;
  var userId = user?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
  if (userId == null) {
    for (int i = 0; i < 5; i++) {
      await Future.delayed(Duration(milliseconds: 150 * (i + 1)));
      if (!isMounted()) return;
      user = Supabase.instance.client.auth.currentUser;
      userId = user?.id ?? Supabase.instance.client.auth.currentSession?.user.id;
      if (userId != null) break;
    }
  }
  if (!isMounted()) return;
  if (user != null) {
    onNameLoaded(user.userMetadata?['full_name']?.toString().split(' ').first ?? 'طالب');
  }
  if (userId != null) {
    final isValid = await _verifyProfile(userId);
    if (!isValid) return;
    if (isMounted()) {
      cubit.loadSubscribedTeachers(userId);
      cubit.loadMyCourses(userId);
    }
  }
  if (isMounted()) {
    cubit.loadPopularCourses();
    cubit.loadApprovedTeachers();
    cubit.loadSubjects();
  }
}

Future<bool> _verifyProfile(String uid) async {
  try {
    final c = Supabase.instance.client;
    final userRow =
        await c.from('users').select('id').eq('id', uid).maybeSingle();
    if (userRow == null) {
      debugPrint('[StudentHome] Account deleted in database. Signing out...');
      await c.auth.signOut();
      return false;
    }
    return true;
  } catch (e) {
    debugPrint('[StudentHome] Profile check error: $e');
    return true;
  }
}
